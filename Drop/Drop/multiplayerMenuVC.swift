//
//  multiplayerMenuVC.swift
//  Drop
//
//  Created by Kristoffer Thorset on 13.03.2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation
import UIKit
class multiplayerMenuVC: UIViewController{
    let colorService = ColorServiceManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorService.delegate = self
    }
    
    @IBOutlet weak var connectionsLabel: UILabel!
    
    @IBAction func back(_ sender: UIButton) {
        backToMenu()
    }
    
    @IBAction func redTapped() {
        self.change(color: .red)
        colorService.send(colorName: "red")
    }
    
    @IBAction func yellowTapped() {
        self.change(color: .yellow)
        colorService.send(colorName: "yellow")
    }
    
    func backToMenu(){
        let menuVC = self.storyboard?.instantiateViewController(withIdentifier: "menuVC") as! menuVC
        self.navigationController?.pushViewController(menuVC, animated: true)
    }
    
    func change(color: UIColor) {
        UIView.animate(withDuration: 0.2) {
            self.view.backgroundColor = color
        }
    }
}

extension multiplayerMenuVC : ColorServiceManagerDelegate {
    func connectedDevicesChanged(manager: ColorServiceManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            self.connectionsLabel.text = "Connections: \(connectedDevices)"
        }
    }
    
    func colorChanged(manager: ColorServiceManager, colorString: String) {
        OperationQueue.main.addOperation {
            switch colorString {
            case "red":
                self.change(color: .red)
            case "yellow":
                self.change(color: .yellow)
            default:
                NSLog("%@", "Unknown color value received: \(colorString)")
            }
        }
    }
}

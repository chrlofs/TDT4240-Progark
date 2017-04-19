//
//  singleplayerMenuVC.swift
//  Drop
//
//  Created by Kristoffer Thorset on 13.03.2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation
import UIKit
class singleplayerMenuVC: UIViewController{
    override func viewDidLoad() {
       
    }
    
    @IBAction func back(_ sender: UIButton) {
        backToMenu()
    }
    
    @IBAction func startGame(_ sender: Any) {
        startgame()
    }
    
    func backToMenu(){
        let menuVC = self.storyboard?.instantiateViewController(withIdentifier: "menuVC") as! menuVC
        self.navigationController?.pushViewController(menuVC, animated: true)
    }
    func startgame(){
        let GameViewController = self.storyboard?.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        self.navigationController?.pushViewController(GameViewController, animated: true)
        
    }
}

//
//  menuVC.swift
//  Drop
//
//  Created by Kristoffer Thorset on 13.03.2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation
import UIKit
class menuVC: UIViewController{
    let fxPlayer = soundManager.sharedInstance
    override func viewDidLoad() {
        super.viewDidLoad()
        fxPlayer.playFx(fileName: "GameMusic", fileType: "mp3")
       
    }

    @IBAction func pushToOptions(_ sender: UIButton) {
        moveToOptions()
    }
    @IBAction func pushToSingleplayer(_ sender: UIButton) {
        moveToSingleplayer()
    }
    
    @IBAction func pushToMultiplayer(_ sender: UIButton) {
        moveToMultiplayer()
    }
    
    func moveToSingleplayer() {
        let singleplayerMenuVC = self.storyboard?.instantiateViewController(withIdentifier: "singleplayerMenuVC") as! singleplayerMenuVC
        self.navigationController?.pushViewController(singleplayerMenuVC, animated: true)
    }
    
    func moveToOptions() {
        let optionsVC = self.storyboard?.instantiateViewController(withIdentifier: "optionsVC") as! optionsVC
        self.navigationController?.pushViewController(optionsVC, animated: true)
    }
    
    func moveToMultiplayer() {
        let multiplayerMenuVC = self.storyboard?.instantiateViewController(withIdentifier: "multiplayerMenuVC") as! multiplayerMenuVC
        self.navigationController?.pushViewController(multiplayerMenuVC, animated: true)
    }
}

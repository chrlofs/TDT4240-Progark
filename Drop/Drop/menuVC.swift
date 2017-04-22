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
    let musicPlayer = soundManager.sharedInstance
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        musicPlayer.playMusic(fileName: "GameMusic", fileType: "mp3")
       
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
    @IBAction func pushToSelectSkin(_ sender: UIButton) {
        moveToSelectSkin()
    }
    
    @IBAction func pushToSelectMap(_ sender: UIButton) {
        moveToSelectMap()
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
    func moveToSelectSkin() {
        let selectSkinVC = self.storyboard?.instantiateViewController(withIdentifier: "selectSkinVC") as! selectSkinVC
        self.navigationController?.pushViewController(selectSkinVC, animated: true)
    }
    func moveToSelectMap() {
        let selectMapVC = self.storyboard?.instantiateViewController(withIdentifier: "selectMapVC") as! selectMapVC
        self.navigationController?.pushViewController(selectMapVC, animated: true)
    }
}

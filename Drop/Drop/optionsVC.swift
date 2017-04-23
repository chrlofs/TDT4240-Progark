//
//  optionsVC.swift
//  Drop
//
//  Created by Kristoffer Thorset on 14.03.2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation
import UIKit
class optionsVC: UIViewController{
    let audioManager = SoundManager.getInstance()
    @IBOutlet weak var fxButton: UIButton!
    @IBOutlet weak var musicButton: UIButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    
    let gameSettings = GameSettings.getInstance()
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = true
        let fxMuted = audioManager.fxMuted
        let musicMuted = audioManager.musicMuted
        
        if fxMuted {
            fxButton.alpha = 0.7
        }
        if musicMuted {
            musicButton.alpha = 0.7
        }
        usernameLabel.text = gameSettings.getUserName()
        
    }
    
    
    @IBAction func back(_ sender: UIButton) {
        backToMenu()
    }
    
    @IBAction func toggleFx(_ sender: UIButton) {
        let state = audioManager.fxMuted
        if state{
            audioManager.unmuteFX()
            fxButton.alpha = 1
        }
        else{
            audioManager.muteFX()
            fxButton.alpha = 0.7
        }
        
    }
 
    @IBAction func toggleMusic(_ sender: UIButton) {
        let state = audioManager.musicMuted
        if state{
            audioManager.unmuteMusic()
            musicButton.alpha = 1
        }
        else{
            audioManager.muteMusic()
            musicButton.alpha = 0.7
        }
    }
    @IBAction func changeUsername(_ sender: UIButton) {
        if usernameField.text != "" {
            gameSettings.setUserName(userName: usernameField.text!)
            usernameLabel.text = gameSettings.getUserName()
            usernameField.text = ""
        }
    }

    func backToMenu(){
        _ = navigationController?.popViewController(animated: true)
    }
    
}

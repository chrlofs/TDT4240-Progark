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
    let audioManager = soundManager.sharedInstance
    
    override func viewDidLoad() {
    self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func back(_ sender: UIButton) {
        backToMenu()
    }
    
    @IBAction func toggleFx(_ sender: UIButton) {
        let state = audioManager.fxMuted
        if state{
            audioManager.unmuteFX()
        }
        else{
            audioManager.muteFX()
        }
        
    }
 
    @IBAction func toggleMusic(_ sender: UIButton) {
        let state = audioManager.musicMuted
        if state{
            audioManager.unmuteMusic()
        }
        else{
            audioManager.muteMusic()
        }
    }

    func backToMenu(){
        _ = navigationController?.popViewController(animated: true)
    }
    
}

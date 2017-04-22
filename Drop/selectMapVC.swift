//
//  mapsVC.swift
//  Drop
//
//  Created by Kristoffer Thorset on 22.04.2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation
import UIKit
class selectMapVC: UIViewController{
    let gameSettings = GameSettings.getInstance()
    let gameConstants = GameConstants.getInstance()
    
    
    @IBOutlet weak var textField: UITextField!
    
    
    
    @IBAction func Back(_ sender: UIButton) {
        backToMenu()
    }
    
    @IBAction func mapLeft(_ sender: UIButton) {
        let maps = gameConstants.getMapList()
        
        var newMapIndex = (gameSettings.getUserMapID() - 1) % maps.count
        if (newMapIndex < 0) {
            newMapIndex = newMapIndex + maps.count
        }
        textField.text = String(gameConstants.getMapById(id: newMapIndex).id)
        gameSettings.setUserMapID(userMapID: newMapIndex)
        
        
    }
    
    @IBAction func mapRight(_ sender: UIButton) {
        let maps = gameConstants.getMapList()
        let newMapIndex = (gameSettings.getUserMapID() + 1) % maps.count
        textField.text = String(gameConstants.getMapById(id: newMapIndex).id)
        gameSettings.setUserMapID(userMapID: newMapIndex)
        
        
    }
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = true
        textField.text = String(gameConstants.getMapById(id: gameSettings.getUserMapID()).id)
        
    }
    func backToMenu(){
        _ = navigationController?.popViewController(animated: true)
    }
    
}

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
    let gameSettings = GameSettings.getInstance()
    let gameConstants = GameConstants.getInstance()
    
    var userName = "No username"
    var userSkin = 0
    var userSkinImage = UIImage(named: "skin1")

    
    @IBOutlet weak var playerSelfSkin: UIImageView!
    @IBOutlet weak var playerSelfLabel: UILabel!
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = true
        
        userName = gameSettings.getUserName()
        userSkin = gameSettings.getUserSkin()
        
        let skins = gameConstants.getSkinList()
        
        if skins.count > userSkin {
            userSkinImage = UIImage(named: skins[userSkin])
        }
        
        OperationQueue.main.addOperation {
            self.playerSelfSkin.image = self.userSkinImage
            self.playerSelfLabel.text = self.userName

        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        backToMenu()
    }
    
    @IBAction func startGame(_ sender: Any) {
        startgame()
    }
    
    func backToMenu(){
        print("back from singleplayer")
        _ = navigationController?.popViewController(animated: true)
    }
    func startgame(){
        let GameViewController = self.storyboard?.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        self.navigationController?.pushViewController(GameViewController, animated: true)
        
    }
}

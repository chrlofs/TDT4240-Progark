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
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var skinImage: UIImageView!
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = true
        let skins = defaults.stringArray(forKey: "skinList") ?? [String]()
        let currentSkinIndex = defaults.integer(forKey: "userSkin")
        
        skinImage.image = UIImage(named: skins[currentSkinIndex])
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

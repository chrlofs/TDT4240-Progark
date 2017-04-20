//
//  selectSkinVC.swift
//  Drop
//
//  Created by Håvard Fagervoll on 19/04/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation
import UIKit
class selectSkinVC: UIViewController{
    let defaults = UserDefaults.standard
    

    @IBOutlet weak var skinImage: UIImageView!
    
    @IBAction func back(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func skinLeft(_ sender: Any) {
        let skins = defaults.stringArray(forKey: "skinList") ?? [String]()
        let currentSkinIndex = defaults.integer(forKey: "userSkin")
        var newSkinIndex = (currentSkinIndex - 1) % skins.count
        if (newSkinIndex < 0) {
            newSkinIndex = newSkinIndex + skins.count
        }
        
        skinImage.image = UIImage(named: skins[newSkinIndex])
        defaults.set(newSkinIndex, forKey: "userSkin")
        
    }
    @IBAction func skinRight(_ sender: Any) {
        let skins = defaults.stringArray(forKey: "skinList") ?? [String]()
        let currentSkinIndex = defaults.integer(forKey: "userSkin")
        let newSkinIndex = (currentSkinIndex + 1) % skins.count
        
        skinImage.image = UIImage(named: skins[newSkinIndex])
        defaults.set(newSkinIndex, forKey: "userSkin")
        
        
    }
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = true
        let skins = defaults.stringArray(forKey: "skinList") ?? [String]()
        let currentSkinIndex = defaults.integer(forKey: "userSkin")
        
        skinImage.image = UIImage(named: skins[currentSkinIndex])

    }
    
}

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
    
    @IBAction func skinLeft(_ sender: Any) {
        let skins = defaults.stringArray(forKey: "skinList") ?? [String]()
        let currentSkinIndex = defaults.integer(forKey: "skin")
        var newSkinIndex = (currentSkinIndex - 1) % skins.count
        if (newSkinIndex < 0) {
            newSkinIndex = newSkinIndex + skins.count
        }
        
        skinImage.image = UIImage(named: skins[newSkinIndex])
        defaults.set(newSkinIndex, forKey: "skin")
        
    }
    @IBAction func skinRight(_ sender: Any) {
        let skins = defaults.stringArray(forKey: "skinList") ?? [String]()
        let currentSkinIndex = defaults.integer(forKey: "skin")
        let newSkinIndex = (currentSkinIndex + 1) % skins.count
        
        skinImage.image = UIImage(named: skins[newSkinIndex])
        defaults.set(newSkinIndex, forKey: "skin")
        
        
    }
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = true

        let skins = defaults.stringArray(forKey: "skinList") ?? [String]()
        let currentSkinIndex = defaults.integer(forKey: "skin")
        print(skins)
        print(currentSkinIndex)
        skinImage.image = UIImage(named: skins[currentSkinIndex])

    }
}

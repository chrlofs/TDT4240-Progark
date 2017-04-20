//
//  gameOverVC.swift
//  Drop
//
//  Created by Christoffer Lofsberg on 20.04.2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation
import UIKit

class gameOverVC: UIViewController {
    let defaults = UserDefaults.standard;
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var highscoreLabel: UILabel!
    
    @IBAction func gotoMain(_ sender: UIButton) {
        gotoMain();
    }
    
    func gotoMain() {
        let menuVC = self.storyboard?.instantiateViewController(withIdentifier: "menuVC") as! menuVC
        self.navigationController?.pushViewController(menuVC, animated: true)
    }
    
    func setScore() {
        scoreLabel = score;
        highscoreLabel = defaults.integer(forKey: "bestScore");
    }
    
}

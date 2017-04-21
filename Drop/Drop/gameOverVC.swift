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
    var userScore = Int()
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var highscoreLabel: UILabel!
    
    @IBAction func gotoMain(_ sender: UIButton) {
        gotoMain();
    }
    
    func gotoMain() {
        
        let controllers = self.navigationController?.viewControllers
        for vc in controllers! {
            if vc is singleplayerMenuVC {
                _ = self.navigationController?.popToViewController(vc as! singleplayerMenuVC, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = true

        OperationQueue.main.addOperation {
            self.setScore()
        }
    }
    
    func setScore() {
        self.scoreLabel.text = String(self.userScore)
        //highscoreLabel = defaults.integer(forKey: "bestScore");
    }
    
}

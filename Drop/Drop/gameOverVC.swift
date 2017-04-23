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
    let musicPlayer = soundManager.sharedInstance
    let gameSettings = GameSettings.getInstance()
    var userScore = Int()
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var highscoreLabel: UILabel!
    @IBOutlet weak var highScoreTextLabel: UILabel!
    
    @IBAction func gotoMain(_ sender: UIButton) {
        gotoMain();
    }
    
    func gotoMain() {
        let controllers = self.navigationController?.viewControllers
        for vc in controllers! {
            if vc is singleplayerMenuVC {
                musicPlayer.stopMusic()
                musicPlayer.playMusic(fileName: "GameMusic", fileType: "mp3")
                _ = self.navigationController?.popToViewController(vc as! singleplayerMenuVC, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true

        OperationQueue.main.addOperation {
            self.setScore()
        }
    }
    
    func setScore() {
        let isHighScore = gameSettings.isHighScore(score: self.userScore)
        if isHighScore {
            self.highScoreTextLabel.text = "New Highscore!"
        }
        
        self.scoreLabel.text = String(self.userScore)
        self.highscoreLabel.text = String(gameSettings.getHighScore())
    }
    
}

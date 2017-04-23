//
//  GameViewController.swift
//  Drop
//
//  Created by Hung Quang Thieu on 09/03/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

protocol GameManager {
    func gameOver(score: Int)
}

class GameViewController: UIViewController, GameManager {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = GameplaySceneClass(fileNamed: "GameplayScene") {
                scene.gameManager = self
                
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = true
            view.showsPhysics = false;
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    func gameOver(score: Int) {
        // Tears down the SKView
        if let view = self.view as! SKView? {
            if let scene = view.scene {
                scene.isPaused = true
            }
            view.presentScene(nil)
        }
        
        print("game over")
        
        let gameOverVC = self.storyboard?.instantiateViewController(withIdentifier: "gameOverVC") as! gameOverVC
        gameOverVC.userScore = score // Passes the score to the gameOverVC
        self.navigationController?.pushViewController(gameOverVC, animated: true)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

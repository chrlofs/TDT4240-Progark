//
//  MultiplayerGameViewController.swift
//  Drop
//
//  Created by Raymi Toro Eldby on 20/04/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

protocol MultiplayerGameManager {
    func gameOver(winner: PlayerPeer?, losers: [PlayerPeer])
}

class MultiplayerGameVC: UIViewController, MultiplayerGameManager {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = MultiplayerGameScene(fileNamed: "MultiplayerGameScene") {
                scene.gameManager = self
                
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    func gameOver(winner: PlayerPeer?, losers: [PlayerPeer]) {
        if let view = self.view as! SKView? {
            view.presentScene(nil)
        }
        
        let gameOverController = self.storyboard?.instantiateViewController(withIdentifier: "MultiplayerGameOverVC") as! MultiplayerGameOverVC
        gameOverController.initialize(winner: winner, losers: losers)
        self.navigationController?.pushViewController(gameOverController, animated: true)
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

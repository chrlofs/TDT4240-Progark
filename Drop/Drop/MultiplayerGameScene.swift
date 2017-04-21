//
//  MultiplayerGameScene.swift
//  Drop
//
//  Created by Raymi Toro Eldby on 20/04/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import SpriteKit

class MultiplayerGameScene: SKScene, SKPhysicsContactDelegate {
    
    let defaults = UserDefaults.standard
    
    let opponents = [Player]()
    let selfPlayer = Player(skinImageName: "putin")
    
    override func didMove(to view: SKView) {
        initializeGame()
    }
    
    func initializeGame() {
        let opponent1 = Player(skinImageName: "kim")
        opponent1.position = CGPoint(x: -200, y: -50)
        opponent1.setScale(0.1)
        opponent1.zPosition = 1
        
        selfPlayer.position = CGPoint(x: 200, y: -50)
        selfPlayer.setScale(0.1)
        selfPlayer.zPosition = 1
        
        addChild(opponent1)
        addChild(selfPlayer)
    }
}

//
//  Player.swift
//  Drop
//
//  Created by Hung Quang Thieu on 13/03/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import SpriteKit

class Player: SKSpriteNode {
    
    let defaults = UserDefaults.standard
    private var minX = CGFloat(-190), maxX = CGFloat(190);
    
    // Initializing a Player object
    func InitializePlayer() {
        name = "Player";
        
        let skin = defaults.integer(forKey: "userSkin")
        let skins = defaults.stringArray(forKey: "skinList") ?? [String]()
        
        if skins.count > skin {
            print("Changing skin??")
            self.texture = SKTexture(imageNamed: skins[skin])
        } else {
            print("Not changing the skin :(")
        }
        
        
        physicsBody = SKPhysicsBody(circleOfRadius: size.height / 2);
        physicsBody?.affectedByGravity = false;
        physicsBody?.isDynamic = false;
        physicsBody?.categoryBitMask = ColliderType.PLAYER;
        physicsBody?.contactTestBitMask = ColliderType.FRUIT_AND_BOMB;
    }
    
    // Moving: Changing Player's x position
    func move(left: Bool){
        if left{
            position.x -= 15;
            
            if position.x < minX{
                position.x = minX;
            }
        }
        else{
            position.x += 15;
            
            if position.x > maxX{
                position.x = maxX;
            }
        }
    }
    
}

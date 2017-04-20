//
//  Player.swift
//  Drop
//
//  Created by Hung Quang Thieu on 13/03/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import SpriteKit

class Player: SKSpriteNode {
    private var minX = CGFloat(-190), maxX = CGFloat(190);
    
    init(skinImageName: String) {
        let texture = SKTexture(imageNamed: skinImageName)
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Initializing a Player object
    func InitializePlayer() {
        name = "Player";
        
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
    
    func setSkin(skinImageName: String) {
        self.texture = SKTexture(imageNamed: skinImageName)
    }
    
}

//
//  ItemController.swift
//  Drop
//
//  Created by Hung Quang Thieu on 16/03/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import SpriteKit

struct ColliderType {
    static let PLAYER: UInt32 = 0;
    static let FRUIT_AND_BOMB: UInt32 = 1;
    static let OBSTACLE: UInt32 = 2;
}

class ItemController {
    
    // Sets the x values where the sprites can spawn between.
    private var minX = CGFloat(-190), maxX = CGFloat(190);
    
    func spawnItems() -> SKSpriteNode {
        
        let item: SKSpriteNode?;

        item = SKSpriteNode(imageNamed: "Bomb");
        item!.name = "Bomb";
        item!.setScale(0.6);
        item!.physicsBody = SKPhysicsBody(circleOfRadius: item!.size.height / 2);
            
        
        
        // Sets the collision bitmask to FRUIT_AND_BOMB (1)
        item!.physicsBody?.categoryBitMask = ColliderType.FRUIT_AND_BOMB;
        item!.physicsBody?.restitution = 1;
        item!.physicsBody?.mass = 1;
        item!.physicsBody?.collisionBitMask = ColliderType.OBSTACLE;
        
        item!.zPosition = 3;
        item!.anchorPoint = CGPoint(x: 0.5, y: 0.5);
        
        // Spawn the item at a random x value inside the screen
        item!.position.x = randomBetweenNumbers(firstNum: minX, secondNum: maxX);
        item!.position.y = 500; 
        
        return item!;
    }
    
    // Returns random numbers between to parameters.
    func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum);
    }
    
}

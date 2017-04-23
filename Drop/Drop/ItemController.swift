//
//  ItemController.swift
//  Drop
//
//  Created by Hung Quang Thieu on 16/03/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import SpriteKit
import GameKit

struct ColliderType {
    static let PLAYER: UInt32 = 0;
    static let FRUIT_AND_BOMB: UInt32 = 1;
    static let ACTIVE_OBSTACLE: UInt32 = 2;
    static let INACTIVE_OBSTACLE: UInt32 = 4;
    static let WALL: UInt32 = 8
}

class ItemController {
    
    // Sets the x values where the sprites can spawn between.
    private var minX = CGFloat(-190), maxX = CGFloat(190);
    private var positionDistribution = GKRandomDistribution(randomSource: GKLinearCongruentialRandomSource(seed: 123456), lowestValue: -190, highestValue: 190)
    
    func spawnItems() -> SKSpriteNode {
        
        let item = SKSpriteNode(imageNamed: "Bomb");
        item.name = "Bomb";
        item.setScale(0.6);
        item.physicsBody = SKPhysicsBody(circleOfRadius: item.size.height / 2);
            
        
        
        // Sets the collision bitmask to FRUIT_AND_BOMB (1)
        item.physicsBody?.categoryBitMask = ColliderType.FRUIT_AND_BOMB;
        item.physicsBody?.restitution = 1;
        item.physicsBody?.mass = 1;
        item.physicsBody?.collisionBitMask = ColliderType.ACTIVE_OBSTACLE | ColliderType.FRUIT_AND_BOMB
        
        item.zPosition = 3;
        item.anchorPoint = CGPoint(x: 0.5, y: 0.5);
        
        // Spawn the item at a random x value inside the screen
        item.position.x = CGFloat(positionDistribution.nextInt())
        item.position.y = 500;
        
        return item;
    }
    
    func spawnItemAt(position: CGPoint) -> SKSpriteNode {
        let item = SKSpriteNode(imageNamed: "Bomb")

        item.setScale(0.6)
        item.physicsBody = getNewPhysicsBody(for: item)
        item.zPosition = 3
        item.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        item.position = position
        
        return item
    }
    
    private func getNewPhysicsBody(for item: SKSpriteNode) -> SKPhysicsBody {
        let physicsBody = SKPhysicsBody(circleOfRadius: item.size.height / 2)
        physicsBody.categoryBitMask = ColliderType.FRUIT_AND_BOMB
        physicsBody.collisionBitMask = ColliderType.ACTIVE_OBSTACLE | ColliderType.FRUIT_AND_BOMB
        physicsBody.restitution = 1
        physicsBody.mass = 1
        return physicsBody
    }
    
    // Returns random numbers between to parameters.
    func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum);
    }
    
}

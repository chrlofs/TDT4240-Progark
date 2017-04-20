//
//  ObstacleController.swift
//  Drop
//
//  Created by Håvard Fagervoll on 20/04/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import SpriteKit

class ObstacleController{
        
    // Initializing a Obstacle object
    func createObstacle(x: Int, y: Int) -> SKSpriteNode {
        let obstacle: SKSpriteNode?;
        obstacle = SKSpriteNode(imageNamed: "pin");
        obstacle!.setScale(0.5);
        obstacle!.name = "Obstacle";
        
        obstacle!.physicsBody = SKPhysicsBody(circleOfRadius: obstacle!.size.height / 2);
        obstacle!.physicsBody?.isDynamic = true;
        obstacle!.physicsBody?.allowsRotation = false;
        obstacle!.physicsBody?.pinned = true;
        obstacle!.physicsBody?.affectedByGravity = false;
        obstacle!.physicsBody?.friction = 0.2;
        obstacle!.physicsBody?.restitution = 0.2;
        obstacle!.physicsBody?.linearDamping = 0.2;
        obstacle!.physicsBody?.angularDamping = 0.2;
        obstacle!.physicsBody?.mass = 0.1;
        obstacle!.physicsBody?.categoryBitMask = 2;
        obstacle!.physicsBody?.collisionBitMask = 1;
        obstacle!.physicsBody?.fieldBitMask = 4294967295
        
        obstacle!.zPosition = 3;
        obstacle!.anchorPoint = CGPoint(x: 0.5, y: 0.5);
        
        // Spawn the item at a random x value inside the screen
        obstacle!.position.x = CGFloat(x);
        obstacle!.position.y = CGFloat(y);

        return obstacle!;
    }
    /*
    func createAllObstacles(GameplaySceneClass: gameplaySceneClass) {
        let positions = [[-144, 200], [0, 200], [144, 200]];
        
        for position in positions {
            let obstacle = createObstacle(x: position[0], y: position[1]);
            gameplaySceneClass.scene?.addChild(obstacle);
        }
    
    }*/
    
}

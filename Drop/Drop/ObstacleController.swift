//
//  ObstacleController.swift
//  Drop
//
//  Created by Håvard Fagervoll on 20/04/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import SpriteKit

class ObstacleController{
    var numberOfObstacles = 0;
    var obstacleDict = [Int: SKSpriteNode]();
    var obstacleStatusDict = [Int: Bool]();
    var activeObstacleSet = Set<Int>();
    var inactiveObstacleSet = Set<Int>();
    var pegName = ""
    var pegInactiveName = ""
        
    // Initializing a Obstacle object
    func createObstacle(x: Int, y: Int, map: Map) -> SKSpriteNode {
        pegName = map.pegName
        pegInactiveName = map.pegInactiveName
        
        let obstacle: SKSpriteNode;
        obstacle = SKSpriteNode(imageNamed: pegName);
        obstacle.setScale(0.4);
        obstacle.name = "Obstacle\(self.numberOfObstacles)";
        
        
        
        obstacle.physicsBody = SKPhysicsBody(circleOfRadius: obstacle.size.height / 2);
        obstacle.physicsBody?.isDynamic = true;
        obstacle.physicsBody?.allowsRotation = false;
        obstacle.physicsBody?.pinned = true;
        obstacle.physicsBody?.affectedByGravity = false;
        obstacle.physicsBody?.friction = 0.2;
        obstacle.physicsBody?.restitution = 0.2;
        obstacle.physicsBody?.linearDamping = 0.2;
        obstacle.physicsBody?.angularDamping = 0.2;
        obstacle.physicsBody?.mass = 0.1;
        obstacle.physicsBody?.categoryBitMask = ColliderType.ACTIVE_OBSTACLE;
        obstacle.physicsBody?.collisionBitMask = ColliderType.FRUIT_AND_BOMB;
        obstacle.physicsBody?.contactTestBitMask = ColliderType.FRUIT_AND_BOMB;
        obstacle.physicsBody?.fieldBitMask = 4294967295
        
        obstacle.zPosition = 3;
        obstacle.anchorPoint = CGPoint(x: 0.5, y: 0.5);
        
        // Spawn the item at a random x value inside the screen
        obstacle.position.x = CGFloat(x);
        obstacle.position.y = CGFloat(y);
        
        self.obstacleDict[self.numberOfObstacles] = obstacle;
        self.obstacleStatusDict[self.numberOfObstacles] = true;
        //self.activeObstacleSet.insert(self.numberOfObstacles);
        self.numberOfObstacles += 1;

        return obstacle;
    }
    
    func getObstacleStatus() -> [Int: Bool]{
        return self.obstacleStatusDict;
    }
    
    func isActive(obstacleId: Int) -> Bool {
        if self.obstacleStatusDict[obstacleId]! {
            return true;
        }
        return false
    }
    
    func deactivateObstacle(obstacleId: Int) {
        let obstacle = self.obstacleDict[obstacleId];
        obstacle!.texture = SKTexture(imageNamed: pegInactiveName);
        obstacle!.physicsBody?.categoryBitMask = ColliderType.INACTIVE_OBSTACLE;
        obstacle!.physicsBody?.contactTestBitMask = 0;
        obstacle!.zPosition = 1;
        
        self.obstacleStatusDict[obstacleId] = false;
    }
    
    func activateObstacle(obstacleId: Int) {
        let obstacle = self.obstacleDict[obstacleId];
        obstacle!.texture = SKTexture(imageNamed: pegName);
        obstacle!.physicsBody?.categoryBitMask = ColliderType.ACTIVE_OBSTACLE;
        obstacle!.physicsBody?.contactTestBitMask = ColliderType.FRUIT_AND_BOMB;
        obstacle!.zPosition = 3;
        
        self.obstacleStatusDict[obstacleId] = true;
    }
    
    func animateObstacle(obstacleId: Int) {
        if isActive(obstacleId: obstacleId) {
            deactivateObstacle(obstacleId: obstacleId)
        } else {
            activateObstacle(obstacleId: obstacleId)
        }
        
    }
    
    
}

//
//  GameplaySceneClass.swift
//  Drop
//
//  Created by Hung Quang Thieu on 13/03/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import SpriteKit

class GameplaySceneClass: SKScene, SKPhysicsContactDelegate{
    
    private var player: Player?;
    
    private var center = CGFloat();
    
    private var canMove = false, moveLeft = false;
    
    private var itemController = ItemController();
    
    private var scoreLabel: SKLabelNode?;
    
    private var score = 0;
    
    private var storedTouches = [UITouch: String]();

    private var obstacleController = ObstacleController();
    
    
    override func didMove(to view: SKView) {
        initializeGame();     }
    
    override func update(_ currentTime: TimeInterval) {
        managePlayer();
        score += 1;
        scoreLabel?.text = String(score);
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let location = touch.location(in: self);
            
            if location.x > center{
                moveLeft = false;
                storedTouches[touch] = "right";
            }
            else{
                moveLeft = true;
                storedTouches[touch] = "left";
            }
        }
        
        canMove = true;
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches{
            storedTouches[touch] = nil;
        }
        
        if storedTouches.isEmpty{
            canMove = false;
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody();
        var secondBody = SKPhysicsBody();
        
        if contact.bodyA.node?.name == "Player" {
            firstBody = contact.bodyA;
            secondBody = contact.bodyB;
        }
        else{
            firstBody = contact.bodyB;
            secondBody = contact.bodyA;
        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Fruit" {
            secondBody.node?.removeFromParent();
        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Bomb" {
            firstBody.node?.removeFromParent();
            secondBody.node?.removeFromParent();
            
            // ScheduledTimer to restart game after x seconds.
            Timer.scheduledTimer(timeInterval: TimeInterval(2), target: self, selector: #selector(GameplaySceneClass.restartGame), userInfo: nil, repeats: false);
        }
        
    }
    
    private func initializeGame(){
        
        physicsWorld.contactDelegate = self;
        
        player = childNode(withName: "Player") as? Player!;
        player?.InitializePlayer();
        
        scoreLabel = childNode(withName: "ScoreLabel") as? SKLabelNode!;
        scoreLabel?.text = "0";
        

        createObstacles()
        
        center = self.frame.size.width / self.frame.size.height;
        
        Timer.scheduledTimer(timeInterval: TimeInterval(itemController.randomBetweenNumbers(firstNum: 1, secondNum: 2)), target: self, selector: #selector(GameplaySceneClass.spawnItems), userInfo: nil, repeats: true);
        
        // Check every 7 seconds if there are items "out of bounds" and remove them.
        Timer.scheduledTimer(timeInterval: TimeInterval(7), target: self, selector: #selector(GameplaySceneClass.removeItems), userInfo: nil, repeats: true);
        
        
    }
    
    func createObstacles(){
        
        // obstacleController.createAllObstacles(self);
        let positions = [
            [-144, 200], [0, 200], [144, 200],
            [-72, 90], [72, 90],
            [-144, -20], [0, -20], [144, -20],
            [-144, -200], [144, -200]
        ];
        for position in positions {
            self.scene?.addChild(obstacleController.createObstacle(x: position[0], y: position[1]));
        }
      
    }
    
    private func managePlayer(){
        if canMove{
            player?.move(left: moveLeft);
        }
    }
    
    //Adding a child (falling objects) to the scene
    func spawnItems(){
        self.scene?.addChild(itemController.spawnItems());
        
    }
    
    func restartGame(){
        if let scene = GameplaySceneClass(fileNamed: "GameplayScene"){
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.doorsOpenHorizontal(withDuration: TimeInterval(2)));
        }
    }
    
    func removeItems(){
        for child in children{
            if child.name == "Fruit" || child.name == "Bomb" {
                if child.position.y < -self.scene!.frame.height - 100 {
                    child.removeFromParent();
                }
            }
        }
    }
    
}

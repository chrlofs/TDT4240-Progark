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
    let audioPlayer = soundManager.sharedInstance
    
    let gameConstants = GameConstants.getInstance()
    
    
    override func didMove(to view: SKView) {
        initializeGame();     }
    
    override func update(_ currentTime: TimeInterval) {
        managePlayer();
        score += 1;
        scoreLabel?.text = String(score);
        
        let randomSample: Int = Int(arc4random_uniform(UInt32(25)))
        if randomSample < 5 {
            let randomInt: Int = Int(arc4random_uniform(UInt32(obstacleController.numberOfObstacles)))
            obstacleController.animateObstacle(obstacleId: randomInt);
        }
        
        
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
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Bomb" {
            firstBody.node?.removeFromParent();
            secondBody.node?.removeFromParent();
            
            // ScheduledTimer to restart game after x seconds.
            Timer.scheduledTimer(timeInterval: TimeInterval(0), target: self, selector: #selector(GameplaySceneClass.restartGame), userInfo: nil, repeats: false);
        }
        
       
        
        if ((contact.bodyA.node?.name?.range(of: "Obstacle")) != nil) {
            audioPlayer.playFx(fileName: "bow", fileType: "mp3")
        }
        
        if((contact.bodyB.node?.name?.range(of: "Obstacle")) != nil) {
            audioPlayer.playFx(fileName: "bow", fileType: "mp3")
            
        }
        if((contact.bodyA.node?.name?.range(of: "Player")) != nil) {
            audioPlayer.playFx(fileName: "ploop", fileType: "mp3")
            
        }
        if((contact.bodyB.node?.name?.range(of: "Player")) != nil) {
            audioPlayer.playFx(fileName: "ploop", fileType: "mp3")
            
        }
        
        
        
        
    }
    
    
    private func initializeGame(){
        
        
        physicsWorld.contactDelegate = self;
        
        player = childNode(withName: "Player") as? Player!;
        player?.InitializePlayer();
        
        scoreLabel = childNode(withName: "ScoreLabel") as? SKLabelNode!;
        scoreLabel?.text = "0";
        createEdgeFrame()

        createObstacles()
        
        center = self.frame.size.width / self.frame.size.height;
        audioPlayer.stopMusic()
        audioPlayer.playMusic(fileName: "ingame", fileType: "mp3")
        
        Timer.scheduledTimer(timeInterval: TimeInterval(itemController.randomBetweenNumbers(firstNum: 1, secondNum: 2)), target: self, selector: #selector(GameplaySceneClass.spawnItems), userInfo: nil, repeats: true);
        
        // Check every 7 seconds if there are items "out of bounds" and remove them.
        Timer.scheduledTimer(timeInterval: TimeInterval(7), target: self, selector: #selector(GameplaySceneClass.removeItems), userInfo: nil, repeats: true);
        
        
    }
    
    func createEdgeFrame() {
        var splinePointsLeft = [CGPoint(x:-225, y: 400), CGPoint(x:-225, y: -400)]
        let leftEdge = SKShapeNode(splinePoints: &splinePointsLeft, count: splinePointsLeft.count)
        leftEdge.lineWidth = 0
        leftEdge.physicsBody = SKPhysicsBody(edgeChainFrom: leftEdge.path!)
        leftEdge.physicsBody?.restitution = 0.75
        leftEdge.physicsBody?.isDynamic = false;
        
        var splinePointsRight = [CGPoint(x:225, y: 400), CGPoint(x:225, y: -400)]
        let rightEdge = SKShapeNode(splinePoints: &splinePointsRight, count: splinePointsRight.count)
        rightEdge.lineWidth = 0
        rightEdge.physicsBody = SKPhysicsBody(edgeChainFrom: rightEdge.path!)
        rightEdge.physicsBody?.restitution = 0.75
        rightEdge.physicsBody?.isDynamic = false;
        
        self.scene?.addChild(leftEdge)
        self.scene?.addChild(rightEdge)
        
    }
    
    func createObstacles(){
        let map = gameConstants.getMapById(id: 1)
        for peg in map.peg_points {
            self.scene?.addChild(obstacleController.createObstacle(x: peg[0], y: peg[1]))
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
            view?.presentScene(scene);
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

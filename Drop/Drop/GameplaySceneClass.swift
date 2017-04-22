//
//  GameplaySceneClass.swift
//  Drop
//
//  Created by Hung Quang Thieu on 13/03/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import SpriteKit

class GameplaySceneClass: SKScene, SKPhysicsContactDelegate{
    let gameConstants = GameConstants.getInstance()
    let audioPlayer = soundManager.sharedInstance
    var gameManager: GameManager?
    private var center = CGFloat();
    private var canMove = false, moveLeft = false;
    private var itemController = ItemController();
    private var scoreLabel: SKLabelNode?;
    private var score = 0;
    private var storedTouches = [UITouch: String]();
    private var obstacleController = ObstacleController();
    
    let gameSettings = GameSettings.getInstance()
    
    private lazy var player: Player = {
        let skinIndex = self.gameSettings.getUserSkin()
        let skinImage = self.gameConstants.getSkinImage(skinIndex: skinIndex)
        return Player(skinImageName: skinImage)
    }()
    
    override func didMove(to view: SKView) {
        initializeGame();
    }
    
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
            gameOver()
        }
        
       
        if ((contact.bodyA.node?.name?.range(of: "Obstacle")) != nil) {
            audioPlayer.playFx(fileName: "bow", fileType: "mp3")
        } else if((contact.bodyB.node?.name?.range(of: "Obstacle")) != nil) {
            audioPlayer.playFx(fileName: "bow", fileType: "mp3")
        }
        if((contact.bodyA.node?.name?.range(of: "Player")) != nil) {
            audioPlayer.playFx(fileName: "ploop", fileType: "mp3")
        } else if((contact.bodyB.node?.name?.range(of: "Player")) != nil) {
            audioPlayer.playFx(fileName: "ploop", fileType: "mp3")
        }
    }
    
    private func gameOver() {
        gameManager?.gameOver(score: self.score)
    }
    
    
    private func initializeGame(){
        physicsWorld.contactDelegate = self;
        addChild(player)
        
        let map = gameConstants.getMapById(id: gameSettings.getUserMapID())

        createBackground(map: map)
        createEdgeFrame()
        createObstacles(map: map)
        
        player.zPosition = 2
        player.position = CGPoint(x: 0, y: -size.height * 0.42)
        
        scoreLabel = childNode(withName: "ScoreLabel") as? SKLabelNode!;
        scoreLabel?.text = "0";
        
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
    
    func createObstacles(map: Map){
        for peg in map.pegList {
            self.scene?.addChild(obstacleController.createObstacle(x: peg[0], y: peg[1]))
        }
    }
    
    func createBackground(map: Map) {
        let background = SKSpriteNode(imageNamed: map.backgroundName)
        background.size = CGSize(width: frame.size.width, height: frame.size.height)
        background.position = CGPoint(x: 0  , y: 0)
        self.scene?.addChild(background)
    }
    
    private func managePlayer(){
        if canMove{
            player.move(left: moveLeft);
        }
    }
    
    //Adding a child (falling objects) to the scene
    func spawnItems(){
        let map = gameConstants.getMapById(id: gameSettings.getUserMapID())
        self.scene?.addChild(itemController.spawnItems(dropImage: map.dropName));
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

//
//  MultiplayerGameScene.swift
//  Drop
//
//  Created by Raymi Toro Eldby on 20/04/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit
import TrueTime

class MultiplayerGameScene: SKScene, SKPhysicsContactDelegate, MultiplayerManagerObserver {
    // MARK: - VARIABLES
    // Services
    private let constants = GameConstants.getInstance()
    private let multiplayerManager = MultiplayerManager.getInstance()
    private let realtime = RealTime.getInstance()
    
    // Controllers
    private let itemController = ItemController();
    private let obstacleController = ObstacleController()
    private var random = RandomGenerator()
    
    // Input management
    private var storedTouches = [UITouch: String]()
    
    // Game objects
    var opponents = [MultiplayerGamePlayer]()
    lazy var selfPlayer: MultiplayerGamePlayer = {
        let selfPeer = self.multiplayerManager.selfPlayer
        let selfSkinImage = self.constants.getSkinImage(skinIndex: selfPeer.skin)
        return MultiplayerGamePlayer(peer: selfPeer, skinImageName: selfSkinImage)
    }()
    
    // Timing
    var startTime: Int?
    var lastUpdate: CFTimeInterval = 0
    var nextDrop: Int?
    var nextPegToggle: Int?
    
    // MARK: - INITIALIZATION
    override func didMove(to view: SKView) {
        // Register to multiplayer events
        multiplayerManager.registerObserver(observer: self)
        
        // If leader, set the game up
        if selfPlayer.peer.isLeader {
            setupGame()
            realtime.getNow(then: { now in
                self.startTime = now
                self.sendInit(startTime: now)
            })
        }
    }
    
    // Leader Setup Game
    func setupGame() {
        // Setup self
        selfPlayer.position = CGPoint(x: -100, y: -350)
        selfPlayer.zPosition = 2
        addChild(selfPlayer)
        
        // Setup opponents
        let opponentPeers = multiplayerManager.players.filter { $0.id != selfPlayer.peer.id }
        for (index, opponentPeer) in opponentPeers.enumerated() {
            let opponentSkinImage = constants.getSkinImage(skinIndex: opponentPeer.skin)
            let opponent = MultiplayerGamePlayer(peer: opponentPeer, skinImageName: opponentSkinImage)
            opponent.position = CGPoint(x: -100 + (index + 1) * 200, y: -350)
            opponent.zPosition = 1
            opponents.append(opponent)
            addChild(opponent)
        }
        
        // Setup pegs
        createObstacles()
        
        // Setup edges
        createEdgeFrame()
    }
    
    // Peer Setup Game
    func setupGame(startTime: Int, seeds: (dropSpawnTimeSeed: Int, dropSpawnPositionSeed: Int, pegIndexSeed: Int, pegToggleTimeSeed: Int), players: [(x: CGFloat, y: CGFloat, leaderScore: Int)]) {
        // Setup time
        self.startTime = startTime
        
        // Setup random generator
        random = RandomGenerator(
            dropSpawnTimeSeed: seeds.dropSpawnTimeSeed,
            dropSpawnPositionSeed: seeds.dropSpawnPositionSeed,
            pegIndexSeed: seeds.pegIndexSeed,
            pegToggleTimeSeed: seeds.pegToggleTimeSeed
        )
        
        // Setup players
        let opponentPeers = multiplayerManager.players
        for player in players {
            if selfPlayer.peer.leaderScore == player.leaderScore {
                // Setup self
                selfPlayer.position = CGPoint(x: player.x, y: player.y)
                selfPlayer.zPosition = 2
                addChild(selfPlayer)
            } else {
                // Setup opponent
                if let opponentPeer = (opponentPeers.first { $0.leaderScore == player.leaderScore }) {
                    let opponentSkinImage = constants.getSkinImage(skinIndex: opponentPeer.skin)
                    let opponent = MultiplayerGamePlayer(peer: opponentPeer, skinImageName: opponentSkinImage)
                    opponent.position = CGPoint(x: player.x, y: player.y)
                    opponent.zPosition = 1
                    opponents.append(opponent)
                    addChild(opponent)
                }
            }
        }
        
        // Setup pegs
        createObstacles()
        
        // Setup edges
        createEdgeFrame()
    }
    
    
    func createObstacles(){
        let map = constants.getMapById(id: 1)
        for peg in map.peg_points {
            addChild(obstacleController.createObstacle(x: peg[0], y: peg[1]))
        }
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

    
    // MARK: - GAME LOOP
    override func update(_ currentTime: TimeInterval) {
        let deltaSeconds = currentTime - lastUpdate
        
        // Update player positions
        selfPlayer.update(delta: deltaSeconds)
        for opponent in opponents {
            opponent.update(delta: deltaSeconds)
        }

        lastUpdate = currentTime
        
        // Run real-time critical objects using NTP server-time
        if
            let now = realtime.getNow(),
            let start = startTime
        {
            updateRealTime(currentTime: now, startTime: start)
        }
        
    }
    
    func updateRealTime(currentTime: Int, startTime: Int) {
        // Update drops
        if let nextDropTime = nextDrop {
            if currentTime > nextDropTime {
                let drop = itemController.spawnItemAt(position: random.pollDropSpawnPosition())
                addChild(drop)
                nextDrop = nextDropTime + random.pollDropSpawnTime()
            }
        } else {
            nextDrop = startTime + random.pollDropSpawnTime()
        }
        
        // Update pegs
        if let nextPegToggleTime = nextPegToggle {
            if currentTime > nextPegToggleTime {
                let pegIndex = random.pollPegIndex(pegCount: obstacleController.numberOfObstacles)
                obstacleController.animateObstacle(obstacleId: pegIndex)
                nextPegToggle = nextPegToggleTime + random.pollPegToggleTime()
            }
        } else {
            nextPegToggle = startTime + random.pollPegToggleTime()
        }
    }

    
    // MARK: - NETWORK COMMUNICATION
    var id = "MULTIPLAYER_GAME_SCENE" // Required for observer protocol
    
    let GAME_INIT_TOPIC = "GAME_INIT"
    let GAME_PLAYER_UPDATE_TOPIC = "GAME_PLAYER_UPDATE"
    
    func sendInit(startTime: Int) {
        let players = [selfPlayer] + opponents
        let seeds = random.getSeeds()
        
        let message = [
            "topic": GAME_INIT_TOPIC,
            "startTime": startTime,
            "dropSpawnTimeSeed": seeds.dropSpawnTimeSeed,
            "dropSpawnPositionSeed": seeds.dropSpawnPositionSeed,
            "pegIndexSeed": seeds.pegIndexSeed,
            "pegToggleTimeSeed": seeds.pegToggleTimeSeed,
            "players": players.map({ $0.toJSON() })
            ] as [String: Any]
        multiplayerManager.send(message: message)
    }
    
    func sendPlayerUpdate() {
        let message = [
            "topic": GAME_PLAYER_UPDATE_TOPIC,
            "x": selfPlayer.position.x,
            "y": selfPlayer.position.y,
            "dx": selfPlayer.dx
        ] as [String: Any]
        multiplayerManager.send(message: message)
    }
    
    func notifyPlayersChange() {
    }
    
    func notifyReceivedMessage(fromPlayer player: PlayerPeer, message: [String: Any]) {
        let topic = message["topic"] as! String
        switch topic {
        case GAME_INIT_TOPIC:
            handleGameInit(initMessage: message)
            break
        case GAME_PLAYER_UPDATE_TOPIC:
            if let opponent = (opponents.first { $0.peer.id == player.id }) {
                handleGamePlayerUpdate(fromPlayer: opponent, message: message)
            }
            break
        default:
            return
        }
    }
    
    func handleGameInit(initMessage: [String: Any]) {
        // Extract startTime
        let startTime = initMessage["startTime"] as! Int
        
        // Extract seeds
        let seeds = (
            dropSpawnTimeSeed: initMessage["dropSpawnTimeSeed"] as! Int,
            dropSpawnPositionSeed: initMessage["dropSpawnPositionSeed"] as! Int,
            pegIndexSeed: initMessage["pegIndexSeed"] as! Int,
            pegToggleTimeSeed: initMessage["pegToggleTimeSeed"] as! Int
        )
        
        // Extract players
        let playersJSON = initMessage["players"] as! [[String: Any]]
        let players = playersJSON.map { player in
            return (
                x: player["x"] as! CGFloat,
                y: player["y"] as! CGFloat,
                leaderScore: player["leaderScore"] as! Int
            )
        }
        
        setupGame(startTime: startTime, seeds: seeds, players: players)
    }
    
    func handleGamePlayerUpdate(fromPlayer player: MultiplayerGamePlayer, message: [String: Any]) {
        let playerPosX = message["x"] as! CGFloat
        let playerPosY = message["y"] as! CGFloat
        let playerDx = message["dx"] as! Int
        player.position = CGPoint(x: playerPosX, y: playerPosY)
        player.dx = playerDx
    }
    
    // MARK: - GAME INPUT
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self);
            
            if location.x > 0 {
                selfPlayer.dx = 1
                storedTouches[touch] = "right";
            }
            else {
                selfPlayer.dx = -1
                storedTouches[touch] = "left";
            }
            sendPlayerUpdate()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            storedTouches[touch] = nil;
        }
        
        if storedTouches.isEmpty {
            selfPlayer.dx = 0
            sendPlayerUpdate()
        }
    }
}

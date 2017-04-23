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
    private let settings = GameSettings.getInstance()
    private let multiplayerManager = MultiplayerManager.getInstance()
    private let realtime = RealTime.getInstance()
    private let audioPlayer = SoundManager.getInstance()
    
    // Controllers
    private let itemController = ItemController();
    private let obstacleController = ObstacleController()
    private var random = RandomGenerator()
    var gameManager: MultiplayerGameManager?
    
    // Input management
    private var storedTouches = [UITouch: String]()
    
    // Game objects
    var opponents = [MultiplayerGamePlayer]()
    lazy var selfPlayer: MultiplayerGamePlayer = {
        let selfPeer = self.multiplayerManager.selfPlayer
        let selfSkinImage = self.constants.getSkinImage(skinIndex: selfPeer.skin)
        return MultiplayerGamePlayer(peer: selfPeer, skinImageName: selfSkinImage)
    }()
    var map: Map?
    
    // Timing
    var startTime: Int?
    var lastUpdate: CFTimeInterval = 0
    var nextDrop: Int?
    var nextPegToggle: Int?
    
    // MARK: - INITIALIZATION
    override func didMove(to view: SKView) {
        // Register to multiplayer events
        multiplayerManager.registerObserver(observer: self)
        
        // Set physicsworld contactDelegate to self
        physicsWorld.contactDelegate = self;
        
        // Start game-music
        audioPlayer.stopMusic()
        audioPlayer.playMusic(fileName: "ingame", fileType: "mp3")
        
        selfPlayer.peer.isGameReady = true
        if selfPlayer.peer.isLeader {
            // If leader, attempt to init
            print("first try")
            attemptLeaderInit()
        }
        else {
            // If not leader, send a ready-message
            multiplayerManager.sendGameReady()
        }
    }
    
    func attemptLeaderInit() {
        let peersExceptSelf = multiplayerManager.players.filter({ $0.id != selfPlayer.peer.id })
        if peersExceptSelf.count == 0 {
            return
        }
        if peersExceptSelf.filter({ !$0.isGameReady }).count == 0 {
            print("All peers are ready? \(peersExceptSelf.count)")
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
        selfPlayer.name = "selfPlayer"
        addChild(selfPlayer)
        
        // Setup opponents
        let opponentPeers = multiplayerManager.players.filter { $0.id != selfPlayer.peer.id }
        print("Opponent peerscount: \(opponentPeers.count)")
        let playerSpacing = Int(200.0 / Double(opponentPeers.count))
        for (index, opponentPeer) in opponentPeers.enumerated() {
            let opponentSkinImage = constants.getSkinImage(skinIndex: opponentPeer.skin)
            let opponent = MultiplayerGamePlayer(peer: opponentPeer, skinImageName: opponentSkinImage)
            opponent.position = CGPoint(x: -100 + (index + 1) * playerSpacing, y: -350)
            opponent.zPosition = 1
            opponents.append(opponent)
            addChild(opponent)
        }
        
        // Setup map
        map = constants.getMapById(id: settings.getUserMapID())
        createBackground(map: map!)
        createObstacles(map: map!)
        createEdgeFrame()
    }
    
    // Peer Setup Game
    func setupGame(startTime: Int, map: Map, seeds: (dropSpawnTimeSeed: Int, dropSpawnPositionSeed: Int, pegIndexSeed: Int, pegToggleTimeSeed: Int), players: [(x: CGFloat, y: CGFloat, leaderScore: Int)]) {
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
                selfPlayer.name = "selfPlayer"
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
        
        // Setup map
        self.map = map
        createBackground(map: map)
        createObstacles(map: map)
        createEdgeFrame()
    }
    
    func createObstacles(map: Map){
        for peg in map.pegList {
            addChild(obstacleController.createObstacle(x: peg[0], y: peg[1], map: map))
        }
    }
    
    func createBackground(map: Map) {
        let background = SKSpriteNode(imageNamed: map.backgroundName)
        background.size = CGSize(width: frame.size.width, height: frame.size.height)
        background.position = CGPoint(x: 0, y: 0)
        addChild(background)
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
        let players = [selfPlayer] + opponents
        for player in players {
            player.update(delta: deltaSeconds)
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
        if let nextDropTime = nextDrop, let dropName = map?.dropName {
            if currentTime > nextDropTime {
                let drop = itemController.spawnItem(
                    dropImage: dropName,
                    at: random.pollDropSpawnPosition()
                )
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
    
    func checkIfGameIsOver() {
        let players = [selfPlayer] + opponents
        if players.filter({ $0.isAlive }).count <= 1 {
            let winner = players.first { $0.isAlive }?.peer
            let losers = players.filter({ !$0.isAlive }).map({ $0.peer })
            multiplayerManager.unregisterObserver(observer: self)
            gameManager?.gameOver(winner: winner, losers: losers)
        }
    }

    
    // MARK: - NETWORK COMMUNICATION
    var id = "MULTIPLAYER_GAME_SCENE" // Required for observer protocol
    
    let GAME_INIT_TOPIC = "GAME_INIT"
    let GAME_PLAYER_UPDATE_TOPIC = "GAME_PLAYER_UPDATE"
    let GAME_SELF_DIED_TOPIC = "GAME_SELF_DIED"
    
    
    func sendInit(startTime: Int) {
        let players = [selfPlayer] + opponents
        let seeds = random.getSeeds()
        let mapID = settings.getUserMapID()
        
        let message = [
            "topic": GAME_INIT_TOPIC,
            "startTime": startTime,
            "mapID": mapID,
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
    
    func sendSelfDied() {
        let message = ["topic": GAME_SELF_DIED_TOPIC]
        multiplayerManager.send(message: message)
    }
    
    func notifyPlayersChange() {
        print("players changed???")
        let peers = multiplayerManager.players

        // Remove peers that have left
        let toRemove = opponents.filter({ opponent in
            return !peers.contains(where: { $0.id == opponent.peer.id })
        })
        for node in toRemove {
            opponents.remove(at: opponents.index(of: node)!)
        }
        removeChildren(in: toRemove)
        
        
        // Add new peers (except self)
        if startTime != nil {
            let peersExceptSelf = peers.filter({ $0.id != selfPlayer.peer.id })
            for peer in peersExceptSelf {
                if !peer.isGameReady {
                    break
                }
                if !opponents.contains(where: { $0.peer.id == peer.id }) {
                    let opponentSkinImage = constants.getSkinImage(skinIndex: peer.skin)
                    let opponent = MultiplayerGamePlayer(peer: peer, skinImageName: opponentSkinImage)
                    opponent.position = CGPoint(x: 0, y: -350)
                    opponent.zPosition = 1
                    opponents.append(opponent)
                    addChild(opponent)
                }
            }
        }
        
        // If leader, and game not started, attempt a leader init
        if selfPlayer.peer.isLeader && startTime == nil {
            print("nth try?")
            attemptLeaderInit()
        }
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
        case GAME_SELF_DIED_TOPIC:
            if let opponent = (opponents.first { $0.peer.id == player.id }) {
                handleGamePlayerDied(fromPlayer: opponent)
            }
            break
        default:
            return
        }
    }
    
    
    func handleGameInit(initMessage: [String: Any]) {
        // Extract startTime
        let startTime = initMessage["startTime"] as! Int
        
        // Extract map
        let mapID = initMessage["mapID"] as! Int
        let map = constants.getMapById(id: mapID)
        
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
        
        setupGame(startTime: startTime, map: map, seeds: seeds, players: players)
    }
    
    func handleGamePlayerUpdate(fromPlayer player: MultiplayerGamePlayer, message: [String: Any]) {
        let playerPosX = message["x"] as! CGFloat
        let playerPosY = message["y"] as! CGFloat
        let playerDx = message["dx"] as! Int
        player.position = CGPoint(x: playerPosX, y: playerPosY)
        player.dx = playerDx
    }
    
    func handleGamePlayerDied(fromPlayer player: MultiplayerGamePlayer) {
        player.isAlive = false
        OperationQueue.main.addOperation {
            self.removeChildren(in: [player])
            self.checkIfGameIsOver()
        }
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
    
    func didBegin(_ contact: SKPhysicsContact) {
        if
            contact.bodyA.node?.name == "selfPlayer" ||
            contact.bodyB.node?.name == "selfPlayer"
        {
            handlePlayerCollision()
        }
        
        
        if
            ((contact.bodyA.node?.name?.range(of: "Obstacle")) != nil) ||
            ((contact.bodyB.node?.name?.range(of: "Obstacle")) != nil)
        {
            audioPlayer.playFx(fileName: "bow", fileType: "mp3")
        }
    }
    
    func handlePlayerCollision() {
        audioPlayer.playFx(fileName: "ploop", fileType: "mp3")
        selfPlayer.isAlive = false
        removeChildren(in: [selfPlayer])
        sendSelfDied()
        checkIfGameIsOver()
    }
}

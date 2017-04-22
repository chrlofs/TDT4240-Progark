//
//  MultiplayerGameScene.swift
//  Drop
//
//  Created by Raymi Toro Eldby on 20/04/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation
import SpriteKit
import TrueTime

extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}

class MultiplayerGameScene: SKScene, SKPhysicsContactDelegate, MultiplayerManagerObserver {
    
    let constants = GameConstants.getInstance()
    let multiplayerManager = MultiplayerManager.getInstance()
    let truetime = TrueTimeClient.sharedInstance
    
    private var itemController = ItemController();
    
    var opponents = [MultiplayerGamePlayer]()
    
    lazy var selfPlayer: MultiplayerGamePlayer = {
        let selfPeer = self.multiplayerManager.selfPlayer
        let selfSkinImage = self.constants.getSkinImage(skinIndex: selfPeer.skin)
        return MultiplayerGamePlayer(peer: selfPeer, skinImageName: selfSkinImage)
    }()
    
    
    override func didMove(to view: SKView) {
        truetime.start()
        
        // OBSERVER LOGIC
        multiplayerManager.registerObserver(observer: self)
        
        
        // If leader, set the game up
        if selfPlayer.peer.isLeader {
            setupGame()
        }
    }
    
    
    func setupGame() {
        // GAME LOGIC
        let opponentPeers = multiplayerManager.players.filter { $0.id != selfPlayer.peer.id }
        for opponentPeer in opponentPeers {
            let opponentSkinImage = constants.getSkinImage(skinIndex: opponentPeer.skin)
            let opponent = MultiplayerGamePlayer(peer: opponentPeer, skinImageName: opponentSkinImage)
            opponents.append(opponent)
        }
        
        // Set positions
        selfPlayer.position = CGPoint(x: -100, y: -250)
        selfPlayer.zPosition = 2
        addChild(selfPlayer)
        
        for (index, opponent) in opponents.enumerated() {
            opponent.position = CGPoint(x: -100 + (index + 1) * 200, y: -250)
            opponent.zPosition = 1
            addChild(opponent)
        }
        
        center = self.frame.size.width / self.frame.size.height;
        
        sendGameInit()
    }
    
    // MARK: - GAME LOGIC
    private var center = CGFloat()
    private var storedTouches = [UITouch: String]()

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self);
            
            if location.x > center {
                selfPlayer.dx = 1
                storedTouches[touch] = "right";
            }
            else {
                selfPlayer.dx = -1
                storedTouches[touch] = "left";
            }
            sendGamePlayerUpdate()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            storedTouches[touch] = nil;
        }
        
        if storedTouches.isEmpty {
            selfPlayer.dx = 0
            sendGamePlayerUpdate()
        }
    }
    
    func poissonPoll(mean: Double) -> Double {
        let random = Double(arc4random_uniform(UInt32.max)) / Double(UInt32.max)
        let nextEvent = -mean * log(random)
        return nextEvent
    }
    
    var syncDelay = 0.0
    var pendingDrops = [(spawnTime: CFTimeInterval, drop: SKSpriteNode)]()
    var lastUpdate: CFTimeInterval = 0
    var lastSync: CFTimeInterval = 0

    override func update(_ currentTime: TimeInterval) {
        let deltaSeconds = currentTime - lastUpdate
        
        // Update player positions
        selfPlayer.update(delta: deltaSeconds)
        for opponent in opponents {
            opponent.update(delta: deltaSeconds)
        }
        
        // Update falling objects
        let syncedNow = currentTime - syncDelay
        if pendingDrops.count > 0 {
            let nextDrop = pendingDrops[0]
            if syncedNow > nextDrop.spawnTime {
                addChild(nextDrop.drop)
                pendingDrops.remove(at: 0)
            }
        } else if selfPlayer.peer.isLeader {
            // No drops in queue, spawn a new one
            let drop = itemController.spawnItems(dropImage: "fireball")
            let dropSpawnTime = poissonPoll(mean: 1)
            pendingDrops.append((currentTime + dropSpawnTime, drop))
            sendDropSpawned(drop: drop, spawnTime: dropSpawnTime)
        }
        
        // Send leader's clock for sync every 1s
        if selfPlayer.peer.isLeader {
            let timeSinceLastSync = currentTime - lastSync
            if timeSinceLastSync >= 1 {
                sendSync()
                lastSync = currentTime
            }
        }
        
        lastUpdate = currentTime
    }
    
    // MARK: - OBSERVER LOGIC
    var id = "MULTIPLAYER_GAME_SCENE"
    
    let GAME_INIT_TOPIC = "GAME_INIT"
    let GAME_PLAYER_UPDATE_TOPIC = "GAME_PLAYER_UPDATE"
    let GAME_DROP_SPAWNED_TOPIC = "GAME_DROP_SPAWNED"
    let GAME_SYNC_TOPIC = "GAME_SYNC"
    
    func sendGameInit() {
        let players = [selfPlayer] + opponents
        let message = [
            "topic": GAME_INIT_TOPIC,
            "players": players.map({ $0.toJSON() })
        ] as [String: Any]
        multiplayerManager.send(message: message)
    }
    
    func sendGamePlayerUpdate() {
        let message = [
            "topic": GAME_PLAYER_UPDATE_TOPIC,
            "x": selfPlayer.position.x,
            "y": selfPlayer.position.y,
            "dx": selfPlayer.dx
        ] as [String: Any]
        multiplayerManager.send(message: message)
    }
    
    func sendDropSpawned(drop: SKSpriteNode, spawnTime: CFTimeInterval) {
        let message = [
            "topic": GAME_DROP_SPAWNED_TOPIC,
            "spawnTime": Double(spawnTime),
            "x": drop.position.x,
            "y": drop.position.y
        ] as [String: Any]
        multiplayerManager.send(message: message)
    }
    
    func sendSync() {
        if let referenceTime = truetime.referenceTime {
            let now = referenceTime.now().millisecondsSince1970
            
            let message = [
                "topic": GAME_SYNC_TOPIC,
                "time": now
            ] as [String: Any]
            multiplayerManager.send(message: message)
        }
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
        case GAME_DROP_SPAWNED_TOPIC:
            handleDropSpawned(message: message)
            break
        case GAME_SYNC_TOPIC:
            handleGameSync(message: message)
            break
        default:
            return
        }
    }
    
    func handleGameInit(initMessage: [String: Any]) {
        let opponentPeers = multiplayerManager.players

        let players = initMessage["players"] as! [[String: Any]]
        for player in players {
            let playerLeaderScore = player["leaderScore"] as! Int
            let playerPosX = player["x"] as! CGFloat
            let playerPosY = player["y"] as! CGFloat
            
            if selfPlayer.peer.leaderScore == playerLeaderScore {
                selfPlayer.position = CGPoint(x: playerPosX, y: playerPosY)
                selfPlayer.zPosition = 2
            } else {
                if let opponentPeer = (opponentPeers.first { $0.leaderScore == playerLeaderScore }) {
                    let opponentSkinImage = constants.getSkinImage(skinIndex: opponentPeer.skin)
                    let opponent = MultiplayerGamePlayer(peer: opponentPeer, skinImageName: opponentSkinImage)
                    opponent.position = CGPoint(x: playerPosX, y: playerPosY)
                    opponent.zPosition = 1
                    opponents.append(opponent)
                }
            }
        }
        
        addChild(selfPlayer)
        for opponent in opponents {
            addChild(opponent)
        }
    }
    
    func handleGamePlayerUpdate(fromPlayer player: MultiplayerGamePlayer, message: [String: Any]) {
        let playerPosX = message["x"] as! CGFloat
        let playerPosY = message["y"] as! CGFloat
        let playerDx = message["dx"] as! Int
        player.position = CGPoint(x: playerPosX, y: playerPosY)
        player.dx = playerDx
    }
    
    func handleDropSpawned(message: [String: Any] ) {
        let dropPosX = message["x"] as! CGFloat
        let dropPosY = message["y"] as! CGFloat
        let dropSpawnTime = message["spawnTime"] as! Double
        
        let drop = itemController.spawnItemAt(position: CGPoint(x: dropPosX, y: dropPosY))
        pendingDrops.append((lastUpdate + dropSpawnTime, drop))
    }
    
    func handleGameSync(message: [String: Any]) {
        if let referenceTime = truetime.referenceTime {
            let now = referenceTime.now().millisecondsSince1970
            let leaderTime = message["time"] as! Int
            let delay = Double(now - leaderTime) / 1000
            print("Peer clock is \(now) - \(leaderTime) = \(delay) seconds behind leader clock")
        }
    }
}

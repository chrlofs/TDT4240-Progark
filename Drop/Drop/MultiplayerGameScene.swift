//
//  MultiplayerGameScene.swift
//  Drop
//
//  Created by Raymi Toro Eldby on 20/04/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import SpriteKit

class MultiplayerGameScene: SKScene, SKPhysicsContactDelegate, MultiplayerManagerObserver {
    
    let constants = GameConstants.getInstance()
    let multiplayerManager = MultiplayerManager.getInstance()
    
    var opponents = [MultiplayerGamePlayer]()
    
    lazy var selfPlayer: MultiplayerGamePlayer = {
        let selfPeer = self.multiplayerManager.selfPlayer
        let selfSkinImage = self.constants.getSkinImage(skinIndex: selfPeer.skin)
        return MultiplayerGamePlayer(peer: selfPeer, skinImageName: selfSkinImage)
    }()
    
    
    override func didMove(to view: SKView) {
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
    
    func initializeGame() {
        
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
    
    var lastUpdate: CFTimeInterval = 0
    override func update(_ currentTime: TimeInterval) {
        let deltaSeconds = currentTime - lastUpdate
        
        selfPlayer.update(delta: deltaSeconds)
        for opponent in opponents {
            opponent.update(delta: deltaSeconds)
        }
        lastUpdate = currentTime
    }
    
    // MARK: - OBSERVER LOGIC
    var id = "MULTIPLAYER_GAME_SCENE"
    
    let GAME_INIT_TOPIC = "GAME_INIT"
    let GAME_PLAYER_UPDATE = "GAME_PLAYER_UPDATE"
    let GAME_SYNC = "GAME_SYNC"
    
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
            "topic": GAME_PLAYER_UPDATE,
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
        case GAME_PLAYER_UPDATE:
            if let opponent = (opponents.first { $0.peer.id == player.id }) {
                handleGamePlayerUpdate(fromPlayer: opponent, message: message)
            }
            break
        default:
            return
        }
    }
    
    func handleGameInit(initMessage: [String: Any]) {
        print("Handling game init")
        let opponentPeers = multiplayerManager.players

        let players = initMessage["players"] as! [[String: Any]]
        for player in players {
            print("player: \(player)")
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
        print(message)
        // let playerPosX = message["x"] as! CGFloat
        // let playerPosY = message["y"] as! CGFloat
        let playerDx = message["dx"] as! Int
        // player.position = CGPoint(x: playerPosX, y: playerPosY)
        player.dx = playerDx
    }
}

//
//  MultiplayerManager.swift
//  Drop
//
//  Created by Raymi Toro Eldby on 20/04/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MPlayer {
    let id: MCPeerID
    let name: String
    let skin: Int
    var isLeader = true
    var leaderScore: Int
    
    init(id: MCPeerID, name: String, skin: Int, leaderScore: Int) {
        self.id = id
        self.name = name
        self.skin = skin
        self.leaderScore = leaderScore
    }
    
    func isReady() -> Bool {
        let requiredFields: [Any?] = [id, name, skin, isLeader]
        return (requiredFields.filter { $0 != nil }).count == requiredFields.count
    }
    
    func toJSON() -> [String: Any] {
        return [
            "name": name,
            "skin": skin,
            "leaderScore": leaderScore
        ]
    }
}

protocol MultiplayerManagerObserver {
    var id : String { get }
    func notifyPlayersChange()
    func notifyReceivedMessage(fromPlayer player: MPlayer, message: [String: Any])
}

class MultiplayerManager: NetworkServiceDelegate {
    let defaults = UserDefaults.standard
    
    // SINGLETON LOGIC
    static let sharedInstance: MultiplayerManager = MultiplayerManager()
    
    private let networkManager = NetworkServiceManager()
    
    // TODO: Move somewhere else
    final let FULL_SESSION_SIZE = 3 // Including self
    final let LEADER_HELLO_TOPIC = "LEADER_HELLO"
    final let PEER_HELLO_TOPIC = "PEER_HELLO"
    
    private init() {
        let userName = defaults.string(forKey: "userName") ?? "Name not set"
        let userSkin = defaults.integer(forKey: "userSkin")
        
        selfPlayer = MPlayer(id: networkManager.myPeerId, name: userName, skin: userSkin, leaderScore: networkManager.leaderScore)
        
        players = [selfPlayer]

        networkManager.delegate = self
    }
    
    
    // OBSERVER LOGIC
    // The observers are notified with event messages such as playerJoined and playerLeft
    private var observers: [MultiplayerManagerObserver] = []
    func registerObserver(observer: MultiplayerManagerObserver) {
        observers.append(observer)
    }
    
    func unregisterObserver(observer: MultiplayerManagerObserver) {
        observers = observers.filter { $0.id != observer.id }
    }
    
    func receiveData(data: Data, fromPeer peerID: MCPeerID) {
        do {
            let message = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            print("Received message \(message)")
            handleMessage(fromPeer: peerID, message: message)
        }
        catch let error {
            NSLog("%@", "Error parsing received data from JSON: \(error)")
        }
        
    }
    
    func notifyPeersChange() {
        for observer in observers {
            observer.notifyPlayersChange()
        }
    }
    
    func notifyReceivedMessage(fromPlayer player: MPlayer, message: [String: Any]) {
        for observer in observers {
            observer.notifyReceivedMessage(fromPlayer: player, message: message)
        }
    }
    
    
    // DELEGATE SPECIFIC
    func peerJoined(peerID: MCPeerID) {
        if selfPlayer.isLeader {
            sendLeaderHello()
        }
    }
    
    func peerLeft(peerID: MCPeerID) {
        players = players.filter { $0.id != peerID }
        electLeader()
        notifyPeersChange()
    }
    
    func joinedSession() {
    }
    
    private func electLeader() {
        // Elect new leader
        var leader = selfPlayer
        for challenger in players {
            if challenger.leaderScore > leader.leaderScore {
                leader.isLeader = false
                leader = challenger
            } else {
                challenger.isLeader = false
            }
        }
        leader.isLeader = true
    }
    
    // INTERNAL LOGIC
    var players: [MPlayer]
    let selfPlayer: MPlayer
    
    private func handleMessage(fromPeer peerID: MCPeerID, message: [String: Any]) {
        let topic = message["topic"] as! String
        switch topic {
        case LEADER_HELLO_TOPIC:
            handleHello(fromPeer: peerID, message: message)
            sendPeerHello()
            break
        case PEER_HELLO_TOPIC:
            handleHello(fromPeer: peerID, message: message)
            break
        default:
            // Pass message on to observers
            if let player = players.first(where: { $0.id == peerID }) {
                notifyReceivedMessage(fromPlayer: player, message: message)
            }
        }
    }
    
    private func sendLeaderHello() {
        send(message: [
            "topic": LEADER_HELLO_TOPIC,
            "playerInfo": selfPlayer.toJSON()
        ])
    }
    
    private func sendPeerHello()  {
        send(message: [
            "topic": PEER_HELLO_TOPIC,
            "playerInfo": selfPlayer.toJSON()
        ])
    }
    
    private func handleHello(fromPeer peerID: MCPeerID, message: [String: Any]) {
        if !players.contains(where: { $0.id == peerID }) {
            let playerInfo = message["playerInfo"] as! [String: Any]
            let playerName = playerInfo["name"] as! String
            let playerSkin = playerInfo["skin"] as! Int
            let playerLeaderScore = playerInfo["leaderScore"] as! Int
            
            let newPlayer = MPlayer(id: peerID, name: playerName, skin: playerSkin, leaderScore: playerLeaderScore)
            players.append(newPlayer)
            electLeader()
            
            notifyPeersChange()
        }
    }
    
    
    // PUBLICLY EXPOSED METHODS
    func send(message: [String: Any]) {
        do {
            let data = try JSONSerialization.data(withJSONObject: message, options: [])
            networkManager.sendData(data: data)
        }
        catch let error {
            NSLog("%@", "Error parsing as JSON: \(error)")
        }
    }
    
    func startBrowsing() {
        networkManager.startBrowsing()
    }
    
    func stopBrowsing() {
        networkManager.stopBrowsing()
    }
    
    func leaveSession() {
        networkManager.stopBrowsing()
        networkManager.leaveSession()
        
        players = [selfPlayer]
        selfPlayer.isLeader = true
        notifyPeersChange()
    }
}

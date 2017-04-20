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
    
    init(id: MCPeerID) {
        self.id = id
    }
}

protocol MultiplayerServiceObserver {
    var id : String { get }
    func notifyStateChange()
    func notifyPlayersChange()
    func notifyReceivedMessage(fromPeer peerID: MCPeerID, message: [String: Any])
}

class MultiplayerManager: NetworkServiceDelegate {
    // GENERAL LOGIC
    var players: [MPlayer]
    let selfPlayer: MPlayer
    
    // SINGLETON LOGIC
    static let sharedInstance: MultiplayerManager = MultiplayerManager()
    
    private let networkManager = NetworkServiceManager()
    
    // TODO: Move somewhere else
    final let FULL_SESSION_SIZE = 2 // Including self
    
    private init() {
        selfPlayer = MPlayer(id: networkManager.myPeerId)
        players = [selfPlayer]

        networkManager.delegate = self
    }
    
    
    // OBSERVER LOGIC
    // The observers are notified with event messages such as playerJoined and playerLeft
    private var observers: [MultiplayerServiceObserver] = []
    func registerObserver(observer: MultiplayerServiceObserver) {
        observers.append(observer)
    }
    
    func unregisterObserver(observer: MultiplayerServiceObserver) {
        observers = observers.filter { $0.id != observer.id }
    }
    
    func receiveData(data: Data, fromPeer peerID: MCPeerID) {
        do {
            let message = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            
            print("Receive message \(message)")
            for observer in observers {
                observer.notifyReceivedMessage(fromPeer: peerID, message: message)
            }
        }
        catch let error {
            NSLog("%@", "Error parsing received data from JSON: \(error)")
        }
        
    }
    
    func notifyChangeState() {
        for observer in observers {
            observer.notifyStateChange()
        }
    }
    
    func notifyPeersChange() {
        for observer in observers {
            observer.notifyPlayersChange()
        }
    }
    
    func peerJoined(peerID: MCPeerID) {
        let newPeer = MPlayer(id: peerID)
        players.append(newPeer)
        
        if players.count >= FULL_SESSION_SIZE {
            stopBrowsing()
        }
        
        notifyPeersChange()
    }
    
    func peerLeft(peerID: MCPeerID) {
        players = players.filter { $0.id != peerID }
        notifyPeersChange()
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
    
    private func stopBrowsing() {
        networkManager.stopBrowsing()
    }
    
    func leaveSession() {
        networkManager.stopBrowsing()
        networkManager.leaveSession()
        
    }
}

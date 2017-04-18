//
//  ColorServiceManager.swift
//  Drop
//
//  Created by Raymi Toro Eldby on 30/03/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation
import MultipeerConnectivity

enum MultiplayerServiceState {
    case DISCONNECTED
    case BROWSING
    case CONNECTED
}

protocol MultiplayerServiceObserver {
    var id : String { get }
    func onMultiplayerStateChange(state: MultiplayerServiceState)
    func onMultiplayerRecvMessage(message: String)
    func onMultiplayerPeerJoined(peerID: MCPeerID)
    func onMultiplayerPeerLeft(peerID: MCPeerID)
}

class MultiplayerServiceManager: NSObject {
    // TODO: Move somewhere else
    final let FULL_SESSION_SIZE = 1 // Not including self
    var state : MultiplayerServiceState = .DISCONNECTED
    
    // SINGLETON LOGIC
    static let instance: MultiplayerServiceManager = MultiplayerServiceManager()
    
    
    // OBSERVER LOGIC
    // The observers are notified with event messages such as playerJoined and playerLeft
    var observers: [MultiplayerServiceObserver] = []
    func registerObserver(observer: MultiplayerServiceObserver) {
        observers.append(observer)
    }
    
    func unregisterObserver(observer: MultiplayerServiceObserver) {
        observers = observers.filter { $0.id != observer.id }
    }
    
    func receiveMessage(message: String) {
        for observer in observers {
            observer.onMultiplayerRecvMessage(message: message)
        }
    }
    
    func changeState(newState: MultiplayerServiceState) {
        for observer in observers {
            observer.onMultiplayerStateChange(state: newState)
        }
    }
    
    func peerJoined(peerID: MCPeerID) {
        for observer in observers {
            observer.onMultiplayerPeerJoined(peerID: peerID)
        }
    }
    
    func peerLeft(peerID: MCPeerID) {
        for observer in observers {
            observer.onMultiplayerPeerLeft(peerID: peerID)
        }
    }
    
    // SERVICE LOGIC
    // Service type must be a unique string, at most 15 characters long
    // and can contain only ASCII lowercase letters, numbers and hyphens.
    private let MultiplayerServiceType = "drop-mp-service"
    
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    var session : MCSession
    
    override private init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: MultiplayerServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: MultiplayerServiceType)
        self.session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        
        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceBrowser.delegate = self
    }
    
    deinit {
        leaveSession()
    }
    
    // PUBLICLY EXPOSED METHODS
    func send(message: String) {
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(message.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error sending: \(error)")
            }
        }
    }
    
    func startBrowsing() {
        session.disconnect()
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self

        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser.startBrowsingForPeers()
        
        changeState(newState: .BROWSING)
    }
    
    func stopBrowsing() {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
        
        changeState(newState: .CONNECTED)
    }
    
    func leaveSession() {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
        
        session.disconnect()
        
        changeState(newState: .DISCONNECTED)
    }
}

// BROWSER LOGIC
extension MultiplayerServiceManager : MCNearbyServiceBrowserDelegate {
    
    // FOUND PEER
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        // If device's score is higher, invite the peer
        // if let peerScore = info?["score"], Int(peerScore)! < self.leader_score {
        //    browser.invitePeer(peerID, to: session!, withContext: nil, timeout: 10)
        //}
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    // REST IS NOT IMPORTANT
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
}



// ADVERTISING LOGIC
extension MultiplayerServiceManager : MCNearbyServiceAdvertiserDelegate {
    
    // RECEIVED INVITATION
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.session)
    }
    
    // REST IS NOT IMPORTANT
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {}
}



// SESSION LOGIC
extension MultiplayerServiceManager : MCSessionDelegate {

    // STATE CHANGED
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            self.peerLeft(peerID: peerID)
        case .connecting:
            return
        case .connected:
            self.peerJoined(peerID: peerID)
            if session.connectedPeers.count == self.FULL_SESSION_SIZE {
                // Session is full
                self.stopBrowsing()
            }
        }
    }

    
    // RECEIVE DATA
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        let message = String(data: data, encoding: .utf8)!
        self.receiveMessage(message: message)
    }
    
    
    // REST IS NOT IMPORTANT
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName: \(resourceName)")
    }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResoureWithName: \(resourceName)")
    }
}

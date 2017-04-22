//
//  ColorServiceManager.swift
//  Drop
//
//  Created by Raymi Toro Eldby on 30/03/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol NetworkServiceDelegate {
    func peerJoined(peerID: MCPeerID)
    func peerLeft(peerID: MCPeerID)
    func joinedSession()
    func receiveData(data: Data, fromPeer peerID: MCPeerID)
}


class NetworkServiceManager: NSObject {
    // SERVICE LOGIC
    // Service type must be a unique string, at most 15 characters long
    // and can contain only ASCII lowercase letters, numbers and hyphens.
    private let MultiplayerServiceType = "drop-mp-service"
    
    let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    let leaderScore = Int(arc4random_uniform(100000))
    
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    var session : MCSession
    
    var delegate: NetworkServiceDelegate?
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: ["leaderScore": String(leaderScore)], serviceType: MultiplayerServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: MultiplayerServiceType)
        self.session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)

        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceBrowser.delegate = self
        self.session.delegate = self
    }
    
    func startBrowsing() {
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    func leaveSession() {
        session.disconnect()
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
    }
    
    func sendData(data: Data) {
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(data, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error sending data: \(error)")
            }
        }
    }
}


// BROWSER LOGIC
extension NetworkServiceManager : MCNearbyServiceBrowserDelegate {
    
    // FOUND PEER
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if
            let peerLeaderScoreInfo = info?["leaderScore"],
            let peerLeaderScore = Int(peerLeaderScoreInfo),
            leaderScore > peerLeaderScore
        {
            browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
        }
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
extension NetworkServiceManager : MCNearbyServiceAdvertiserDelegate {
    
    // RECEIVED INVITATION
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        if !self.session.connectedPeers.contains(peerID) {
            invitationHandler(true, self.session)
            self.delegate?.joinedSession()
        } else {
            invitationHandler(false, nil)
        }
        
    }
    
    // REST IS NOT IMPORTANT
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {}
}



// SESSION LOGIC
extension NetworkServiceManager : MCSessionDelegate {

    // STATE CHANGED
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            self.delegate?.peerLeft(peerID: peerID)
            break
        case .connecting:
            break
        case .connected:
            self.delegate?.peerJoined(peerID: peerID)
            break
        }
    }

    
    // RECEIVE DATA
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        self.delegate?.receiveData(data: data, fromPeer: peerID)
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

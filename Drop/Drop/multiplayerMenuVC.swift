//
//  multiplayerMenuVC.swift
//  Drop
//
//  Created by Kristoffer Thorset on 13.03.2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

class PlayerPeer {
    let id: MCPeerID
    var name = ""
    var masterScore = -1
    var skin = UIImage(named: "unknown_player")
    
    init(id: MCPeerID) {
        self.id = id
    }
}

class multiplayerMenuVC : UIViewController, MultiplayerServiceObserver {
    // ID must be unique among MultiplayerServiceObservers
    var id : String = "MULTIPLAYER_MENU_VC"
    let multiplayerService : MultiplayerServiceManager = MultiplayerServiceManager.instance
    
    let defaults = UserDefaults.standard
    
    var players = [PlayerPeer]()
    var userName = "No userName"
    var userSkin = UIImage(named: "skin1")
    let userMasterScore = Int(arc4random_uniform(1000000))
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    
    @IBOutlet weak var playerSelfLabel: UILabel!
    @IBOutlet weak var playerPeer1Label: UILabel!
    @IBOutlet weak var playerPeer2Label: UILabel!
    
    @IBOutlet weak var playerSelfSkin: UIImageView!
    @IBOutlet weak var playerPeer1Skin: UIImageView!
    @IBOutlet weak var playerPeer2Skin: UIImageView!


    override func viewDidLoad() {
        super.viewDidLoad()
        multiplayerService.registerObserver(observer: self)
        
        // Set own userName in playerSelfLabel text
        userName = defaults.value(forKey: "userName") as? String ?? userName
        OperationQueue.main.addOperation {
            self.playerSelfLabel.text = self.userName
            self.playerSelfSkin.image = self.userSkin
        }
        
        multiplayerService.startBrowsing()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        multiplayerService.unregisterObserver(observer: self)
        multiplayerService.leaveSession()
    }
    
    func backToMenu(){
        let menuVC = self.storyboard?.instantiateViewController(withIdentifier: "menuVC") as! menuVC
        self.navigationController?.pushViewController(menuVC, animated: true)
    }
    
    func onMultiplayerRecvMessage(fromPeer peerID: MCPeerID, message: [String: Any]) {
        if
            let player = (players.first { $0.id == peerID }),
            let topic = message["topic"] as? String,
            topic == "GREETING"
        {
            player.name = (message["userName"] as? String)!
            player.masterScore = (message["userMasterScore"] as? Int)!
            player.skin = UIImage(named: "skin2")
            updatePlayers()
        }
    }
    
    func onMultiplayerStateChange(state: MultiplayerServiceState) {
        if (state == .CONNECTED) {
            // Broadcast name
            let message = [
                "topic": "GREETING",
                "userName": userName,
                "userMasterScore": userMasterScore
            ] as [String : Any]

            multiplayerService.send(message: message)
        }
        
        var stateText = "?"
        switch state {
        case .DISCONNECTED:
            stateText = "Disconnected"
        case .BROWSING:
            stateText = "Browsing"
        case .CONNECTED:
            stateText = "Connected"
        }
        OperationQueue.main.addOperation {
            self.stateLabel.text = stateText
        }
    }
    
    func onMultiplayerPeerLeft(peerID: MCPeerID) {
        players = players.filter { $0.id != peerID }
        updatePlayers()
    }
    
    func onMultiplayerPeerJoined(peerID: MCPeerID) {
        let newPlayer = PlayerPeer(id: peerID)
        players.append(newPlayer)
        updatePlayers()
    }
    
    func updatePlayers() {
        OperationQueue.main.addOperation {
            if (self.players.filter { $0.masterScore > self.userMasterScore }).count == 0 {
                // Leader
                self.roleLabel.text = "Role: Leader"
            } else {
                // Peer
                self.roleLabel.text = "Role: Peer"
            }
            
            if (self.players.count > 0) {
                self.playerPeer1Label.text = self.players[0].name
                self.playerPeer1Skin.image = self.players[0].skin
            }
            if (self.players.count > 1) {
                self.playerPeer2Label.text = self.players[1].name
                self.playerPeer2Skin.image = self.players[1].skin
            }
        }
    }
}


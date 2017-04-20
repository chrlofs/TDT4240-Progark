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
    var name = "Unknown"
    var masterScore = -1
    var skinImage = UIImage(named: "unknown_player")
    
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
    var userName = "No username"
    var userSkin = 0
    var userSkinImage = UIImage(named: "skin1")
    let userMasterScore = Int(arc4random_uniform(1000000))
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    
    @IBOutlet weak var playerSelfLabel: UILabel!
    @IBOutlet weak var playerPeer1Label: UILabel!
    @IBOutlet weak var playerPeer2Label: UILabel!
    
    @IBOutlet weak var playerSelfSkin: UIImageView!
    @IBOutlet weak var playerPeer1Skin: UIImageView!
    @IBOutlet weak var playerPeer2Skin: UIImageView!

    @IBAction func back(_ sender: UIButton) {
        multiplayerService.leaveSession()
        
        let menuVC = self.storyboard?.instantiateViewController(withIdentifier: "menuVC") as! menuVC
        self.navigationController?.pushViewController(menuVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        multiplayerService.registerObserver(observer: self)
        
        // Set own userName in playerSelfLabel text
        userName = defaults.value(forKey: "userName") as? String ?? userName
        userSkin = defaults.value(forKey: "userSkin") as? Int ?? 0
        let skins = defaults.stringArray(forKey: "skinList") ?? [String]()
        
        if skins.count > userSkin {
            userSkinImage = UIImage(named: skins[userSkin])
        }
        
        OperationQueue.main.addOperation {
            self.playerSelfLabel.text = self.userName
            self.playerSelfSkin.image = self.userSkinImage
        }
        
        multiplayerService.startBrowsing()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        multiplayerService.unregisterObserver(observer: self)
        multiplayerService.leaveSession()
    }
    
    func goToGame() {
        let MultiplayerGameViewController = self.storyboard?.instantiateViewController(withIdentifier: "MultiplayerGameViewController") as! MultiplayerGameViewController
        
        self.navigationController?.pushViewController(MultiplayerGameViewController, animated: true)
    }
    
    func onMultiplayerRecvMessage(fromPeer peerID: MCPeerID, message: [String: Any]) {
        if
            let player = (players.first { $0.id == peerID }),
            let topic = message["topic"] as? String,
            topic == "GREETING"
        {
            player.name = (message["userName"] as? String)!
            
            player.masterScore = (message["userMasterScore"] as? Int)!
            
            let skins = defaults.stringArray(forKey: "skinList") ?? [String]()
            let skin = (message["userSkin"] as? Int)!
            if skins.count > skin {
                player.skinImage = UIImage(named: skins[skin])
            }
            updatePlayers()
            goToGame()
        }
    }
    
    func onMultiplayerStateChange(state: MultiplayerServiceState) {
        if (state == .CONNECTED) {
            // Broadcast name
            let message = [
                "topic": "GREETING",
                "userName": userName,
                "userSkin": userSkin,
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
                self.playerPeer1Skin.image = self.players[0].skinImage
            } else {
                self.playerPeer1Label.text = "Player 2"
                self.playerPeer1Skin.image = UIImage(named: "unknown_player")
            }
            if (self.players.count > 1) {
                self.playerPeer2Label.text = self.players[1].name
                self.playerPeer2Skin.image = self.players[1].skinImage
            } else {
                self.playerPeer2Label.text = "Player 3"
                self.playerPeer2Skin.image = UIImage(named: "unknown_player")
            }
        }
    }
}


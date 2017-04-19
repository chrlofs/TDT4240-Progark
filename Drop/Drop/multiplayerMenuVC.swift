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

class multiplayerMenuVC : UIViewController, MultiplayerServiceObserver {
    var id : String = "MULTIPLAYER_MENU_VC"
    let multiplayerService : MultiplayerServiceManager = MultiplayerServiceManager.instance
    
    var players: Set<MCPeerID> = []
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var numPeersLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var lastMessageReceived: UILabel!
    
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var messageInput: UITextField!
    
    @IBAction func onTouchStartBrowsing(_ sender: Any) {
        multiplayerService.startBrowsing()
    }
    
    @IBAction func onTouchStopBrowsing(_ sender: Any) {
        multiplayerService.stopBrowsing()
    }
    
    @IBAction func onTouchLeaveSession(_ sender: Any) {
        multiplayerService.leaveSession()
    }
    
    @IBAction func onTouchSendMessage(_ sender: Any) {
        print("Send message")
        let message = messageInput.text!
        print(message)
        multiplayerService.send(message: message)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        multiplayerService.registerObserver(observer: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        multiplayerService.unregisterObserver(observer: self)
        multiplayerService.leaveSession()
    }
    
    func backToMenu(){
        let menuVC = self.storyboard?.instantiateViewController(withIdentifier: "menuVC") as! menuVC
        self.navigationController?.pushViewController(menuVC, animated: true)
    }
    
    func onMultiplayerRecvMessage(message: String) {
        OperationQueue.main.addOperation {
            self.lastMessageReceived.text = message
        }
    }
    
    func onMultiplayerStateChange(state: MultiplayerServiceState) {
        var stateString = ""
        switch state {
        case .DISCONNECTED:
            stateString = "Disconnected"
        case .BROWSING:
            stateString = "Browsing"
        case .CONNECTED:
            stateString = "Connected"
            
        }
        
        OperationQueue.main.addOperation {
            self.stateLabel.text = "State: \(stateString)"
            self.toggleMessageInput(toggleOn: state == .CONNECTED)
        }
    }
    
    func onMultiplayerPeerLeft(peerID: MCPeerID) {
        players.remove(peerID)
        
        OperationQueue.main.addOperation {
            self.numPeersLabel.text = "Num of peers: \(self.players.count)"
        }
    }
    
    func onMultiplayerPeerJoined(peerID: MCPeerID) {
        players.insert(peerID)
        
        OperationQueue.main.addOperation {
            self.numPeersLabel.text = "Num of peers: \(self.players.count)"
        }
    }
    
    func toggleMessageInput(toggleOn : Bool) {
        sendMessageButton.isHidden = !toggleOn
        messageInput.isHidden = !toggleOn
    }
}


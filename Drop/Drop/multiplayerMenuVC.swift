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

class multiplayerMenuVC : UIViewController, UITableViewDataSource, UITableViewDelegate, MultiplayerManagerObserver {
    // ID must be unique among MultiplayerServiceObservers
    var id: String = "MULTIPLAYER_MENU_VC"
    let multiplayerManager = MultiplayerManager.getInstance()
    
    let defaults = UserDefaults.standard

    @IBOutlet weak var playerTableView: UITableView!

    @IBAction func back(_ sender: UIButton) {
        multiplayerManager.leaveSession()
        multiplayerManager.unregisterObserver(observer: self)
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        
        multiplayerManager.registerObserver(observer: self)
        multiplayerManager.startBrowsing()
        
        playerTableView.delegate = self
        playerTableView.dataSource = self
    }

    
    func goToGame() {
        multiplayerManager.stopBrowsing()
        multiplayerManager.unregisterObserver(observer: self)
        let MultiplayerGameViewController = self.storyboard?.instantiateViewController(withIdentifier: "MultiplayerGameViewController") as! MultiplayerGameViewController
        self.navigationController?.pushViewController(MultiplayerGameViewController, animated: true)
    }
    
    
    internal func notifyPlayersChange() {
        OperationQueue.main.addOperation {
            self.playerTableView.reloadData()
            
            if (self.multiplayerManager.players.count == 2) {
                print("Let's go to game")
                self.goToGame()
            }
        }
    }
    
    internal func notifyReceivedMessage(fromPlayer player: PlayerPeer, message: [String : Any]) {
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return multiplayerManager.players.count // Number of rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerTableCell") as! PlayerPeerTableCell
        
        print("Rendering at index: \(indexPath.item) of \(multiplayerManager.players.count)")
        let player = multiplayerManager.players[indexPath.item]
        cell.nameLabel.text = "\(player.name) \(player.skin)"
        
        if player.isLeader {
            cell.roleLabel.text = "Leader"
        } else {
            cell.roleLabel.text = "Peer"
        }
        
        cell.leaderScoreLabel.text = "\(player.leaderScore)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}


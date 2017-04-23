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

class MultiplayerLobbyVC : UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, MultiplayerManagerObserver {
    
    @IBOutlet weak var selfPlayerSkinImage: UIImageView!
    @IBOutlet weak var selfPlayerNameLabel: UILabel!
    @IBOutlet weak var playerCollectionView: UICollectionView!
    
    @IBAction func back(_ sender: UIButton) {
        multiplayerManager.leaveSession()
        multiplayerManager.unregisterObserver(observer: self)
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    // ID must be unique among MultiplayerServiceObservers
    var id: String = "MULTIPLAYER_MENU_VC"
    
    let constants = GameConstants.getInstance()
    let multiplayerManager = MultiplayerManager.getInstance()
    let peersPerSection = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        multiplayerManager.registerObserver(observer: self)
        multiplayerManager.startBrowsing()
        
        let selfPlayer = multiplayerManager.selfPlayer
        selfPlayerNameLabel.text = selfPlayer.name
        selfPlayerSkinImage.image = UIImage(named: constants.getSkinImage(skinIndex: selfPlayer.skin))
    }

    
    func goToGame() {
        multiplayerManager.stopBrowsing()
        multiplayerManager.unregisterObserver(observer: self)
        let multiplayerGameVC = self.storyboard?.instantiateViewController(withIdentifier: "MultiplayerGameVC") as! MultiplayerGameVC
        self.navigationController?.pushViewController(multiplayerGameVC, animated: true)
    }
    
    
    internal func notifyPlayersChange() {
        OperationQueue.main.addOperation {
            self.playerCollectionView.reloadData()
            
            if (self.multiplayerManager.players.count == self.constants.maxPlayersInMultiplayerGame) {
                print("Let's go to game")
                self.goToGame()
            }
        }
    }
    
    internal func notifyReceivedMessage(fromPlayer player: PlayerPeer, message: [String : Any]) {
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        /*
        let numPeers = multiplayerManager.players.count - 1
        let numSections = Int(ceil(Double(numPeers) / 2))
        let isLastRow = (section == numSections - 1)
        let cellCount = CGFloat(isLastRow ? 1 : 2)
        
        if cellCount > 0 {
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            let cellWidth = flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing
            let totalCellWidth = cellWidth*cellCount + 10 * (cellCount-1)
            let contentWidth = collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right
            
            if (totalCellWidth < contentWidth) {
                let padding = (contentWidth - totalCellWidth) / 2.0
                let paddingTop = CGFloat(numPeers == 1 ? 50 : 0)
                print("padding top: \(paddingTop)")
                return UIEdgeInsetsMake(paddingTop, padding, 0, padding)
            }
        }
         */
        
        return UIEdgeInsets.zero
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let numPeers = multiplayerManager.players.count - 1
        return Int(ceil(Double(numPeers) / 2))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numPeers = multiplayerManager.players.count - 1
        return (numPeers % 2 == 0 ? 2 : 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = playerCollectionView.dequeueReusableCell(withReuseIdentifier: "MultiplayerLobbyPlayerCollectionCell", for: indexPath) as! PlayerCollectionCell
        
        let selfPlayer = multiplayerManager.selfPlayer
        let peerIndex = indexPath.item
        let peers = multiplayerManager.players.filter { $0.id != selfPlayer.id }

        print("(peerIndex, peerCount) = (\(peerIndex), \(peers.count))")
        if peers.count > peerIndex {
            let peer = peers[peerIndex]
            cell.userName.text = peer.name
            cell.userSkin.image = UIImage(named: constants.getSkinImage(skinIndex: peer.skin))
        }
        
        return cell
    }    
}


//
//  MultiplayerGameOverViewController.swift
//  Drop
//
//  Created by Raymi Toro Eldby on 23/04/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation
import UIKit

class MultiplayerGameOverVC: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    @IBOutlet weak var winnerSkinImage: UIImageView!
    @IBOutlet weak var winnerNameLabel: UILabel!
    @IBOutlet weak var playerCollectionView: UICollectionView!
    
    let multiplayerManager = MultiplayerManager.getInstance()
    let constants = GameConstants.getInstance()
    let audioPlayer = SoundManager.getInstance()

    var winner: PlayerPeer?
    var losers = [PlayerPeer]()
    let losersPerSection = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        if let winner = self.winner {
            winnerSkinImage.image = UIImage(named: constants.getSkinImage(skinIndex: winner.skin))
            winnerNameLabel.text = winner.name
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        multiplayerManager.leaveSession()
        audioPlayer.stopMusic()
        audioPlayer.playMusic(fileName: "GameMusic", fileType: "mp3")

        let controllers = self.navigationController?.viewControllers
        for vc in controllers! {
            if vc is menuVC {
                _ = self.navigationController?.popToViewController(vc as! menuVC, animated: true)
            }
        }
    }
    
    func initialize(winner: PlayerPeer?, losers: [PlayerPeer]) {
        self.winner = winner
        self.losers = losers
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let numLosers = losers.count
        let numSections = Int(ceil(Double(losers.count) / 2))
        let isLastRow = (section == numSections - 1)
        let cellCount = CGFloat(isLastRow ? 1 : 2)
        
        if cellCount > 0 {
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            let cellWidth = flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing
            let totalCellWidth = cellWidth*cellCount + 10*(cellCount-1)
            let contentWidth = collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right
            
            if (totalCellWidth < contentWidth) {
                let padding = (contentWidth - totalCellWidth) / 2.0
                let paddingTop = CGFloat(numLosers == 1 ? 50 : 0)
                return UIEdgeInsetsMake(paddingTop, padding, 0, padding)
            }
        }
        
        return UIEdgeInsets.zero
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Int(ceil(Double(losers.count) / 2))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numSections = Int(ceil(Double(losers.count) / 2))
        return (section < numSections - 1) ? 2 : (losers.count % 2 == 0 ? 2 : 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = playerCollectionView.dequeueReusableCell(withReuseIdentifier: "MultiplayerGameOverPlayerCollectionCell", for: indexPath) as! PlayerCollectionCell
        
        let loserIndex = indexPath.section * losersPerSection + indexPath.item
        print("loserIndex: \(loserIndex) of \(losers.count)")
        if losers.count > loserIndex {
            let loser = losers[loserIndex]
            cell.userName.text = loser.name
            cell.userSkin.image = UIImage(named: constants.getSkinImage(skinIndex: loser.skin))
        }
        
        return cell
    }
}

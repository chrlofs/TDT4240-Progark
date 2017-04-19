//
//  soundManager.swift
//  Drop
//
//  Created by Kristoffer Thorset on 27.03.2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation
import AVFoundation

class soundManager {
    static let sharedInstance = soundManager()
    var fxPlayer = AVAudioPlayer()
    var musicPlayer = AVAudioPlayer()
    func playSound() {
        
    }
    func playFx(fileName: String, fileType: String){
        let url = Bundle.main.url(forResource: fileName, withExtension: fileType)!
        do {
            fxPlayer = try AVAudioPlayer(contentsOf: url)
            fxPlayer.prepareToPlay()
            fxPlayer.play()
        } catch  {
            // couldn't load file :(
        }
        
    }
    func playMusic(fileName: String, fileType: String){
        let url = Bundle.main.url(forResource: fileName, withExtension: fileType)!
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer.prepareToPlay()
            musicPlayer.play()
            musicPlayer.numberOfLoops = -1
        } catch  {
            // couldn't load file :(
        }
        
    }
    func muteFx(){
        fxPlayer.stop()
    }
    func muteMusic(){
        musicPlayer.stop()
    }
    
    
}

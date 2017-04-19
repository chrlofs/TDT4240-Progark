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
    var fxPlayer: AVAudioPlayer = AVAudioPlayer()
    var musicPlayer: AVAudioPlayer = AVAudioPlayer()
    var fxPlaying = false
    var musicPlaying = false
    static let sharedInstance = soundManager()
    
    func playFx(fileName: String, fileType: String){
        let url = Bundle.main.url(forResource: fileName, withExtension: fileType)!
        do {
            if !fxPlaying{
            fxPlayer = try AVAudioPlayer(contentsOf: url)
            fxPlayer.prepareToPlay()
            fxPlayer.play()
                if fxPlayer.isPlaying{
                    fxPlaying = true
                }
            }
        } catch  {
            // couldn't load file :(
        }
    
    }
    func playMusic(fileName: String, fileType: String){
        let url = Bundle.main.url(forResource: fileName, withExtension: fileType)!
        do {
            if !musicPlaying{
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer.numberOfLoops = -1
            musicPlayer.prepareToPlay()
            musicPlayer.play()
            if musicPlayer.isPlaying{
                    musicPlaying = true
                }
            }
        } catch  {
            // couldn't load file :(
        }
        
    }
    func muteFx(){
        fxPlaying = false
        fxPlayer.stop()
    }
    func muteMusic(){
        musicPlaying = false
        musicPlayer.stop()
    }
    
    
}

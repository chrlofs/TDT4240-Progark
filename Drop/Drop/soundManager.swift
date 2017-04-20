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
    var musicMuted = false
    var fxMuted = false
    
    static let sharedInstance = soundManager()
    
    
    func playFx(fileName: String, fileType: String){
        if !fxMuted{
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
    }
        
    func playMusic(fileName: String, fileType: String){
        if !musicMuted {
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
        
    }
    func stopFx(){
        fxPlaying = false
        fxPlayer.stop()
    }
    func stopMusic(){
        musicPlaying = false
        musicPlayer.stop()
    }
    func muteMusic(){
        if musicPlaying{
        musicPlayer.volume = 0
        musicMuted = true
        }
    }
    func muteFX(){
        if fxPlaying{
        fxPlayer.volume = 0
        fxMuted = true
        }
    }
    func unmuteMusic(){
        if musicPlaying{
        musicPlayer.volume = 1
        musicMuted = false
        }
    }
    func unmuteFX(){
        if musicPlaying{
        fxPlayer.volume = 1
        fxMuted = false
        }}
    
    
    
    
}

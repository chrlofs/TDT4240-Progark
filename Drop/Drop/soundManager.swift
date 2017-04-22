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
    
    //AUDIOPLAYERS
    var fxPlayer: AVAudioPlayer = AVAudioPlayer()
    var musicPlayer: AVAudioPlayer = AVAudioPlayer()

    //FLAGS
    var fxPlaying = false
    var musicPlaying = false
    var musicMuted = false
    var fxMuted = false
    
    //SINGLETON
    static let sharedInstance = soundManager()
    
    
    
    //USE FXPLAYER
    func playFx(fileName: String, fileType: String){
        if !fxMuted{
            let url = Bundle.main.url(forResource: fileName, withExtension: fileType)!
            do {
                fxPlayer = try AVAudioPlayer(contentsOf: url)
                fxPlayer.prepareToPlay()
                fxPlayer.play()
                }
        
            catch  { // couldn't load file :( 
            }
        }
    }
    
    //USE MUSICPLAYER
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
            }
                
            catch  {
                // couldn't load file :(
            }
        }
        
    }
    
    
    //STOP FXPLAYER
    func stopFx(){
        fxPlaying = false
        fxPlayer.stop()
    }
    
    //MUTE FXPLAYER
    func muteFX(){
        if fxPlaying{
        fxPlayer.volume = 0
        fxMuted = true
        }
    }
    
    //UNMUTE FXPLAYER
    func unmuteFX(){
        if fxPlaying{
            fxPlayer.volume = 1
            fxMuted = false
        }
    }
    
    
    //STOP MUSICPLAYER
    func stopMusic(){
        musicPlaying = false
        musicPlayer.stop()
    }
    
    //MUTE MUSICPLAYER
    func muteMusic(){
        if musicPlaying{
            musicPlayer.volume = 0
            musicMuted = true
        }
    }
    
    //UNMUTE MUSICPLAYER
    func unmuteMusic(){
        if musicPlaying{
        musicPlayer.volume = 1
        musicMuted = false
        }
    }
}

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
    
    private let defaults = UserDefaults.standard
    
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
    
    init() {
        musicMuted = defaults.bool(forKey: "musicMuted")
        fxMuted = defaults.bool(forKey: "fxMuted")
        print(fxMuted)
        print(musicMuted)
    }
    
    
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
        fxMuted = true
        defaults.set(true, forKey: "fxMuted")
    }
    
    //UNMUTE FXPLAYER
    func unmuteFX(){
        fxMuted = false
        defaults.set(false, forKey: "fxMuted")
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
            defaults.set(true, forKey: "musicMuted")
        }
    }
    
    //UNMUTE MUSICPLAYER
    func unmuteMusic(){
        if musicPlaying{
            musicPlayer.volume = 1
            musicMuted = false
            defaults.set(false, forKey: "musicMuted")
        }
    }
}

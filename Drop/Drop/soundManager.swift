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
    var player: AVAudioPlayer?
    
    var musicPlayer = AVAudioPlayer()
    func playSound() {
        
    }
    func playFx(fileName: String, fileType: String){
        /*
        let path = Bundle.main.path(forResource: fileName, ofType: fileType, inDirectory: "Sounds")!
        let url = URL(fileURLWithPath: path)
        do {
            let fxPlayer = try AVAudioPlayer(contentsOf: url)
            fxPlayer.volume=1.0
            fxPlayer.prepareToPlay()
            fxPlayer.play()
        } catch {
            print("Error playing")
            // couldn't load file :(
        }
        */
        let url = Bundle.main.url(forResource: "adhku", withExtension: "mp3")!
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    func playMusic(fileName: String, fileType: String){
        let path = Bundle.main.path(forResource: fileName, ofType: fileType, inDirectory: "Sounds")!
        let url = URL(fileURLWithPath: path)
        do {
            let musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer.prepareToPlay()
            musicPlayer.play()
        } catch {
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

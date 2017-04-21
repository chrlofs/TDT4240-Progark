//
//  GameSettings.swift
//  Drop
//
//  Created by Håvard Fagervoll on 20/04/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation

class GameSettings {
    private static let sharedInstance = GameSettings()
    private let defaults = UserDefaults.standard
    
    let gameConstants = GameConstants.getInstance()
    
    private var userName: String
    private var userSkin: Int
    private var loggedIn: Bool
    private var highScore: Int
    
    
    private init(){
        if let userName = defaults.string(forKey: "userName") {
            self.userName = userName
            self.loggedIn = true
        } else {
            self.userName = ""
            self.loggedIn = false
        }
        
        self.userSkin = defaults.integer(forKey: "userSkin")
        self.highScore = defaults.integer(forKey: "highScore")
    }
    
    public static func getInstance() -> GameSettings {
        return sharedInstance
    }
    
    public func getUserName() -> String {
        return self.userName
    }
    
    public func getUserSkin() -> Int {
        return self.userSkin
    }
    
    public func getHighScore() -> Int {
        return self.highScore
    }
    
    public func setUserName(userName: String) {
        self.userName = userName
        self.loggedIn = true
        defaults.set(userName, forKey: "userName")
    }
    
    public func setUserSkin(userSkin: Int) {
        self.userSkin = userSkin
        defaults.set(userSkin, forKey: "userSkin")
    }
    
    public func isHighScore(score: Int) -> Bool {
        if score > self.highScore {
            self.highScore = score
            defaults.set(self.highScore, forKey: "highScore")
            return true
        }
        return false
    }
    
    public func isLoggedIn() -> Bool{
        return self.loggedIn
    }
    
    
    
    
    
    
    
}

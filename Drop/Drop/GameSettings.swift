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
    
    private var userName: String
    private var userSkin: Int
    private var loggedIn: Bool
    
    
    
    private init(){
        if let userName = defaults.string(forKey: "userName") {
            self.userName = userName
            self.loggedIn = true
        } else {
            self.userName = ""
            self.loggedIn = false
        }
        
        self.userSkin = defaults.integer(forKey: "userSkin")
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
    
    public func setUserName(userName: String) {
        self.userName = userName
        self.loggedIn = true
        defaults.set(userName, forKey: "userName")
    }
    
    public func setUserSkin(userSkin: Int) {
        self.userSkin = userSkin
        defaults.set(userSkin, forKey: "userSkin")
    }
    
    public func isLoggedIn() -> Bool{
        return self.loggedIn
    }
    
    
    
    
    
}

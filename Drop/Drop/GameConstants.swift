//
//  GameConstants.swift
//  Drop
//
//  Created by Håvard Fagervoll on 20/04/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation

class GameConstants {
    private static let sharedInstance = GameConstants()
    
    let defaults = UserDefaults.standard
    
    private let skinList: [String] = ["skin1", "skin2", "skin3", "kim", "trump", "putin"]
    private let mapList: [String: [[Int]]] = [
        "Map1": [
            [-144, 200], [0, 200], [144, 200],
            [-72, 90], [72, 90],
            [-144, -20], [0, -20], [144, -20],
            [-144, -200], [144, -200]
        ],
        "Map2": [
            [-144, 200], [0, 200], [144, 200],
            [-72, 90], [72, 90],
            [-144, -20], [0, -20], [144, -20],
        ]
    ]
    private init() {
    }
    
    public static func getInstance() -> GameConstants {
        return sharedInstance
    }
    
    public func getSkinList() -> [String] {
        return self.skinList
    }
    
    public func getMapList() -> [String: [[Int]]] {
        return self.mapList
    }
}

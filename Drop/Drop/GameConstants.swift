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
    
    private let skinList: [String] = ["skin1", "skin2", "skin3", "kim", "trump", "putin"]
    
    private let mapList: [Map] = [
        Map(id: 1, peg_points: [
            [-144, 200], [0, 200], [144, 200],
            [-72, 90], [72, 90],
            [-144, -20], [0, -20], [144, -20],
            [-144, -200], [144, -200]
            ], background: "background_standing3"),
        Map(id: 2, peg_points: [
            [-144, 200], [0, 200], [144, 200],
            [-72, 90], [72, 90],
            [-144, -20], [0, -20], [144, -20],
            ], background: "background_standing3")
    ]
    
    private init() {
    }
    
    public static func getInstance() -> GameConstants {
        return sharedInstance
    }
    
    public func getSkinList() -> [String] {
        return self.skinList
    }
    
    public func getMapList() -> [Map] {
        return self.mapList
    }
    
    public func getMapById(id: Int) -> Map {
        for map in self.mapList {
            if (map.id == id) {
                return map
            }
        }
        return Map(id: 0, peg_points: [[-72, 90], [72, 90]], background: "background_standing3")
    }
}

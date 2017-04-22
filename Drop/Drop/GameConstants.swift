//
//  GameConstants.swift
//  Drop
//
//  Created by Håvard Fagervoll on 20/04/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation
import UIKit

class GameConstants {
    private static let sharedInstance = GameConstants()
    
    private let skinList: [String] = ["skin1", "skin2", "skin3", "kim", "trump", "putin"]
    
    private let mapList: [Map] = [
        Map(id: 0, peg_points: [
            [-144, 200], [0, 200], [144, 200],
            [-72, 90], [72, 90],
            [-144, -20], [0, -20], [144, -20],
            [-144, -200], [144, -200]
            ], background: "background_standing3"),
        Map(id: 1, peg_points: [
            [-144, 200], [0, 200], [144, 200],
            [-72, 90], [72, 90],
            [-144, -20], [0, -20], [144, -20],
            ], background: "background_standing3"),
        Map(id: 2, peg_points: [
            [-80, 300], [-20, 200], [80, 300],
            [-100, 90], [100, 90],
            [-150, -20], [20, -20], [150, -20],
            ], background: "background_standing3")
    ]
    
    public let darkGreen = UIColor(red: 0.27, green: 0.57, blue: 0.53, alpha: 1.0)
    public let lightGreen = UIColor(red: 0.57, green: 0.89, blue: 0.65, alpha: 1.0)
    public let lightBlue = UIColor(red: 0.37, green: 0.39, blue: 0.75, alpha: 1.0)
    public let darkBlue = UIColor(red: 0.27, green: 0.19, blue: 0.39, alpha: 1.0)
    
    
    private init() {
    }
    
    public static func getInstance() -> GameConstants {
        return sharedInstance
    }
    
    public func getSkinList() -> [String] {
        return self.skinList
    }
    
    public func getSkinImage(skinIndex: Int) -> String {
        if skinList.count > skinIndex {
            return skinList[skinIndex]
        } else {
            return skinList[0]
        }
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

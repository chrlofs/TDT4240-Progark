//
//  Map.swift
//  Drop
//
//  Created by Håvard Fagervoll on 21/04/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation

class Map {
    let id: Int
    let name: String
    let pegList: [[Int]]
    let backgroundName: String
    let dropName: String
    let pegName: String
    let pegInactiveName: String
    
    init(id: Int, name: String, pegList: [[Int]], backgroundName: String, dropName: String, pegName: String, pegInactiveName: String) {
        self.id = id
        self.name = name
        self.pegList = pegList
        self.backgroundName = backgroundName
        self.dropName = dropName
        self.pegName = pegName
        self.pegInactiveName = pegInactiveName
    }
    
    func toJSON() -> [String: Any]{
        return ["id": self.id]
    }
}

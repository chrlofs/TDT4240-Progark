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
    let peg_points: [[Int]]
    let background: String
    
    init(id: Int, peg_points: [[Int]], background: String) {
        self.id = id
        self.peg_points = peg_points
        self.background = background
    }
    
    func toJSON() -> [String: Any]{
        return ["id": self.id]
    }
}

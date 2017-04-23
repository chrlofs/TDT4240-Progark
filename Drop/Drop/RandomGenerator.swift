//
//  RandomGenerator.swift
//  Drop
//
//  Created by Raymi Toro Eldby on 23/04/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation
import GameKit

class RandomGenerator {
    
    private let dropSpawnTimeSeed: UInt64
    private let dropSpawnPositionSeed: UInt64
    private let pegIndexSeed: UInt64
    private let pegToggleTimeSeed: UInt64
    
    private let dropSpawnTimeDistribution: GKRandomDistribution
    private let dropSpawnPositionDistribution: GKRandomDistribution
    private let pegIndexDistribution: GKRandomDistribution
    private let pegToggleTimeDistribution: GKRandomDistribution
    
    init(dropSpawnTimeSeed: Int, dropSpawnPositionSeed: Int, pegIndexSeed: Int, pegToggleTimeSeed: Int) {
        self.dropSpawnTimeSeed = UInt64(dropSpawnTimeSeed)
        self.dropSpawnPositionSeed = UInt64(dropSpawnPositionSeed)
        self.pegIndexSeed = UInt64(pegIndexSeed)
        self.pegToggleTimeSeed = UInt64(pegToggleTimeSeed)
        
        dropSpawnTimeDistribution = GKGaussianDistribution(randomSource: GKLinearCongruentialRandomSource(seed: self.dropSpawnTimeSeed), mean: 1000, deviation: 200)
        dropSpawnPositionDistribution = GKRandomDistribution(randomSource: GKLinearCongruentialRandomSource(seed: self.dropSpawnPositionSeed), lowestValue: -190, highestValue: 190)
        pegIndexDistribution = GKRandomDistribution(randomSource: GKLinearCongruentialRandomSource(seed: self.pegIndexSeed), lowestValue: 0, highestValue: 100)
        pegToggleTimeDistribution = GKGaussianDistribution(randomSource: GKLinearCongruentialRandomSource(seed: self.pegToggleTimeSeed), mean: 1000, deviation: 200)
    }
    
    convenience init() {
        self.init(
            dropSpawnTimeSeed: Int(arc4random_uniform(UINT32_MAX)),
            dropSpawnPositionSeed: Int(arc4random_uniform(UINT32_MAX)),
            pegIndexSeed: Int(arc4random_uniform(UINT32_MAX)),
            pegToggleTimeSeed: Int(arc4random_uniform(UINT32_MAX))
        )
    }
    
    func pollDropSpawnTime() -> Int {
        return dropSpawnTimeDistribution.nextInt()
    }
    
    func pollDropSpawnPosition() -> CGPoint {
        let posX = dropSpawnPositionDistribution.nextInt()
        return CGPoint(x: posX, y: 500)
    }
    
    func pollPegIndex(pegCount: Int) -> Int {
        return pegIndexDistribution.nextInt(upperBound: pegCount - 1)
    }
    
    func pollPegToggleTime() -> Int {
        return pegToggleTimeDistribution.nextInt()
    }
    
    func getSeeds() -> (dropSpawnTimeSeed: Int, dropSpawnPositionSeed: Int, pegIndexSeed: Int, pegToggleTimeSeed: Int) {
        return (
            dropSpawnTimeSeed: Int(dropSpawnTimeSeed),
            dropSpawnPositionSeed: Int(dropSpawnPositionSeed),
            pegIndexSeed: Int(pegIndexSeed),
            pegToggleTimeSeed: Int(pegToggleTimeSeed)
        )
    }
}

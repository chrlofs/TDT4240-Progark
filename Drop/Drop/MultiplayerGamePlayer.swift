//
//  MultiplayerGamePlayer.swift
//  Drop
//
//  Created by Raymi Toro Eldby on 21/04/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import SpriteKit

class MultiplayerGamePlayer: SKSpriteNode {
    let peer: PlayerPeer
    
    let VELOCITY: Double = 500
    var dx = 0
    private var minX = CGFloat(-190), maxX = CGFloat(190);
    
    init(peer: PlayerPeer, skinImageName: String) {
        self.peer = peer
        
        let texture = SKTexture(imageNamed: skinImageName)
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        setScale(0.1)
        
        
        physicsBody = SKPhysicsBody(circleOfRadius: size.height / 2);
        physicsBody?.affectedByGravity = false;
        physicsBody?.isDynamic = false;
        physicsBody?.categoryBitMask = ColliderType.PLAYER;
        physicsBody?.contactTestBitMask = ColliderType.FRUIT_AND_BOMB;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(delta: Double) {
        position.x += CGFloat(delta * Double(dx) * VELOCITY)
        
        if position.x < minX{
            position.x = minX;
        }
        if position.x > maxX{
            position.x = maxX;
        }
    }

    func toJSON() -> [String: Any] {
        return [
            "leaderScore": peer.leaderScore,
            "x": position.x,
            "y": position.y
        ]
    }
}

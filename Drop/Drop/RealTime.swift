//
//  RealTime.swift
//  Drop
//
//  Created by Raymi Toro Eldby on 23/04/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import Foundation
import TrueTime

extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}

class RealTime {
    private static let sharedInstance = RealTime()
    private static let truetime = TrueTimeClient.sharedInstance

    private init() {
        RealTime.truetime.start()
    }

    public static func getInstance() -> RealTime {
        return sharedInstance
    }
    
    public func getNow(then callback: @escaping (_ now: Int) -> Void) {
        RealTime.truetime.fetchIfNeeded() { result in
            switch result {
            case let .success(referenceTime):
                let now = referenceTime.now().millisecondsSince1970
                callback(now)
                break
            case let .failure(error):
                print("Couldn't init due to truetime error: \(error)")
                break
            }
        }
    }
    
    public func getNow() -> Int? {
        DispatchQueue.main.async {
            RealTime.truetime.fetchIfNeeded()
        }
        return RealTime.truetime.referenceTime?.now().millisecondsSince1970
    }
}

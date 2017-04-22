//
//  GameSettingsTests.swift
//  Drop
//
//  Created by Håvard Fagervoll on 20/04/2017.
//  Copyright © 2017 Team15. All rights reserved.
//

import XCTest
@testable import Drop

class GameSettingsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testUsernameExist() {
        let gameSettings = GameSettings.getInstance()
        XCTAssertNotNil(gameSettings.getUserName())
    }
}

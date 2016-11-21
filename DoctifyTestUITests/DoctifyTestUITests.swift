//
//  DoctifyTestUITests.swift
//  DoctifyTestUITests
//
//  Created by galmarom on 16/11/2016.
//  Copyright © 2016 galmarom. All rights reserved.
//

import XCTest

class DoctifyTestUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        XCUIApplication().tables.staticTexts["General Practice"].tap()
        let cells = XCUIApplication().tables.cells
        XCTAssertEqual(cells.count, 4, "found instead: \(cells.debugDescription)")
        
        var cellLabel: String = cells.element(boundBy: 0)
            .staticTexts.element(boundBy: 0).label
        XCTAssertEqual(cellLabel,"Name:", "found instead: \(cellLabel)")
        
        cellLabel = cells.element(boundBy: 1)
            .staticTexts.element(boundBy: 0).label
        XCTAssertEqual(cellLabel,"Description:", "found instead: \(cellLabel)")
    }
    
}

//
//  TaskListViewControllerUITests.swift
//  RxTodo
//
//  Created by cruz on 11/12/2016.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import XCTest

class TaskListViewControllerUITests: UITestCase {
    
  func testDefaultSections() {
    let expectCount: UInt = 3
    XCTAssertEqual(app.tables.element.cells.count, expectCount, "it should have 3 tasks as default")
  }
  
  func testTaskAdd() {
    let beforeCount: UInt = app.tables.element.cells.count
    let expectCount = UInt(beforeCount + 1)
    
    XCTAssertTrue(app.navigationBars.buttons["Add"].exists)
    XCTAssertTrue(app.navigationBars.buttons["Add"].isHittable)
    app.navigationBars.buttons["Add"].tap()
    
    app.textFields.element.tap()
    app.textFields.element.typeText("Hello")
    app.navigationBars.buttons["Done"].tap()
    
    XCTAssertEqual(app.tables.element.cells.count, expectCount, "it should add a new task")
  }
  
  func testTaskEdit() {
    let thirdCellTitle = "Make a pull request"
    XCTAssertTrue(app.cells.staticTexts[thirdCellTitle].exists)
    
    let typedText = " thank you :)"
    let expectedText = thirdCellTitle + typedText
    
    app.tables.element.cells.element(boundBy: 2).tap()
    app.textFields.element.tap()
    app.textFields.element.typeText(typedText)
    app.navigationBars.buttons["Done"].tap()
    
    XCTAssertTrue(app.cells.staticTexts[expectedText].exists)
  }
}

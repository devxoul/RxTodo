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
}

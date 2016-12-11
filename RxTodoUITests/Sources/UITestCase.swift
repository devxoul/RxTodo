//
//  RxTodoUITests.swift
//  RxTodoUITests
//
//  Created by cruz on 11/12/2016.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import XCTest

class UITestCase: XCTestCase {
    
  var app: XCUIApplication!
    
  override func setUp() {
    super.setUp()
    app = XCUIApplication()
    continueAfterFailure = false
    app.launch()
  }
    
  override func tearDown() {
    super.tearDown()
  }
}

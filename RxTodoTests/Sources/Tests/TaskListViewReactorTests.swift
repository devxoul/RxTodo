//
//  RxTodoTests.swift
//  RxTodoTests
//
//  Created by Suyeol Jeon on 8/8/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import XCTest
@testable import RxTodo

import RxCocoa
import RxExpect
import RxSwift
import RxTest

class TaskListViewReactorTests: XCTestCase {

  func testFetchTasks() {
    let test = RxExpect()
    let provider = MockServiceProvider()
    let reactor = test.retain(TaskListViewReactor(provider: provider))
    
    // input
    test.input(reactor.action, [next(100, .refresh)])
    
    // assertion
    let taskCount = reactor.state.map { $0.sections.first!.items.count }
    test.assert(taskCount) { events in
      XCTAssertEqual(events, [
        next(0, 0),
        next(100, 3)
      ])
    }
  }

  func testToggleEditing() {
    let test = RxExpect()
    let provider = MockServiceProvider()
    let reactor = test.retain(TaskListViewReactor(provider: provider))
    
    // input
    test.input(reactor.action, [
      next(100, .toggleEditing),
      next(200, .toggleEditing),
    ])
    
    // assertion
    test.assert(reactor.state.map { $0.isEditing }) { events in
      XCTAssertEqual(events, [
        next(0, false),
        next(100, true),
        next(200, false)
      ])
    }
  }

  func testToggleTaskDone() {
    let test = RxExpect()
    let provider = MockServiceProvider()
    let reactor = test.retain(TaskListViewReactor(provider: provider))
    
    // input
    test.input(reactor.action, [
      next(100, .refresh), // prepare seed data
      next(200, .toggleTaskDone(IndexPath(item: 0, section: 0))),
      next(300, .toggleTaskDone(IndexPath(item: 0, section: 0))),
      next(400, .toggleTaskDone(IndexPath(item: 2, section: 0))),
    ])
    
    // assert
    let isDones = reactor.state.map { state in
        return state.sections[0].items.map { cellReactor in
            return cellReactor.currentState.isDone
        }
    }
    test.assert(isDones) { events in
      XCTAssertEqual(events, [
        next(0, []),
        next(100, [false, false, false]),
        next(200, [true, false, false]),
        next(300, [false, false, false]),
        next(400, [false, false, true])
      ])
    }
  }

  func testDeleteTask() {
    let test = RxExpect()
    let provider = MockServiceProvider()
    let reactor = test.retain(TaskListViewReactor(provider: provider))
    
    // input
    test.input(reactor.action, [
      next(100, .refresh), // prepare seed data
      next(200, .deleteTask(IndexPath(item: 0, section: 0))),
    ])
    
    // assert
    let itemCount = reactor.state.map { $0.sections[0].items.count }
    test.assert(itemCount) { events in
      XCTAssertEqual(events, [
        next(0, 0),
        next(100, 3),
        next(200, 2)
      ])
    }
  }
}

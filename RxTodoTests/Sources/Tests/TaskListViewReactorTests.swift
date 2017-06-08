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
    RxExpect("it should fetch saved tasks") { test in
      let provider = MockServiceProvider()
      let reactor = test.retain(TaskListViewReactor(provider: provider))

      // input
      test.input(reactor.action, [next(100, .refresh)])

      // assertion
      let taskCount = reactor.state.map { $0.sections.first!.items.count }
      test.assert(taskCount)
        .since(100)
        .filterNext()
        .equal([3])
    }
  }

  func testToggleEditing() {
    RxExpect("it should toggle isEditing") { test in
      let provider = MockServiceProvider()
      let reactor = test.retain(TaskListViewReactor(provider: provider))

      // input
      test.input(reactor.action, [
        next(100, .toggleEditing),
        next(200, .toggleEditing),
      ])

      // assertion
      test.assert(reactor.state.map { $0.isEditing })
        .filterNext()
        .equal([
          false, // initial value
          true,  // toggle value
          false, // toggle value
        ])
    }
  }

  func testToggleTaskDone() {
    RxExpect("it should toggle isDone of task") { test in
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
      test.assert(isDones)
        .since(100)
        .filterNext()
        .equal([
          [false, false, false], // initial
          [true,  false, false], // toggle [0]
          [false, false, false], // toggle [0]
          [false, false, true ], // toggle [2]
        ])
    }
  }

  func testDeleteTask() {
    RxExpect("it should delete task") { test in
      let provider = MockServiceProvider()
      let reactor = test.retain(TaskListViewReactor(provider: provider))

      // input
      test.input(reactor.action, [
        next(100, .refresh), // prepare seed data
        next(200, .deleteTask(IndexPath(item: 0, section: 0))),
      ])

      // assert
      let itemCount = reactor.state.map { $0.sections[0].items.count }
      test.assert(itemCount)
        .since(100)
        .filterNext()
        .equal([
          3, // initial
          2, // after delete
        ])
    }
  }
}

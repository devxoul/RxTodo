//
//  TaskEditViewReactorTests.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 8/23/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import XCTest
@testable import RxTodo

import RxCocoa
import RxExpect
import RxOptional
import RxSwift
import RxTest

class TaskEditViewReactorTests: XCTestCase {

  func testTitle() {
    RxExpect("it should use 'New' title when the editor mode is .new") { test in
      let provider = MockServiceProvider()
      let reactor = test.retain(TaskEditViewReactor(provider: provider, mode: .new))
      test.assert(reactor.state.map { $0.title })
        .filterNext()
        .equal(["New"])
    }

    RxExpect("it should use 'Edit' title when the editor mode is .edit") { test in
      let provider = MockServiceProvider()
      let task = Task(title: "Test")
      let reactor = TaskEditViewReactor(provider: provider, mode: .edit(task))
      test.assert(reactor.state.map { $0.title })
        .filterNext()
        .equal(["Edit"])
    }
  }

  func testTaskTitle() {
    RxExpect("it should update taskTitle") { test in
      let provider = MockServiceProvider()
      let reactor = test.retain(TaskEditViewReactor(provider: provider, mode: .new))

      // input
      test.input(reactor.action, [
        next(100, .updateTaskTitle("a")),
        next(200, .updateTaskTitle("ab")),
        next(300, .updateTaskTitle("")),
      ])

      // output
      test.assert(reactor.state.map { $0.taskTitle })
        .since(100)
        .filterNext()
        .equal([
          "a",
          "ab",
          "",
        ])
    }
  }

  func testCanSubmit() {
    RxExpect("it should adjust canSubmit when the editor mode is .new") { test in
      let provider = MockServiceProvider()
      let reactor = test.retain(TaskEditViewReactor(provider: provider, mode: .new))

      // input
      test.input(reactor.action, [
        next(100, .updateTaskTitle("a")),
        next(200, .updateTaskTitle("")),
      ])

      // assert
      test.assert(reactor.state.map { $0.canSubmit })
        .filterNext()
        .equal([
          false, // initial
          true,  // "a"
          false, // ""
        ])
    }

    RxExpect("it should adjust canSubmit when the editor mode is .edit") { test in
      let provider = MockServiceProvider()
      let task = Task(title: "Test")
      let reactor = test.retain(TaskEditViewReactor(provider: provider, mode: .edit(task)))

      // input
      test.input(reactor.action, [
        next(100, .updateTaskTitle("a")),
        next(200, .updateTaskTitle("")),
      ])

      // assert
      test.assert(reactor.state.map { $0.canSubmit })
        .filterNext()
        .equal([
          true,  // initial
          true,  // "a"
          false, // ""
        ])
    }
  }

  func testShouldComfirmCancel() {
    RxExpect("it should confirm cancel when the editor mode is .new") { test in
      let provider = MockServiceProvider()
      let reactor = test.retain(TaskEditViewReactor(provider: provider, mode: .new))

      // input
      test.input(reactor.action, [
        next(100, .updateTaskTitle("a")),
        next(200, .updateTaskTitle("")),
      ])

      // assert
      test.assert(reactor.state.map { $0.shouldConfirmCancel })
        .filterNext()
        .equal([
          false, // initial
          true,  // "a"
          false, // ""
        ])
    }

    RxExpect("it should confirm cancel when the editor mode is .edit") { test in
      let provider = MockServiceProvider()
      let task = Task(title: "TEST")
      let reactor = test.retain(TaskEditViewReactor(provider: provider, mode: .edit(task)))

      // input
      test.input(reactor.action, [
        next(100, .updateTaskTitle("a")),
        next(200, .updateTaskTitle("")),
        next(300, .updateTaskTitle("TEST")),
      ])

      // assert
      test.assert(reactor.state.map { $0.shouldConfirmCancel })
        .filterNext()
        .equal([
          false, // initial
          true,  // "a"
          true,  // ""
          false, // "TEST"
        ])
    }
  }

  func testIsDismissed() {
    RxExpect("it should dismiss on cancel") { test in
      let provider = MockServiceProvider()
      let reactor = test.retain(TaskEditViewReactor(provider: provider, mode: .new))

      // input
      test.input(reactor.action, [
        next(100, .cancel),
      ])

      // assert
      test.assert(reactor.state.map { $0.isDismissed }.distinctUntilChanged())
        .filterNext()
        .equal([
          false, // initial
          true,  // cancel
        ])
    }

    RxExpect("it should dismiss when select leave on cancel alert") { test in
      let provider = MockServiceProvider()
      provider.alertService = MockAlertService(provider: provider).then {
        $0.selectAction = TaskEditViewCancelAlertAction.leave
      }
      let reactor = test.retain(TaskEditViewReactor(provider: provider, mode: .new))

      // input
      test.input(reactor.action, [
        next(100, .updateTaskTitle("a")),
        next(200, .cancel),
      ])

      // assert
      test.assert(reactor.state.map { $0.isDismissed }.distinctUntilChanged())
        .filterNext()
        .equal([
          false, // initial
          true,  // cancel
        ])
    }

    RxExpect("it should dismiss on submit") { test in
      let provider = MockServiceProvider()
      let reactor = test.retain(TaskEditViewReactor(provider: provider, mode: .new))

      // input
      test.input(reactor.action, [
        next(100, .updateTaskTitle("a")),
        next(200, .submit),
      ])

      // assert
      test.assert(reactor.state.map { $0.isDismissed }.distinctUntilChanged())
        .filterNext()
        .equal([
          false, // initial
          true,  // submit
        ])
    }
  }

}

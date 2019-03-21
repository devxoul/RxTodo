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
    // it should use 'New' title when the editor mode is .new
    let testNewTitle = RxExpect()
    let providerNewTitle = MockServiceProvider()
    let reactorNewTitle = testNewTitle.retain(TaskEditViewReactor(provider: providerNewTitle, mode: .new))
    testNewTitle.assert(reactorNewTitle.state.map { $0.title }) { events in
      XCTAssertEqual(events.elements, ["New"])
    }

    // it should use 'Edit' title when the editor mode is .edit
    let testEditTitle = RxExpect()
    let providerEditTitle = MockServiceProvider()
    let task = Task(title: "Test")
    let reactorEditTitle = testEditTitle.retain(TaskEditViewReactor(provider: providerEditTitle, mode: .edit(task)))
    testEditTitle.assert(reactorEditTitle.state.map { $0.title }) { events in
      XCTAssertEqual(events.elements, ["Edit"])
    }
  }

  func testTaskTitle() {
    let test = RxExpect()
    let provider = MockServiceProvider()
    let reactor = test.retain(TaskEditViewReactor(provider: provider, mode: .new))
    
    // input
    test.input(reactor.action, [
      next(100, .updateTaskTitle("a")),
      next(200, .updateTaskTitle("ab")),
      next(300, .updateTaskTitle("")),
    ])
    
    // output
    test.assert(reactor.state.map { $0.taskTitle }) { events in
      XCTAssertEqual(events, [
        next(0, ""),
        next(100, "a"),
        next(200, "ab"),
        next(300, "")
      ])
    }
  }

  func testCanSubmit() {
    // it should adjust canSubmit when the editor mode is .new
    let testEditorModeNew = RxExpect()
    let providerEditorModeNew = MockServiceProvider()
    let reactorEditorModeNew = testEditorModeNew.retain(TaskEditViewReactor(provider: providerEditorModeNew, mode: .new))
    
    // input
    testEditorModeNew.input(reactorEditorModeNew.action, [
      next(100, .updateTaskTitle("a")),
      next(200, .updateTaskTitle("")),
    ])
    
    // assert
    testEditorModeNew.assert(reactorEditorModeNew.state.map { $0.canSubmit }) { events in
      XCTAssertEqual(events, [
        next(0, false),
        next(100, true),
        next(200, false)
      ])
    }
    
    // it should adjust canSubmit when the editor mode is .edit
    let testEditorModeEdit = RxExpect()
    let providerEditorModeEdit = MockServiceProvider()
    let task = Task(title: "Test")
    let reactorEditorModeEdit = testEditorModeEdit.retain(TaskEditViewReactor(provider: providerEditorModeEdit, mode: .edit(task)))
    
    // input
    testEditorModeEdit.input(reactorEditorModeEdit.action, [
      next(100, .updateTaskTitle("a")),
      next(200, .updateTaskTitle("")),
    ])
    
    // assert
    testEditorModeEdit.assert(reactorEditorModeEdit.state.map { $0.canSubmit }) { events in
      XCTAssertEqual(events, [
        next(0, true),
        next(100, true),
        next(200, false)
      ])
    }
  }

  func testShouldComfirmCancel() {
    // it should confirm cancel when the editor mode is .new
    let testEditorModeNew = RxExpect()
    let providerEditorModeNew = MockServiceProvider()
    let reactorEditorModeNew = testEditorModeNew.retain(TaskEditViewReactor(provider: providerEditorModeNew, mode: .new))
    
    // input
    testEditorModeNew.input(reactorEditorModeNew.action, [
      next(100, .updateTaskTitle("a")),
      next(200, .updateTaskTitle("")),
    ])
    
    // assert
    testEditorModeNew.assert(reactorEditorModeNew.state.map { $0.shouldConfirmCancel }) { events in
      XCTAssertEqual(events, [
        next(0, false),
        next(100, true),
        next(200, false)
      ])
    }

    // it should confirm cancel when the editor mode is .edit
    let testEditorModeEdit = RxExpect()
    let providerEditorModeEdit = MockServiceProvider()
    let task = Task(title: "TEST")
    let reactorEditorModeEdit = testEditorModeEdit.retain(TaskEditViewReactor(provider: providerEditorModeEdit, mode: .edit(task)))
    
    // input
    testEditorModeEdit.input(reactorEditorModeEdit.action, [
      next(100, .updateTaskTitle("a")),
      next(200, .updateTaskTitle("")),
      next(300, .updateTaskTitle("TEST")),
    ])
    
    // assert
    testEditorModeEdit.assert(reactorEditorModeEdit.state.map { $0.shouldConfirmCancel }) { events in
      XCTAssertEqual(events, [
        next(0, false),
        next(100, true),
        next(200, true),
        next(300, false)
      ])
    }
  }

  func testIsDismissed() {
    // it should dismiss on cancel
    let testCancel = RxExpect()
    let providerCancel = MockServiceProvider()
    let reactorCancel = testCancel.retain(TaskEditViewReactor(provider: providerCancel, mode: .new))
    
    // input
    testCancel.input(reactorCancel.action, [
      next(100, .cancel),
    ])
    
    // assert
    testCancel.assert(reactorCancel.state.map { $0.isDismissed }.distinctUntilChanged()) { events in
      XCTAssertEqual(events, [
        next(0, false),
        next(100, true)
      ])
    }

    // it should dismiss when select leave on cancel alert
    let testLeaveCancel = RxExpect()
    let providerLeaveCancel = MockServiceProvider()
    providerLeaveCancel.alertService = MockAlertService(provider: providerLeaveCancel).then {
        $0.selectAction = TaskEditViewCancelAlertAction.leave
    }
    let reactorLeaveCancel = testLeaveCancel.retain(TaskEditViewReactor(provider: providerLeaveCancel, mode: .new))
    
    // input
    testLeaveCancel.input(reactorLeaveCancel.action, [
      next(100, .updateTaskTitle("a")),
      next(200, .cancel),
    ])
    
    // assert
    testLeaveCancel.assert(reactorLeaveCancel.state.map { $0.isDismissed }.distinctUntilChanged()) { events in
      XCTAssertEqual(events, [
        next(0, false),
        next(200, true) // no event when time at 100, due to distinctUntilChanged()
      ])
    }

    // it should dismiss on submit
    let testSubmit = RxExpect()
    let providerSubmit = MockServiceProvider()
    let reactorSubmit = testSubmit.retain(TaskEditViewReactor(provider: providerSubmit, mode: .new))
    
    // input
    testSubmit.input(reactorSubmit.action, [
      next(100, .updateTaskTitle("a")),
      next(200, .submit),
    ])
    
    // assert
    testSubmit.assert(reactorSubmit.state.map { $0.isDismissed }.distinctUntilChanged()) { events in
      XCTAssertEqual(events, [
        next(0, false),
        next(200, true) // no event when time at 100, due to distinctUntilChanged()
      ])
    }
  }

}

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
      let reactor = TaskListViewReactor(provider: provider)

      // input
      test.input(reactor.action, [next(100, TaskListViewReactor.Action.refresh())])

      // assertion
      let taskCount = reactor.state.map { $0.sections.first!.items.count }
      test.assert(taskCount)
        .since(100)
        .filterNext()
        .equal([3])
    }
  }
/*
  func testFetchTasks() {
    RxExpect("it should fetch saved tasks") { test in
      let provider = MockServiceProvider()
      let reactor = TaskListViewReactor(provider: provider)

      // input
      test.input(reactor.viewDidLoad, [next(100, Void())])

      // assertion
      let taskCount = reactor.sections.map { $0.first!.items.count }
      test.assert(taskCount)
        .filterNext()
        .equal([3])
    }
  }

  func testSections() {
    RxExpect("it should add a new task at the top when receive TaskEvent.create") { test in
      let provider = MockServiceProvider()
      let reactor = TaskListViewReactor(provider: provider)

      let newTask = Task(title: "Hello")
      test.input(provider.taskService.event, [next(100, .create(newTask))])

      let firstItemTitle = reactor.sections.map { $0.first!.items.first!.title }
      test.assert(firstItemTitle)
        .filterNext()
        .equal(["Hello"])
    }

    RxExpect("it should update a task when receive TaskEvent.update") { test in
      let provider = MockServiceProvider()
      let reactor = TaskListViewReactor(provider: provider)

      // prepare test data
      var task = Task(title: "Hello")
      test.input(provider.taskService.event, [next(100, .create(task))])

      // update the task and input create event
      task.title = "Hello, world!"
      test.input(provider.taskService.event, [next(200, .create(task))])

      let firstItemTitle = reactor.sections.map { $0.first!.items.first!.title }
      test.assert(firstItemTitle)
        .filterNext()
        .since(200)
        .equal(["Hello, world!"])
    }

    RxExpect("it should delete a task when delete item") { test in
      let provider = MockServiceProvider()
      let reactor = TaskListViewReactor(provider: provider)

      // prepare test data
      let task = Task(title: "Hello")
      test.input(provider.taskService.event, [next(100, .create(task))])

      // input
      test.input(reactor.itemDidDelete, [next(200, IndexPath(row: 0, section: 0))])

      let count = reactor.sections.map { $0.first!.items.count }
      test.assert(count)
        .filterNext()
        .since(200)
        .equal([0])
    }

    RxExpect("it should move a task when move item") { test in
      let provider = MockServiceProvider()
      let reactor = TaskListViewReactor(provider: provider)

      // prepare test data
      let task1 = Task(title: "Hello1")
      let task2 = Task(title: "Hello2")
      test.input(provider.taskService.event, [next(100, .create(task1))])
      test.input(provider.taskService.event, [next(200, .create(task2))])

      // input
      let moveEvent = (
        sourceIndex: IndexPath(row: 0, section: 0),
        destinationIndex: IndexPath(row: 1, section: 0)
      )
      test.input(reactor.itemDidMove, [next(300, moveEvent)])

      let count = reactor.sections.map { $0.first!.items.first!.title }
      test.assert(count)
        .filterNext()
        .since(200)
        .equal([task2.title, task1.title])
    }

    RxExpect("it should mark the task as done when select undone item") { test in
      let provider = MockServiceProvider()
      let reactor = TaskListViewReactor(provider: provider)

      // provider test data
      let task = Task(title: "Hello")
      test.input(provider.taskService.event, [next(100, .create(task))])

      // input markDone event
      test.input(reactor.itemDidSelect, [next(200, IndexPath(row: 0, section: 0))])

      let firstItemAccessoryType = reactor.sections.map { $0.first!.items.first!.accessoryType }
      test.assert(firstItemAccessoryType)
        .filterNext()
        .since(200)
        .equal([.checkmark])
    }

    RxExpect("it should mark the task as not done when select done item") { test in
      let provider = MockServiceProvider()
      let reactor = TaskListViewReactor(provider: provider)

      // provider test data
      let task = Task(title: "Hello")
      test.input(provider.taskService.event, [next(100, .create(task))])
      test.input(provider.taskService.event, [next(200, .markDone(id: task.id))])

      // input markDone event
      test.input(reactor.itemDidSelect, [next(300, IndexPath(row: 0, section: 0))])

      let firstItemAccessoryType = reactor.sections.map { $0.first!.items.first!.accessoryType }
      test.assert(firstItemAccessoryType)
        .filterNext()
        .since(300)
        .equal([.none])
    }
  }

  func testPresentEditViewController() {
    RxExpect("it should present edit view controller when tap add button") { test in
      let provider = MockServiceProvider()
      let reactor = TaskListViewReactor(provider: provider)

      // prepare test data
      let task = Task(title: "Hello")
      test.input(provider.taskService.event, [next(100, .create(task))])

      // input
      test.input(reactor.addButtonItemDidTap, [next(200, Void())])

      // assertion
      let isPresented = reactor.presentTaskEditViewReactor.map { _ in true }
      test.assert(isPresented)
        .filterNext()
        .since(200)
        .equal([true])
    }

    RxExpect("it should present edit view controller when select item") { test in
      let provider = MockServiceProvider()
      let reactor = TaskListViewReactor(provider: provider)

      // prepare test data
      let task = Task(title: "Hello")
      test.input(provider.taskService.event, [next(100, .create(task))])
      test.input(reactor.editButtonItemDidTap, [next(200, Void())])

      // input
      test.input(reactor.itemDidSelect, [next(300, IndexPath(row: 0, section: 0))])

      // assertion
      let isPresented = reactor.presentTaskEditViewReactor.map { _ in true }
      test.assert(isPresented)
        .filterNext()
        .since(300)
        .equal([true])
    }
  }
*/
}

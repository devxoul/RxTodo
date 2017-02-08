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

class TaskListViewModelTests: XCTestCase {

  func setupTest() -> (MockServiceProvider, MockTaskListViewModelInputs, TaskListViewModelOutputs) {
    let provider = MockServiceProvider()
    let inputs = MockTaskListViewModelInputs()
    let viewModel = createTaskListViewModel(provider: provider)
    let outputs = viewModel(inputs.asInputs())
    return (provider, inputs, outputs)
  }

  func testFetchTasks() {
    RxExpect("it should fetch saved tasks") { test in
      let (_, inputs, outputs) = self.setupTest()
      // input
      test.input(inputs.viewDidLoad, [next(100, Void())])

      // assertion
      let taskCount = outputs.sections.map { $0.first!.items.count }
      test.assert(taskCount)
        .filterNext()
        .equal([3])
    }
  }

  func testSections() {
    RxExpect("it should add a new task at the top when receive TaskEvent.create") { test in
      let (provider, _, outputs) = self.setupTest()
      let newTask = Task(title: "Hello")
      test.input(provider.taskService.event, [next(100, .create(newTask))])

      let firstItemTitle = outputs.sections.map { $0.first!.items.first!.title }
      test.assert(firstItemTitle)
        .filterNext()
        .equal(["Hello"])
    }

    RxExpect("it should update a task when receive TaskEvent.update") { test in
      let (provider, _, outputs) = self.setupTest()
      // prepare test data
      var task = Task(title: "Hello")
      test.input(provider.taskService.event, [next(100, .create(task))])

      // update the task and input create event
      task.title = "Hello, world!"
      test.input(provider.taskService.event, [next(200, .create(task))])

      let firstItemTitle = outputs.sections.map { $0.first!.items.first!.title }
      test.assert(firstItemTitle)
        .filterNext()
        .since(200)
        .equal(["Hello, world!"])
    }

    RxExpect("it should delete a task when delete item") { test in
      let (provider, inputs, outputs) = self.setupTest()
      // prepare test data
      let task = Task(title: "Hello")
      test.input(provider.taskService.event, [next(100, .create(task))])

      // input
      test.input(inputs.itemDidDelete, [next(200, IndexPath(row: 0, section: 0))])

      let count = outputs.sections.map { $0.first!.items.count }
      test.assert(count)
        .filterNext()
        .since(200)
        .equal([0])
    }

    RxExpect("it should move a task when move item") { test in
      let (provider, inputs, outputs) = self.setupTest()
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
      test.input(inputs.itemDidMove, [next(300, moveEvent)])

      let count = outputs.sections.map { $0.first!.items.first!.title }
      test.assert(count)
        .filterNext()
        .since(200)
        .equal([task2.title, task1.title])
    }

    RxExpect("it should mark the task as done when select undone item") { test in
      let (provider, inputs, outputs) = self.setupTest()
      // provider test data
      let task = Task(title: "Hello")
      test.input(provider.taskService.event, [next(100, .create(task))])

      // input markDone event
      test.input(inputs.itemDidSelect, [next(200, IndexPath(row: 0, section: 0))])

      let firstItemAccessoryType = outputs.sections.map { $0.first!.items.first!.accessoryType }
      test.assert(firstItemAccessoryType)
        .filterNext()
        .since(200)
        .equal([.checkmark])
    }

    RxExpect("it should mark the task as not done when select done item") { test in
      let (provider, inputs, outputs) = self.setupTest()
      // provider test data
      let task = Task(title: "Hello")
      test.input(provider.taskService.event, [next(100, .create(task))])
      test.input(provider.taskService.event, [next(200, .markDone(id: task.id))])

      // input markDone event
      test.input(inputs.itemDidSelect, [next(300, IndexPath(row: 0, section: 0))])

      let firstItemAccessoryType = outputs.sections.map { $0.first!.items.first!.accessoryType }
      test.assert(firstItemAccessoryType)
        .filterNext()
        .since(300)
        .equal([.none])
    }
  }

  func testPresentEditViewController() {
    RxExpect("it should present edit view controller when tap add button") { test in
      let (provider, inputs, outputs) = self.setupTest()
      // prepare test data
      let task = Task(title: "Hello")
      test.input(provider.taskService.event, [next(100, .create(task))])

      // input
      test.input(inputs.addButtonItemDidTap, [next(200, Void())])

      // assertion
      let isPresented = outputs.presentTaskEditViewModel.map { _ in true }
      test.assert(isPresented)
        .filterNext()
        .since(200)
        .equal([true])
    }

    RxExpect("it should present edit view controller when select item") { test in
      let (provider, inputs, outputs) = self.setupTest()
      // prepare test data
      let task = Task(title: "Hello")
      test.input(provider.taskService.event, [next(100, .create(task))])
      test.input(inputs.editButtonItemDidTap, [next(200, Void())])

      // input
      test.input(inputs.itemDidSelect, [next(300, IndexPath(row: 0, section: 0))])

      // assertion
      let isPresented = outputs.presentTaskEditViewModel.map { _ in true }
      test.assert(isPresented)
        .filterNext()
        .since(300)
        .equal([true])
    }
  }

}

//
//  TaskEditViewModelTests.swift
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

class TaskEditViewModelTests: XCTestCase {

  func testNavigationBarTitle() {
    RxExpect { test in
      let provider = MockServiceProvider()
      let viewModel = TaskEditViewModel(provider: provider, mode: .new)
      test.assert(viewModel.navigationBarTitle.map { $0! })
        .filterNext()
        .equal(["New"])
    }

    RxExpect { test in
      let task = Task(title: "Hello")
      let provider = MockServiceProvider()
      let viewModel = TaskEditViewModel(provider: provider, mode: .edit(task))
      test.assert(viewModel.navigationBarTitle.map { $0! })
        .filterNext()
        .equal(["Edit"])
    }
  }

  func testDoneButtonEnabled() {
    RxExpect { test in
      let provider = MockServiceProvider()
      let viewModel = TaskEditViewModel(provider: provider, mode: .new)
      test.input(viewModel.titleInputDidChangeText, [
        next(100, "A"),
        next(200, "AB"),
        next(300, ""),
      ])
      test.assert(viewModel.doneButtonEnabled)
        .filterNext()
        .since(100)
        .equal([true, false])
    }
  }

  func testPresentCancelAlert_new() {
    RxExpect("it should not present cancel alert when title is empty") { test in
      let provider = MockServiceProvider()
      let viewModel = TaskEditViewModel(provider: provider, mode: .new)
      test.input(viewModel.cancelButtonItemDidTap, [next(100)])
      test.assert(viewModel.presentCancelAlert)
        .filterNext()
        .isEmpty()
    }

    RxExpect("it should present cancel alert when title is not empty") { test in
      let provider = MockServiceProvider()
      let viewModel = TaskEditViewModel(provider: provider, mode: .new)
      test.input(viewModel.titleInputDidChangeText, [next(100, "A")])
      test.input(viewModel.cancelButtonItemDidTap, [next(200)])
      test.assert(viewModel.presentCancelAlert)
        .filterNext()
        .isNotEmpty()
    }
  }

  func testPresentCancelAlert_edit() {
    let task = Task(title: "Clean my room")

    RxExpect("it should not present cancel alert when title is not changed") { test in
      let provider = MockServiceProvider()
      let viewModel = TaskEditViewModel(provider: provider, mode: .edit(task))
      test.input(viewModel.cancelButtonItemDidTap, [next(200)])
      test.assert(viewModel.presentCancelAlert)
        .filterNext()
        .isEmpty()
    }

    RxExpect("it should present cancel alert when title is changed") { test in
      let provider = MockServiceProvider()
      let viewModel = TaskEditViewModel(provider: provider, mode: .edit(task))
      test.input(viewModel.titleInputDidChangeText, [next(100, "New Title")])
      test.input(viewModel.cancelButtonItemDidTap, [next(200)])
      test.assert(viewModel.presentCancelAlert)
        .filterNext()
        .isNotEmpty()
    }
  }

  func testDismissViewController_cancel() {
    RxExpect("it should not dismiss view controller on tapping cancel button when title is changed") { test in
      let provider = MockServiceProvider()
      let viewModel = TaskEditViewModel(provider: provider, mode: .new)
      test.input(viewModel.titleInputDidChangeText, [next(100, "A")])
      test.input(viewModel.cancelButtonItemDidTap, [next(200)])
      test.assert(viewModel.dismissViewController)
        .filterNext()
        .isEmpty()
    }

    RxExpect("it should dismiss view controller on tapping cancel button when title is not changed") { test in
      let provider = MockServiceProvider()
      let viewModel = TaskEditViewModel(provider: provider, mode: .new)
      test.input(viewModel.cancelButtonItemDidTap, [next(200)])
      test.assert(viewModel.dismissViewController)
        .filterNext()
        .isNotEmpty()
    }
  }

  func testDismissViewController_leave() {
    RxExpect("it should dismiss view controller on tapping leave button") { test in
      let provider = MockServiceProvider()
      let viewModel = TaskEditViewModel(provider: provider, mode: .new)
      test.input(viewModel.cancelAlertDidSelectAction, [next(100, .leave)])
      test.assert(viewModel.dismissViewController)
        .filterNext()
        .isNotEmpty()
    }
  }

  func testDismissViewController_done() {
    RxExpect("it should not dismiss view controller on tapping done button when title is empty") { test in
      let provider = MockServiceProvider()
      let viewModel = TaskEditViewModel(provider: provider, mode: .new)
      test.input(viewModel.doneButtonItemDidTap, [next(100)])
      test.assert(viewModel.dismissViewController)
        .filterNext()
        .isEmpty()
    }

    RxExpect("it should dismiss view controller on tapping done button when title is not empty") { test in
      let provider = MockServiceProvider()
      let viewModel = TaskEditViewModel(provider: provider, mode: .new)
      test.input(viewModel.titleInputDidChangeText, [next(100, "A")])
      test.input(viewModel.doneButtonItemDidTap, [next(200)])
      test.assert(viewModel.dismissViewController)
        .filterNext()
        .isNotEmpty()
    }
  }

  func testTaskEvent() {
    RxExpect("it should emit TaskEvent.create when done editing") { test in
      let provider = MockServiceProvider()
      let viewModel = TaskEditViewModel(provider: provider, mode: .new)
      test.input(viewModel.titleInputDidChangeText, [next(100, "A")])
      test.input(viewModel.doneButtonItemDidTap, [next(200)])

      let taskTitleFromCreateEvent = provider.taskService.event
        .flatMap { event -> Observable<String> in
          if case .create(let task) = event {
            return .just(task.title)
          } else {
            return .empty()
          }
        }
      test.assert(taskTitleFromCreateEvent)
        .filterNext()
        .equal(["A"])
    }

    RxExpect("it should emit TaskEvent.update when done editing") { test in
      let provider = MockServiceProvider()
      let task = Task(title: "Clean my room")
      let viewModel = TaskEditViewModel(provider: provider, mode: .edit(task))
      test.input(viewModel.titleInputDidChangeText, [next(100, "Hi")])
      test.input(viewModel.doneButtonItemDidTap, [next(200)])

      let taskTitleFromUpdateEvent = provider.taskService.event
        .flatMap { event -> Observable<String> in
          if case .update(let task) = event {
            return .just(task.title)
          } else {
            return .empty()
          }
        }
      test.assert(taskTitleFromUpdateEvent)
        .filterNext()
        .equal(["Hi"])
    }
  }

}

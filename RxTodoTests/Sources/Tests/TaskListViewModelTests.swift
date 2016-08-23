//
//  RxTodoTests.swift
//  RxTodoTests
//
//  Created by Suyeol Jeon on 8/8/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import XCTest
@testable import RxTodo

import RxExpect
import RxCocoa
import RxSwift
import RxTests

class TaskListViewModelTests: XCTestCase {

    func testSections() {
        RxExpect("it should have only one section") { test in
            let viewModel = TaskListViewModel()
            let sectionCount = viewModel.sections.map { $0.count }
            test.assertNextEqual(sectionCount, [1])
        }

        RxExpect("it should have 3 tasks as default") { test in
            let viewModel = TaskListViewModel()
            let itemCount = viewModel.sections.map { $0.first!.items.count }
            test.assertNextEqual(itemCount, [3])
        }
    }

    func testTaskAdd() {
        RxExpect("it should add a new task at the top") { test in
            let viewModel = TaskListViewModel()
            let newTask = Task(title: "Hello")
            test.input(Task.didCreate, [next(100, newTask)])

            let firstItemTitle = viewModel.sections
                .map { $0.first!.items.first!.title }
                .skip(1) // skip initial value
            test.assertNextEqual(firstItemTitle, ["Hello"])
        }
    }

    func testTaskUpdate() {
        RxExpect("it should update a task") { test in
            let viewModel = TaskListViewModel()

            // we will test whether this task is updated
            var task = Task(title: "Hello")
            test.input(Task.didCreate, [next(100, task)])

            // update the task and input didUpdate event
            task.title = "Hello, world!"
            test.input(Task.didUpdate, [next(200, task)])

            let firstItemTitle = viewModel.sections
                .map { $0.first!.items.first!.title }
                .skip(2) // skip initial value and didCreate input
            test.assertNextEqual(firstItemTitle, ["Hello, world!"])
        }
    }

    func testTaskDelete() {
        RxExpect("it should delete a task when item deleted") { test in
            let viewModel = TaskListViewModel()

            // we will test whether this task is deleted
            let task = Task(title: "Hello")
            test.input(Task.didCreate, [next(100, task)])

            // input didDelete evenet
            test.input(Task.didDelete, [next(200, task)])

            let firstItemTitle = viewModel.sections
                .map { $0.first!.items.first!.title }
                .skip(2) // skip initial value and didCreate input
            test.assertNextNotEqual(firstItemTitle, ["Hello"])
        }
    }

    func testTaskDidDelete() {
        RxExpect("it should fire Task.didDelete event when user deletes item") { test in
            let viewModel = TaskListViewModel()

            // we will test whether this task is deleted
            let task = Task(title: "Hello")
            test.input(Task.didCreate, [next(100, task)])

            // when user deletes item...
            test.input(viewModel.itemDeleted, [next(200, NSIndexPath(forRow: 0, inSection: 0))])

            let deletedTaskTitle = Task.didDelete.map { $0.title }
            test.assertNextEqual(deletedTaskTitle, ["Hello"])
        }
    }

    func testPresentEditViewController() {
        RxExpect("it should present edit view controller when add button tapped") { test in
            let viewModel = TaskListViewModel()
            test.input(viewModel.addButtonDidTap, [
                next(100, Void()),
            ])
            let presented = viewModel.presentTaskEditViewModel.map { _ in true }
            test.assertNextEqual(presented, [true])
        }

        RxExpect("it should present edit view controller when item selected") { test in
            let viewModel = TaskListViewModel()
            test.input(viewModel.itemDidSelect, [
                next(100, NSIndexPath(forRow: 0, inSection: 0)),
            ])
            let presented = viewModel.presentTaskEditViewModel.map { _ in true }
            test.assertNextEqual(presented, [true])
        }
    }

}

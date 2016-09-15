//
//  TaskListViewModel.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 7/1/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift

typealias TaskListSection = SectionModel<Void, TaskCellModelType>

protocol TaskListViewModelType {

  // Input
  var addButtonDidTap: PublishSubject<Void> { get }
  var itemDidSelect: PublishSubject<IndexPath> { get }
  var itemDeleted: PublishSubject<IndexPath> { get }

  // Output
  var navigationBarTitle: Driver<String?> { get }
  var sections: Driver<[TaskListSection]> { get }
  var presentTaskEditViewModel: Driver<TaskEditViewModelType> { get }

}

struct TaskListViewModel: TaskListViewModelType {

  // MARK: Input

  let addButtonDidTap = PublishSubject<Void>()
  let itemDidSelect = PublishSubject<IndexPath>()
  var itemDeleted = PublishSubject<IndexPath>()


  // MARK: Output

  let navigationBarTitle: Driver<String?>
  let sections: Driver<[TaskListSection]>
  let presentTaskEditViewModel: Driver<TaskEditViewModelType>


  // MARK: Private

  private let disposeBag = DisposeBag()
  private var tasks: Variable<[Task]>

  init() {
    let defaultTasks = [
      Task(title: "Go to https://github.com/devxoul"),
      Task(title: "Star repositories I am intersted in"),
      Task(title: "Make a pull request"),
    ]
    let tasks = Variable<[Task]>(defaultTasks)
    self.tasks = tasks
    self.navigationBarTitle = .just("Tasks")
    self.sections = tasks.asObservable()
      .map { tasks in
        let cellModels = tasks.map(TaskCellModel.init) as [TaskCellModelType]
        let section = TaskListSection(model: Void(), items: cellModels)
        return [section]
      }
      .asDriver(onErrorJustReturn: [])

    self.itemDeleted
      .subscribeNext { indexPath in
        let task = tasks.value[indexPath.row]
        Task.didDelete.onNext(task)
      }
      .addDisposableTo(self.disposeBag)

    //
    // View Controller Navigations
    //
    let presentAddViewModel: Observable<TaskEditViewModelType> = self.addButtonDidTap
      .map { TaskEditViewModel(mode: .New) }

    let presentEditViewModel: Observable<TaskEditViewModelType> = self.itemDidSelect
      .map { indexPath in
        let task = tasks.value[indexPath.row]
        return TaskEditViewModel(mode: .Edit(task))
      }

    self.presentTaskEditViewModel = Observable.of(presentAddViewModel, presentEditViewModel).merge()
      .asDriver(onErrorDriveWith: .empty())

    //
    // Model Service
    //
    Task.didCreate
      .subscribeNext { task in
        tasks.value.insert(task, at: 0)
      }
      .addDisposableTo(self.disposeBag)

    Task.didUpdate
      .subscribeNext { task in
        if let index = tasks.value.indexOf(element: task) {
          tasks.value[index] = task
        }
      }
      .addDisposableTo(self.disposeBag)

    Task.didDelete
      .subscribeNext { task in
        if let index = tasks.value.indexOf(element: task) {
          tasks.value.remove(at: index)
        }
      }
      .addDisposableTo(self.disposeBag)
  }

}

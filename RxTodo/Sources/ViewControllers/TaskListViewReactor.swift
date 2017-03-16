//
//  TaskListViewReactor.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 7/1/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift

typealias TaskListSection = SectionModel<Void, TaskCellModelType>

protocol TaskListViewReactorType: class {

  // Input
  var viewDidLoad: PublishSubject<Void> { get }
  var viewDidDeallocate: PublishSubject<Void> { get }
  var editButtonItemDidTap: PublishSubject<Void> { get }
  var addButtonItemDidTap: PublishSubject<Void> { get }
  var itemDidSelect: PublishSubject<IndexPath> { get }
  var itemDidDelete: PublishSubject<IndexPath> { get }
  var itemDidMove: PublishSubject<(sourceIndex: IndexPath, destinationIndex: IndexPath)> { get }

  // Output
  var navigationBarTitle: Driver<String?> { get }
  var editButtonItemTitle: Driver<String> { get }
  var editButtonItemStyle: Driver<UIBarButtonItemStyle> { get }
  var sections: Driver<[TaskListSection]> { get }
  var isTableViewEditing: Driver<Bool> { get }
  var presentTaskEditViewReactor: Observable<TaskEditViewReactorType> { get }

}

final class TaskListViewReactor: TaskListViewReactorType {

  // MARK: Types

  fileprivate enum TaskOperation {
    case refresh([Task])
    case add(Task)
    case replace(Task)
    case move(from: Int, to: Int)
    case delete(id: String)
    case markDone(id: String)
    case markUndone(id: String)
  }


  // MARK: Input

  let viewDidLoad = PublishSubject<Void>()
  let viewDidDeallocate = PublishSubject<Void>()
  let editButtonItemDidTap = PublishSubject<Void>()
  let addButtonItemDidTap = PublishSubject<Void>()
  let itemDidSelect = PublishSubject<IndexPath>()
  let itemDidDelete = PublishSubject<IndexPath>()
  let itemDidMove = PublishSubject<(sourceIndex: IndexPath, destinationIndex: IndexPath)>()


  // MARK: Output

  let navigationBarTitle: Driver<String?>
  let editButtonItemTitle: Driver<String>
  let editButtonItemStyle: Driver<UIBarButtonItemStyle>
  let sections: Driver<[TaskListSection]>
  let isTableViewEditing: Driver<Bool>
  let presentTaskEditViewReactor: Observable<TaskEditViewReactorType>


  // MARK: Initializing

  init(provider: ServiceProviderType) {
    //
    // Editing
    //
    let isEditing = self.editButtonItemDidTap
      .scan(false) { lastValue, _ in !lastValue }
      .startWith(false)
      .asDriver(onErrorJustReturn: false)

    //
    // Navigation Item
    //
    self.navigationBarTitle = .just("Tasks")
    self.editButtonItemTitle = isEditing
      .map { isEditing in
        return isEditing ? "Done" : "Edit"
      }
    self.editButtonItemStyle = isEditing
      .map { isEditing in
        return isEditing ? .done : .plain
      }

    //
    // Task Operation
    //
    let taskRefreshOperation = self.viewDidLoad
      .flatMap {
        provider.taskService.fetchTasks()
          .ignoreErrors()
      }
      .map(TaskOperation.refresh)

    let taskEventOperation = provider.taskService.event
      .map { event -> TaskOperation in
        switch event {
        case let .create(task): return .add(task)
        case let .update(task): return .replace(task)
        case let .delete(id): return .delete(id: id)
        case let .markDone(id): return .markDone(id: id)
        case let .markUndone(id): return .markUndone(id: id)
        }
      }
      .shareReplay(1)

    let taskMoveOperation = self.itemDidMove
      .map { sourceIndexPath, destinationIndexPath -> TaskOperation in
        return .move(from: sourceIndexPath.row, to: destinationIndexPath.row)
      }

    //
    // Tasks
    //
    let tasks: Observable<[Task]> = Observable
      .of(taskRefreshOperation, taskEventOperation, taskMoveOperation)
      .merge()
      .scan([]) { tasks, operation in
        switch operation {
        case let .refresh(newTasks):
          return newTasks

        case let .add(newTask):
          var newTasks = tasks
          newTasks.insert(newTask, at: 0)
          return newTasks

        case let .replace(newTask):
          guard let index = tasks.index(where: { $0.id == newTask.id }) else { return tasks }
          var newTasks = tasks
          newTasks[index] = newTask
          return newTasks

        case let .delete(id):
          guard let index = tasks.index(where: { $0.id == id }) else { return tasks }
          var newTasks = tasks
          newTasks.remove(at: index)
          return newTasks

        case let .move(from, to):
          var newTasks = tasks
          let task = newTasks.remove(at: from)
          newTasks.insert(task, at: to)
          return newTasks

        case let .markDone(id):
          guard let index = tasks.index(where: { $0.id == id }) else { return tasks }
          var task = tasks[index]
          task.isDone = true
          var newTasks = tasks
          newTasks[index] = task
          return newTasks

        case let .markUndone(id):
          guard let index = tasks.index(where: { $0.id == id }) else { return tasks }
          var task = tasks[index]
          task.isDone = false
          var newTasks = tasks
          newTasks[index] = task
          return newTasks
        }
      }
      .shareReplay(1)

    _ = tasks
      .takeUntil(self.viewDidDeallocate)
      .subscribe(onNext: { tasks in
        provider.taskService.saveTasks(tasks)
      })

    // 
    // Sections
    //
    self.sections = tasks
      .map { tasks in
        let cellModels = tasks.map(TaskCellModel.init) as [TaskCellModelType]
        let section = TaskListSection(model: Void(), items: cellModels)
        return [section]
      }
      .asDriver(onErrorJustReturn: [])

    //
    // Table View Editing
    //
    self.isTableViewEditing = isEditing

    //
    // Interactions
    //
    _ = self.itemDidSelect
      .withLatestFrom(isEditing) { ($0, $1) }
      .filter { _, isEditing in !isEditing }
      .map { indexPath, _ in indexPath }
      .withLatestFrom(tasks) { indexPath, tasks -> TaskEvent in
        let task = tasks[indexPath.row]
        if task.isDone {
          return .markUndone(id: task.id)
        } else {
          return .markDone(id: task.id)
        }
      }
      .takeUntil(self.viewDidDeallocate)
      .bindTo(provider.taskService.event)

    _ = self.itemDidDelete
      .withLatestFrom(tasks) { indexPath, tasks -> TaskEvent in
        return TaskEvent.delete(id: tasks[indexPath.row].id)
      }
      .takeUntil(self.viewDidDeallocate)
      .bindTo(provider.taskService.event)


    //
    // View Controller Navigations
    //
    let presentAddViewReactor: Observable<TaskEditViewReactorType> = self.addButtonItemDidTap
      .map {
        TaskEditViewReactor(provider: provider, mode: .new)
      }
    let presentEditViewReactor: Observable<TaskEditViewReactorType> = self.itemDidSelect
      .withLatestFrom(isEditing) { ($0, $1) }
      .filter { _, isEditing in isEditing }
      .map { indexPath, _ in indexPath }
      .withLatestFrom(tasks) { indexPath, tasks -> TaskEditViewReactor in
        let task = tasks[indexPath.row]
        return TaskEditViewReactor(provider: provider, mode: .edit(task))
      }
    self.presentTaskEditViewReactor = Observable
      .of(presentAddViewReactor, presentEditViewReactor)
      .merge()
      .observeOn(MainScheduler.instance)
      .subscribeOn(ConcurrentMainScheduler.instance)
  }

}

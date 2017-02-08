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

struct TaskListViewModelInputs {
    var viewDidLoad: Observable<Void>
    var editButtonItemDidTap: Observable<Void>
    var addButtonItemDidTap: Observable<Void>
    var itemDidSelect: Observable<IndexPath>
    var itemDidDelete: Observable<IndexPath>
    var itemDidMove: Observable<(sourceIndex: IndexPath, destinationIndex: IndexPath)>
}

struct TaskListViewModelOutputs {
    var navigationBarTitle: Driver<String?>
    var editButtonItemTitle: Driver<String>
    var editButtonItemStyle: Driver<UIBarButtonItemStyle>
    var sections: Driver<[TaskListSection]>
    var isTableViewEditing: Driver<Bool>
    var presentTaskEditViewModel: Observable<TaskEditViewModel>
}

typealias TaskListViewModel = (TaskListViewModelInputs) -> TaskListViewModelOutputs

private enum TaskOperation {
    case refresh([Task])
    case add(Task)
    case replace(Task)
    case move(from: Int, to: Int)
    case delete(id: String)
    case markDone(id: String)
    case markUndone(id: String)
}

func createTaskListViewModel(provider: ServiceProviderType) -> TaskListViewModel {
    return { input in
        //
        // Editing
        //

        let isEditing = input.editButtonItemDidTap
            .scan(false) { lastValue, _ in !lastValue }
            .startWith(false)
            .asDriver(onErrorJustReturn: false)

        //
        // Navigation Item
        //
        let navigationBarTitle = Driver<String?>.just("Tasks")
        let editButtonItemTitle = isEditing
            .map { isEditing in
                return isEditing ? "Done" : "Edit"
            }

        let editButtonItemStyle: Driver<UIBarButtonItemStyle> = isEditing
            .map { isEditing in
                return isEditing ? .done : .plain
            }

        //
        // Task Operation
        //
        let taskRefreshOperation = input.viewDidLoad
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

        let taskMoveOperation = input.itemDidMove
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
            .do(onNext: {
                provider.taskService.saveTasks($0)
            })
            .shareReplay(1)
        
        //
        // Sections
        //
        let sections: Driver<[TaskListSection]> = tasks
            .map { tasks in
                let cellModels = tasks.map(TaskCellModel.init) as [TaskCellModelType]
                let section = TaskListSection(model: Void(), items: cellModels)
                return [section]
            }
            .asDriver(onErrorJustReturn: [])

        //
        // Table View Editing
        //
        let isTableViewEditing = isEditing

        //
        // Interactions
        //

        let selectTaskEvent = input.itemDidSelect
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
        provider.taskService.add(event: selectTaskEvent)

        let deleteTaskEvent = input.itemDidDelete
            .withLatestFrom(tasks) { indexPath, tasks -> TaskEvent in
                return TaskEvent.delete(id: tasks[indexPath.row].id)
            }
        provider.taskService.add(event: deleteTaskEvent)

        //
        // View Controller Navigations
        //
        let presentAddViewModel: Observable<TaskEditViewModel> = input.addButtonItemDidTap
            .map {
                createTaskEditViewModel(provider: provider, mode: .new)
        }
        let presentEditViewModel: Observable<TaskEditViewModel> = input.itemDidSelect
            .withLatestFrom(isEditing) { ($0, $1) }
            .filter { _, isEditing in isEditing }
            .map { indexPath, _ in indexPath }
            .withLatestFrom(tasks) { indexPath, tasks -> TaskEditViewModel in
                let task = tasks[indexPath.row]
                return createTaskEditViewModel(provider: provider, mode: .edit(task))
        }
        let presentTaskEditViewModel = Observable
            .of(presentAddViewModel, presentEditViewModel)
            .merge()
            .observeOn(MainScheduler.instance)
            .subscribeOn(ConcurrentMainScheduler.instance)

        return TaskListViewModelOutputs(navigationBarTitle: navigationBarTitle, editButtonItemTitle: editButtonItemTitle, editButtonItemStyle: editButtonItemStyle, sections: sections, isTableViewEditing: isTableViewEditing, presentTaskEditViewModel: presentTaskEditViewModel)
    }
}

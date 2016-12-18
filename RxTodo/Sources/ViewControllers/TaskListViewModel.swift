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

        tasks = Variable<[Task]>(defaultTasks)

        navigationBarTitle = .just("Tasks")

        sections = tasks.asObservable()
            .map { tasks in
                let cellModels = tasks.map(TaskCellModel.init)
                let section = TaskListSection(model: Void(), items: cellModels)
                return [section]
            }
            .asDriver(onErrorJustReturn: [])

        itemDeleted
            .withLatestFrom(tasks.asObservable()) { $0 }
            .subscribe(onNext: { indexPath, tasks in
                let task = tasks[indexPath.row]
                Task.didDelete.onNext(task)
            })
            .addDisposableTo(disposeBag)

        // View Controller Navigations
        let presentAddViewModel: Observable<TaskEditViewModelType> = addButtonDidTap
            .map { TaskEditViewModel(mode: .new) }

        let presentEditViewModel: Observable<TaskEditViewModelType> = itemDidSelect
            .withLatestFrom(tasks.asObservable()) { $0 }
            .map { indexPath, tasks in
                let task = tasks[indexPath.row]
                return TaskEditViewModel(mode: .edit(task))
            }

        presentTaskEditViewModel = Observable.of(presentAddViewModel, presentEditViewModel).merge()
            .asDriver(onErrorDriveWith: .empty())

        // Model Service
        Task.didCreate
            .withLatestFrom(tasks.asObservable()) { $0 }
            .map { createdTask, tasks in
                var newTasks = tasks
                newTasks.insert(createdTask, at: 0)
                return newTasks
            }
            .bindTo(tasks)
            .addDisposableTo(disposeBag)

        Task.didUpdate
            .withLatestFrom(tasks.asObservable()) { $0 }
            .map { updatedTask, tasks -> [Task] in
                guard let index = tasks.index(of: updatedTask) else {
                    return tasks
                }
                
                var newTasks = tasks
                newTasks[index] = updatedTask
                return newTasks
            }
            .bindTo(tasks)
            .addDisposableTo(disposeBag)

        Task.didDelete
            .withLatestFrom(tasks.asObservable()) { $0 }
            .map { deletedTask, tasks -> [Task] in
                guard let index = tasks.index(of: deletedTask) else {
                    return tasks
                }
                
                var newTasks = tasks
                newTasks.remove(at: index)
                return newTasks
            }
            .bindTo(tasks)
            .addDisposableTo(disposeBag)
    }
}

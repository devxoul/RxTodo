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
    // Output
    var title: Driver<String?> { get }
    var sections: Driver<[TaskListSection]> { get }
}

struct TaskListViewModel: TaskListViewModelType {

    // MARK: Output

    let title: Driver<String?>
    let sections: Driver<[TaskListSection]>


    // MARK: Private

    private let disposeBag = DisposeBag()
    private var tasks = Variable<[Task]>([])

    init() {
        self.title = .just("Tasks")
        self.sections = self.tasks.asObservable()
            .map { tasks in
                let cellModels = tasks.map(TaskCellModel.init) as [TaskCellModelType]
                let section = TaskListSection(model: Void(), items: cellModels)
                return [section]
            }
            .asDriver(onErrorJustReturn: [])

        Task.didCreate
            .subscribeNext { task in
                self.tasks.value.insert(task, atIndex: 0)
            }
            .addDisposableTo(self.disposeBag)

        Task.didUpdate
            .subscribeNext { task in
                if let index = self.tasks.value.indexOf(task) {
                    self.tasks.value[index] = task
                }
            }
            .addDisposableTo(self.disposeBag)

        Task.didUpdate
            .subscribeNext { task in
                if let index = self.tasks.value.indexOf(task) {
                    self.tasks.value.removeAtIndex(index)
                }
            }
            .addDisposableTo(self.disposeBag)
    }

}

//
//  TaskEditViewModel.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 7/2/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import RxCocoa
import RxSwift

enum TaskEditViewMode {
    case New
    case Edit(Task)
}

protocol TaskEditViewModelType {

    // 2-Way Binding
    var title: Variable<String> { get }

    // Input
    var cancelButtonDidTap: PublishSubject<Void> { get }
    var doneButtonDidTap: PublishSubject<Void> { get }
    var alertLeaveButtonDidTap: PublishSubject<Void> { get }
    var alertStayButtonDidTap: PublishSubject<Void> { get }
    var memo: PublishSubject<String> { get }

    // Output
    var navigationBarTitle: Driver<String?> { get }
    var doneButtonEnabled: Driver<Bool> { get }
    var presentCancelAlert: Driver<(String, String, String, String)> { get }
    var dismissViewController: Driver<Void> { get }

}

struct TaskEditViewModel: TaskEditViewModelType {

    // MARK: 2-Way Binding

    var title: Variable<String>


    // MARK: Input

    let cancelButtonDidTap = PublishSubject<Void>()
    let doneButtonDidTap = PublishSubject<Void>()
    let alertLeaveButtonDidTap = PublishSubject<Void>()
    let alertStayButtonDidTap = PublishSubject<Void>()
    let memo = PublishSubject<String>()


    // MARK: Output

    let navigationBarTitle: Driver<String?>
    let doneButtonEnabled: Driver<Bool>
    let presentCancelAlert: Driver<(String, String, String, String)>
    let dismissViewController: Driver<Void>


    // MARK: Initializing

    init(mode: TaskEditViewMode) {
        switch mode {
        case .New:
            self.navigationBarTitle = .just("New")
            self.title = Variable("")

        case .Edit(let task):
            self.navigationBarTitle = .just("Edit")
            self.title = Variable(task.title)
        }

        self.doneButtonEnabled = self.title.asDriver()
            .map { !$0.isEmpty }
            .asDriver(onErrorJustReturn: false)
            .startWith(false)

        let needsPresentCancelAlert = self.cancelButtonDidTap.asDriver()
            .withLatestFrom(self.title.asDriver())
            .map { title -> Bool in
                switch mode {
                case .New: return !title.isEmpty
                case .Edit(let task): return title != task.title
                }
            }

        self.presentCancelAlert = needsPresentCancelAlert
            .filter { $0 }
            .map { _ in
                let title = "Really?"
                let message = "Changes will be lost."
                return (title, message, "Leave", "Stay")
            }

        let didDone = self.doneButtonDidTap.asDriver()
            .withLatestFrom(self.doneButtonEnabled).filter { $0 }
            .withLatestFrom(self.title.asDriver())
            .map { title in
                switch mode {
                case .New:
                    let newTask = Task(title: title)
                    Task.didCreate.onNext(newTask)

                case .Edit(let task):
                    let newTask = task.then {
                        $0.title = title
                    }
                    Task.didUpdate.onNext(newTask)
                }
            }

        self.dismissViewController = Driver.of(self.alertLeaveButtonDidTap.asDriver(), didDone,
                                               needsPresentCancelAlert.filter { !$0 }.map { _ in Void() }).merge()
    }

}

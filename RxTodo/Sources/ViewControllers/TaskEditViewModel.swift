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
  case new
  case edit(Task)
}

protocol TaskEditViewModelType {
    // 2-Way Binding
    var title: Variable<String?> { get }

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

    let title: Variable<String?>

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


    // MARK: Private
    private let disposeBag = DisposeBag()

    // MARK: Initializing
    init(mode: TaskEditViewMode) {
        switch mode {
        case .new:
            navigationBarTitle = .just("New")
            title = Variable("")

        case .edit(let task):
            navigationBarTitle = .just("Edit")
            title = Variable(task.title)
        }

    doneButtonEnabled = title.asDriver()
        .map { $0 ?? "" }
        .map { !$0.isEmpty }
        .asDriver(onErrorJustReturn: false)
        .startWith(false)
        .distinctUntilChanged()

    let needsPresentCancelAlert = cancelButtonDidTap.asDriver()
        .withLatestFrom(title.asDriver())
        .map { $0 ?? "" }
        .map { title -> Bool in
            switch mode {
            case .new:
                return !title.isEmpty
        
            case .edit(let task):
                return title != task.title
            }
        }

    presentCancelAlert = needsPresentCancelAlert
        .filter { $0 }
        .map { _ in
            let title = "Really?"
            let message = "Changes will be lost."
            return (title, message, "Leave", "Stay")
        }

    let didDone = doneButtonDidTap.asDriver()
        .withLatestFrom(doneButtonEnabled).filter { $0 }
        .map { _ in }

    switch mode {
    case .new:
        didDone
            .withLatestFrom(title.asDriver())
            .filterNil()
            .map { title in
                Task(title: title)
            }
            .drive(Task.didCreate)
            .addDisposableTo(disposeBag)

    case .edit(let task):
        didDone
            .withLatestFrom(title.asDriver())
            .filterNil()
            .map { title in
                task.with {
                    $0.title = title
                }
            }
            .drive(Task.didUpdate)
            .addDisposableTo(disposeBag)
        }

    dismissViewController = Driver
        .of(
            alertLeaveButtonDidTap.asDriver(),
            didDone,
            needsPresentCancelAlert.filter { !$0 }.map { _ in }
        )
        .merge()
    }
}

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

enum TaskEditViewCancelAlertAction {
    case leave
    case stay
}

struct TaskEditViewModelInputs {
    var cancelButtonItemDidTap: Observable<Void>
    var doneButtonItemDidTap: Observable<Void>
    var titleInputDidChangeText: Observable<String?>
    var cancelAlertDidSelectAction: Observable<TaskEditViewCancelAlertAction>
}

struct TaskEditViewModelOutputs {
    var navigationBarTitle: Driver<String?>
    var doneButtonEnabled: Driver<Bool>
    var titleInputText: Driver<String?>
    var presentCancelAlert: Observable<[TaskEditViewCancelAlertAction]>
    var dismissViewController: Observable<Void>
}

typealias TaskEditViewModel = (TaskEditViewModelInputs) -> TaskEditViewModelOutputs

func createTaskEditViewModel(provider: ServiceProviderType, mode: TaskEditViewMode) -> TaskEditViewModel {
    return { input in
      let cancelAlertDidSelectAction = input.cancelAlertDidSelectAction.asInput()
      let cancelButtonItemDidTap = input.cancelButtonItemDidTap.asInput()
      let doneButtonItemDidTap = input.doneButtonItemDidTap.asInput()
      let titleInputDidChangeText = input.titleInputDidChangeText.asInput()

        //
        // Title Input Text
        //
        let titleInputText = createTitleInputText(
            mode: mode,
            titleInputDidChangeText: titleInputDidChangeText.asObservable()
        )

        //
        // Navigation Item
        //
        let navigationBarTitle = createNavigationBarTitle(mode: mode)

        let doneButtonEnabled = titleInputText
            .map { text in text?.isEmpty == false }
            .startWith(false)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)

        //
        // Confirm Cancel
        //
        let presentCancelAlert: Observable<[TaskEditViewCancelAlertAction]> = cancelButtonItemDidTap
            .withLatestFrom(titleInputText)
            .filter { isTitleChanged(mode: mode, title: $0) }
            .map { _ in [.leave, .stay] }
            .observeOn(MainScheduler.instance)
            .subscribeOn(ConcurrentMainScheduler.instance)

        //
        // Done
        //
        let createTaskEvent = doneButtonItemDidTap
            .withLatestFrom(doneButtonEnabled)
            .filter { isEnabled in isEnabled }
            .withLatestFrom(titleInputText)
            .filterNil()
            .map { title -> TaskEvent in
                switch mode {
                case .new:
                    let newTask = Task(title: title)
                    return .create(newTask)
                case .edit(let task):
                    let newTask = task.with { $0.title = title }
                    return .update(newTask)
                }
            }

        provider.taskService.add(event: createTaskEvent)

        //
        // Dismiss
        //
        let cancelButtonDidTapWithoutChanges = cancelButtonItemDidTap
            .withLatestFrom(titleInputText)
            .filter { !isTitleChanged(mode: mode, title: $0) }
            .map { _ in Void() }

        let cancelAlertDidSelectLeaveAction = cancelAlertDidSelectAction
            .filter { $0 == .leave }
            .map { _ in Void() }

        let doneButtonDidTapWhenEnabled = doneButtonItemDidTap
            .withLatestFrom(doneButtonEnabled)
            .filter { isEnabled in isEnabled }
            .map { _ in Void() }

        let dismissViewController = Observable
            .of(cancelButtonDidTapWithoutChanges, cancelAlertDidSelectLeaveAction, doneButtonDidTapWhenEnabled)
            .merge()
            .observeOn(MainScheduler.instance)
            .subscribeOn(ConcurrentMainScheduler.instance)

        return TaskEditViewModelOutputs(navigationBarTitle: navigationBarTitle, doneButtonEnabled: doneButtonEnabled, titleInputText: titleInputText, presentCancelAlert: presentCancelAlert, dismissViewController: dismissViewController)
    }
}

// MARK: - Functions

private func createNavigationBarTitle(mode: TaskEditViewMode) -> Driver<String?> {
    switch mode {
    case .new: return .just("New")
    case .edit: return .just("Edit")
    }
}

private func createTitleInputText(
    mode: TaskEditViewMode,
    titleInputDidChangeText: Observable<String?>
    ) -> Driver<String?> {
    let source = titleInputDidChangeText.asDriver(onErrorJustReturn: nil)
    switch mode {
    case .edit(let task):
        return source.startWith(task.title)
    case .new:
        return source.startWith(nil)
    }
}

private func isTitleChanged(mode: TaskEditViewMode, title: String?) -> Bool {
    switch mode {
    case .new:
        return title?.isEmpty == false
    case .edit(let task):
        return title != task.title
    }
}


//
//  TaskEditViewReactor.swift
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

enum TaskEditViewAction {
  case updateTaskTitle(String)
  case cancel()
  case done()
}

struct TaskEditViewState {
  var title: String?
  var taskTitle: String?
  var canDone: Bool
}

final class TaskEditViewReactor: Reactor<TaskEditViewAction, TaskEditViewState> {

  init(provider: ServiceProviderType, mode: TaskEditViewMode) {
    let initialState: State
    switch mode {
    case .new:
      initialState = State(
        title: "New",
        taskTitle: nil,
        canDone: false
      )
    case .edit(let task):
      initialState = State(
        title: "Edit",
        taskTitle: task.title,
        canDone: true
      )
    }
    super.init(initialState: initialState)
  }

//  override func reduce(state: State, action: Action) -> State {
//    var state = state
//    switch action {
//    case let .updateTaskTitle(taskTitle):
//      state.taskTitle = taskTitle
//      return state
//
//    case .cancel:
//      return state
//
//    case .done:
//      return state
//    }
//  }


  // MARK: Initializing

  /*init(provider: ServiceProviderType, mode: TaskEditViewMode) {
    let cls = TaskEditViewReactor.self

    //
    // Title Input Text
    //
    self.titleInputText = cls.titleInputText(
      mode: mode,
      titleInputDidChangeText: titleInputDidChangeText.asObservable()
    )

    //
    // Navigation Item
    //
    self.navigationBarTitle = cls.navigationBarTitle(mode: mode)
    self.doneButtonEnabled = titleInputText
      .map { text in text?.isEmpty == false }
      .startWith(false)
      .distinctUntilChanged()
      .asDriver(onErrorJustReturn: false)

    //
    // Confirm Cancel
    //
    self.presentCancelAlert = self.cancelButtonItemDidTap
      .withLatestFrom(self.titleInputText)
      .filter { cls.isTitleChanged(mode: mode, title: $0) }
      .map { _ in [.leave, .stay] }
      .observeOn(MainScheduler.instance)
      .subscribeOn(ConcurrentMainScheduler.instance)

    //
    // Done
    //
    _ = self.doneButtonItemDidTap
      .withLatestFrom(self.doneButtonEnabled)
      .filter { isEnabled in isEnabled }
      .withLatestFrom(self.titleInputText)
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
      .takeUntil(self.viewDidDeallocate)
      .bindTo(provider.taskService.event)

    //
    // Dismiss
    //
    let cancelButtonDidTapWithoutChanges = self.cancelButtonItemDidTap
      .withLatestFrom(self.titleInputText)
      .filter { !cls.isTitleChanged(mode: mode, title: $0) }
      .map { _ in Void() }

    let cancelAlertDidSelectLeaveAction = self.cancelAlertDidSelectAction
      .filter { $0 == .leave }
      .map { _ in Void() }

    let doneButtonDidTapWhenEnabled = self.doneButtonItemDidTap
      .withLatestFrom(self.doneButtonEnabled)
      .filter { isEnabled in isEnabled }
      .map { _ in Void() }

    self.dismissViewController = Observable
      .of(cancelButtonDidTapWithoutChanges, cancelAlertDidSelectLeaveAction, doneButtonDidTapWhenEnabled)
      .merge()
      .observeOn(MainScheduler.instance)
      .subscribeOn(ConcurrentMainScheduler.instance)
  }


  // MARK: - Functions

  class func navigationBarTitle(mode: TaskEditViewMode) -> Driver<String?> {
    switch mode {
    case .new: return .just("New")
    case .edit: return .just("Edit")
    }
  }

  class func titleInputText(
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

  class func isTitleChanged(mode: TaskEditViewMode, title: String?) -> Bool {
    switch mode {
    case .new:
      return title?.isEmpty == false
    case .edit(let task):
      return title != task.title
    }
  }*/

}

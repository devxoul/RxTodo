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

enum TaskEditViewCancelAlertAction: AlertActionType {
  case leave
  case stay

  var title: String? {
    switch self {
    case .leave: return "Leave"
    case .stay: return "Stay"
    }
  }

  var style: UIAlertActionStyle {
    switch self {
    case .leave: return .destructive
    case .stay: return .default
    }
  }
}

enum TaskEditViewAction {
  case updateTaskTitle(String)
  case cancel
  case submit
  case dismiss
}

struct TaskEditViewState {
  var title: String
  var taskTitle: String
  var canSubmit: Bool
  var shouldConfirmCancel: Bool
  var isDismissed: Bool

  init(title: String, taskTitle: String, canSubmit: Bool) {
    self.title = title
    self.taskTitle = taskTitle
    self.canSubmit = canSubmit
    self.shouldConfirmCancel = false
    self.isDismissed = false
  }
}

final class TaskEditViewReactor: Reactor<TaskEditViewAction, TaskEditViewState> {

  let provider: ServiceProviderType
  let mode: TaskEditViewMode

  init(provider: ServiceProviderType, mode: TaskEditViewMode) {
    self.provider = provider
    self.mode = mode

    let initialState: State
    switch mode {
    case .new:
      initialState = State(title: "New", taskTitle: "", canSubmit: false)
    case .edit(let task):
      initialState = State(title: "Edit", taskTitle: task.title, canSubmit: true)
    }
    super.init(initialState: initialState)
  }

  override func transform(action: Observable<Action>) -> Observable<Action> {
    return action
      .flatMap { action -> Observable<Action> in
        switch action {
        case .submit where self.currentState.canSubmit:
          switch self.mode {
          case .new:
            return self.provider.taskService
              .create(title: self.currentState.taskTitle, memo: nil)
              .map { _ in .dismiss }

          case .edit(let task):
            return self.provider.taskService
              .update(taskID: task.id, title: self.currentState.taskTitle, memo: nil)
              .map { _ in .dismiss }
          }

        case .cancel:
          if !self.currentState.shouldConfirmCancel {
            return .just(.dismiss)
          }
          let alertActions: [TaskEditViewCancelAlertAction] = [.leave, .stay]
          return self.provider.alertService
            .show(
              title: "Really?",
              message: "All changes will be lost",
              preferredStyle: .alert,
              actions: alertActions
            )
            .flatMap { alertAction -> Observable<Action> in
              switch alertAction {
              case .leave:
                return .just(.dismiss)

              case .stay:
                return .empty()
              }
            }

        default:
          return .just(action)
        }
      }
  }

  override func reduce(state: State, action: Action) -> State {
    var state = state
    switch action {
    case let .updateTaskTitle(taskTitle):
      state.taskTitle = taskTitle
      state.canSubmit = !taskTitle.isEmpty
      state.shouldConfirmCancel = taskTitle != self.initialState.taskTitle
      return state

    case .cancel:
      return state

    case .submit:
      return state

    case .dismiss:
      state.isDismissed = true
      return state
    }
  }

}

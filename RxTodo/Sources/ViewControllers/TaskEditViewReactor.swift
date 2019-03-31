//
//  TaskEditViewReactor.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 7/2/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import ReactorKit
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

    var style: UIAlertAction.Style {
    switch self {
    case .leave: return .destructive
    case .stay: return .default
    }
  }
}


final class TaskEditViewReactor: Reactor {

  enum Action {
    case updateTaskTitle(String)
    case cancel
    case submit
  }

  enum Mutation {
    case updateTaskTitle(String)
    case dismiss
  }

  struct State {
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

  let provider: ServiceProviderType
  let mode: TaskEditViewMode
  let initialState: State

  init(provider: ServiceProviderType, mode: TaskEditViewMode) {
    self.provider = provider
    self.mode = mode

    switch mode {
    case .new:
      self.initialState = State(title: "New", taskTitle: "", canSubmit: false)
    case .edit(let task):
      self.initialState = State(title: "Edit", taskTitle: task.title, canSubmit: true)
    }
  }

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .updateTaskTitle(taskTitle):
      return .just(.updateTaskTitle(taskTitle))

    case .submit:
      guard self.currentState.canSubmit else { return .empty() }
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
        return .just(.dismiss) // no need to confirm
      }
      let alertActions: [TaskEditViewCancelAlertAction] = [.leave, .stay]
      return self.provider.alertService
        .show(
          title: "Really?",
          message: "All changes will be lost",
          preferredStyle: .alert,
          actions: alertActions
        )
        .flatMap { alertAction -> Observable<Mutation> in
          switch alertAction {
          case .leave:
            return .just(.dismiss)

          case .stay:
            return .empty()
          }
        }
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .updateTaskTitle(taskTitle):
      state.taskTitle = taskTitle
      state.canSubmit = !taskTitle.isEmpty
      state.shouldConfirmCancel = taskTitle != self.initialState.taskTitle
      return state

    case .dismiss:
      state.isDismissed = true
      return state
    }
  }

}

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

typealias TaskListSection = SectionModel<Void, TaskCellReactor>

enum TasListViewAction {
  case refresh(Phase<[TaskListSection]>)
  case toggleEditing
  case toggleTaskDone(IndexPath)
  case presentEditView(IndexPath)
}

struct TaskListViewState {
  var isEditing: Bool
  var sections: [TaskListSection]
}

final class TaskListViewReactor: Reactor<TasListViewAction, TaskListViewState> {

  let provider: ServiceProviderType

  init(provider: ServiceProviderType) {
    self.provider = provider
    let initialState = State(
      isEditing: false,
      sections: [TaskListSection(model: Void(), items: [])]
    )
    super.init(initialState: initialState)
  }

  override func flatMap(action: Action) -> Observable<Action> {
    switch action {
    case .refresh(.begin):
      return self.provider.taskService.fetchTasks()
        .map { tasks in
          let sectionItems = tasks.map(TaskCellReactor.init)
          let section = TaskListSection(model: Void(), items: sectionItems)
          return .refresh(.end([section]))
      }

    default:
      return .just(action)
    }
  }

  override func reduce(state: State, action: Action) -> State {
    var state = state
    switch action {
    case .refresh(.begin):
      return state

    case let .refresh(.end(sections)):
      state.sections = sections
      return state

    case .toggleEditing:
      state.isEditing = !state.isEditing
      return state

    case .toggleTaskDone:
//      state.sections.
      return state

    case let .presentEditView(indexPath):
      return state
    }
  }

}

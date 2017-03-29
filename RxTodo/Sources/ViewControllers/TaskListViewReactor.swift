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
  case toggleTaskDone(TaskListSection.Item)
  case deleteTask(IndexPath)
  case moveTask(IndexPath, IndexPath)
  case taskEvent(TaskEvent)
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

  override func transform(action: Observable<Action>) -> Observable<Action> {
    let actionFromTaskEvent = self.provider.taskService.event.map(Action.taskEvent)
    return Observable.of(action, actionFromTaskEvent).merge()
      .flatMap { action -> Observable<Action> in
        switch action {
        case .refresh(.begin):
          return self.provider.taskService.fetchTasks()
            .map { tasks in
              let sectionItems = tasks.map(TaskCellReactor.init)
              let section = TaskListSection(model: Void(), items: sectionItems)
              return .refresh(.end([section]))
            }

        case let .toggleTaskDone(sectionItem):
          let task = sectionItem.currentState
          if !task.isDone {
            return self.provider.taskService.markAsDone(taskID: task.id).flatMap { _ in Observable.empty() }
          } else {
            return self.provider.taskService.markAsUndone(taskID: task.id).flatMap { _ in Observable.never() }
          }

        default:
          return .just(action)
        }
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
      return state

    case let .deleteTask(indexPath):
      state.sections.remove(at: indexPath)
      return state

    case let .moveTask(sourceIndexPath, destinationIndexPath):
      let sectionItem = state.sections.remove(at: sourceIndexPath)
      state.sections.insert(newElement: sectionItem, at: destinationIndexPath)
      return state

    case let .taskEvent(event):
      return self.reduceTaskEvent(state: state, event: event)
    }
  }

  private func reduceTaskEvent(state: State, event: TaskEvent) -> State {
    var state = state
    switch event {
    case let .create(task):
      let reactor = TaskCellReactor(task: task)
      state.sections[0].items.insert(reactor, at: 0)
      return state

    case let .update(task):
      guard let indexPath = self.indexPath(forTaskID: task.id, from: state) else { return state }
      state.sections[indexPath] = TaskCellReactor(task: task)
      return state

    case let .delete(id):
      guard let indexPath = self.indexPath(forTaskID: id, from: state) else { return state }
      state.sections.remove(at: indexPath)
      return state

    case let .markAsDone(id):
      guard let indexPath = self.indexPath(forTaskID: id, from: state) else { return state }
      var task = state.sections[indexPath].currentState
      task.isDone = true
      state.sections[indexPath] = TaskCellReactor(task: task)
      return state

    case let .markAsUndone(id):
      guard let indexPath = self.indexPath(forTaskID: id, from: state) else { return state }
      var task = state.sections[indexPath].currentState
      task.isDone = false
      state.sections[indexPath] = TaskCellReactor(task: task)
      return state
    }
  }

  private func indexPath(forTaskID taskID: String, from state: State) -> IndexPath? {
    let section = 0
    let item = state.sections[section].items.index { reactor in reactor.currentState.id == taskID }
    if let item = item {
      return IndexPath(item: item, section: section)
    } else {
      return nil
    }
  }

  func reactorForCreatingTask() -> TaskEditViewReactor {
    return TaskEditViewReactor(provider: self.provider, mode: .new)
  }

  func reactorForEditingTask(_ taskCellReactor: TaskCellReactor) -> TaskEditViewReactor {
    let task = taskCellReactor.currentState
    return TaskEditViewReactor(provider: self.provider, mode: .edit(task))
  }

}

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

enum TaskListViewAction {
  case refresh
  case toggleEditing
  case toggleTaskDone(IndexPath)
  case deleteTask(IndexPath)
  case moveTask(IndexPath, IndexPath)
  case taskEvent(TaskEvent)
}

enum TaskListViewMutation {
  case toggleEditing
  case setSections([TaskListSection])
  case insertSectionItem(IndexPath, TaskListSection.Item)
  case updateSectionItem(IndexPath, TaskListSection.Item)
  case deleteSectionItem(IndexPath)
  case moveSectionItem(IndexPath, IndexPath)
}

struct TaskListViewState {
  var isEditing: Bool
  var sections: [TaskListSection]
}

final class TaskListViewReactor: Reactor<TaskListViewAction, TaskListViewMutation, TaskListViewState> {

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
  }

  override func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .refresh:
      return self.provider.taskService.fetchTasks()
        .map { tasks in
          let sectionItems = tasks.map(TaskCellReactor.init)
          let section = TaskListSection(model: Void(), items: sectionItems)
          return .setSections([section])
        }

    case .toggleEditing:
      return .just(.toggleEditing)

    case let .toggleTaskDone(indexPath):
      let task = self.currentState.sections[indexPath].currentState
      if !task.isDone {
        return self.provider.taskService.markAsDone(taskID: task.id).flatMap { _ in Observable.empty() }
      } else {
        return self.provider.taskService.markAsUndone(taskID: task.id).flatMap { _ in Observable.empty() }
      }

    case let .deleteTask(indexPath):
      let task = self.currentState.sections[indexPath].currentState
      return self.provider.taskService.delete(taskID: task.id).flatMap { _ in Observable.empty() }

    case let .moveTask(sourceIndexPath, destinationIndexPath):
      let task = self.currentState.sections[sourceIndexPath].currentState
      return self.provider.taskService.move(taskID: task.id, to: destinationIndexPath.item)
        .flatMap { _ in Observable.empty() }

    case let .taskEvent(taskEvent):
      return self.mutate(taskEvent: taskEvent)
    }
  }

  private func mutate(taskEvent: TaskEvent) -> Observable<Mutation> {
    let state = self.currentState
    switch taskEvent {
    case let .create(task):
      let indexPath = IndexPath(item: 0, section: 0)
      let reactor = TaskCellReactor(task: task)
      return .just(.insertSectionItem(indexPath, reactor))

    case let .update(task):
      guard let indexPath = self.indexPath(forTaskID: task.id, from: state) else { return .empty() }
      let reactor = TaskCellReactor(task: task)
      return .just(.updateSectionItem(indexPath, reactor))

    case let .delete(id):
      guard let indexPath = self.indexPath(forTaskID: id, from: state) else { return .empty() }
      return .just(.deleteSectionItem(indexPath))

    case let .move(id, index):
      guard let sourceIndexPath = self.indexPath(forTaskID: id, from: state) else { return .empty() }
      let destinationIndexPath = IndexPath(item: index, section: 0)
      return .just(.moveSectionItem(sourceIndexPath, destinationIndexPath))

    case let .markAsDone(id):
      guard let indexPath = self.indexPath(forTaskID: id, from: state) else { return .empty() }
      var task = state.sections[indexPath].currentState
      task.isDone = true
      let reactor = TaskCellReactor(task: task)
      return .just(.updateSectionItem(indexPath, reactor))

    case let .markAsUndone(id):
      guard let indexPath = self.indexPath(forTaskID: id, from: state) else { return .empty() }
      var task = state.sections[indexPath].currentState
      task.isDone = false
      let reactor = TaskCellReactor(task: task)
      return .just(.updateSectionItem(indexPath, reactor))
    }
  }

  override func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .setSections(sections):
      state.sections = sections
      return state

    case .toggleEditing:
      state.isEditing = !state.isEditing
      return state

    case let .insertSectionItem(indexPath, sectionItem):
      state.sections.insert(sectionItem, at: indexPath)
      return state

    case let .updateSectionItem(indexPath, sectionItem):
      state.sections[indexPath] = sectionItem
      return state

    case let .deleteSectionItem(indexPath):
      state.sections.remove(at: indexPath)
      return state

    case let .moveSectionItem(sourceIndexPath, destinationIndexPath):
      let sectionItem = state.sections.remove(at: sourceIndexPath)
      state.sections.insert(sectionItem, at: destinationIndexPath)
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

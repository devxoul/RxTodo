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

enum TaskListAction {
  case refresh()
  case presentAddView((TaskEditViewReactor) -> Void)
  case toggleEditing()
  case toggleTaskDone(IndexPath)
  case moveTask(IndexPath, IndexPath)
  case deleteTask(IndexPath)
  case taskEvent(TaskEvent)
}

struct TaskListState {
  var title: String?
  var isEditing: Bool
  var sections: [TaskListSection]

  init() {
    self.title = nil
    self.isEditing = false
    self.sections = []
  }
}

final class TaskListViewReactor: Reactor<TaskListAction, TaskListState> {

  let provider: ServiceProviderType

  init(provider: ServiceProviderType) {
    self.provider = provider
    super.init(initialState: State())
  }

  override func transformAction(_ action: Observable<Action>) -> Observable<Action> {
    let actionFromTaskEvent = self.provider.taskService.event.map(Action.taskEvent)
    return Observable.of(action, actionFromTaskEvent).merge()
  }

  override func reduce(state: State, action: Action) -> Observable<State> {
    var state = state
    switch action {
    case .refresh:
      return self.provider.taskService.fetchTasks()
        .map { tasks -> State in
          let reactors = tasks.map(TaskCellReactor.init)
          let section = TaskListSection(model: Void(), items: reactors)
          state.sections = [section]
          return state
        }

    case .presentAddView:
      return .just(state)

    case .toggleEditing:
      state.isEditing = !state.isEditing
      return .just(state)

    case let .toggleTaskDone(indexPath):
      let reactor = state.sections[indexPath]
      return reactor.state
        .do(onNext: { [weak self] state in
          if state.isDone {
            self?.provider.taskService.event.onNext(.markUndone(id: state.id))
          } else {
            self?.provider.taskService.event.onNext(.markDone(id: state.id))
          }
        })
        .map { _ in state }

    case let .moveTask(sourceIndexPath, destinationIndexPath):
      var sectionItems = state.sections[sourceIndexPath.section].items
      let sectionItem = sectionItems.remove(at: sourceIndexPath.item)
      sectionItems.insert(sectionItem, at: destinationIndexPath.item)
      state.sections[sourceIndexPath.section].items = sectionItems
      return .just(state)

    case let .deleteTask(indexPath):
      return state.sections[indexPath].state
        .do(onNext: { [weak self] cellState in
          self?.provider.taskService.event.onNext(.delete(id: cellState.id))
        })
        .map { _ in state }

    case let .taskEvent(event):
      return self.reduceTaskEvent(state: state, event: event)
    }
  }

  private func reduceTaskEvent(state: State, event: TaskEvent) -> Observable<State> {
    var state = state
    switch event {
    case let .create(task):
      let reactor = TaskCellReactor(task: task)
      state.sections[0].items.append(reactor)
      return .just(state)

    case let .update(task):
      guard let indexPath = self.taskIndexPath(id: task.id, state: state) else { return .just(state) }
      state.sections[indexPath] = TaskCellReactor(task: task)
      return .just(state)

    case let .delete(id):
      guard let indexPath = self.taskIndexPath(id: id, state: state) else { return .just(state) }
      state.sections.remove(at: indexPath)
      return .just(state)

    case let .markDone(id):
      guard let indexPath = self.taskIndexPath(id: id, state: state) else { return .just(state) }
      return state.sections[indexPath].state
        .map { cellState -> State in
          var task = cellState
          task.isDone = true
          state.sections[indexPath] = TaskCellReactor(task: task)
          return state
        }

    case let .markUndone(id):
      guard let indexPath = self.taskIndexPath(id: id, state: state) else { return .just(state) }
      return state.sections[indexPath].state
        .map { cellState -> State in
          var task = cellState
          task.isDone = false
          state.sections[indexPath] = TaskCellReactor(task: task)
          return state
        }
    }
  }

  private func taskIndexPath(id: String, state: State) -> IndexPath? {
    let section = 0
    let item = state.sections[section].items.index { $0.initialState.id == id }
    if let item = item {
      return IndexPath(item: item, section: section)
    } else {
      return nil
    }
  }

}

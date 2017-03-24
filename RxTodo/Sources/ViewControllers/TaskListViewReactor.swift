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

typealias TaskListSection = SectionModel<Void, TaskCellReactorType>

protocol TaskListViewReactorType: class {
  var action: PublishSubject<TaskListViewReactor.Action> { get }
  var state: Observable<TaskListViewReactor.State> { get }
}

final class TaskListViewReactor: TaskListViewReactorType {

  // MARK: Types

  struct State {
    var title: String?
    var isEditing: Bool
    private(set) var sections: [TaskListSection]
    fileprivate var tasks: [Task] {
      didSet {
        let reactors = self.tasks.map(TaskCellReactor.init)
        let section = TaskListSection(model: Void(), items: reactors)
        self.sections = [section]
      }
    }

    init() {
      self.title = nil
      self.isEditing = false
      self.sections = []
      self.tasks = []
    }
  }

  enum Action {
    case refresh()
    case toggleEditing()
    case toggleTaskDone(IndexPath)
    case moveTask(IndexPath, IndexPath)
    case deleteTask(IndexPath)
    case taskEvent(TaskEvent)
  }

  let action: PublishSubject<Action> = .init()
  let state: Observable<State>

  init(provider: ServiceProviderType) {
    let seedState = Observable.just(State())
    self.state = Observable
      .of(self.action, provider.taskService.event.map(Action.taskEvent)).merge()
      .scan(seedState) { stateObservable, action in
        return stateObservable
          .flatMap { state -> Observable<State> in
            var state = state
            switch action {
            case .refresh:
              return provider.taskService.fetchTasks()
                .map { tasks -> State in
                  state.tasks = tasks
                  return state
                }

            case .toggleEditing:
              state.isEditing = !state.isEditing
              return .just(state)

            case let .toggleTaskDone(indexPath):
              let task = state.tasks[indexPath.item]
              if task.isDone {
                provider.taskService.event.onNext(.markUndone(id: task.id))
              } else {
                provider.taskService.event.onNext(.markDone(id: task.id))
              }
              return .just(state)

            case let .moveTask(sourceIndexPath, destinationIndexPath):
              let section = state.tasks.remove(at: sourceIndexPath.item)
              state.tasks.insert(section, at: destinationIndexPath.item)
              return .just(state)

            case let .deleteTask(indexPath):
              let task = state.tasks[indexPath.item]
              provider.taskService.event.onNext(.delete(id: task.id))
              return .just(state)

            case let .taskEvent(event):
              switch event {
              case let .create(task):
                state.tasks.append(task)
                return .just(state)

              case let .update(task):
                guard let index = state.tasks.index(of: task) else { return .just(state) }
                state.tasks[index] = task
                return .just(state)

              case let .delete(id):
                guard let index = state.tasks.index(where: { $0.id == id }) else { return .just(state) }
                state.tasks.remove(at: index)
                return .just(state)

              case let .markDone(id):
                guard let index = state.tasks.index(where: { $0.id == id }) else { return .just(state) }
                state.tasks[index].isDone = true
                return .just(state)

              case let .markUndone(id):
                guard let index = state.tasks.index(where: { $0.id == id }) else { return .just(state) }
                state.tasks[index].isDone = false
                return .just(state)
              }
            }
          }
          .shareReplay(1)
      }
      .flatMap { $0 }
      .observeOn(ConcurrentMainScheduler.instance)
      .shareReplay(1)
  }

}

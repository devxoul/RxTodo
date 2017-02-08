//
//  TaskService.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 12/01/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

import RxSwift

enum TaskEvent {
  case create(Task)
  case update(Task)
  case delete(id: String)
  case markDone(id: String)
  case markUndone(id: String)
}

protocol TaskServiceType {
  var event: PublishSubject<TaskEvent> { get }
  func add(event: Observable<TaskEvent>)
  func fetchTasks() -> Observable<[Task]>

  @discardableResult
  func saveTasks(_ tasks: [Task]) -> Observable<Void>
}

final class TaskService: BaseService, TaskServiceType {

  var event = PublishSubject<TaskEvent>()

  func add(event: Observable<TaskEvent>) {
    _ = event.subscribe(self.event)
  }

  func fetchTasks() -> Observable<[Task]> {
    if let savedTaskDictionaries = self.provider.userDefaultsService.value(forKey: .tasks) {
      let tasks = savedTaskDictionaries.flatMap(Task.init)
      return .just(tasks)
    }
    let defaultTasks: [Task] = [
      Task(title: "Go to https://github.com/devxoul"),
      Task(title: "Star repositories I am intersted in"),
      Task(title: "Make a pull request"),
    ]
    let defaultTaskDictionaries = defaultTasks.map { $0.asDictionary() }
    self.provider.userDefaultsService.set(value: defaultTaskDictionaries, forKey: .tasks)
    return .just(defaultTasks)
  }

  @discardableResult
  func saveTasks(_ tasks: [Task]) -> Observable<Void> {
    let dicts = tasks.map { $0.asDictionary() }
    self.provider.userDefaultsService.set(value: dicts, forKey: .tasks)
    return .empty()
  }

}

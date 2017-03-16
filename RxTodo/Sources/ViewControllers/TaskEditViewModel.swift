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

protocol TaskEditViewModelType: class {
}

final class TaskEditViewModel: TaskEditViewModelType {

  let deallocate: PublishSubject<Void> = .init()

  let title: Variable<String?> = .init(nil)

  let canSubmit: Driver<Bool>
  let submit: PublishSubject<Void> = .init()

  let cancel: PublishSubject<Void> = .init()
  let shouldConfirm: Driver<Bool>


  // MARK: Initializing

  init(provider: ServiceProviderType, mode: TaskEditViewMode) {
    let initialTitle: String?

    switch mode {
    case .new:
      initialTitle = nil
    case .edit(let task):
      initialTitle = task.title
    }

    let canSubmit = self.title.asObservable().map { $0?.isEmpty == false }
    self.canSubmit = canSubmit.asDriver(onErrorJustReturn: false)
    _ = self.submit
      .withLatestFrom(self.title.asObservable())
      .filterNil()
      .filterEmpty()
      .withLatestFrom(self.canSubmit) { ($0, $1) }
      .flatMap { title, canSubmit -> Observable<String> in
        return canSubmit ? .just(title) : .empty()
      }
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
      .takeUntil(self.deallocate)
      .bindTo(provider.taskService.event)

    self.shouldConfirm = self.title.asDriver()
      .map { $0 != initialTitle }
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
  }

}

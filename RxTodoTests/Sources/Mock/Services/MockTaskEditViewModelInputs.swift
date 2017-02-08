//
//  MockTaskEditViewModelInputs.swift
//  RxTodo
//
//  Created by Andy Chou on 2/7/17.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

import RxSwift
@testable import RxTodo

struct MockTaskEditViewModelInputs {
  var cancelButtonItemDidTap = PublishSubject<Void>()
  var doneButtonItemDidTap = PublishSubject<Void>()
  var titleInputDidChangeText = PublishSubject<String?>()
  var cancelAlertDidSelectAction = PublishSubject<TaskEditViewCancelAlertAction>()

  func asInputs() -> TaskEditViewModelInputs {
    return TaskEditViewModelInputs(cancelButtonItemDidTap: cancelButtonItemDidTap, doneButtonItemDidTap: doneButtonItemDidTap, titleInputDidChangeText: titleInputDidChangeText, cancelAlertDidSelectAction: cancelAlertDidSelectAction)
  }
}

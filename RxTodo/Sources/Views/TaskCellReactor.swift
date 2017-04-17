//
//  TaskCellReactor.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 7/1/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

class TaskCellReactor: Reactor {
  typealias Action = NoAction

  let initialState: Task

  init(task: Task) {
    self.initialState = task
  }
}

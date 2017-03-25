//
//  TaskCellReactor.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 7/1/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import RxCocoa
import RxSwift

class TaskCellReactor: Reactor<NoAction, Task> {
  init(task: Task) {
    super.init(initialState: task)
  }
}

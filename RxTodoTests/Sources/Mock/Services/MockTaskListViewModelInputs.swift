//
//  MockTaskListViewModelInputs.swift
//  RxTodo
//
//  Created by Andy Chou on 2/7/17.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

import RxSwift
@testable import RxTodo

struct MockTaskListViewModelInputs {
  var viewDidLoad = PublishSubject<Void>()
  var editButtonItemDidTap = PublishSubject<Void>()
  var addButtonItemDidTap = PublishSubject<Void>()
  var itemDidSelect = PublishSubject<IndexPath>()
  var itemDidDelete = PublishSubject<IndexPath>()
  var itemDidMove = PublishSubject<(sourceIndex: IndexPath, destinationIndex: IndexPath)>()

  func asInputs() -> TaskListViewModelInputs {
    return TaskListViewModelInputs(viewDidLoad: viewDidLoad, editButtonItemDidTap: editButtonItemDidTap, addButtonItemDidTap: addButtonItemDidTap, itemDidSelect: itemDidSelect, itemDidDelete: itemDidDelete, itemDidMove: itemDidMove)
  }
}

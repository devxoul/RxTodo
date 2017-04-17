//
//  MockServiceProvider.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 15/01/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

@testable import RxTodo

final class MockServiceProvider: ServiceProviderType {
  lazy var userDefaultsService: UserDefaultsServiceType = MockUserDefaultsService()
  lazy var alertService: AlertServiceType = MockAlertService(provider: self)
  lazy var taskService: TaskServiceType = TaskService(provider: self)
}

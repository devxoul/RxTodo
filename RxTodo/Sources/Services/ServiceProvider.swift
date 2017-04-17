//
//  ServiceProvider.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 12/01/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

protocol ServiceProviderType: class {
  var userDefaultsService: UserDefaultsServiceType { get }
  var alertService: AlertServiceType { get }
  var taskService: TaskServiceType { get }
}

final class ServiceProvider: ServiceProviderType {
  lazy var userDefaultsService: UserDefaultsServiceType = UserDefaultsService(provider: self)
  lazy var alertService: AlertServiceType = AlertService(provider: self)
  lazy var taskService: TaskServiceType = TaskService(provider: self)
}

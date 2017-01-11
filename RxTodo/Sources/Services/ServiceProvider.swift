//
//  ServiceProvider.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 12/01/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

protocol ServiceProviderType: class {
  var userDefaultsService: UserDefaultsServiceType { get }
}

final class ServiceProvider: ServiceProviderType {
  lazy var userDefaultsService: UserDefaultsServiceType = UserDefaultsService(provider: self)
}

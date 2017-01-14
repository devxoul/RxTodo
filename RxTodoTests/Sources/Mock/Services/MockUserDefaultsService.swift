//
//  MockUserDefaultsService.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 15/01/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

@testable import RxTodo

final class MockUserDefaultsService: UserDefaultsServiceType {
  var store = [String: Any]()

  func value<T>(forKey key: UserDefaultsKey<T>) -> T? {
    return self.store[key.key] as? T
  }

  func set<T>(value: T?, forKey key: UserDefaultsKey<T>) {
    if let value = value {
      self.store[key.key] = value
    } else {
      self.store.removeValue(forKey: key.key)
    }
  }
}

//
//  UserDefaultsKey.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 12/01/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

/// A generic key for `UserDefaults`. Extend this type to define custom user defaults keys.
///
/// ```
/// extension UserDefaultsKey {
///   static var myKey: Key<String> {
///     return "myKey"
///   }
///
///   static var anotherKey: Key<Int> {
///     return "anotherKey"
///   }
/// }
/// ```
struct UserDefaultsKey<T> {
  typealias Key<T> = UserDefaultsKey<T>
  let key: String
}

extension UserDefaultsKey: ExpressibleByStringLiteral {
  public init(unicodeScalarLiteral value: StringLiteralType) {
    self.init(key: value)
  }

  public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
    self.init(key: value)
  }

  public init(stringLiteral value: StringLiteralType) {
    self.init(key: value)
  }
}

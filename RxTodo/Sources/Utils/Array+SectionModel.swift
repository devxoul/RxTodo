//
//  Array+SectionModel.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 26/03/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

import RxDataSources

extension Array where Element: SectionModelType {

  public subscript(indexPath: IndexPath) -> Element.Item {
    get {
      return self[indexPath.section].items[indexPath.item]
    }
    mutating set {
      self.update(section: indexPath.section) { items in
        items[indexPath.item] = newValue
      }
    }
  }

  public mutating func insert(_ newElement: Element.Item, at indexPath: IndexPath) {
    self.update(section: indexPath.section) { items in
      items.insert(newElement, at: indexPath.item)
    }
  }

  @discardableResult
  public mutating func remove(at indexPath: IndexPath) -> Element.Item {
    return self.update(section: indexPath.section) { items in
      return items.remove(at: indexPath.item)
    }
  }

  private mutating func replace(section: Int, items: [Element.Item]) {
    self[section] = Element.init(original: self[section], items: items)
  }

  private mutating func update<T>(section: Int, mutate: (inout [Element.Item]) -> T) -> T {
    var items = self[section].items
    let value = mutate(&items)
    self[section] = Element.init(original: self[section], items: items)
    return value
  }

}

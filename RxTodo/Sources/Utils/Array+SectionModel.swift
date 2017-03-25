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

  public mutating func insert(newElement: Element.Item, at indexPath: IndexPath) {
    self.update(section: indexPath.section) { items in
      items.insert(newElement, at: indexPath.item)
    }
  }

  public mutating func remove(at indexPath: IndexPath) {
    self.update(section: indexPath.section) { items in
      items.remove(at: indexPath.item)
    }
  }

  private mutating func replace(section: Int, items: [Element.Item]) {
    self[section] = Element.init(original: self[section], items: items)
  }

  private mutating func update(section: Int, mutate: (inout [Element.Item]) -> Void) {
    var items = self[section].items
    mutate(&items)
    self[section] = Element.init(original: self[section], items: items)
  }

}

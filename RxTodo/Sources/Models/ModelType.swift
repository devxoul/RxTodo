//
//  ModelType.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 7/1/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import Then

protocol Identifiable {
    associatedtype Identifier: Equatable
    var id: Identifier { get }
}

protocol ModelType: Then {
}

extension CollectionType where Generator.Element: Identifiable {

    func indexOf(element: Self.Generator.Element) -> Self.Index? {
        return self.indexOf { $0.id == element.id }
    }

}

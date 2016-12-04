//
//  Task.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 7/1/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import Foundation

struct Task: ModelType, Identifiable {

    let id: String
    var title: String
    let memo: String?

    init(title: String, memo: String? = nil) {
        self.id = UUID().uuidString
        self.title = title
        self.memo = memo
    }
}

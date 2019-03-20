//
//  BaseTableViewCell.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 7/1/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import UIKit

import RxSwift

class BaseTableViewCell: UITableViewCell {

  // MARK: Properties

  var disposeBag: DisposeBag = DisposeBag()


  // MARK: Initializing

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.initialize()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func initialize() {
    // Override point
  }

}

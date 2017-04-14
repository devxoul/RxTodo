//
//  TaskCell.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 7/1/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import UIKit

import ReactorKit
import RxSwift

final class TaskCell: BaseTableViewCell, View {
  typealias Reactor = TaskCellReactor

  // MARK: Constants

  struct Constant {
    static let titleLabelNumberOfLines = 2
  }

  struct Metric {
    static let cellPadding = 15.f
  }

  struct Font {
    static let titleLabel = UIFont.systemFont(ofSize: 14)
  }

  struct Color {
    static let titleLabelText = UIColor.black
  }


  // MARK: UI

  let titleLabel = UILabel().then {
    $0.font = Font.titleLabel
    $0.textColor = Color.titleLabelText
    $0.numberOfLines = Constant.titleLabelNumberOfLines
  }


  // MARK: Initializing

  override func initialize() {
    self.contentView.addSubview(self.titleLabel)
  }


  // MARK: Binding

  func bind(reactor: Reactor) {
    self.titleLabel.text = reactor.currentState.title
    self.accessoryType = reactor.currentState.isDone ? .checkmark : .none
  }


  // MARK: Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    self.titleLabel.top = Metric.cellPadding
    self.titleLabel.left = Metric.cellPadding
    self.titleLabel.width = self.contentView.width - Metric.cellPadding * 2
    self.titleLabel.sizeToFit()
  }


  // MARK: Cell Height

  class func height(fits width: CGFloat, reactor: Reactor) -> CGFloat {
    let height =  reactor.currentState.title.height(
      fits: width - Metric.cellPadding * 2,
      font: Font.titleLabel,
      maximumNumberOfLines: Constant.titleLabelNumberOfLines
    )
    return height + Metric.cellPadding * 2
  }

}

//
//  TaskCell.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 7/1/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import UIKit
import RxSwift

final class TaskCell: BaseTableViewCell {

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

    // MARK: Properties
    
    let titleLabel = UILabel().then {
        $0.font = Font.titleLabel
        $0.textColor = Color.titleLabelText
        $0.numberOfLines = Constant.titleLabelNumberOfLines
    }


    // MARK: Initializing
    
    override func initialize() {
        contentView.addSubview(titleLabel)
    }

    // MARK: Configuring
    
    func configure(_ viewModel: TaskCellModelType) {
        titleLabel.text = viewModel.title
    }

    // MARK: Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        titleLabel.top = Metric.cellPadding
        titleLabel.left = Metric.cellPadding
        titleLabel.width = contentView.width - Metric.cellPadding * 2
        titleLabel.sizeToFit()
    }

    // MARK: Cell Height

    class func height(fits width: CGFloat, viewModel: TaskCellModelType) -> CGFloat {
        let height =  viewModel.title.height(
            fits: width - Metric.cellPadding * 2,
            font: Font.titleLabel,
            maximumNumberOfLines: Constant.titleLabelNumberOfLines
        )
        
        return height + Metric.cellPadding * 2
    }
}

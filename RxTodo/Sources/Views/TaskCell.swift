//
//  TaskCell.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 7/1/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import UIKit

import ReactorKit

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
        static let descriptionLabel = UIFont.systemFont(ofSize: 10)
    }
    
    struct Color {
        static let titleLabelText = UIColor.black
        static let descriptionLabelText = UIColor.gray
    }
    
    
    // MARK: UI
    
    let titleLabel = UILabel().then {
        $0.font = Font.titleLabel
        $0.textColor = Color.titleLabelText
        $0.numberOfLines = Constant.titleLabelNumberOfLines
    }
    
    let descriptionLabel = UILabel().then {
        $0.text = "Hi I'm a caption"
        $0.font = Font.descriptionLabel
        $0.textColor = Color.descriptionLabelText
    }
    
    
    // MARK: Initializing
    
    // 1 - After this cell is created, its superclass does whatever it needs to then delegates back down to the overriden initialize() method of this class
    override func initialize() {
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.descriptionLabel)
    }
    
    
    // MARK: Binding
    
    // 3 - Called when the tableview is loading its datasource. The datasource holds an array of TaskCellReactors, which are then passed to their respective TaskCells, and used to set/change the titleLabel or checked state of the cell
    func bind(reactor: Reactor) {
        self.titleLabel.text = reactor.currentState.title
        self.accessoryType = reactor.currentState.isDone ? .checkmark : .none
    }
    
    
    // MARK: Layout
    
    // 2 - Called right after the titleLabel is added to the contentView. Programmatically sets constraints to to the titleLabel of the cell
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleLabel.top = Metric.cellPadding
        //Np need to set .bottom cell padding because the cell infers the amount of padding necessary for the bottom from the top
        self.titleLabel.left = Metric.cellPadding
        self.titleLabel.width = self.contentView.width - Metric.cellPadding * 2
        self.titleLabel.sizeToFit()
        
        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4).isActive = true
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

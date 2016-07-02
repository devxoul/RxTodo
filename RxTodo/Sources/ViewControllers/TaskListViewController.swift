//
//  TaskListViewController.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 7/1/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import UIKit

import RxCocoa
import RxDataSources
import RxSwift
import ReusableKit

final class TaskListViewController: BaseViewController {

    // MARK: Constants

    struct Reusable {
        static let taskCell = ReusableCell<TaskCell>()
    }


    // MARK: Properties

    let dataSource = RxTableViewSectionedReloadDataSource<TaskListSection>()

    let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: nil, action: Selector())
    let tableView = UITableView().then {
        $0.registerCell(Reusable.taskCell)
    }


    // MARK: Initializing

    init(viewModel: TaskListViewModelType) {
        super.init()
        self.navigationItem.rightBarButtonItem = self.addBarButtonItem
        self.configure(viewModel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .whiteColor()
        self.tableView.rx_setDelegate(self)
        self.view.addSubview(self.tableView)
    }

    override func setupConstraints() {
        super.setupConstraints()
        self.tableView.snp_makeConstraints { make in
            make.edges.equalTo(0)
        }
    }


    // MARK: Configuring

    private func configure(viewModel: TaskListViewModelType) {
        self.dataSource.configureCell = { _, tableView, indexPath, viewModel in
            let cell = tableView.dequeueCell(Reusable.taskCell, forIndexPath: indexPath)
            cell.configure(viewModel)
            return cell
        }

        // Input
        self.addBarButtonItem.rx_tap
            .bindTo(viewModel.addButtonDidTap)
            .addDisposableTo(self.disposeBag)

        self.tableView.rx_itemSelected
            .bindTo(viewModel.itemDidSelect)
            .addDisposableTo(self.disposeBag)

        self.tableView.rx_itemDeleted
            .bindTo(viewModel.itemDeleted)
            .addDisposableTo(self.disposeBag)

        // Ouput
        viewModel.navigationBarTitle
            .drive(self.navigationItem.rx_title)
            .addDisposableTo(self.disposeBag)

        viewModel.sections
            .drive(self.tableView.rx_itemsWithDataSource(self.dataSource))
            .addDisposableTo(self.disposeBag)

        viewModel.presentTaskEditViewModel
            .driveNext { [weak self] viewModel in
                guard let `self` = self else { return }
                let viewController = TaskEditViewController(viewModel: viewModel)
                let navigationController = UINavigationController(rootViewController: viewController)
                self.presentViewController(navigationController, animated: true, completion: nil)
            }
            .addDisposableTo(self.disposeBag)
    }

}


// MARK: - UITableViewDelegate

extension TaskListViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let viewModel = self.dataSource.itemAtIndexPath(indexPath)
        return TaskCell.cellHeightThatFitsWidth(tableView.width, viewModel: viewModel)
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}

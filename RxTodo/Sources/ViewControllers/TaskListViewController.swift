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
    
    private let disposeBag = DisposeBag()

    // MARK: Constants

    struct Reusable {
        static let taskCell = ReusableCell<TaskCell>()
    }

    // MARK: Properties

    let dataSource = RxTableViewSectionedReloadDataSource<TaskListSection>()

    let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    let tableView = UITableView().then {
        $0.register(Reusable.taskCell)
    }

    // MARK: Initializing

    init(viewModel: TaskListViewModelType) {
        super.init()
        navigationItem.rightBarButtonItem = addBarButtonItem
        configure(viewModel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        tableView.rx
            .setDelegate(self)
            .addDisposableTo(disposeBag)

        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .addDisposableTo(disposeBag)

        view.addSubview(tableView)
    }

    override func setupConstraints() {
        super.setupConstraints()
        tableView.snp.makeConstraints { make in
          make.edges.equalTo(0)
        }
    }

    // MARK: Configuring

    private func configure(_ viewModel: TaskListViewModelType) {
        dataSource.configureCell = { _, tableView, indexPath, viewModel in
          let cell = tableView.dequeue(Reusable.taskCell, for: indexPath)
          cell.configure(viewModel)
          return cell
        }

        // Input
        addBarButtonItem.rx.tap
          .bindTo(viewModel.addButtonDidTap)
          .addDisposableTo(disposeBag)

        tableView.rx.itemSelected
          .bindTo(viewModel.itemDidSelect)
          .addDisposableTo(disposeBag)

        tableView.rx.itemDeleted
          .bindTo(viewModel.itemDeleted)
          .addDisposableTo(disposeBag)

        // Ouput
        viewModel.navigationBarTitle
          .drive(navigationItem.rx.title)
          .addDisposableTo(disposeBag)

        viewModel.sections
          .drive(tableView.rx.items(dataSource: dataSource))
          .addDisposableTo(disposeBag)

        viewModel.presentTaskEditViewModel
          .drive(onNext: { [weak self] viewModel in
            let viewController = TaskEditViewController(viewModel: viewModel)
            let navigationController = UINavigationController(rootViewController: viewController)
            self?.present(navigationController, animated: true, completion: nil)
          })
          .addDisposableTo(disposeBag)
    }
}


// MARK: - UITableViewDelegate

extension TaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let viewModel = dataSource[indexPath]
        return TaskCell.height(fits: tableView.width, viewModel: viewModel)
    }
}

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
  var viewModel: TaskListViewModelType!

  // MARK: Constants

  struct Reusable {
    static let taskCell = ReusableCell<TaskCell>()
  }


  // MARK: Properties

  let dataSource = RxTableViewSectionedReloadDataSource<TaskListSection>()

  let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
  let tableView = UITableView().then {
    $0.allowsSelectionDuringEditing = true
    $0.register(Reusable.taskCell)
  }


  // MARK: Initializing

  init(viewModel: @escaping TaskListViewModelType) {
    super.init()
    self.navigationItem.leftBarButtonItem = self.editButtonItem
    self.navigationItem.rightBarButtonItem = self.addButtonItem
    self.viewModel = viewModel
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: View Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    self.view.addSubview(self.tableView)
    self.configure(self.viewModel)
  }

  override func setupConstraints() {
    super.setupConstraints()
    self.tableView.snp.makeConstraints { make in
      make.edges.equalTo(0)
    }
  }

  // MARK: Configuring

  private func configure(_ viewModel: TaskListViewModelType) {
    self.tableView.rx.setDelegate(self).addDisposableTo(self.disposeBag)
    self.dataSource.configureCell = { _, tableView, indexPath, viewModel in
      let cell = tableView.dequeue(Reusable.taskCell, for: indexPath)
      cell.configure(viewModel)
      return cell
    }
    self.dataSource.canEditRowAtIndexPath = { _ in true }
    self.dataSource.canMoveRowAtIndexPath = { _ in true }

    // Input
    let inputs = TaskListViewModelInputs(viewDidLoad: .just(),
                                         editButtonItemDidTap: self.editButtonItem.rx.tap.asObservable(),
                                         addButtonItemDidTap: self.addButtonItem.rx.tap.asObservable(),
                                         itemDidSelect: self.tableView.rx.itemSelected.asObservable(),
                                         itemDidDelete: self.tableView.rx.itemDeleted.asObservable(),
                                         itemDidMove: self.tableView.rx.itemMoved.asObservable())

    let output = viewModel(inputs)

    // Ouput
    output.navigationBarTitle
      .drive(self.navigationItem.rx.title)
      .addDisposableTo(self.disposeBag)

    output.editButtonItemTitle
      .drive(self.editButtonItem.rx.title)
      .addDisposableTo(self.disposeBag)

    output.editButtonItemStyle
      .drive(onNext: { [weak self] style in
        self?.editButtonItem.style = style
      })
      .addDisposableTo(self.disposeBag)

    output.sections
      .drive(self.tableView.rx.items(dataSource: self.dataSource))
      .addDisposableTo(self.disposeBag)

    output.isTableViewEditing
      .drive(onNext: { [weak self] isEditing in
        self?.tableView.setEditing(isEditing, animated: true)
      })
      .addDisposableTo(self.disposeBag)

    output.presentTaskEditViewModel
      .subscribe(onNext: { [weak self] viewModel in
        guard let `self` = self else { return }
        let viewController = TaskEditViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        self.present(navigationController, animated: true, completion: nil)
      })
      .addDisposableTo(self.disposeBag)
  }

}


// MARK: - UITableViewDelegate

extension TaskListViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let viewModel = self.dataSource[indexPath]
    return TaskCell.height(fits: tableView.width, viewModel: viewModel)
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }

//  tableview

}

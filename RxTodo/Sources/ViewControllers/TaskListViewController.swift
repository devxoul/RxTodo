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

  let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
  let tableView = UITableView().then {
    $0.allowsSelectionDuringEditing = true
    $0.register(Reusable.taskCell)
  }


  // MARK: Initializing

  init(viewModel: TaskListViewModelType) {
    super.init()
    self.navigationItem.leftBarButtonItem = self.editButtonItem
    self.navigationItem.rightBarButtonItem = self.addButtonItem
    self.configure(viewModel)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }


  // MARK: View Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    self.view.addSubview(self.tableView)
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
    self.rx.viewDidLoad
      .bindTo(viewModel.viewDidLoad)
      .addDisposableTo(self.disposeBag)

    self.rx.deallocated
      .bindTo(viewModel.viewDidDeallocate)
      .addDisposableTo(self.disposeBag)

    self.editButtonItem.rx.tap
      .bindTo(viewModel.editButtonItemDidTap)
      .addDisposableTo(self.disposeBag)

    self.addButtonItem.rx.tap
      .bindTo(viewModel.addButtonItemDidTap)
      .addDisposableTo(self.disposeBag)

    self.tableView.rx.itemSelected
      .bindTo(viewModel.itemDidSelect)
      .addDisposableTo(self.disposeBag)

    self.tableView.rx.itemDeleted
      .bindTo(viewModel.itemDidDelete)
      .addDisposableTo(self.disposeBag)

    self.tableView.rx.itemMoved
      .bindTo(viewModel.itemDidMove)
      .addDisposableTo(self.disposeBag)

    // Ouput
    viewModel.navigationBarTitle
      .drive(self.navigationItem.rx.title)
      .addDisposableTo(self.disposeBag)

    viewModel.editButtonItemTitle
      .drive(self.editButtonItem.rx.title)
      .addDisposableTo(self.disposeBag)

    viewModel.editButtonItemStyle
      .drive(onNext: { [weak self] style in
        self?.editButtonItem.style = style
      })
      .addDisposableTo(self.disposeBag)

    viewModel.sections
      .drive(self.tableView.rx.items(dataSource: self.dataSource))
      .addDisposableTo(self.disposeBag)

    viewModel.isTableViewEditing
      .drive(onNext: { [weak self] isEditing in
        self?.tableView.setEditing(isEditing, animated: true)
      })
      .addDisposableTo(self.disposeBag)

    viewModel.presentTaskEditViewModel
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

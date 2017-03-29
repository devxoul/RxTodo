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

final class TaskListViewController: BaseViewController, ViewType {

  typealias Reactor = TaskListViewReactor


  // MARK: Constants

  struct Reusable {
    static let taskCell = ReusableCell<TaskCell>()
  }


  // MARK: Properties

  let reactor: Reactor?
  let dataSource = RxTableViewSectionedReloadDataSource<TaskListSection>()

  let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
  let tableView = UITableView().then {
    $0.allowsSelectionDuringEditing = true
    $0.register(Reusable.taskCell)
  }


  // MARK: Initializing

  init(reactor: Reactor) {
    self.reactor = reactor
    super.init()
    self.navigationItem.leftBarButtonItem = self.editButtonItem
    self.navigationItem.rightBarButtonItem = self.addButtonItem
    self.configure(reactor: reactor)
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

  func configure(reactor: Reactor) {
    // DataSource
    self.tableView.rx.setDelegate(self).addDisposableTo(self.disposeBag)
    self.dataSource.configureCell = { _, tableView, indexPath, reactor in
      let cell = tableView.dequeue(Reusable.taskCell, for: indexPath)
      cell.configure(reactor: reactor)
      return cell
    }
    self.dataSource.canEditRowAtIndexPath = { _ in true }
    self.dataSource.canMoveRowAtIndexPath = { _ in true }

    // Action
    self.rx.viewDidLoad
      .map { Reactor.Action.refresh }
      .bindTo(reactor.action)
      .addDisposableTo(self.disposeBag)

    self.editButtonItem.rx.tap
      .map { Reactor.Action.toggleEditing }
      .bindTo(reactor.action)
      .addDisposableTo(self.disposeBag)

    self.tableView.rx.itemSelected
      .filterNot(reactor.state.map { $0.isEditing })
      .map { indexPath in .toggleTaskDone(indexPath) }
      .bindTo(reactor.action)
      .addDisposableTo(self.disposeBag)

    self.tableView.rx.itemDeleted
      .map(Reactor.Action.deleteTask)
      .bindTo(reactor.action)
      .addDisposableTo(self.disposeBag)

    self.tableView.rx.itemMoved
      .map(Reactor.Action.moveTask)
      .bindTo(reactor.action)
      .addDisposableTo(self.disposeBag)

    self.addButtonItem.rx.tap
      .map(reactor.reactorForCreatingTask)
      .subscribe(onNext: { [weak self] reactor in
        guard let `self` = self else { return }
        let viewController = TaskEditViewController(reactor: reactor)
        let navigationController = UINavigationController(rootViewController: viewController)
        self.present(navigationController, animated: true, completion: nil)
      })
      .addDisposableTo(self.disposeBag)

    self.tableView.rx.modelSelected(type(of: self.dataSource).Section.Item.self)
      .filter(reactor.state.map { $0.isEditing })
      .map(reactor.reactorForEditingTask)
      .subscribe(onNext: { [weak self] reactor in
        guard let `self` = self else { return }
        let viewController = TaskEditViewController(reactor: reactor)
        let navigationController = UINavigationController(rootViewController: viewController)
        self.present(navigationController, animated: true, completion: nil)
      })
      .addDisposableTo(self.disposeBag)

    // State
    reactor.state.asObservable().map { $0.sections }
      .bindTo(self.tableView.rx.items(dataSource: self.dataSource))
      .addDisposableTo(self.disposeBag)

    reactor.state.asObservable().map { $0.isEditing }
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] isEditing in
        guard let `self` = self else { return }
        self.navigationItem.leftBarButtonItem?.title = isEditing ? "Done" : "Edit"
        self.navigationItem.leftBarButtonItem?.style = isEditing ? .done : .plain
        self.tableView.setEditing(isEditing, animated: true)
      })
      .addDisposableTo(self.disposeBag)
  }

}


// MARK: - UITableViewDelegate

extension TaskListViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let reactor = self.dataSource[indexPath]
    return TaskCell.height(fits: tableView.width, reactor: reactor)
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }

}

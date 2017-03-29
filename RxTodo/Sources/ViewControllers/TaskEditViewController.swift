//
//  TaskEditViewController.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 7/2/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import UIKit

import RxSwift

final class TaskEditViewController: BaseViewController, ViewType {

  typealias Reactor = TaskEditViewReactor


  // MARK: Constants

  struct Metric {
    static let padding = 15.f
    static let titleInputCornerRadius = 5.f
    static let titleInputBorderWidth = 1 / UIScreen.main.scale
  }

  struct Font {
    static let titleLabel = UIFont.systemFont(ofSize: 14)
  }

  struct Color {
    static let titleInputBorder = UIColor.lightGray
  }


  // MARK: Properties

  let reactor: Reactor?


  // MARK: UI

  let cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
  let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
  let titleInput = UITextField().then {
    $0.autocorrectionType = .no
    $0.borderStyle = .roundedRect
    $0.font = Font.titleLabel
    $0.placeholder = "Do something..."
  }


  // MARK: Initializing

  init(reactor: Reactor) {
    self.reactor = reactor
    super.init()
    self.navigationItem.leftBarButtonItem = self.cancelButtonItem
    self.navigationItem.rightBarButtonItem = self.doneButtonItem
    self.configure(reactor: reactor)
  }

  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }


  // MARK: View Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    self.view.addSubview(self.titleInput)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.titleInput.becomeFirstResponder()
  }

  override func setupConstraints() {
    self.titleInput.snp.makeConstraints { make in
      make.top.equalTo(self.topLayoutGuide.snp.bottom).offset(Metric.padding)
      make.left.equalTo(Metric.padding)
      make.right.equalTo(-Metric.padding)
    }
  }


  // MARK: Configuring

  func configure(reactor: Reactor) {
    // Action
    self.cancelButtonItem.rx.tap
      .map { Reactor.Action.cancel }
      .bindTo(reactor.action)
      .addDisposableTo(self.disposeBag)

    self.doneButtonItem.rx.tap
      .map { Reactor.Action.submit }
      .bindTo(reactor.action)
      .addDisposableTo(self.disposeBag)

    self.titleInput.rx.text
      .filterNil()
      .map(Reactor.Action.updateTaskTitle)
      .bindTo(reactor.action)
      .addDisposableTo(self.disposeBag)

    // State
    reactor.state.asObservable().map { $0.title }
      .distinctUntilChanged()
      .bindTo(self.navigationItem.rx.title)
      .addDisposableTo(self.disposeBag)

    reactor.state.asObservable().map { $0.taskTitle }
      .distinctUntilChanged()
      .bindTo(self.titleInput.rx.text)
      .addDisposableTo(self.disposeBag)

    reactor.state.asObservable().map { $0.canSubmit }
      .distinctUntilChanged()
      .bindTo(self.doneButtonItem.rx.isEnabled)
      .addDisposableTo(self.disposeBag)

    reactor.state.asObservable().map { $0.isDismissed }
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        self?.dismiss(animated: true, completion: nil)
      })
      .addDisposableTo(self.disposeBag)
  }

}

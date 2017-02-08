//
//  TaskEditViewController.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 7/2/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import UIKit
import RxSwift

final class TaskEditViewController: BaseViewController {
  var viewModel: TaskEditViewModelType!
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

  let cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
  let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
  let titleInput = UITextField().then {
    $0.autocorrectionType = .no
    $0.borderStyle = .roundedRect
    $0.font = Font.titleLabel
    $0.placeholder = "Do something..."
  }


  // MARK: Initializing

  init(viewModel: @escaping TaskEditViewModelType) {
    super.init()
    self.navigationItem.leftBarButtonItem = self.cancelButtonItem
    self.navigationItem.rightBarButtonItem = self.doneButtonItem
    self.viewModel = viewModel
  }

  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: View Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    self.view.addSubview(self.titleInput)
    self.configure(self.viewModel)
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

  private func configure(_ viewModel: TaskEditViewModelType) {
    let cancelAlertDidSelectAction = PublishSubject<TaskEditViewCancelAlertAction>()

    let input = TaskEditViewModelInputs(cancelButtonItemDidTap: self.cancelButtonItem.rx.tap.asObservable(),
                                        doneButtonItemDidTap: self.doneButtonItem.rx.tap.asObservable(),
                                        titleInputDidChangeText: self.titleInput.rx.text.changed.asObservable(),
                                        cancelAlertDidSelectAction: cancelAlertDidSelectAction)

    let output = viewModel(input)

    // Output
    output.navigationBarTitle
      .drive(self.navigationItem.rx.title)
      .addDisposableTo(self.disposeBag)

    output.doneButtonEnabled
      .drive(self.doneButtonItem.rx.isEnabled)
      .addDisposableTo(self.disposeBag)

    output.titleInputText
      .drive(self.titleInput.rx.text)
      .addDisposableTo(self.disposeBag)

    output.presentCancelAlert
      .subscribe(onNext: { [weak self] actions in
        guard let `self` = self else { return }
        self.view.endEditing(true)
        let alertController = UIAlertController(
          title: "Really?",
          message: "Changes will be lost.",
          preferredStyle: .alert
        )
        actions
          .map { action -> UIAlertAction in
            let handler: (UIAlertAction) -> Void =  { _ in
              cancelAlertDidSelectAction.onNext(action)
            }
            switch action {
            case .leave:
              return UIAlertAction(title: "Leave", style: .destructive, handler: handler)
            case .stay:
              return UIAlertAction(title: "Stay", style: .default, handler: handler)
            }
          }
          .forEach(alertController.addAction)
        self.present(alertController, animated: true, completion: nil)
      })
      .addDisposableTo(self.disposeBag)

    output.dismissViewController
      .subscribe(onNext: { [weak self] in
        self?.view.endEditing(true)
        self?.dismiss(animated: true, completion: nil)
      })
      .addDisposableTo(self.disposeBag)
  }

}

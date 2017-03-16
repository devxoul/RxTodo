//
//  TaskEditViewController.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 7/2/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import UIKit

final class TaskEditViewController: BaseViewController {

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

  init(viewModel: TaskEditViewModelType) {
    super.init()
    self.navigationItem.leftBarButtonItem = self.cancelButtonItem
    self.navigationItem.rightBarButtonItem = self.doneButtonItem
    self.configure(viewModel)
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

  private func configure(_ viewModel: TaskEditViewModelType) {
    let viewModel = viewModel as! TaskEditViewModel

    self.rx.deallocated
      .bindTo(viewModel.deallocate)
      .addDisposableTo(self.disposeBag)

    self.titleInput.rx.text
      .bindTo(viewModel.title)
      .addDisposableTo(self.disposeBag)

    viewModel.title.asDriver()
      .drive(self.titleInput.rx.text)
      .addDisposableTo(self.disposeBag)

    viewModel.canSubmit
      .drive(self.doneButtonItem.rx.isEnabled)
      .addDisposableTo(self.disposeBag)

    self.doneButtonItem.rx.tap
      .bindTo(viewModel.submit)
      .addDisposableTo(self.disposeBag)

    self.cancelButtonItem.rx.tap
      .withLatestFrom(viewModel.shouldConfirm)
      .subscribe(onNext: { [weak self] shouldConfirm in
        guard let `self` = self else { return }
        if !shouldConfirm {
          self.dismiss(animated: true, completion: nil)
        }
        let alertController = UIAlertController(
          title: "Really?",
          message: "Changes will be lost.",
          preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "Leave", style: .destructive) { _ in
          self.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(UIAlertAction(title: "Stay", style: .cancel, handler: nil))
      })
      .addDisposableTo(self.disposeBag)
  }

}

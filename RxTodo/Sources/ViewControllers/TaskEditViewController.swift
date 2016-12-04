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
    
    // MARK: Rx
    private let disposeBag = DisposeBag()

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
    let cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    let titleInput = UITextField().then {
        $0.autocorrectionType = .no
        $0.font = Font.titleLabel
        $0.layer.cornerRadius = Metric.titleInputCornerRadius
        $0.layer.borderWidth = Metric.titleInputBorderWidth
        $0.layer.borderColor = Color.titleInputBorder.cgColor
    }


    // MARK: Initializing

    init(viewModel: TaskEditViewModelType) {
        super.init()
        navigationItem.leftBarButtonItem = cancelBarButtonItem
        navigationItem.rightBarButtonItem = doneBarButtonItem
        configure(viewModel)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(titleInput)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleInput.becomeFirstResponder()
    }

    override func setupConstraints() {
        titleInput.snp.makeConstraints { make in
          make.top.equalTo(20 + 44 + Metric.padding)
          make.left.equalTo(Metric.padding)
          make.right.equalTo(-Metric.padding)
        }
    }

    // MARK: Configuring

    private func configure(_ viewModel: TaskEditViewModelType) {
        // 2-Way Binding
        (titleInput.rx.text <-> viewModel.title)
          .addDisposableTo(disposeBag)

        // Input
        cancelBarButtonItem.rx.tap
          .bindTo(viewModel.cancelButtonDidTap)
          .addDisposableTo(disposeBag)

        doneBarButtonItem.rx.tap
          .bindTo(viewModel.doneButtonDidTap)
          .addDisposableTo(disposeBag)

        // Output
        viewModel.navigationBarTitle
          .drive(navigationItem.rx.title)
          .addDisposableTo(disposeBag)

        viewModel.doneButtonEnabled
          .drive(doneBarButtonItem.rx.isEnabled)
          .addDisposableTo(disposeBag)

        viewModel.presentCancelAlert
          .drive(onNext: { [weak self] title, message, leaveTitle, stayTitle in
            guard let strongSelf = self else { return }
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let actions = [
              UIAlertAction(title: leaveTitle, style: .destructive) { _ in
                viewModel.alertLeaveButtonDidTap.onNext()
              },
              UIAlertAction(title: stayTitle, style: .default) { _ in
                strongSelf.titleInput.becomeFirstResponder()
                viewModel.alertStayButtonDidTap.onNext()
              }
            ]
            actions.forEach(alertController.addAction)
            
            strongSelf.view.endEditing(true)
            strongSelf.present(alertController, animated: true, completion: nil)
          })
          .addDisposableTo(disposeBag)

        viewModel.dismissViewController
          .drive(onNext: { [weak self] in
            self?.view.endEditing(true)
            self?.dismiss(animated: true, completion: nil)
          })
          .addDisposableTo(disposeBag)
    }

}

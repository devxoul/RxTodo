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
        self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem
        self.navigationItem.rightBarButtonItem = self.doneBarButtonItem
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
            make.top.equalTo(20 + 44 + Metric.padding)
            make.left.equalTo(Metric.padding)
            make.right.equalTo(-Metric.padding)
        }
    }


    // MARK: Configuring

    private func configure(_ viewModel: TaskEditViewModelType) {
        // 2-Way Binding
        (self.titleInput.rx.text <-> viewModel.title)
            .addDisposableTo(self.disposeBag)

        // Input
        self.cancelBarButtonItem.rx.tap
            .bindTo(viewModel.cancelButtonDidTap)
            .addDisposableTo(self.disposeBag)

        self.doneBarButtonItem.rx.tap
            .bindTo(viewModel.doneButtonDidTap)
            .addDisposableTo(self.disposeBag)

        // Output
        viewModel.navigationBarTitle
            .drive(self.navigationItem.rx.title)
            .addDisposableTo(self.disposeBag)

        viewModel.doneButtonEnabled
            .drive(self.doneBarButtonItem.rx.enabled)
            .addDisposableTo(self.disposeBag)

        viewModel.presentCancelAlert
            .driveNext { [weak self] title, message, leaveTitle, stayTitle in
                guard let `self` = self else { return }
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let actions = [
                    UIAlertAction(title: leaveTitle, style: .destructive) { _ in
                        viewModel.alertLeaveButtonDidTap.onNext()
                    },
                    UIAlertAction(title: stayTitle, style: .default) { _ in
                        self.titleInput.becomeFirstResponder()
                        viewModel.alertStayButtonDidTap.onNext()
                    }
                ]
                actions.forEach(alertController.addAction)
                self.view.endEditing(true)
                self.present(alertController, animated: true, completion: nil)
            }
            .addDisposableTo(self.disposeBag)

        viewModel.dismissViewController
            .driveNext { [weak self] in
                self?.view.endEditing(true)
                self?.dismiss(animated: true, completion: nil)
            }
            .addDisposableTo(self.disposeBag)
    }

}

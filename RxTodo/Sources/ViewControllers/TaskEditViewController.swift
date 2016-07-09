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
        static let titleInputBorderWidth = 1 / UIScreen.mainScreen().scale
    }

    struct Font {
        static let titleLabel = UIFont.systemFontOfSize(14)
    }

    struct Color {
        static let titleInputBorder = UIColor.lightGrayColor()
    }


    // MARK: Properties

    let cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: nil, action: Selector())
    let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: nil, action: Selector())
    let titleInput = UITextField().then {
        $0.autocorrectionType = .No
        $0.font = Font.titleLabel
        $0.layer.cornerRadius = Metric.titleInputCornerRadius
        $0.layer.borderWidth = Metric.titleInputBorderWidth
        $0.layer.borderColor = Color.titleInputBorder.CGColor
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
        self.view.backgroundColor = .whiteColor()
        self.view.addSubview(self.titleInput)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.titleInput.becomeFirstResponder()
    }

    override func setupConstraints() {
        self.titleInput.snp_makeConstraints { make in
            make.top.equalTo(20 + 44 + Metric.padding)
            make.left.equalTo(Metric.padding)
            make.right.equalTo(-Metric.padding)
        }
    }


    // MARK: Configuring

    private func configure(viewModel: TaskEditViewModelType) {
        // 2-Way Binding
        (self.titleInput.rx_text <-> viewModel.title)
            .addDisposableTo(self.disposeBag)

        // Input
        self.cancelBarButtonItem.rx_tap
            .bindTo(viewModel.cancelButtonDidTap)
            .addDisposableTo(self.disposeBag)

        self.doneBarButtonItem.rx_tap
            .bindTo(viewModel.doneButtonDidTap)
            .addDisposableTo(self.disposeBag)

        // Output
        viewModel.navigationBarTitle
            .drive(self.navigationItem.rx_title)
            .addDisposableTo(self.disposeBag)

        viewModel.doneButtonEnabled
            .drive(self.doneBarButtonItem.rx_enabled)
            .addDisposableTo(self.disposeBag)

        viewModel.presentCancelAlert
            .driveNext { [weak self] title, message, leaveTitle, stayTitle in
                guard let `self` = self else { return }
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                let actions = [
                    UIAlertAction(title: leaveTitle, style: .Destructive) { _ in
                        viewModel.alertLeaveButtonDidTap.onNext()
                    },
                    UIAlertAction(title: stayTitle, style: .Default) { _ in
                        self.titleInput.becomeFirstResponder()
                        viewModel.alertStayButtonDidTap.onNext()
                    }
                ]
                actions.forEach(alertController.addAction)
                self.view.endEditing(true)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            .addDisposableTo(self.disposeBag)

        viewModel.dismissViewController
            .driveNext { [weak self] in
                self?.view.endEditing(true)
                self?.dismissViewControllerAnimated(true, completion: nil)
            }
            .addDisposableTo(self.disposeBag)
    }

}

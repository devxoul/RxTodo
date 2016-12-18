//
//  BaseViewController.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 7/1/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import UIKit

import RxSwift

class BaseViewController: UIViewController {

    // MARK: Initializing
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }

    // MARK: Layout Constraints
    private(set) var didSetupConstraints = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.setNeedsUpdateConstraints()
    }

    override func updateViewConstraints() {
        if !didSetupConstraints {
          setupConstraints()
          didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }

    func setupConstraints() {
        // Override point
    }
}

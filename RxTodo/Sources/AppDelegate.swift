//
//  AppDelegate.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 7/1/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import UIKit

import CGFloatLiteral
import ManualLayout
import SnapKit
import Then

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window.backgroundColor = .whiteColor()
        window.makeKeyAndVisible()

        let viewModel = TaskListViewModel()
        let viewController = TaskListViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        window.rootViewController = navigationController

        self.window = window
        return true
    }

}

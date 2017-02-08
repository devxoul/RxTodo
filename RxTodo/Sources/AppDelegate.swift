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
import RxOptional
import SnapKit
import Then

class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.backgroundColor = .white
    window.makeKeyAndVisible()

    let serviceProvider = ServiceProvider()
    let viewModel = createTaskListViewModel(provider: serviceProvider)
    let viewController = TaskListViewController(viewModel: viewModel)
    let navigationController = UINavigationController(rootViewController: viewController)
    window.rootViewController = navigationController

    self.window = window
    return true
  }

}

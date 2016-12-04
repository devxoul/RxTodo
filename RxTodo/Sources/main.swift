//
//  main.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 8/9/16.
//  Copyright © 2016 Suyeol Jeon. All rights reserved.
//

import Foundation
import UIKit

final class MockAppDelegate: UIResponder, UIApplicationDelegate {}

private func appDelegateClassName() -> String {
    let isTesting = NSClassFromString("XCTestCase") != nil
    return NSStringFromClass(isTesting ? MockAppDelegate.self : AppDelegate.self)
}

UIApplicationMain(
    CommandLine.argc,
    UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(
        to: UnsafeMutablePointer<Int8>.self,
        capacity: Int(CommandLine.argc)
    ),
    NSStringFromClass(UIApplication.self),
    appDelegateClassName()
)

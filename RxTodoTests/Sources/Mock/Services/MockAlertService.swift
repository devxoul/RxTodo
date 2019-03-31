//
//  MockAlertService.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 30/03/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

import UIKit
@testable import RxTodo

import RxSwift
import Then

final class MockAlertService: BaseService, AlertServiceType, Then {

  var selectAction: AlertActionType?

  func show<Action: AlertActionType>(
    title: String?,
    message: String?,
    preferredStyle: UIAlertController.Style,
    actions: [Action]
  ) -> Observable<Action> {
    guard let selectAction = self.selectAction as? Action else { return .empty() }
    return .just(selectAction)
  }

}

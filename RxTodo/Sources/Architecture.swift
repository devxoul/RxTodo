//
//  Architecture.swift
//  RxTodo
//
//  Created by Suyeol Jeon on 26/03/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

//////
// This code will become an independent library in the future.
//////

import RxSwift

// MARK: - Reactor

public struct NoAction {}

public protocol ReactorType {
  associatedtype Action
  associatedtype State

  var action: PublishSubject<Action> { get }
  var initialState: State { get }
  var state: Observable<State> { get }

  func transformAction(_ action: Observable<Action>) -> Observable<Action>
  func reduce(state: State, action: Action) -> Observable<State>
}

open class Reactor<ActionType, StateType>: ReactorType {
  public typealias Action = ActionType
  public typealias State = StateType

  open let action: PublishSubject<Action> = .init()
  open let initialState: State
  open private(set) lazy var state: Observable<State> = self.createStateStream()

  public init(initialState: State) {
    self.initialState = initialState
  }

  func createStateStream() -> Observable<State> {
    return self.transformAction(self.action)
      .scan(.just(self.initialState)) { [weak self] stateObservable, action -> Observable<State> in
        return stateObservable
          .flatMap { state -> Observable<State> in
            guard let `self` = self else { return .empty() }
            return self.reduce(state: state, action: action)
          }
          .shareReplay(1)
      }
      .flatMap { $0 }
      .startWith(self.initialState)
      .shareReplay(1)
      .observeOn(ConcurrentMainScheduler.instance)
  }

  open func transformAction(_ action: Observable<Action>) -> Observable<Action> {
    return action
  }

  open func reduce(state: State, action: Action) -> Observable<State> {
    return .just(self.initialState)
  }
}


// MARK: - View

public protocol ViewType {
  associatedtype Reactor: ReactorType

  func configure(reactor: Reactor)
}

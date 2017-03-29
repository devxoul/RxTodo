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
import RxDataSources

// MARK: - Reactor

public enum Phase<Value> {
  case begin
  case end(Value)
}

public struct NoAction {}

public protocol ReactorType {
  associatedtype Action
  associatedtype State

  /// The action from the view. Bind user inputs to this subject.
  var action: PublishSubject<Action> { get }

  /// The initial state.
  var initialState: State { get }

  /// The current state. This value is changed just after the state stream emits a new state.
  var currentState: State { get }

  /// The state stream. Use this observable to observe the state changes.
  var state: Observable<State> { get }

  /// Transforms the action. This is a good place to perform side-effects such as async tasks. This
  /// method is called once before the state stream is created.
  func transform(action: Observable<Action>) -> Observable<Action>

  /// Generates a new state from the previous state with the action. It should be purely functional
  /// so don't perform side-effects here. This method is called every time when the action is
  /// performed.
  func reduce(state: State, action: Action) -> State

  /// Transforms the state stream. Use this function to perform side-effects such as logging. This
  /// method is called once after the state stream is created.
  func transform(state: Observable<State>) -> Observable<State>
}

extension ReactorType {
  public func transform(action: Observable<Action>) -> Observable<Action> {
    return action
  }

  public func reduce(state: State, action: Action) -> State {
    return state
  }

  public func transform(state: Observable<State>) -> Observable<State> {
    return state
  }
}

/// The base class of reactors.
open class Reactor<ActionType, StateType>: ReactorType {
  public typealias Action = ActionType
  public typealias State = StateType

  open let action: PublishSubject<Action> = .init()

  open let initialState: State
  open private(set) var currentState: State
  open lazy private(set) var state: Observable<State> = self.createStateStream()

  public init(initialState: State) {
    self.initialState = initialState
    self.currentState = initialState
  }

  func createStateStream() -> Observable<State> {
    return self.transform(action: self.action)
      .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
      .scan(self.initialState) { [weak self] state, action -> State in
        guard let `self` = self else { return state }
        return self.reduce(state: state, action: action)
      }
      .startWith(self.initialState)
      .shareReplay(1)
      .do(onNext: { [weak self] state in
        self?.currentState = state
      })
      .observeOn(MainScheduler.instance)
  }

  open func transform(action: Observable<Action>) -> Observable<Action> {
    return action
  }

  open func reduce(state: State, action: Action) -> State {
    return state
  }

  open func transform(state: Observable<State>) -> Observable<State> {
    return state
  }
}


// MARK: - View

public protocol ViewType {
  associatedtype Reactor: ReactorType

  var reactor: Reactor? { get }

  func configure(reactor: Reactor)
  func configure(reactor: Reactor?) // sugar
}

extension ViewType {
  func configure(reactor: Reactor?) {
    if let reactor = reactor {
      self.configure(reactor: reactor)
    }
  }
}

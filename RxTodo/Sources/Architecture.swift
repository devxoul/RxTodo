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
public struct NoMutation {}

public protocol ReactorType {
  associatedtype Action
  associatedtype Mutation
  associatedtype State

  /// The action from the view. Bind user inputs to this subject.
  var action: PublishSubject<Action> { get }

  /// The initial state.
  var initialState: State { get }

  /// The current state. This value is changed just after the state stream emits a new state.
  var currentState: State { get }

  /// The state stream. Use this observable to observe the state changes.
  var state: Observable<State> { get }

  /// Transforms the action. Use this function to combine with other observables. This method is
  /// called once before the state stream is created.
  func transform(action: Observable<Action>) -> Observable<Action>

  /// Commits mutation from the action. This is the best place to perform side-effects such as
  /// async tasks.
  func mutate(action: Action) -> Observable<Mutation>

  /// Generates a new state with the previous state and the action. It should be purely functional
  /// so it should not perform any side-effects here. This method is called every time when the
  /// mutation is committed.
  func reduce(state: State, mutation: Mutation) -> State

  /// Transforms the state stream. Use this function to perform side-effects such as logging. This
  /// method is called once after the state stream is created.
  func transform(state: Observable<State>) -> Observable<State>
}

extension ReactorType {
  public func transform(action: Observable<Action>) -> Observable<Action> {
    return action
  }

  public func transform(state: Observable<State>) -> Observable<State> {
    return state
  }
}

extension ReactorType where Action == Mutation {
  public func mutate(action: Action) -> Observable<Mutation> {
    return .just(action)
  }
}

/// The base class of reactors.
open class Reactor<ActionType, MutationType, StateType>: ReactorType {
  public typealias Action = ActionType
  public typealias Mutation = MutationType
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
    let state = self.transform(action: self.action)
      .flatMap { [weak self] action -> Observable<Mutation> in
        guard let `self` = self else { return .empty() }
        return self.mutate(action: action)
      }
      .scan(self.initialState) { [weak self] state, mutation -> State in
        guard let `self` = self else { return state }
        return self.reduce(state: state, mutation: mutation)
      }
      .startWith(self.initialState)
      .shareReplay(1)
      .do(onNext: { [weak self] state in
        self?.currentState = state
      })
      .observeOn(MainScheduler.instance)
    return self.transform(state: state)
  }

  open func transform(action: Observable<Action>) -> Observable<Action> {
    return action
  }

  open func mutate(action: Action) -> Observable<Mutation> {
    return .empty()
  }

  open func reduce(state: State, mutation: Mutation) -> State {
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

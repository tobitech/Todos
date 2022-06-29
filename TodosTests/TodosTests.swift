//
//  TodosTests.swift
//  TodosTests
//
//  Created by Oluwatobi Omotayo on 28/06/2022.
//

import ComposableArchitecture
import XCTest
@testable import Todos

class TodosTests: XCTestCase {
  
  func testCompletingTodo() throws {
    let store = TestStore(
      initialState: AppState(
        todos: [
          Todo(
            description: "Milk",
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            isComplete: false
          )
        ]
      ),
      reducer: appReducer,
      environment: AppEnvironment(
        uuid: { fatalError("unimplemented") } // because we don't expect this test to have this dependency called.
      )
    )
    
    // the assert function allows us to feed a series of system actions
    // to it and see how the system evolves.
    store.assert(
      // 1: send an action
      .send(.todo(index: 0, action: .checkboxTapped)) {
        // 2: sending an action is only half of the assert story,
        // we need to describe how the state changes after the action is sent to the store.
        // we make mutation to the state that we expect to happen in a trailing closure.
        $0.todos[0].isComplete = true
      },
      .do {
        let expectation = self.expectation(description: "wait")
        _ = XCTWaiter.wait(for: [expectation], timeout: 1)
      },
      .receive(.todoDelayCompleted)
    )
  }
  
  
  func testAddTodo() {
    let store = TestStore(
      initialState: AppState(
        todos: []
      ),
      reducer: appReducer,
      environment: AppEnvironment(
        uuid: { UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")! }
      )
    )
    // check the episode exercise for an implementation of a deterministic UUID generator for a reducer that needs a random UUID
    
    store.assert(
      .send(.addButtonTapped) {
        $0.todos = [
          Todo(
            description: "",
            id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!,
            isComplete: false
          )
        ]
      }
    )
  }
  
  func testTodoSorting() throws {
    let store = TestStore(
      initialState: AppState(
        todos: [
          Todo(
            description: "Milk",
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            isComplete: false
          ),
          Todo(
            description: "Eggs",
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            isComplete: false
          )
        ]
      ),
      reducer: appReducer,
      environment: AppEnvironment(
        uuid: { fatalError("unimplemented") } // because we don't expect this test to have this dependency called.
      )
    )
    
    store.assert(
      .send(.todo(index: 0, action: .checkboxTapped)) {
        $0.todos[0].isComplete = true
      },
      .do {
        // do any imperative work that we want to happen
        // in between steps of our assert.
        // we will wait 1sec using XCTest expectation API
        let expectation = self.expectation(description: "wait")
        _ = XCTWaiter.wait(for: [expectation], timeout: 1)
      },
      .receive(.todoDelayCompleted) {
        $0.todos.swapAt(0, 1)
      }
    )
  }
  
  func testTodoSorting_Cancellation() throws {
    let store = TestStore(
      initialState: AppState(
        todos: [
          Todo(
            description: "Milk",
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            isComplete: false
          ),
          Todo(
            description: "Eggs",
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            isComplete: false
          )
        ]
      ),
      reducer: appReducer,
      environment: AppEnvironment(
        uuid: { fatalError("unimplemented") } // because we don't expect this test to have this dependency called.
      )
    )
    
    store.assert(
      .send(.todo(index: 0, action: .checkboxTapped)) {
        $0.todos[0].isComplete = true
      },
      .do {
        let expectation = self.expectation(description: "wait")
        _ = XCTWaiter.wait(for: [expectation], timeout: 0.5)
      },
      .send(.todo(index: 0, action: .checkboxTapped)) {
        $0.todos[0].isComplete = false
      },
      .do {
        let expectation = self.expectation(description: "wait")
        _ = XCTWaiter.wait(for: [expectation], timeout: 1)
      },
      .receive(.todoDelayCompleted)
    )
  }
}

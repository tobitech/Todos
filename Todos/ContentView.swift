//
//  ContentView.swift
//  Todos
//
//  Created by Oluwatobi Omotayo on 27/06/2022.
//

import Combine
import ComposableArchitecture
import SwiftUI

struct Todo: Equatable, Identifiable {
  var description = ""
  let id: UUID
  var isComplete = false
}

enum TodoAction: Equatable {
  case checkboxTapped
  case textFieldChanged(String)
}

// In case the todo needs some dependencies to produce some effects
struct TodoEnvironment {
}

let todoReducer = Reducer<Todo, TodoAction, TodoEnvironment> { state, action, environment in
  switch action {
  case .checkboxTapped:
    // basically what we do inside these cases is mutate our state and return an effect.
    state.isComplete.toggle()
    return .none
  case .textFieldChanged(let text):
    state.description = text
    return .none
  }
}

struct AppState: Equatable {
  var todos: [Todo]
}


enum AppAction: Equatable {
  case addButtonTapped
  case todo(index: Int, action: TodoAction)
  case todoDelayCompleted
  //  case todoCheckboxTapped(index: Int)
  //  case todoTextFieldChanged(index: Int, text: String)
}

struct AppEnvironment {
  // typealias for the below verbose code.
  var mainQueue: AnySchedulerOf<DispatchQueue>
  
  // this is verbose
//  var mainQueue: AnyScheduler<DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions>
  
  // we will be able to do this when Swift supports existential types.
//  var mainQueue: Scheduler where .SchedulerTimeType == DispatchQueue.SchedulerTimeType, .SchedulerOptions == DispatchQueue.SchedulerOptions
  var uuid: () -> UUID
}

// We expected that Swift has `AnyScheduler` a type erasure for the Scheduler protocol with an associated type just like these. but it doesn't
// that's why it was included in the composable architecture.
// AnyCancellable
// AnyPublisher
// AnyView
// AnyHashable
// AnyCollection
// AnyIterator
// AnySubscriber

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
  todoReducer.forEach(
    state: \AppState.todos,
    action: /AppAction.todo(index:action:),
    environment: { _ in TodoEnvironment() }
  ),
  Reducer { state, action, environment in
    switch action {
    case .addButtonTapped:
      state.todos.insert(Todo(id: environment.uuid()), at: 0)
      return .none
      
    case .todo(index: _, action: .checkboxTapped):
      // we can do our sorting logic here. Since the appReducer has access to all the todos.
      
      // concatenate is from combine: allows us to queue some operations together
//      return .concatenate(
//        // cancel any inflight delayed todo completion.
//        .cancel(id: "completion effect"),
//
//        Effect(value: AppAction.todoDelayCompleted)
//          .delay(for: 1, scheduler: DispatchQueue.main)
//          .eraseToEffect()
//          .cancellable(id: "completion effect")
//      )
      
      // Swift feature that allows us define types inline within functions.
      // this type isn't visible to anyone outside this function, in fact it's only visible to this switch case scope.
      // use this to prevent typos when using hardcoded string
      struct CancelDelayID: Hashable {}
      
      return Effect(value: AppAction.todoDelayCompleted)
        .debounce(id: CancelDelayID(), for: 1, scheduler: environment.mainQueue)
//        .debounce(id: CancelDelayID(), for: 1, scheduler: DispatchQueue.main)
//        .delay(for: 1, scheduler: DispatchQueue.main)
//        .eraseToEffect()
//        .cancellable(id: CancelDelayID(), cancelInFlight: true)
      
    case .todo(index: let index, action: let action):
      // this is where you can layer additional functionality onto the app reducer to listen for specific todo actions.
      return .none
      
    case .todoDelayCompleted:
      
      // the standard library sort function isn't a stable sort but we can go around that with this implementation to technically achieve a stable sort.
      state.todos = state.todos
        .enumerated()
        .sorted { lhs, rhs in
          (!lhs.element.isComplete && rhs.element.isComplete) || lhs.offset < rhs.offset
        }
      // .map { $0.element }
        .map(\.element) // Swift 5.2 keypath feature
      
      return .none
    }
  }
).debug()


struct ContentView: View {
  
  let store: Store<AppState, AppAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      NavigationView {
        List {
          ForEachStore(
            self.store.scope(
              state: \.todos,
              action: AppAction.todo(index:action:)
            ),
            content: TodoView.init(store:)
          )
        }
        .navigationTitle("Todos")
        .navigationBarItems(
          trailing: Button("Add") {
            viewStore.send(.addButtonTapped)
          }
        )
      }
    }
  }
}

struct TodoView: View {
  
  let store: Store<Todo, TodoAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      HStack {
        Button(action: {
          viewStore.send(.checkboxTapped)
        }) {
          Image(systemName: viewStore.isComplete ? "checkmark.square" : "square")
        }
        .buttonStyle(PlainButtonStyle())
        
        TextField(
          "Untitled",
          text: viewStore.binding(
            get: \.description,
            send: TodoAction.textFieldChanged
          )
        )
      }
      .foregroundColor(viewStore.isComplete ? .gray : nil)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(
      store: Store(
        initialState: AppState(
          todos: [
            Todo(
              description: "Milk",
              id: UUID(),
              isComplete: false
            ),
            Todo(
              description: "Eggs",
              id: UUID(),
              isComplete: false
            ),
            Todo(
              description: "Hand Soap",
              id: UUID(),
              isComplete: true
            )
          ]
        ),
        reducer: appReducer,
        environment: AppEnvironment(
          mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
          uuid: UUID.init
        )
      )
    )
  }
}

//
//  ContentView.swift
//  Todos
//
//  Created by Oluwatobi Omotayo on 27/06/2022.
//

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
  //  case todoCheckboxTapped(index: Int)
  //  case todoTextFieldChanged(index: Int, text: String)
}

struct AppEnvironment {
  var uuid: () -> UUID
}

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
      // the standard library sort function isn't a stable sort but we can go around that with this implementation to technically achieve a stable sort.
      state.todos = state.todos
        .enumerated()
        .sorted { lhs, rhs in
          (!lhs.element.isComplete && rhs.element.isComplete) || lhs.offset < rhs.offset
        }
        // .map { $0.element }
        .map(\.element) // Swift 5.2 keypath feature
      return .none
      
    case .todo(index: let index, action: let action):
      // this is where you can layer additional funcationlity onto the app reducer to listen for specific todo actions.
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
        environment: AppEnvironment(uuid: UUID.init)
      )
    )
  }
}

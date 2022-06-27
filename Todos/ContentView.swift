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

enum TodoAction {
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


enum AppAction {
  case todo(index: Int, action: TodoAction)
  //  case todoCheckboxTapped(index: Int)
  //  case todoTextFieldChanged(index: Int, text: String)
}

struct AppEnvironment {
  
}

let appReducer: Reducer<AppState, AppAction, AppEnvironment> = todoReducer.forEach(
  state: \AppState.todos,
  action: /AppAction.todo(index:action:),
  environment: { _ in TodoEnvironment() }
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
        environment: AppEnvironment()
      )
    )
  }
}

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

struct AppState: Equatable {
  var todos: [Todo]
}


enum AppAction {
  case todoCheckboxTapped(index: Int)
  case todoTextFieldChanged(index: Int, text: String)
}

struct AppEnvironment {

}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
  switch action {
  case .todoCheckboxTapped(index: let index):
    // basically what we do inside these cases is mutate our state and return an effect.
    state.todos[index].isComplete.toggle()
    return .none
  case .todoTextFieldChanged(index: let index, text: let text):
    state.todos[index].description = text
    return .none
  }
}.debug()


struct ContentView: View {
  
  let store: Store<AppState, AppAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      NavigationView {
        List {
          // More technically correct way to get index out of the loop
          // zip(viewStore.todos.indices, viewStore.todos)
          // Use this zip based approach for production app.
          // .enumerated() approach works for now because we have a zero based index,
          ForEach(Array(viewStore.todos.enumerated()), id: \.element.id) { index, todo in
            HStack {
              Button(action: {
                viewStore.send(.todoCheckboxTapped(index: index))
              }) {
                Image(systemName: todo.isComplete ? "checkmark.square" : "square")
              }
              .buttonStyle(PlainButtonStyle())
              
              TextField(
                "Untitled",
                text: viewStore.binding(
                  get: { $0.todos[index].description },
                  send: { .todoTextFieldChanged(index: index, text: $0) }
                )
              )
            }
            .foregroundColor(todo.isComplete ? .gray : nil)
          }
        }
        .navigationTitle("Todos")
      }
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

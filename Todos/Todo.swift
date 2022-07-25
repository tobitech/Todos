//
//  Todo.swift
//  Todos
//
//  Created by Oluwatobi Omotayo on 25/07/2022.
//

import ComposableArchitecture
import SwiftUI

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

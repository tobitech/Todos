//
//  TodosApp.swift
//  Todos
//
//  Created by Oluwatobi Omotayo on 27/06/2022.
//

import ComposableArchitecture
import SwiftUI

@main
struct TodosApp: App {
  var body: some Scene {
    WindowGroup {
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
          reducer: appReducer, // .debug(),
          environment: AppEnvironment(
            uuid: UUID.init
          )
        )
      )
    }
  }
}

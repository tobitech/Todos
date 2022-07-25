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
      VStack(spacing: 0) {
        AppView(
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
              mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
              uuid: UUID.init
            )
          )
        )
        TodoDetailsView(
          store: Store(
            initialState: DetailsState(),
            reducer: detailsReducer,
            environment: DetailsEnvironment()
          )
        )
      }
    }
  }
}

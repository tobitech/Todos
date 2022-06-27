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
          initialState: AppState(),
          reducer: appReducer,
          environment: AppEnvironment()
        )
      )
    }
  }
}

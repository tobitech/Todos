//
//  ContentView.swift
//  Todos
//
//  Created by Oluwatobi Omotayo on 27/06/2022.
//

import ComposableArchitecture
import SwiftUI

struct AppState {
  
}


enum AppAction {
}

struct AppEnvironment {

}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
  switch action {
    
  }
}


struct ContentView: View {
  
  let store: Store<AppState, AppAction>
  
  var body: some View {
    Text("Hello, world!")
      .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(
      store: Store(
        initialState: AppState(),
        reducer: appReducer,
        environment: AppEnvironment()
      )
    )
  }
}

//
//  TodoDetailsView.swift
//  Todos
//
//  Created by Oluwatobi Omotayo on 11/07/2022.
//

import ComposableArchitecture
import SwiftUI

let detailsReducer = Reducer<DetailsState, DetailsAction, DetailsEnvironment> { state, action, environment in
  switch action {
  case .options:
    print("showing options...")
    return .none
  }
}

struct DetailsState: Equatable {
  var title: String?
}

struct DetailsEnvironment: Equatable {
  
}

enum DetailsAction {
  case options
}

struct TodoDetailsView: View {
  
  let store: Store<DetailsState, DetailsAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        Button("Show Options") {
          viewStore.send(.options)
        }
        Text("Details Screen")
      }
    }
  }
}

struct TodoDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    TodoDetailsView(
      store: Store(
        initialState: DetailsState(),
        reducer: detailsReducer,
        environment: DetailsEnvironment()
      )
    )
  }
}

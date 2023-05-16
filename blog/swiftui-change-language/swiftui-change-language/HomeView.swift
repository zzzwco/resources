//
//  HomeView.swift
//  swiftui-change-language
//
//  Created by Bruce on 2023/5/16.
//

import SwiftUI

struct HomeView: View {
  // AppState holds global application settings and triggers view refreshes upon changes.
  @EnvironmentObject private var appState: AppState
  
  var body: some View {
    VStack {
      Text("Home".localized)
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}

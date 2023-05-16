//
//  swiftui_change_languageApp.swift
//  swiftui-change-language
//
//  Created by Bruce on 2023/5/16.
//

import SwiftUI

@main
struct swiftui_change_languageApp: App {
  @StateObject private var appState = AppState()
  
  var body: some Scene {
    WindowGroup {
      rootView
        .environmentObject(appState)
    }
  }
  
  private var rootView: some View {
    TabView {
      HomeView()
        .tabItem {
          Label("Home".localized, systemImage: "house")
        }
      
      SettingsView()
        .tabItem {
          Label("Settings".localized, systemImage: "gear")
        }
    }
  }
}

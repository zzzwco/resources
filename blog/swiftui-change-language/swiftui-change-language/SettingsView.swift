//
//  SettingsView.swift
//  swiftui-change-language
//
//  Created by Bruce on 2023/5/16.
//

import SwiftUI

struct SettingsView: View {
  @EnvironmentObject private var appState: AppState
  
  var body: some View {
    NavigationStack {
      Form {
        NavigationLink {
          ChangeLanguageView()
        } label: {
          Text("Language".localized)
        }
      }
      .navigationTitle("Settings".localized)
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
  }
}

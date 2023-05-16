//
//  ChangeLanguageView.swift
//  swiftui-change-language
//
//  Created by Bruce on 2023/5/16.
//

import SwiftUI

struct ChangeLanguageView: View {
  @EnvironmentObject private var appState: AppState
  
  private let languages = [
    "English": "en",
    "中文": "zh-Hans"
  ]
  
  var body: some View {
    Form {
      ForEach(Array(languages.keys), id: \.self) { v in
        LabeledContent(v) {
          Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.accentColor)
            .opacity(isSelected(v) ? 1 : 0)
        }
        .contentShape(Rectangle())
        .onTapGesture {
          if isSelected(v) { return }
          appState.language = languages[v]!
        }
      }
    }
    .navigationTitle("Language".localized)
    .navigationBarTitleDisplayMode(.inline)
  }
  
  private func isSelected(_ language: String) -> Bool {
    appState.language == languages[language]
  }
}

struct ChangeLanguageView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeLanguageView()
    }
}

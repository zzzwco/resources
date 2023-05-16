//
//  AppState.swift
//  swiftui-change-language
//
//  Created by Bruce on 2023/5/16.
//

import SwiftUI

final class AppState: ObservableObject {
  
  @AppStorage("language") var language = "en"
}

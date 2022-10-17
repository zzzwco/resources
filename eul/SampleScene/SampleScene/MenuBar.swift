//
//  MenuBar.swift
//  SampleScene
//
//  Created by zzzwco on 2022/10/17.
//

import SwiftUI

struct MenuBar: View {
  
  @Environment(\.openWindow) private var openWindow
  
  var body: some View {
    VStack {
      Button("Open WindowGroup1") {
        openWindow(id: "WindowGroup1")
      }
      .keyboardShortcut("1")
      
      Button("Open WindowGroup2") {
        openWindow(id: "WindowGroup2")
      }
      .keyboardShortcut("2")
      
      Divider()
      Button("Quit") {
        exit(0)
      }
      .keyboardShortcut("q")
    }
  }
}

struct MenuBar_Previews: PreviewProvider {
  static var previews: some View {
    MenuBar()
  }
}

//
//  SampleSceneApp.swift
//  SampleScene
//
//  Created by zzzwco on 2022/10/15.
//

import SwiftUI

@main
struct SampleSceneApp: App {
  
  var body: some Scene {
    SharedScene()
    
    #if os(macOS)
    macScene()
    #endif
  }
}

struct SharedScene: Scene {
  
  var body: some Scene {
    WindowGroup("MainWindow") {
      MainWindow()
    }
    #if os(macOS)
    // 设置窗口默认尺寸
    .defaultSize(width: 600, height: 1000)
    // 设置默认位置
    .defaultPosition(.center)
    // 系统默认快捷键为 ⌘ + N，这里设置为 ⌘ + T
    .keyboardShortcut("t", modifiers: [.command])
    #endif
    
    WindowGroup("WindowGroup1", id: "WindowGroup1", for: String.self) { $value in
      Text(value ?? "WindowGroup1 没有传值")
    }
    #if os(macOS)
    .keyboardShortcut("1", modifiers: [.command, .shift])
    #endif

    WindowGroup("WindowGroup2", id: "WindowGroup2", for: String.self) { $value in
      Text(value)
    } defaultValue: {
      "WindowGroup2 默认传值"
    }
    #if os(macOS)
    .keyboardShortcut("2", modifiers: [.command, .shift])
    #endif
  }
}

#if os(macOS)
struct macScene: Scene {
  
  var body: some Scene {
    // Window > SingleWindow，或者使用快捷键 ⌘ + ⇧ + S
    Window("SingleWindow", id: "SingleWindow") {
      Text("I'm a single, unque window.")
    }
    .keyboardShortcut("s", modifiers: [.command, .shift])

    Settings {
      TabView {
        Color.blue
          .tabItem {
            Label("Settings 1", systemImage: "gear")
          }

        Color.cyan
          .tabItem {
            Label("Settings 2", systemImage: "gearshape")
          }
      }
      .frame(minWidth: 600, minHeight: 390)
    }
    
    MenuBarExtra("SampleSceneMenuBar", systemImage: "bolt") {
      MenuBar()
    }
    .menuBarExtraStyle(.menu)
  }
}
#endif

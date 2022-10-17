//
//  MainWindow.swift
//  SampleScene
//
//  Created by zzzwco on 2022/10/15.
//

import SwiftUI

struct MainWindow: View {
  
  @State private var textColor: Color = .primary
  @State private var openWindowSelection = OpenWindowType.onlyId.rawValue
  @State private var openWindowId = "WindowGroup1"
  @State private var openWindowValue = "Default value"
  @Environment(\.openWindow) private var openWindow
  
  private let openWindowData = OpenWindowType.allCases.map { $0.rawValue }
  
  var body: some View {
    Form {
      Section {
        VStack(alignment: .leading) {
          ColorPicker("文字颜色", selection: $textColor)
            .foregroundColor(textColor)
          
          VStack(alignment: .leading, spacing: 5) {
            #if os(macOS)
            Text("使用 ⌘ + T 新建窗口")
            #else
            Text("iPad 支持多窗口，iPhone 不支持")
            #endif
            
            Text("试试在 Mac、iPad 上改变文字颜色后新建窗口")
              .font(.footnote)
              .foregroundColor(.secondary)
          }
          .foregroundColor(textColor)
        }
      } header: {
        Text("WindowGroup")
          .textCase(nil)
      }
      
      #if os(iOS)
      if UIDevice.current.userInterfaceIdiom == .pad {
        configWindowGroup
      }
      #elseif os(macOS)
      configWindowGroup
      #endif
      
      #if os(macOS)
      Section("Window") {
        Text("使用 ⌘ + ⇧ + S 打开一个独立的单窗口")
      }
      
      Section("Settings") {
        Text("使用 ⌘ + , 打开设置页面")
      }
      
      Section("MenuBarExtra") {
        Text("看看菜单栏")
      }
      #endif
      
      Section {
        Link(
          "参考：Building a Document-Based App with SwiftUI",
          destination: URL(string: "https://developer.apple.com/documentation/swiftui/building_a_document-based_app_with_swiftui?changes=latest_minor")!
        )
      } header: {
        Text("DocumentGroup")
          .textCase(nil)
      }
    }
    .formStyle(.grouped)
  }
  
  private var configWindowGroup: some View {
    Section {
      Picker("Select openWindow method", selection: $openWindowSelection) {
        ForEach(openWindowData, id: \.self) {
          Text($0)
        }
      }
      TextField("id", text: $openWindowId)
        .disabled(openWindowSelection == OpenWindowType.onlyValue.rawValue)
        .textFieldStyle(.roundedBorder)
      TextField("value", text: $openWindowValue)
        .disabled(openWindowSelection == OpenWindowType.onlyId.rawValue)
        .textFieldStyle(.roundedBorder)
    } footer: {
      VStack(alignment: footerAlignment) {
        if [OpenWindowType.onlyId, OpenWindowType.idAndValue]
          .map { $0.rawValue }.contains(openWindowSelection) {
            VStack(alignment: footerAlignment, spacing: 5) {
              Text("试试改变 id 后再执行 openWindow")
                .font(.body)
                .foregroundColor(.primary)
              Text("WindowGroup1、WindowGroup2 均为有效 id，其它无效")
                .font(.footnote)
                .foregroundColor(.secondary)
            }
        }
        Button("openWindow") {
          openWindowAction()
        }
        #if os(iOS)
        .buttonStyle(.borderedProminent)
        #endif
      }
    }
  }
  
  private var footerAlignment: HorizontalAlignment {
    var ans = HorizontalAlignment.leading
    #if os(macOS)
    ans = .trailing
    #endif
    return ans
  }
  
  private func openWindowAction() {
    switch openWindowSelection {
    case OpenWindowType.onlyId.rawValue:
      openWindow(id: openWindowId)
    case OpenWindowType.onlyValue.rawValue:
      openWindow(value: openWindowValue)
    case OpenWindowType.idAndValue.rawValue:
      openWindow(id: openWindowId, value: openWindowValue)
    default:
      break
    }
  }
}

extension MainWindow {
  
  enum OpenWindowType: String, CaseIterable {
    
    case onlyId = "openWindow(id:)"
    case onlyValue = "openWindow(value:)"
    case idAndValue = "openWindow(id:value:)"
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    MainWindow()
  }
}

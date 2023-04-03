//
//  main.swift
//  Swift5.8
//
//  Created by zzzwco on 2023/3/31.
//

import Foundation
import SwiftUI

// MARK: - 闭包内隐式调用 self

class Timer {
  var eventHandler: (() -> Void)?
  
  func start() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
      self.eventHandler?()
    }
  }
}

class ViewController {
  let timer = Timer()
  
  init() {
    timer.eventHandler = { [weak self] in
      guard let self else { return }
      // 如果已使用 [weak self] 捕获了 self 并且解包
      // 则无需显式调用 self
      doSomething()
    }
    timer.start()
  }
  
  func doSomething() {
    print("Doing something...")
  }
}

// MARK: - `@backDeployed(before:)` 属性

@available(macOS 12, *)
public struct Temperature {
  public var degreesCelsius: Double
  
  // ...
}

extension Temperature {
  @available(macOS 12, *)
  @backDeployed(before: macOS 13)
  public var degreesFahrenheit: Double {
    return (degreesCelsius * 9 / 5) + 32
  }
}

// MARK: - 集合类型支持向下类型转换

class A {}
class A1: A {}
class A2: A {}

func downcast(arr: [A]) {
  switch arr {
  case let a1 as [A1]:
    print("arr is [A1]: \(a1)")
  case let a2 as [A2]:
    print("arr is [A2]: \(a2)")
  default:
    print("Unknown collection type")
  }
}

// MARK: - #file & #filePath

print(#file)
print(#filePath)

// MARK: - 解除结果生成器中变量的使用限制

struct ContentView: View {
  
  var body: some View {
    lazy var v1: Int = .random(in: 0...10)
    var v2: Int { v1 * v1 }
    Text("v1: \(v1)") +
    Text("v2: \(v2)")
  }
}

// MARK: - 支持 Swift-DocC 生成关于 extensions 的文档

// $ swift package generate-documentation --include-extended-types



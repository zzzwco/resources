//
//  main.swift
//  Swift5.8
//
//  Created by zzzwco on 2023/3/31.
//

import Foundation

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


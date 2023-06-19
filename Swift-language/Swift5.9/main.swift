//
//  main.swift
//  Swift5.9
//
//  Created by Bruce on 2023/6/8.
//

import Foundation
import SwiftUI

// MARK: - if 和 switch 语句作为表达式

let s1 = if Bool.random() { "YES" } else { "NO" }

let s2 = switch Bool.random() {
case true: "YES"
case false: "NO"
}

// MARK: - 值和类型参数包

struct Pair<First, Second> {
  var first: First
  var second: Second
}

// each First, each Second 是两个类型的参数包
func makePairs<each First, each Second>(
  firsts first: repeat each First, // 参数包扩展，可以传入可变参数
  seconds second: repeat each Second
) -> (repeat Pair<each First, each Second>) {
  // 从参数包扩展 first 和 second 中各取一个值构建 Pair
  // 所有的 Pair 实例构成一个元组并返回
  return (repeat Pair(first: each first, second: each second))
}

let pairs = makePairs(firsts: 1, "hello", "world", seconds: true, 1.0, false)
// 'pairs' is '(Pair(1, true), Pair("hello", 2.0), Pair("world", false))'

// MARK: - DiscardingTaskGroups

/**
try await withThrowingDiscardingTaskGroup() { group in
  while let newConnection = try await listeningSocket.accept() {
    group.addTask {
      handleConnection(newConnection)
    }
  }
}
*/

// MARK: - Ownership

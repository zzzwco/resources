//
//  main.swift
//  Swift5.7
//
//  Created by zzzwco on 2022/11/19.
//

import Foundation
import RegexBuilder
import SwiftUI

// https://github.com/apple/swift/blob/main/CHANGELOG.md

let symbol = "======================\n"

// MARK: - Optional shorthand

printLog("Optional shorthand", symbol: symbol)

let s1: String? = "s1"

if let s1 {
  printLog(s1)
}

guard let s1 else {
  exit(0)
}
printLog(s1)

// MARK: - More powerful type inference

// MARK: Type inference from default expressions

func compute<C: Collection>(_ values: C = [0, 1, 2]) { }

compute([1, 2, 3]) // [Int]
compute(["a", "b", "c"]) // [String]
compute([1, "2", {}]) // [Any]

// MARK: Enable multi-statement closure parameter/result type inference

let _ = [-1, 0, 1].map { v -> String in
  if v < 0 {
    return "negative"
  } else if v > 0 {
    return "positive"
  } else {
    return "zero"
  }
}

let _ = [-1, 0, 1].map {
  if $0 < 0 {
    return "negative"
  } else if $0 > 0 {
    return "positive"
  } else {
    return "zero"
  }
}

// MARK: - Clarify the Execution of Non-Actor-Isolated Async Functions

class C { }

// 总是在全局的协作并发池上执行
func f(_: C) async { }

actor A {
  func g(c: C) async {
    // 总是在 actor 上执行
    print("on the actor")

    await f(c)
  }
}

// MARK: - Regex

// MARK: Regex Type

printLog("Regex Type", symbol: symbol)

let s = "Stay hungry, stay foolish."
let regex1 = try! Regex("[Ss]tay")
let matches1 = s.matches(of: regex1)
for match in matches1 {
  let l = match.range.lowerBound
  let r = match.range.upperBound
  printLog(s[l..<r])
}

// MARK: Regex builder DSL

printLog("Regex builder DSL", symbol: symbol)

let regex2 = Regex {
  "Stay "
  Capture {
    OneOrMore(.word) // matches2.1
  }
  ", stay "
  Capture {
    OneOrMore(.word) // matches2.2
  }
  "."
}
if let matches2 = try regex2.wholeMatch(in: s) {
  // matches2.0 是整个匹配的字符串
  printLog(matches2.0, matches2.1, matches2.2)
}

let ref1 = Reference(Substring.self)
let ref2 = Reference(Substring.self)
let regex3 = Regex {
  "Stay "
  Capture(as: ref1) { // res[ref1]
    OneOrMore(.word)
  }
  ", stay "
  Capture(as: ref2) { // res[ref2]
    OneOrMore(.word)
  }
  "."
}
if let matches3 = try regex3.wholeMatch(in: s) {
  printLog(matches3[ref1], matches3[ref2])
}

// MARK: Regex Literals

printLog("Regex Literals", symbol: symbol)

let regex4 = /[Ss]tay/
let matches4 = s.matches(of: regex4)
for match in matches4 {
  let l = match.range.lowerBound
  let r = match.range.upperBound
  printLog(s[l..<r])
}

let regex5 = /Stay (?<s1>.+), stay (?<s2>[A-Za-z0-9]+)./
if let matches5 = try regex5.wholeMatch(in: s) {
  printLog(matches5.s1, matches5.s2)
}

let regex6 = Regex {
  "Stay"
  Capture { // 空格使用使用\转义
    /\ .+/
  }
  ", stay"
  Capture {
    /\ [A-Za-z0-9]+/
  }
  "."
}
if let matches6 = try regex6.wholeMatch(in: s) {
  printLog(matches6.1, matches6.2)
}

// MARK: Regex-powered string processing algorithms

printLog("Regex-powered string processing algorithms", symbol: symbol)

printLog(s.replacing(/[Ss]tay/, with: "be"))
printLog(s.contains(/\ foo.+/))

// MARK: - Clock, Instant, and Duration

printLog("Clock, Instant, and Duration", symbol: symbol)

let clock = ContinuousClock()
let elapsed = clock.measure {
  for _ in 0..<999999 {}
}
printLog("Loop duration: \(elapsed)")

func delayWork() async throws {
  let elapsed = try await clock.measure {
    // tolerance 为容差，默认为 nil
    // 这里表示任务会睡眠 0.5 至 1 秒
    try await Task.sleep(until: .now + .seconds(0.5), tolerance: .seconds(0.5), clock: .continuous)
  }
  printLog("Sleep duration: \(elapsed)")
  printLog("Time is up, keep working...")
}

try await delayWork()

// MARK: - Opaque Types

func tuple(_ v1: some View, _ v2: some View) -> (some View, some View) {
  (v1, v2)
}

// MARK: - Lightweight same-type requirements for primary associated types

//func compare<C1: Collection, C2: Collection>(_ c1: C1, _ c2: C2) -> Bool
//where C1.Element == C2.Element, C1.Element: Equatable {
//  if c1.count != c2.count { return false }
//  for i in 0..<c1.count {
//    let v1 = c1[c1.index(c1.startIndex, offsetBy: i)]
//    let v2 = c2[c2.index(c2.startIndex, offsetBy: i)]
//    if v1 != v2 {
//      return false
//    }
//  }
//  return true
//}

func compare<E: Equatable>(_ c1: some Collection<E>, _ c2: some Collection<E>) -> Bool {
  if c1.count != c2.count { return false }
  for i in 0..<c1.count {
    let v1 = c1[c1.index(c1.startIndex, offsetBy: i)]
    let v2 = c2[c2.index(c2.startIndex, offsetBy: i)]
    if v1 != v2 {
      return false
    }
  }
  return true
}

let c1: [Int] = [1, 2, 3]
let c2: Set<Int> = [1, 2, 3]
let ans = compare(c1, c2) // true
printLog(ans)

//some P
//T where T: P

//some P<V>
//T where T: P, T.E: V

// MARK: - Existential Types

// MARK: Implicitly Opened Existentials=

protocol P {
  associatedtype A
  func getA() -> A
}

func takeP<T: P>(_ value: T) { }

func test(p: any P) {
  // error: protocol 'P' as a type cannot conform to itself
  takeP(p)
}

// MARK: Constrained Existential Types

func mapNumbers(_ c: any Collection<Int>) -> [Int] {
  c.map { $0 }
}

// MARK: - Distributed Actor Isolation





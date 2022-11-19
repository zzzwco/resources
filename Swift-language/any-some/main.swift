//
//  main.swift
//  any-some
//
//  Created by zzzwco on 2022/11/19.
//

import Foundation
import SwiftUI

// MARK: - Opaque types, some

var body: some View {
  Text("Hello")
}

//var body: View {
//  Bool.random() ? Text("Hello") : Image(systemName: "swift")
//}

func build1<V: View>(_ v: V) -> V {
  v
}
// v1 is Text
let v1 = build1(Text("Hello"))

func build2() -> some View {
  Text("Hello")
}

let v2 = build2()

// MARK: - Existential types, any

protocol P {}

struct CP1: P {}
struct CP2: P {}

func f1(_ p: any P) -> any P {
  p
}

func f2<V: P>(_ p: V) -> V {
  p
}

func f3() -> any P {
  Bool.random() ? CP1() : CP2()
}

_ = f2(CP1())

// MARK: - More elegant generics

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

//
//  PrintLog.swift
//  Swift-language
//
//  Created by zzzwco on 2022/11/19.
//

import Foundation

func printLog<T>(
  _ msg: T...,
  symbol: String = "🍺🍺🍺",
  file: String = #file,
  method: String = #function,
  line: Int = #line
) {
  #if DEBUG
  let msg = msg.map { "\($0)\n" }.joined()
  let content = "\(Date()) \((file as NSString).lastPathComponent)[\(line)], \(method): \n\(msg)\n"
  Swift.print("\(symbol) \(content)")
  #endif
}

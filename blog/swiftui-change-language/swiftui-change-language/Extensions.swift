//
//  Extensions.swift
//  swiftui-change-language
//
//  Created by Bruce on 2023/5/16.
//

import Foundation
import SwiftUI

extension String {

  var localized: String {
    let res = UserDefaults.standard.string(forKey: "language")
    let path = Bundle.main.path(forResource: res, ofType: "lproj")
    let bundle: Bundle
    if let path = path {
      bundle = Bundle(path: path) ?? .main
    } else {
      bundle = .main
    }
    return NSLocalizedString(self, bundle: bundle, value: "", comment: "")
  }
}

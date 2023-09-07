//
//  SampleView.swift
//  CombineHandbook
//
//  Created by Bruce on 2023/9/7.
//

import SwiftUI

struct SampleView: View {
  @State private var vm = SampleViewModel()
  
  var body: some View {
    Form {
      Section {
        TextField("Input something", text: $vm.searchText)
      } header: {
        Text("Debounce")
      } footer: {
        Text("Searching **\(vm.searchKeywords)** ...")
          .opacity(vm.isSearching ? 1 : 0)
      }
      .textCase(nil)
    }
  }
}

#Preview {
  SampleView()
}

//
//  SampleViewModel.swift
//  CombineHandbook
//
//  Created by Bruce on 2023/9/7.
//

import SwiftUI
import Observation
import Combine

/// The ViewModel responsible for managing the state and logic for ``SampleView``.
/// It performs a debounced search based on user input.
@Observable
final class SampleViewModel {
  
  /// The text entered by the user in the search text field.
  var searchText: String = "" {
    didSet {
      // Send the updated text to the Combine pipeline
      searchTextPub.send(searchText)
    }
  }
  
  /// The processed keywords used for searching.
  var searchKeywords = ""
  
  /// A flag indicating whether a search is currently in progress.
  var isSearching = false
  
  /// A Combine PassthroughSubject to publish updates to `searchText`.
  private let searchTextPub = PassthroughSubject<String, Never>()
  
  /// A collection of AnyCancellable to store Combine subscriptions.
  private var bag = Set<AnyCancellable>()
  
  init() {
    searchTextPub
      .dropFirst() // Ignore the initial value
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } // Trim whitespaces and new lines
      .filter { !$0.isEmpty } // Filter out empty strings
      .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main) // Debounce for 0.5 seconds
      .sink { [weak self] value in // Subscribe to updates
        guard let self else { return }
        if searchKeywords != value {
          searchKeywords = value
          mockRequest()
        }
      }
      .store(in: &bag)
  }
  
  /// Simulates a search request with a random delay.
  func mockRequest() {
    isSearching = true
    Task { @MainActor in
      try? await Task.sleep(for: .seconds(.random(in: 1...2)))
      isSearching = false
    }
  }
}

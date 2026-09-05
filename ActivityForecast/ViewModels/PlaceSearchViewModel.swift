//
//  PlaceSearchViewModel.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import Foundation
import Observation

/// Drives search-as-you-type against the geocoding API.
///
/// Keeps the debounce-and-cancel behaviour the original `SearchPlacesView` had, but
/// out of the view: a view that calls the network directly can't be previewed or
/// tested, and can't tell the difference between "no matches" and "not asked yet".
@Observable
@MainActor
final class PlaceSearchViewModel {

    enum ViewState: Equatable {
        /// Nothing worth searching for has been typed.
        case prompt
        case searching
        case results([Place])
        /// A valid query that the geocoder had nothing for.
        case noMatches(query: String)
        case failed(String)
    }

    private(set) var state: ViewState = .prompt

    private let service: PlaceSearching
    private var searchTask: Task<Void, Never>?

    nonisolated init(service: PlaceSearching = PlaceSearchService()) {
        self.service = service
    }

    /// Schedules a search, superseding any keystroke still waiting out its debounce.
    func search(query: String) {
        searchTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= AppLimits.minimumQueryLength else {
            state = .prompt
            return
        }

        searchTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await Task.sleep(for: AppLimits.searchDebounce)
                try Task.checkCancellation()

                self.state = .searching
                let places = try await self.service.places(matching: trimmed)
                try Task.checkCancellation()

                self.state = places.isEmpty ? .noMatches(query: trimmed) : .results(places)
            } catch is CancellationError {
                // Superseded by a newer keystroke, or the sheet was dismissed.
            } catch {
                self.state = .failed(error.readableMessage)
            }
        }
    }

    func cancel() {
        searchTask?.cancel()
        searchTask = nil
    }
}

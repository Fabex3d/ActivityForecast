//
//  PlacesViewModel.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import Observation
import SwiftUI

/// Owns the saved-place list and each place's week.
///
/// The list is capped at `AppLimits.maximumSavedPlaces`; that rule is enforced here
/// rather than in the view, so the search screen and the home screen cannot disagree
/// about whether there is room for one more.
@Observable
@MainActor
final class PlacesViewModel {

    private(set) var places: [Place]

    /// Forecast state keyed by place, so a slow or failing place doesn't hold up the
    /// rest of the list.
    private(set) var forecasts: [Place.ID: ForecastLoadState] = [:]

    private let service: ForecastServicing
    private let store: SavedPlacesStoring
    private var loadTask: Task<Void, Never>?

    init(
        service: ForecastServicing = ForecastService(),
        store: SavedPlacesStoring = UserDefaultsSavedPlacesStore()
    ) {
        self.service = service
        self.store = store
        self.places = store.load()
    }

    // MARK: Capacity

    /// How many more places may be added before the cap is reached.
    var remainingSlots: Int {
        max(0, AppLimits.maximumSavedPlaces - places.count)
    }

    var isAtCapacity: Bool {
        remainingSlots == 0
    }

    var isEmpty: Bool {
        places.isEmpty
    }

    func contains(_ place: Place) -> Bool {
        places.contains { $0.id == place.id }
    }

    // MARK: Intents

    /// Adds a place, respecting the cap and rejecting duplicates.
    /// - Returns: `false` when the place was not added, so the caller can explain why.
    @discardableResult
    func add(_ place: Place) -> Bool {
        guard !isAtCapacity, !contains(place) else { return false }
        places.append(place)
        persist()
        loadForecast(for: place)
        return true
    }

    func remove(atOffsets offsets: IndexSet) {
        let discarded = offsets.compactMap { places.indices.contains($0) ? places[$0] : nil }
        places.remove(atOffsets: offsets)
        for place in discarded {
            forecasts.removeValue(forKey: place.id)
        }
        persist()
    }

    func remove(_ place: Place) {
        guard let index = places.firstIndex(where: { $0.id == place.id }) else { return }
        remove(atOffsets: IndexSet(integer: index))
    }

    func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        places.move(fromOffsets: source, toOffset: destination)
        persist()
    }

    /// Changes which activity a place is watched for. Purely a re-read of scores the
    /// app already holds, so no fetch is triggered.
    func setPreferredActivity(_ activity: Activity, for place: Place) {
        guard let index = places.firstIndex(where: { $0.id == place.id }) else { return }
        places[index].preferredActivity = activity
        persist()
    }

    // MARK: Loading

    func forecastState(for place: Place) -> ForecastLoadState {
        forecasts[place.id] ?? .loading
    }

    /// Fetches every saved place's week concurrently, replacing any refresh already
    /// in flight. Results are applied as they arrive rather than all at the end.
    func refresh() {
        loadTask?.cancel()

        let snapshot = places
        let service = self.service

        for place in snapshot where forecasts[place.id] == nil {
            forecasts[place.id] = .loading
        }

        loadTask = Task { [weak self] in
            await withTaskGroup(of: (Place.ID, ForecastLoadState?).self) { group in
                for place in snapshot {
                    group.addTask {
                        do {
                            let days = try await service.dailyForecast(for: place)
                            return (place.id, .loaded(days))
                        } catch is CancellationError {
                            return (place.id, nil)
                        } catch {
                            return (place.id, .failed(error.readableMessage))
                        }
                    }
                }

                for await (id, state) in group {
                    guard let self, !Task.isCancelled else { return }
                    guard let state else { continue }
                    self.forecasts[id] = state
                }
            }
        }
    }

    /// `refresh()` that only returns once every place has settled, so pull-to-refresh
    /// keeps its spinner up for as long as the work actually takes.
    func refreshAndWait() async {
        refresh()
        await loadTask?.value
    }

    /// Fetches one place — used when a place is newly added, and by a row's retry.
    func loadForecast(for place: Place) {
        forecasts[place.id] = .loading
        let service = self.service

        Task { [weak self] in
            do {
                let days = try await service.dailyForecast(for: place)
                try Task.checkCancellation()
                self?.forecasts[place.id] = .loaded(days)
            } catch is CancellationError {
                // Superseded, or the place was removed while the fetch was in flight.
            } catch {
                self?.forecasts[place.id] = .failed(error.readableMessage)
            }
        }
    }

    /// Drops in-flight work when the screen goes away.
    func cancel() {
        loadTask?.cancel()
        loadTask = nil
    }

    // MARK: Persistence

    private func persist() {
        store.save(places)
    }
}

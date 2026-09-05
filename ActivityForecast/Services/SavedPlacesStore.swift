//
//  SavedPlacesStore.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import Foundation

/// Where the saved-place list lives between launches.
protocol SavedPlacesStoring: Sendable {
    func load() -> [Place]
    func save(_ places: [Place])
}

/// A `UserDefaults`-backed store.
///
/// The list is capped at ten small structs, so a JSON blob in user defaults is the
/// right weight of solution — a database would be ceremony for no benefit.
struct UserDefaultsSavedPlacesStore: SavedPlacesStoring {

    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults = .standard, key: StorageKey = .savedPlaces) {
        self.defaults = defaults
        self.key = key.rawValue
    }

    func load() -> [Place] {
        guard let data = defaults.data(forKey: key) else { return [] }
        guard let places = try? JSONDecoder().decode([Place].self, from: data) else {
            // Unreadable data means a format we no longer understand. Starting from an
            // empty list is recoverable; propagating a decode failure into the UI is not.
            return []
        }
        return places
    }

    func save(_ places: [Place]) {
        guard let data = try? JSONEncoder().encode(places) else { return }
        defaults.set(data, forKey: key)
    }
}

/// An in-memory store for previews and tests.
final class InMemorySavedPlacesStore: SavedPlacesStoring, @unchecked Sendable {

    private let lock = NSLock()
    private var places: [Place]

    init(places: [Place] = []) {
        self.places = places
    }

    func load() -> [Place] {
        lock.withLock { places }
    }

    func save(_ places: [Place]) {
        lock.withLock { self.places = places }
    }
}

//
//  PlaceSearchService.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import Foundation

/// Looks up places by name against the geocoding API.
protocol PlaceSearching: Sendable {

    /// Places whose name matches `query`, narrowed to the app's own value type.
    func places(matching query: String) async throws -> [Place]
}

struct PlaceSearchService: PlaceSearching {

    private let network: NetworkService

    init(network: NetworkService = .shared) {
        self.network = network
    }

    func places(matching query: String) async throws -> [Place] {
        let response = try await network.execute(with: LocationSearchUri(name: query))
        return (response.results ?? []).map(Place.init(location:))
    }
}

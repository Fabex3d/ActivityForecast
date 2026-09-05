//
//  ForecastService.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import Foundation

/// Fetches and scores a location's week.
///
/// ViewModels depend on this protocol rather than on `NetworkService` so they can be
/// driven by a stub in previews and tests.
protocol ForecastServicing: Sendable {

    /// The next seven days for a coordinate, already scored for all four activities.
    func dailyForecast(latitude: Double, longitude: Double) async throws -> [DayForecast]
}

/// The live implementation: existing network layer in, existing scoring engine out.
struct ForecastService: ForecastServicing {

    private let network: NetworkService

    init(network: NetworkService = .shared) {
        self.network = network
    }

    func dailyForecast(latitude: Double, longitude: Double) async throws -> [DayForecast] {
        let response = try await network.execute(
            with: LocationForecastUri(latitude: latitude, longitude: longitude)
        )
        return try response.dailyForecasts()
    }
}

extension ForecastServicing {

    /// Convenience for the common case of forecasting a saved place.
    func dailyForecast(for place: Place) async throws -> [DayForecast] {
        try await dailyForecast(latitude: place.latitude, longitude: place.longitude)
    }
}

//
//  Place.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import Foundation

/// A location a person cares about.
///
/// `LocationSearchResponse.Location` is a wire type: `Decodable` only, so it can be
/// neither persisted nor used as a `NavigationStack` route. `Place` is the app's own
/// value type — hashable for navigation, codable for the saved list — carrying only
/// the fields the app actually shows or sends.
public struct Place: Identifiable, Hashable, Codable, Sendable {

    /// Open-Meteo's stable geocoding identifier, reused as the app's identity so the
    /// same town added twice is recognised as a duplicate.
    public let id: Int
    public let name: String
    public let region: String?
    public let country: String
    public let latitude: Double
    public let longitude: Double
    public let elevation: Double?

    /// Which activity this place is being watched for. Drives the score strip on the
    /// home screen and the initially selected tab on the forecast screen.
    public var preferredActivity: Activity

    public init(
        id: Int,
        name: String,
        region: String?,
        country: String,
        latitude: Double,
        longitude: Double,
        elevation: Double? = nil,
        preferredActivity: Activity = .outdoorSightseeing
    ) {
        self.id = id
        self.name = name
        self.region = region
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
        self.preferredActivity = preferredActivity
    }

    /// Narrows a geocoding result down to what the app keeps.
    public init(location: LocationSearchResponse.Location) {
        self.init(
            id: location.id,
            name: location.name,
            region: location.admin1,
            country: location.country,
            latitude: location.latitude,
            longitude: location.longitude,
            elevation: location.elevation
        )
    }
}

public extension Place {

    /// "Valais, Switzerland" — or just the country when there is no region.
    var subtitle: String {
        guard let region, !region.isEmpty else { return country }
        return "\(region), \(country)"
    }

    /// "Valais, Switzerland · 1,608 m" — the forecast screen has room for elevation.
    var detailedSubtitle: String {
        guard let elevation else { return subtitle }
        let height = Measurement(value: elevation, unit: UnitLength.meters)
        let formatted = height.formatted(
            .measurement(
                width: .abbreviated,
                usage: .asProvided,
                numberFormatStyle: .number.precision(.fractionLength(0))
            )
        )
        return "\(subtitle) · \(formatted)"
    }
}

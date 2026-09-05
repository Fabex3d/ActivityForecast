//
//  PreviewData.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import Foundation

/// Fixtures for `#Preview` blocks and tests.
///
/// The scored days are produced by running the *real* mapper and the *real* scoring
/// engine over a captured Open-Meteo response, rather than by hand-writing scores.
/// A preview therefore can't drift away from what the app actually computes.
enum PreviewData {

    /// A week at Zermatt: heavy snow at both ends, a clear, calm middle.
    /// Great for skiing, unarguable for indoor sights, poor for outdoor sights.
    static let zermattResponse = LocationForecastResponse(
        latitude: 46.0207,
        longitude: 7.7491,
        generationtimeMs: 0.4,
        utcOffsetSeconds: 7200,
        timezone: "Europe/Zurich",
        timezoneAbbreviation: "GMT+2",
        elevation: 1608,
        dailyUnits: .preview,
        daily: DailyForecast(
            time: [
                "2026-09-05", "2026-09-06", "2026-09-07", "2026-09-08",
                "2026-09-09", "2026-09-10", "2026-09-11"
            ],
            weathercode: [75, 71, 3, 1, 2, 61, 75],
            temperature2mMax: [-4, -3, -1, 1, 2, -2, -5],
            temperature2mMin: [-11, -10, -7, -5, -3, -8, -12],
            apparentTemperatureMax: [-11, -10, -7, -4, -2, -8, -13],
            precipitationSum: [12.4, 3.1, 0, 0, 0, 6.8, 21],
            precipitationProbabilityMax: [86, 54, 10, 4, 8, 72, 94],
            snowfallSum: [18, 4.5, 0, 0, 0, 7.2, 25],
            windSpeed10mMax: [14, 11, 9, 7, 13, 28, 44],
            windGusts10mMax: [31, 26, 22, 19, 30, 58, 79],
            windDirection10mDominant: [310, 295, 270, 240, 225, 300, 320],
            uvIndexMax: [1.4, 2.2, 2.8, 3, 2.9, 1.8, 1.1],
            sunshineDuration: [7200, 25000, 41000, 42000, 39000, 12000, 3600]
        )
    )

    /// A week at Los Andes: dry, sunny and mild — the mirror image of Zermatt.
    static let losAndesResponse = LocationForecastResponse(
        latitude: -32.8337,
        longitude: -70.5983,
        generationtimeMs: 0.4,
        utcOffsetSeconds: -10800,
        timezone: "America/Santiago",
        timezoneAbbreviation: "GMT-3",
        elevation: 828,
        dailyUnits: .preview,
        daily: DailyForecast(
            time: [
                "2026-09-05", "2026-09-06", "2026-09-07", "2026-09-08",
                "2026-09-09", "2026-09-10", "2026-09-11"
            ],
            weathercode: [51, 0, 1, 1, 3, 80, 61],
            temperature2mMax: [18.7, 22.4, 22.5, 22.7, 22.4, 21.6, 14.8],
            temperature2mMin: [8.7, 6.4, 8, 7.4, 8.3, 7.6, 5.7],
            apparentTemperatureMax: [18.7, 21.4, 22.5, 22, 21.7, 20.1, 12.5],
            precipitationSum: [0.1, 0, 0, 0, 0, 4.2, 17.4],
            precipitationProbabilityMax: [0, 0, 0, 4, 18, 57, 88],
            snowfallSum: [0, 0, 0, 0, 0, 0, 0],
            windSpeed10mMax: [9.6, 7.4, 8.3, 6.1, 16.9, 9.9, 7.1],
            windGusts10mMax: [24.1, 26.3, 27.4, 29.9, 54.7, 33.1, 33.8],
            windDirection10mDominant: [236, 241, 249, 235, 95, 254, 272],
            uvIndexMax: [6.25, 6.35, 6.25, 6.45, 6.5, 5.7, 6.05],
            sunshineDuration: [40004, 40537, 40516, 40495, 40199, 29076, 12040]
        )
    )

    static let zermattWeek: [DayForecast] = (try? zermattResponse.dailyForecasts()) ?? []
    static let losAndesWeek: [DayForecast] = (try? losAndesResponse.dailyForecasts()) ?? []
}

// MARK: - Response fixtures

extension DailyUnits {

    /// The units Open-Meteo returns when `LocationForecastUri` asks for no conversion.
    static let preview = DailyUnits(
        time: "iso8601",
        weathercode: "wmo code",
        temperature2mMax: "°C",
        temperature2mMin: "°C",
        apparentTemperatureMax: "°C",
        precipitationSum: "mm",
        precipitationProbabilityMax: "%",
        snowfallSum: "cm",
        windSpeed10mMax: "km/h",
        windGusts10mMax: "km/h",
        windDirection10mDominant: "°",
        uvIndexMax: "",
        sunshineDuration: "s"
    )
}

// MARK: - Place fixtures

extension Place {

    static let previewZermatt = Place(
        id: 2_657_896,
        name: "Zermatt",
        region: "Valais",
        country: "Switzerland",
        latitude: 46.0207,
        longitude: 7.7491,
        elevation: 1608,
        preferredActivity: .skiing
    )

    static let previewEriceira = Place(
        id: 2_268_339,
        name: "Ericeira",
        region: "Lisbon",
        country: "Portugal",
        latitude: 38.9634,
        longitude: -9.4159,
        elevation: 41,
        preferredActivity: .surfing
    )

    static let previewLosAndes = Place(
        id: 3_890_692,
        name: "Los Andes",
        region: "Valparaíso Region",
        country: "Chile",
        latitude: -32.8337,
        longitude: -70.5983,
        elevation: 828,
        preferredActivity: .outdoorSightseeing
    )

    static let previewKyoto = Place(
        id: 1_857_910,
        name: "Kyoto",
        region: "Kyoto Prefecture",
        country: "Japan",
        latitude: 35.0116,
        longitude: 135.7681,
        elevation: 56,
        preferredActivity: .indoorSightseeing
    )

    /// The layout's worst case: a name that will not fit on one line.
    static let previewLongName = Place(
        id: 2_988_507,
        name: "Chamonix-Mont-Blanc Aiguille du Midi",
        region: "Auvergne-Rhône-Alpes",
        country: "France",
        latitude: 45.9237,
        longitude: 6.8694,
        elevation: 3842,
        preferredActivity: .skiing
    )

    static let previewList: [Place] = [
        previewZermatt, previewEriceira, previewKyoto, previewLosAndes
    ]

    /// A full list, for checking the cap's copy and the disabled add button.
    /// Identifiers are offset so each entry stays distinct.
    static var previewCapacityList: [Place] {
        (0..<AppLimits.maximumSavedPlaces).map { index in
            let template = previewList[index % previewList.count]
            return Place(
                id: template.id + index,
                name: template.name,
                region: template.region,
                country: template.country,
                latitude: template.latitude,
                longitude: template.longitude,
                elevation: template.elevation,
                preferredActivity: template.preferredActivity
            )
        }
    }
}

// MARK: - DayForecast fixtures

extension DayForecast {

    /// Heavy snow: a 5 for skiing, a 1 for outdoor sights.
    static var previewSnowy: DayForecast? { PreviewData.zermattWeek.first }

    /// Clear and calm: good for sightseeing, nothing doing for skiing.
    static var previewClear: DayForecast? { PreviewData.zermattWeek.dropFirst(3).first }

    /// Blown out: the worst day of the Zermatt week.
    static var previewStormy: DayForecast? { PreviewData.zermattWeek.last }
}

// MARK: - Service stubs

/// A stand-in failure for previews.
///
/// `NetworkError` carries an `unknown(Error)` case and so is not `Sendable`, which
/// would make the stubs below unable to conform to the service protocols.
enum PreviewError: Error, LocalizedError, Sendable {
    case offline

    var errorDescription: String? {
        "🔌 No connection. Check your network and try again."
    }
}

/// Returns a fixed week without touching the network.
struct StubForecastService: ForecastServicing {

    let days: [DayForecast]
    let failure: PreviewError?
    let delay: Duration

    init(days: [DayForecast] = PreviewData.zermattWeek, failure: PreviewError? = nil, delay: Duration = .zero) {
        self.days = days
        self.failure = failure
        self.delay = delay
    }

    func dailyForecast(latitude: Double, longitude: Double) async throws -> [DayForecast] {
        if delay > .zero {
            try await Task.sleep(for: delay)
        }
        if let failure {
            throw failure
        }
        return days
    }
}

/// Returns fixed search results without touching the network.
struct StubPlaceSearchService: PlaceSearching {

    let results: [Place]
    let failure: PreviewError?

    init(results: [Place] = Place.previewList, failure: PreviewError? = nil) {
        self.results = results
        self.failure = failure
    }

    func places(matching query: String) async throws -> [Place] {
        if let failure {
            throw failure
        }
        return results
    }
}

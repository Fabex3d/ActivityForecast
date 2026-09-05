//
//  DayForecast.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import Foundation

/// One day of the forecast, already scored.
///
/// The feed arrives as a dozen parallel arrays plus a separate array of ratings.
/// This collapses index `i` of all of them into a single value a row view can be
/// handed directly, which is what makes those row views previewable in isolation.
public struct DayForecast: Identifiable, Hashable, Sendable {

    /// Midnight local to the forecast location.
    public let date: Date

    /// The location's own time zone, so "Today" means today *there*.
    public let timeZone: TimeZone

    public let condition: WeatherCondition
    public let highTemperatureCelsius: Double
    public let lowTemperatureCelsius: Double
    public let apparentHighCelsius: Double
    public let precipitationMillimetres: Double
    public let precipitationProbability: Int
    public let snowfallCentimetres: Double
    public let windSpeedKilometresPerHour: Double
    public let windGustsKilometresPerHour: Double
    public let uvIndex: Double
    public let sunshineHours: Double

    /// The scoring engine's output for this day, all four activities.
    public let ratings: DayActivityRating

    public var id: Date { date }

    public init(
        date: Date,
        timeZone: TimeZone,
        condition: WeatherCondition,
        highTemperatureCelsius: Double,
        lowTemperatureCelsius: Double,
        apparentHighCelsius: Double,
        precipitationMillimetres: Double,
        precipitationProbability: Int,
        snowfallCentimetres: Double,
        windSpeedKilometresPerHour: Double,
        windGustsKilometresPerHour: Double,
        uvIndex: Double,
        sunshineHours: Double,
        ratings: DayActivityRating
    ) {
        self.date = date
        self.timeZone = timeZone
        self.condition = condition
        self.highTemperatureCelsius = highTemperatureCelsius
        self.lowTemperatureCelsius = lowTemperatureCelsius
        self.apparentHighCelsius = apparentHighCelsius
        self.precipitationMillimetres = precipitationMillimetres
        self.precipitationProbability = precipitationProbability
        self.snowfallCentimetres = snowfallCentimetres
        self.windSpeedKilometresPerHour = windSpeedKilometresPerHour
        self.windGustsKilometresPerHour = windGustsKilometresPerHour
        self.uvIndex = uvIndex
        self.sunshineHours = sunshineHours
        self.ratings = ratings
    }
}

public extension DayForecast {

    /// The suitability tier for one activity. The scoring engine clamps to 1–5, so
    /// the fallback is only reached if that contract ever changes.
    func rating(for activity: Activity) -> ActivityRating {
        ActivityRating(rawValue: activity.score(in: ratings)) ?? .stayIn
    }

    /// How gusty the wind is relative to its sustained speed — the chop proxy the
    /// surfing score uses.
    var gustRatio: Double {
        guard windSpeedKilometresPerHour > 0 else { return 0 }
        return windGustsKilometresPerHour / windSpeedKilometresPerHour
    }
}

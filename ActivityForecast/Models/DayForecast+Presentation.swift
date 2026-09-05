//
//  DayForecast+Presentation.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import Foundation

/// Human-readable renderings of a scored day.
///
/// These live on the model rather than in a view so that a row and a card describing
/// the same day always agree, and so they can be exercised in a unit test. Nothing
/// here reaches for a colour or a font — that stays in the view layer.
public extension DayForecast {

    /// The separator between the parameters that drove a score.
    private static let separator = " · "

    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar
    }

    private var localisedStyle: Date.FormatStyle {
        Date.FormatStyle(date: .omitted, time: .omitted, timeZone: timeZone)
    }

    /// True when this is today *at the forecast location*, which can differ from
    /// today where the reader is standing.
    var isToday: Bool {
        calendar.isDateInToday(date)
    }

    /// "Today" or "Sat".
    var weekdayLabel: String {
        isToday ? "Today" : date.formatted(localisedStyle.weekday(.abbreviated))
    }

    /// "Sep 5".
    var dateLabel: String {
        date.formatted(localisedStyle.month(.abbreviated).day())
    }

    /// "Sa" — for the seven-column score strip, where a full name would not fit.
    var shortWeekdayLabel: String {
        date.formatted(localisedStyle.weekday(.short))
    }

    /// "Heavy snow · feels −11°" — the one-line conditions summary for a card header.
    var conditionsSummary: String {
        [
            condition.description,
            "feels \(WeatherFormat.temperature(celsius: apparentHighCelsius))"
        ].joined(separator: Self.separator)
    }

    /// "−4° / −11°".
    var temperatureRange: String {
        let high = WeatherFormat.temperature(celsius: highTemperatureCelsius)
        let low = WeatherFormat.temperature(celsius: lowTemperatureCelsius)
        return "\(high) / \(low)"
    }

    /// The parameters that actually moved this activity's score, in plain language.
    ///
    /// Each activity is driven by a different subset of the feed, so showing all
    /// twelve fields on every row would bury the reason. These mirror the drivers
    /// documented in `ActivityRating`'s scoring extension.
    func reason(for activity: Activity) -> String {
        let components: [String]

        switch activity {
            case .skiing:
                components = [
                    "\(WeatherFormat.snowfall(centimetres: snowfallCentimetres)) snow",
                    "max \(WeatherFormat.temperature(celsius: highTemperatureCelsius))",
                    "wind \(WeatherFormat.windSpeed(kilometresPerHour: windSpeedKilometresPerHour))"
                ]

            case .surfing:
                components = [
                    "wind \(WeatherFormat.windSpeed(kilometresPerHour: windSpeedKilometresPerHour))",
                    "gusts \(WeatherFormat.windSpeed(kilometresPerHour: windGustsKilometresPerHour))",
                    "\(WeatherFormat.ratio(gustRatio)) gust ratio"
                ]

            case .indoorSightseeing:
                components = [
                    WeatherFormat.rainfall(millimetres: precipitationMillimetres),
                    "\(WeatherFormat.probability(precipitationProbability)) chance",
                    condition.description
                ]

            case .outdoorSightseeing:
                components = [
                    "\(WeatherFormat.hours(sunshineHours)) sun",
                    "feels \(WeatherFormat.temperature(celsius: apparentHighCelsius))",
                    WeatherFormat.rainfall(millimetres: precipitationMillimetres)
                ]
        }

        return components.joined(separator: Self.separator)
    }

    /// A VoiceOver-friendly rendering of a whole row: the day, the tier, the reason.
    func accessibilityDescription(for activity: Activity) -> String {
        let tier = rating(for: activity).accessibleLabel
        return "\(weekdayLabel) \(dateLabel). \(activity.title): \(tier). \(reason(for: activity))"
    }
}

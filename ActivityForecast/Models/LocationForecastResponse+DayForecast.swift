//
//  LocationForecastResponse+DayForecast.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import Foundation

/// Failures that come from the *shape* of an otherwise successful response, as
/// opposed to the transport failures `NetworkError` covers.
public enum ForecastMappingError: Error, LocalizedError {
    case inconsistentDailyArrays
    case unreadableDate(String)

    public var errorDescription: String? {
        switch self {
            case .inconsistentDailyArrays:
                return "📉 The forecast arrived incomplete. Please try again."
            case .unreadableDate(let value):
                return "📅 The forecast contained a date this app can't read: \(value)."
        }
    }
}

public extension LocationForecastResponse {

    /// Collapses the response's parallel arrays and the scoring engine's output into
    /// one scored value per day.
    ///
    /// The feed is documented to return arrays of equal length, but the arrays are
    /// indexed positionally by both this mapper and `activityRatings()`, so their
    /// lengths are verified up front rather than trusted — a short array would
    /// otherwise be an out-of-bounds crash.
    func dailyForecasts() throws -> [DayForecast] {
        let dayCount = daily.time.count
        guard dayCount > 0 else { return [] }
        guard daily.hasCompleteValues(for: dayCount) else {
            throw ForecastMappingError.inconsistentDailyArrays
        }

        let ratings = activityRatings()
        guard ratings.count == dayCount else {
            throw ForecastMappingError.inconsistentDailyArrays
        }

        let zone = TimeZone(identifier: timezone) ?? .gmt
        let dateStrategy = Date.ISO8601FormatStyle(timeZone: zone).year().month().day()

        return try (0..<dayCount).map { index in
            let rawDate = daily.time[index]
            guard let date = try? Date(rawDate, strategy: dateStrategy) else {
                throw ForecastMappingError.unreadableDate(rawDate)
            }

            return DayForecast(
                date: date,
                timeZone: zone,
                condition: WeatherCondition(code: daily.weathercode[index]),
                highTemperatureCelsius: daily.temperature2mMax[index],
                lowTemperatureCelsius: daily.temperature2mMin[index],
                apparentHighCelsius: daily.apparentTemperatureMax[index],
                precipitationMillimetres: daily.precipitationSum[index],
                precipitationProbability: daily.precipitationProbabilityMax[index] ?? 0,
                snowfallCentimetres: daily.snowfallSum[index],
                windSpeedKilometresPerHour: daily.windSpeed10mMax[index],
                windGustsKilometresPerHour: daily.windGusts10mMax[index],
                uvIndex: daily.uvIndexMax[index],
                sunshineHours: (daily.sunshineDuration[index] ?? 0) / AppLimits.secondsPerHour,
                ratings: ratings[index]
            )
        }
    }
}

private extension DailyForecast {

    /// Whether every array the mapper and the scoring engine read is long enough to
    /// be indexed up to `dayCount`.
    func hasCompleteValues(for dayCount: Int) -> Bool {
        let lengths = [
            weathercode.count,
            temperature2mMax.count,
            temperature2mMin.count,
            apparentTemperatureMax.count,
            precipitationSum.count,
            precipitationProbabilityMax.count,
            snowfallSum.count,
            windSpeed10mMax.count,
            windGusts10mMax.count,
            uvIndexMax.count,
            sunshineDuration.count
        ]
        return lengths.allSatisfy { $0 >= dayCount }
    }
}

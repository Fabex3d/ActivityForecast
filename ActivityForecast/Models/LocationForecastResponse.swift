//
//  LocationForecastResponse.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 04/09/26.
//


import Foundation

// MARK: - LocationForecastResponse
/// Root response object returned by Open-Meteo endpoint when requesting daily values.
public struct LocationForecastResponse: Codable, Sendable {
    public let latitude: Double
    public let longitude: Double
    public let generationtimeMs: Double
    public let utcOffsetSeconds: Int
    public let timezone: String
    public let timezoneAbbreviation: String
    public let elevation: Double
    public let dailyUnits: DailyUnits
    public let daily: DailyForecast

    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case generationtimeMs = "generationtime_ms"
        case utcOffsetSeconds = "utc_offset_seconds"
        case timezone
        case timezoneAbbreviation = "timezone_abbreviation"
        case elevation
        case dailyUnits = "daily_units"
        case daily
    }
}

// MARK: - DailyUnits
/// Represents the unit metadata for each requested variable.
public struct DailyUnits: Codable, Sendable {
    public let time: String
    public let weathercode: String
    public let temperature2mMax: String
    public let temperature2mMin: String
    public let apparentTemperatureMax: String
    public let precipitationSum: String
    public let precipitationProbabilityMax: String
    public let snowfallSum: String
    public let windSpeed10mMax: String
    public let windGusts10mMax: String
    public let windDirection10mDominant: String
    public let uvIndexMax: String
    public let sunshineDuration: String

    enum CodingKeys: String, CodingKey {
        case time
        case weathercode
        case temperature2mMax = "temperature_2m_max"
        case temperature2mMin = "temperature_2m_min"
        case apparentTemperatureMax = "apparent_temperature_max"
        case precipitationSum = "precipitation_sum"
        case precipitationProbabilityMax = "precipitation_probability_max"
        case snowfallSum = "snowfall_sum"
        case windSpeed10mMax = "wind_speed_10m_max"
        case windGusts10mMax = "wind_gusts_10m_max"
        case windDirection10mDominant = "wind_direction_10m_dominant"
        case uvIndexMax = "uv_index_max"
        case sunshineDuration = "sunshine_duration"
    }
}

// MARK: - DailyForecast
/// Contains parallel arrays corresponding to the 7-day forecast.
public struct DailyForecast: Codable, Sendable {
    /// Date strings in "YYYY-MM-DD" format.
    public let time: [String]
    
    /// WMO Weather interpretation code.
    public let weathercode: [Int]
    
    /// Maximum air temperature at 2m (°C or °F).
    public let temperature2mMax: [Double]
    
    /// Minimum air temperature at 2m (°C or °F).
    public let temperature2mMin: [Double]
    
    /// Maximum "feels like" temperature.
    public let apparentTemperatureMax: [Double]
    
    /// Total daily precipitation sum (mm or inches).
    public let precipitationSum: [Double]
    
    /// Maximum daily probability of precipitation (0–100%).
    public let precipitationProbabilityMax: [Int?]
    
    /// Total daily snowfall amount (cm).
    public let snowfallSum: [Double]
    
    /// Maximum daily wind speed at 10m.
    public let windSpeed10mMax: [Double]
    
    /// Maximum daily wind gust at 10m.
    public let windGusts10mMax: [Double]
    
    /// Dominant daily wind direction (in degrees, 0°-360°).
    public let windDirection10mDominant: [Int]
    
    /// Maximum UV Index for outdoor activities.
    public let uvIndexMax: [Double]
    
    /// Total duration of sunshine in seconds.
    public let sunshineDuration: [Double?]

    enum CodingKeys: String, CodingKey {
        case time
        case weathercode
        case temperature2mMax = "temperature_2m_max"
        case temperature2mMin = "temperature_2m_min"
        case apparentTemperatureMax = "apparent_temperature_max"
        case precipitationSum = "precipitation_sum"
        case precipitationProbabilityMax = "precipitation_probability_max"
        case snowfallSum = "snowfall_sum"
        case windSpeed10mMax = "wind_speed_10m_max"
        case windGusts10mMax = "wind_gusts_10m_max"
        case windDirection10mDominant = "wind_direction_10m_dominant"
        case uvIndexMax = "uv_index_max"
        case sunshineDuration = "sunshine_duration"
    }
}


// MARK: - Rating Logic
public extension LocationForecastResponse {
    
    /// Rates every day in the forecast 1–5 (5 = ideal) for each activity.
    func activityRatings() -> [DayActivityRating] {
        (0..<daily.time.count).map { i in
            DayActivityRating(
                date: daily.time[i],
                skiing: skiingScore(index: i),
                surfing: surfingScore(index: i),
                indoorSightseeing: indoorScore(index: i),
                outdoorSightseeing: outdoorScore(index: i)
            )
        }
    }
    
    // MARK: Skiing
    // Drivers: snowfall_sum (fresh snow), temperature_2m_min/max (cold = good snow),
    // wind_speed_10m_max (high wind = lift closures).
    private func skiingScore(index i: Int) -> Int {
        let d = daily
        var score = 1
        
        let snow = d.snowfallSum[i]
        let tempMax = d.temperature2mMax[i]
        let wind = d.windSpeed10mMax[i]
        
        // Fresh snow is the main driver (0-3 pts)
        if snow >= 10 { score += 3 }
        else if snow >= 3 { score += 2 }
        else if snow > 0 { score += 1 }
        
        // Cold enough to hold snow / avoid melt (0-1 pt)
        if tempMax <= 2 { score += 1 }
        
        // Wind risks lift closures
        if wind >= 40 { score -= 2 }
        else if wind >= 25 { score -= 1 }
        
        return clamp(score)
    }
    
    // MARK: Surfing
    // Drivers: wind_speed_10m_max, wind_gusts_10m_max (gustiness = chop).
    // Note: true swell/offshore-onshore quality needs coastline orientation,
    // which isn't in this dataset, so this is a wind-quality proxy only.
    private func surfingScore(index i: Int) -> Int {
        let d = daily
        var score = 3 // neutral baseline
        
        let wind = d.windSpeed10mMax[i]
        let gust = d.windGusts10mMax[i]
        
        if wind >= 10 && wind <= 25 { score += 1 }      // clean, sailable wind
        else if wind < 5 { score -= 1 }                  // too flat
        else if wind > 35 { score -= 2 }                 // blown out
        
        let gustRatio = wind > 0 ? gust / wind : 0
        if gustRatio > 3 { score -= 1 }                  // gusty = choppy
        
        return clamp(score)
    }
    
    // MARK: Sightseeing shared signals
    //
    // Indoor and outdoor sightseeing read the same handful of feed values, so each
    // judgement call — "is this day wet/stormy", "is it too hot or cold", "is UV
    // extreme" — is made once here and reused by both scores below. That's what
    // stops one stormy day from being counted twice within a single score (once
    // for its rain total, once for its weather code).
    
    /// Precipitation intensity for the day, 0 (dry) to 2 (heavy or stormy).
    /// Folds the rain total, the forecast probability, and storm/heavy-weather
    /// codes into a single level, rather than letting each add its own point.
    private func wetnessLevel(index i: Int) -> Int {
        let d = daily
        let precip = d.precipitationSum[i]
        let precipProbability = d.precipitationProbabilityMax[i] ?? 0
        let code = d.weathercode[i]
        
        if precip >= SightseeingThresholds.heavyPrecipitationMillimetres
            || SightseeingThresholds.stormWeatherCodes.contains(code) {
            return 2
        }
        if precip >= SightseeingThresholds.moderatePrecipitationMillimetres
            || precipProbability >= SightseeingThresholds.moderatePrecipitationProbability {
            return 1
        }
        return 0
    }
    
    /// Whether the day's "feels like" high sits outside a comfortable range to be
    /// outside for a while. Reads apparent temperature alone (rather than also
    /// checking the raw max/min separately) so heat and cold aren't scored twice.
    private func hasExtremeTemperature(index i: Int) -> Bool {
        let feelsLike = daily.apparentTemperatureMax[i]
        return feelsLike <= SightseeingThresholds.coldExtreme
        || feelsLike >= SightseeingThresholds.hotExtreme
    }
    
    private func isComfortableTemperature(index i: Int) -> Bool {
        let feelsLike = daily.apparentTemperatureMax[i]
        return feelsLike >= SightseeingThresholds.comfortableLow
        && feelsLike <= SightseeingThresholds.comfortableHigh
    }
    
    private func hasExtremeUV(index i: Int) -> Bool {
        daily.uvIndexMax[i] >= SightseeingThresholds.extremeUV
    }
    
    /// Fog/rime codes only — a distinct signal from the wetness codes above, since a
    /// foggy day isn't necessarily a wet one.
    private func hasPoorVisibility(index i: Int) -> Bool {
        SightseeingThresholds.fogWeatherCodes.contains(daily.weathercode[i])
    }
    
    private func hasGoodDaylight(index i: Int) -> Bool {
        let hours = (daily.sunshineDuration[i] ?? 0) / AppLimits.secondsPerHour
        return hours >= SightseeingThresholds.goodSunshineHours
    }
    
    private func hasSomeDaylight(index i: Int) -> Bool {
        let hours = (daily.sunshineDuration[i] ?? 0) / AppLimits.secondsPerHour
        return hours >= SightseeingThresholds.someSunshineHours
    }
    
    /// Thresholds shared by the two sightseeing scores.
    ///
    /// Note: Open-Meteo's daily forecast doesn't include an air-quality figure, so
    /// AQI isn't part of either score — adding it would mean requesting a new feed
    /// variable and extending `LocationForecastResponse`, which is a data-model
    /// change rather than a scoring-logic one.
    private enum SightseeingThresholds {
        static let heavyPrecipitationMillimetres = 10.0
        static let moderatePrecipitationMillimetres = 1.0
        static let moderatePrecipitationProbability = 50
        static let stormWeatherCodes: Set<Int> = [65, 75, 82, 86, 95, 96, 99]
        static let fogWeatherCodes: Set<Int> = [45, 48]
        
        static let comfortableLow = 15.0
        static let comfortableHigh = 28.0
        static let coldExtreme = 0.0
        static let hotExtreme = 32.0
        
        static let extremeUV = 11.0
        
        static let goodSunshineHours = 8.0
        static let someSunshineHours = 4.0
        
        /// Both sightseeing activities start from the same neutral midpoint; indoor
        /// only ever moves up from here, outdoor moves in both directions.
        static let sightseeingBaseScore = 3
    }
    
    // MARK: Indoor Sightseeing
    // Indoor sightseeing is largely weather-proof, so nothing here ever subtracts
    // from the base score — temperature, storms, precipitation, UV, and (were it
    // available) AQI never count against it directly. Bad outdoor conditions only
    // ever push the score up, toward "this is a good day to be inside instead".
    private func indoorScore(index i: Int) -> Int {
        var score = SightseeingThresholds.sightseeingBaseScore
        
        if wetnessLevel(index: i) >= 1 { score += 1 }       // rain/storm outside
        if hasExtremeTemperature(index: i) { score += 1 }   // too hot or cold outside
        if hasExtremeUV(index: i) { score += 1 }            // harsh sun outside
        if !hasSomeDaylight(index: i) { score += 1 }         // grey, low-light day
        
        return clamp(score, min: 0, max: 5)
    }
    
    // MARK: Outdoor Sightseeing
    // Outdoor sightseeing moves in both directions: comfortable temperatures and
    // good daylight add to the base score, while rain/storms, temperature extremes,
    // poor visibility, and extreme UV subtract from it.
    private func outdoorScore(index i: Int) -> Int {
        var score = SightseeingThresholds.sightseeingBaseScore
        
        if isComfortableTemperature(index: i) { score += 1 }
        if hasGoodDaylight(index: i) { score += 1 }
        
        switch wetnessLevel(index: i) {
            case 2: score -= 2   // heavy rain or storm
            case 1: score -= 1   // light rain / good chance of it
            default: break
        }
        if hasExtremeTemperature(index: i) { score -= 1 }
        if hasExtremeUV(index: i) { score -= 1 }
        if hasPoorVisibility(index: i) { score -= 1 }
        
        return clamp(score, min: 0, max: 5)
    }
    
    private func clamp(_ value: Int, min lower: Int = 1, max upper: Int = 5) -> Int {
        max(lower, min(upper, value))
    }
}

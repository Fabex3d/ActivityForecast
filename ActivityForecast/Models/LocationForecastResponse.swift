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
    
    // MARK: Indoor Sightseeing
    // Drivers: precipitation_sum, precipitation_probability_max, weathercode.
    // Bad outdoor weather = good indoor day.
    private func indoorScore(index i: Int) -> Int {
        let d = daily
        var score = 1
        
        let precip = d.precipitationSum[i]
        let precipProb = d.precipitationProbabilityMax[i] ?? 0
        let code = d.weathercode[i]
        
        if precip >= 10 { score += 3 }
        else if precip >= 1 { score += 2 }
        else if precipProb >= 50 { score += 2 }
        else if precipProb >= 20 { score += 1 }
        
        // Severe WMO codes (thunderstorm, heavy rain/snow)
        if [65, 75, 82, 86, 95, 96, 99].contains(code) { score += 1 }
        
        return clamp(score)
    }
    
    // MARK: Outdoor Sightseeing
    // Drivers: uv_index_max, sunshine_duration, apparent_temperature_max, precipitation_sum.
    private func outdoorScore(index i: Int) -> Int {
        let d = daily
        var score = 1
        
        let uv = d.uvIndexMax[i]
        let sunshine = d.sunshineDuration[i] ?? 0
        let feelsLike = d.apparentTemperatureMax[i]
        let precip = d.precipitationSum[i]
        
        let sunshineHours = sunshine / 3600
        if sunshineHours >= 8 { score += 2 }
        else if sunshineHours >= 4 { score += 1 }
        
        if feelsLike >= 15 && feelsLike <= 28 { score += 2 }
        else if feelsLike >= 10 && feelsLike < 15 { score += 1 }
        else if feelsLike > 32 { score -= 1 } // too hot to enjoy
        
        if precip >= 5 { score -= 2 }
        else if precip > 0 { score -= 1 }
        
        if uv >= 11 { score -= 1 } // extreme sun exposure caution
        
        return clamp(score)
    }
    
    private func clamp(_ v: Int) -> Int { max(1, min(5, v)) }
}

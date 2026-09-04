//
//  UrlComponents.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 04/09/26.
//

import Foundation

enum Scheme: String {
    case https = "https"
}

enum Host: String {
    case geocodingOpenMeteo = "geocoding-api.open-meteo.com"
    case openMeteo = "api.open-meteo.com"
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum UrlPath: String {
    case search = "/v1/search"
    case forecast = "/v1/forecast"
}

enum HeaderKey: String {
    case authorization = "Authorization"
    case contentType = "Content-Type"
}

enum HeaderValue: String {
    case appJson = "application/json"
}

// MARK: - Geocoding API search locations
//https://geocoding-api.open-meteo.com/v1/search?name=mumbai&count=5&language=en&format=json

// MARK: - Weather Forecasting API
//https://api.open-meteo.com/v1/forecast?latitude=46.88&longitude=9.88&timezone=auto&forecast_days=7&daily=weathercode,temperature_2m_max,temperature_2m_min,apparent_temperature_max,precipitation_sum,precipitation_probability_max,snowfall_sum,wind_speed_10m_max,wind_gusts_10m_max,wind_direction_10m_dominant,uv_index_max,sunshine_duration

//https://api.open-meteo.com/v1/forecast?latitude=46.88&longitude=9.88&timezone=auto&daily=weathercode,temperature_2m_max,temperature_2m_min,apparent_temperature_max,precipitation_sum,precipitation_probability_max,snowfall_sum,wind_speed_10m_max,wind_gusts_10m_max,wind_direction_10m_dominant,uv_index_max,sunshine_duration
// MARK: - Marine Forcasting API

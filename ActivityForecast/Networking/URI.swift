//
//  URI.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 04/09/26.
//

import Foundation

protocol URI {
    associatedtype Derived: Decodable
    var httpMethod: HTTPMethod { get }
    var scheme: Scheme { get }
    var headers: [String: String]? { get }
    var host: Host { get }
    var path: UrlPath { get }
    var isParametersPercentEncoded: Bool { get }
    var urlQueryItems: [URLQueryItem]? { get }
    var body: Data? { get }
    
    func getURLRequest() -> URLRequest?
}

extension URI {
    
    var scheme: Scheme {
        return .https
    }
    
    var isParametersPercentEncoded: Bool {
        return false
    }
    
    var urlQueryItems: [URLQueryItem]? {
        return nil
    }
    
    var body: Data? {
        return nil
    }
    
    var headers: [String: String]? {
        return nil
    }
    
    func getURLRequest() -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.host = host.rawValue
        urlComponents.scheme = scheme.rawValue
        urlComponents.path = path.rawValue
        urlComponents.queryItems = urlQueryItems
        guard let url = urlComponents.url else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = headers
        if let body {
            urlRequest.httpBody = body
            urlRequest.setValue(HeaderValue.appJson.rawValue,
                                forHTTPHeaderField: HeaderKey.contentType.rawValue)
        }
        
        return urlRequest
    }
}

// MARK: Open-Meteo URI
protocol OpenMeteo: URI { }

extension OpenMeteo {
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var host: Host {
        return .openMeteo
    }
}

// MARK: GeoCoding URI
protocol GeoCoding: URI { }

extension GeoCoding {
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var host: Host {
        return .geocodingOpenMeteo
    }
}

// MARK: Search API
struct LocationSearchUri: GeoCoding {
    typealias Derived = LocationSearchResponse
    
    var name: String
    
    var path: UrlPath {
        return .search
    }
    
    var urlQueryItems: [URLQueryItem]? {
        return [.init(name: "name", value: name)]
    }
}

// MARK: Forecast API
struct LocationForecastUri: OpenMeteo {
    typealias Derived = LocationForecastResponse
    
    var latitude: Double
    var longitude: Double
    
    var path: UrlPath {
        return .forecast
    }
    
    var urlQueryItems: [URLQueryItem]? {
        let dailyParameters = [
            "weathercode",
            "temperature_2m_max",
            "temperature_2m_min",
            "apparent_temperature_max",
            "precipitation_sum",
            "precipitation_probability_max",
            "snowfall_sum",
            "wind_speed_10m_max",
            "wind_gusts_10m_max",
            "wind_direction_10m_dominant",
            "uv_index_max",
            "sunshine_duration"
        ].joined(separator: ",")
        
        return [
            .init(name: "latitude", value: "\(latitude)"),
            .init(name: "longitude", value: "\(longitude)"),
            .init(name: "timezone", value: "auto"),
            .init(name: "daily", value: dailyParameters)
        ]
    }
}

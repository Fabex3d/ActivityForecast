//
//  GeocodingResponse.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 04/09/26.
//

import Foundation

typealias Locations = [LocationSearchResponse.Location]

/// Top-level response for the Open-Meteo Geocoding search API (`/v1/search`).
/// Note: The `/v1/get?id=` endpoint returns `LocationResult` directly.
public struct LocationSearchResponse: Decodable, Sendable {
    public let results: [Location]?
    
    /// Represents a single location result from Open-Meteo.
    public struct Location: Decodable, Identifiable, Sendable {
        // MARK: - Required Properties (Constants)
        public let id: Int
        public let name: String
        public let latitude: Double
        public let longitude: Double
        public let countryCode: String
        public let country: String
        public let countryId: Int
        
        // MARK: - Optional Properties
        public let elevation: Double?
        public let featureCode: String?
        public let timezone: String?
        public let postcodes: [String]?
        
        // Administrative Area Levels (Omitted in JSON if not applicable)
        public let admin1: String?
        public let admin1Id: Int?
        public let admin2: String?
        public let admin2Id: Int?
        public let admin3: String?
        public let admin3Id: Int?
        public let admin4: String?
        public let admin4Id: Int?
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case latitude
            case longitude
            case elevation
            case featureCode = "feature_code"
            case countryCode = "country_code"
            case country
            case countryId = "country_id"
            case timezone
            case postcodes
            case admin1
            case admin1Id = "admin1_id"
            case admin2
            case admin2Id = "admin2_id"
            case admin3
            case admin3Id = "admin3_id"
            case admin4
            case admin4Id = "admin4_id"
        }
    }
}


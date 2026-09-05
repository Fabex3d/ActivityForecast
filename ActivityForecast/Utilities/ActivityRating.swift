//
//  ActivityRating.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 04/09/26.
//


import Foundation

// MARK: - Rating

/// `public` to match the other domain types (`DayActivityRating`,
/// `LocationForecastResponse`), so scored values can surface through their APIs.
public enum ActivityRating: Int {
    case great = 5
    case good = 4
    case doable = 3
    case marginal = 2
    case skip = 1
    case notHere = 0 // gated off entirely (no snow / no coastline)
    
    var label: String {
        switch self {
            case .great: return "Great"
            case .good: return "Good"
            case .doable: return "Doable"
            case .marginal: return "Marginal"
            case .skip: return "Skip"
            case .notHere: return "Not here"
        }
    }
    
    static func from(score: Double) -> ActivityRating {
        switch Int(score.rounded()) {
            case 5: return .great
            case 4: return .good
            case 3: return .doable
            case 2: return .marginal
            default: return .skip
        }
    }
}

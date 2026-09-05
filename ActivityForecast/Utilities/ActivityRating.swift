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
    case sendIt = 5
    case goForIt = 4
    case notBad = 3
    case ehMaybe = 2
    case stayIn = 1
    case notHere = 0 // gated off entirely (no snow / no coastline)
    
    var label: String {
        switch self {
            case .sendIt: return "Send it"
            case .goForIt: return "Go for it"
            case .notBad: return "Not bad"
            case .ehMaybe: return "Eh, maybe"
            case .stayIn: return "Stay in"
            case .notHere: return "Not here"
        }
    }
    
    static func from(score: Double) -> ActivityRating {
        switch Int(score.rounded()) {
            case 5: return .sendIt
            case 4: return .goForIt
            case 3: return .notBad
            case 2: return .ehMaybe
            default: return .stayIn
        }
    }
}

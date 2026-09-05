//
//  Activity.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import Foundation

/// The four things a day can be rated for.
///
/// This is the presentation-facing counterpart to `DayActivityRating`, which stores
/// the four scores as separate properties. Keeping the selection as a value type
/// means the forecast screen switches activity without re-fetching anything.
public enum Activity: String, CaseIterable, Identifiable, Codable, Sendable {
    case skiing
    case surfing
    case outdoorSightseeing
    case indoorSightseeing

    public var id: String { rawValue }

    /// The full name, used in headings and VoiceOver.
    public var title: String {
        switch self {
            case .skiing: return "Skiing"
            case .surfing: return "Surfing"
            case .outdoorSightseeing: return "Outdoor sights"
            case .indoorSightseeing: return "Indoor sights"
        }
    }

    /// The abbreviated name for the segmented picker, where space is tight.
    public var shortTitle: String {
        switch self {
            case .skiing: return "Ski"
            case .surfing: return "Surf"
            case .outdoorSightseeing: return "Outdoors"
            case .indoorSightseeing: return "Indoors"
        }
    }

    public var systemImage: String {
        switch self {
            case .skiing: return "figure.skiing.downhill"
            case .surfing: return "figure.surfing"
            case .outdoorSightseeing: return "mountain.2.fill"
            case .indoorSightseeing: return "building.columns.fill"
        }
    }

    /// A limitation of the underlying data that a person should know about before
    /// trusting the score. Only surfing has one: the forecast feed carries no swell
    /// or coastline orientation, so its score is a wind-quality proxy.
    public var dataCaveat: String? {
        switch self {
            case .surfing:
                return "Wind quality only — this forecast carries no swell height or coastline orientation."
            case .skiing, .outdoorSightseeing, .indoorSightseeing:
                return nil
        }
    }

    /// Pulls this activity's score out of a day's ratings.
    public func score(in ratings: DayActivityRating) -> Int {
        switch self {
            case .skiing: return ratings.skiing
            case .surfing: return ratings.surfing
            case .outdoorSightseeing: return ratings.outdoorSightseeing
            case .indoorSightseeing: return ratings.indoorSightseeing
        }
    }
}

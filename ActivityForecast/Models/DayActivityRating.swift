//
//  DayActivityRating.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import Foundation

// MARK: - Activity Rating Models
/// `Hashable` so a scored day can take part in view state and diffable lists.
/// Synthesis requires the conformance to sit alongside the declaration.
public struct DayActivityRating: Codable, Hashable, Sendable {
    public let date: String
    public let skiing: Int
    public let surfing: Int
    public let indoorSightseeing: Int
    public let outdoorSightseeing: Int
}

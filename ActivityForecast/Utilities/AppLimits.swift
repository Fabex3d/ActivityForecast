//
//  AppLimits.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import Foundation

/// Behavioural limits and durations. Kept out of the view layer so a rule like the
/// ten-place cap is stated exactly once.
public enum AppLimits {

    /// How many places a person may keep on the home screen.
    public static let maximumSavedPlaces: Int = 10

    /// How long to wait after the last keystroke before hitting the geocoding API.
    public static let searchDebounce: Duration = .milliseconds(300)

    /// Queries shorter than this are not worth a round trip.
    public static let minimumQueryLength: Int = 2

    /// Seconds in an hour — used when turning the feed's sunshine duration into hours.
    public static let secondsPerHour: Double = 3600
}

/// Keys for anything the app writes to `UserDefaults`.
public enum StorageKey: String {
    case savedPlaces = "com.activityforecast.savedPlaces"
}

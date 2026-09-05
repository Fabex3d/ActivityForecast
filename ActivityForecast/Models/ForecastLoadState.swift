//
//  ForecastLoadState.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import Foundation

/// The state of one place's forecast fetch.
///
/// Declared at file scope rather than nested inside a `@MainActor` ViewModel so it
/// stays free of actor isolation and can therefore cross a `TaskGroup` boundary —
/// the home screen fetches every saved place's week concurrently.
public enum ForecastLoadState: Equatable, Sendable {
    case loading
    case loaded([DayForecast])
    case failed(String)

    public var days: [DayForecast] {
        guard case .loaded(let days) = self else { return [] }
        return days
    }
}

//
//  ForecastViewModel.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import Foundation
import Observation

/// Drives the forecast screen for a single place.
///
/// Fetches once and holds all four activities' scores, so switching the activity tab
/// is a pure view change with no further network traffic.
@Observable
@MainActor
final class ForecastViewModel {

    /// The single source of truth the view reads. Every case is rendered explicitly.
    /// Shared with the home screen through `ForecastLoadState`, so both screens agree
    /// on what "loading", "loaded" and "failed" mean.
    typealias ViewState = ForecastLoadState

    /// The place being forecast. Immutable for the lifetime of the screen.
    let place: Place

    private(set) var state: ViewState = .loading

    private let service: ForecastServicing
    private var loadTask: Task<Void, Never>?

    nonisolated init(place: Place, service: ForecastServicing = ForecastService()) {
        self.place = place
        self.service = service
    }

    // MARK: Intents

    /// Fetches the week, replacing any fetch already in flight.
    ///
    /// Mirrors the cancellation pattern the search debounce uses: the previous task
    /// is cancelled, and a `CancellationError` is swallowed because it means the work
    /// was deliberately superseded rather than that anything went wrong.
    func load() {
        loadTask?.cancel()
        state = .loading

        loadTask = Task { [weak self] in
            guard let self else { return }
            do {
                let days = try await self.service.dailyForecast(for: self.place)
                try Task.checkCancellation()
                self.state = .loaded(days)
            } catch is CancellationError {
                // Superseded by a retry, or the reader navigated back.
            } catch {
                self.state = .failed(error.readableMessage)
            }
        }
    }

    func retry() {
        load()
    }

    /// Drops an in-flight fetch. Called when the screen goes away.
    func cancel() {
        loadTask?.cancel()
        loadTask = nil
    }

    // MARK: Derived reads

    var days: [DayForecast] {
        guard case .loaded(let days) = state else { return [] }
        return days
    }

    /// The nearest day in the forecast — the one the hero card describes.
    var leadingDay: DayForecast? {
        days.first
    }

    /// The best day of the week for an activity, used for the "best day" hint.
    /// `nil` while loading, or when every day ties with the leading day, in which
    /// case pointing somewhere else would be noise.
    func bestDay(for activity: Activity) -> DayForecast? {
        let ranked = days.max { activity.score(in: $0.ratings) < activity.score(in: $1.ratings) }
        guard let ranked, let leadingDay else { return nil }
        guard activity.score(in: ranked.ratings) > activity.score(in: leadingDay.ratings) else {
            return nil
        }
        return ranked
    }
}

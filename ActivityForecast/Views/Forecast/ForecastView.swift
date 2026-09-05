//
//  ForecastView.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import SwiftUI

/// A place's week, translated into a suitability ranking per activity.
///
/// The selected activity is `@State` here rather than on the ViewModel: it changes
/// nothing about the data, only which of the four scores already in hand is on
/// screen. Changes are reported back through `onActivityChange` so the home screen
/// can remember what this place is being watched for.
struct ForecastView: View {

    private let onActivityChange: (Activity) -> Void

    @State private var viewModel: ForecastViewModel
    @State private var selectedActivity: Activity

    /// `@MainActor` because it builds a main-actor-isolated ViewModel.
    @MainActor
    init(
        place: Place,
        service: ForecastServicing = ForecastService(),
        onActivityChange: @escaping (Activity) -> Void = { _ in }
    ) {
        // Non-`@State` members are assigned first: the `@State` macro synthesises
        // backing storage, so writing to it before `self` is fully initialised is
        // rejected by the compiler.
        self.onActivityChange = onActivityChange
        viewModel = ForecastViewModel(place: place, service: service)
        selectedActivity = place.preferredActivity
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.large) {
                LocationHeaderView(place: viewModel.place, leadingDay: viewModel.leadingDay)
                ActivityPickerView(selection: $selectedActivity)
                stateContent
            }
            .padding(Spacing.standard)
        }
        .screenBackground()
        .navigationTitle(viewModel.place.name)
        .toolbarTitleDisplayMode(.inline)
        .task { viewModel.load() }
        .onDisappear { viewModel.cancel() }
        .onChange(of: selectedActivity) { _, activity in
            onActivityChange(activity)
        }
    }

    /// Every case of the ViewModel's state is rendered; none fails silently.
    @ViewBuilder
    private var stateContent: some View {
        switch viewModel.state {
            case .loading:
                ForecastLoadingView()

            case .loaded(let days):
                ForecastWeekView(
                    days: days,
                    activity: selectedActivity,
                    bestDay: viewModel.bestDay(for: selectedActivity)
                )

            case .failed(let message):
                ForecastErrorView(message: message) {
                    viewModel.retry()
                }
        }
    }
}

#Preview("Loaded") {
    NavigationStack {
        ForecastView(
            place: .previewZermatt,
            service: StubForecastService(days: PreviewData.zermattWeek)
        )
    }
}

#Preview("Long place name") {
    NavigationStack {
        ForecastView(
            place: .previewLongName,
            service: StubForecastService(days: PreviewData.zermattWeek)
        )
    }
}

#Preview("Loading") {
    NavigationStack {
        ForecastView(
            place: .previewLosAndes,
            service: StubForecastService(delay: .seconds(30))
        )
    }
}

#Preview("Failed") {
    NavigationStack {
        ForecastView(
            place: .previewEriceira,
            service: StubForecastService(failure: .offline)
        )
    }
}

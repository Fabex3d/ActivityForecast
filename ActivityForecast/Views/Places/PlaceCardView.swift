//
//  PlaceCardView.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import SwiftUI

/// One saved place on the home screen.
///
/// Renders whatever state that place's fetch is in, so one slow or failing place
/// never blocks the rest of the list.
struct PlaceCardView: View {

    let place: Place
    let state: ForecastLoadState
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            PlaceCardHeaderView(place: place, leadingDay: state.days.first)

            switch state {
                case .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .leading)

                case .loaded(let days):
                    loadedContent(days: days)

                case .failed(let message):
                    PlaceCardFailureView(message: message, retry: retry)
            }
        }
        .cardSurface()
    }

    @ViewBuilder
    private func loadedContent(days: [DayForecast]) -> some View {
        if let leadingDay = days.first {
            Label(
                "\(place.preferredActivity.title) · \(leadingDay.rating(for: place.preferredActivity).label)",
                systemImage: place.preferredActivity.systemImage
            )
            .font(AppFont.sectionHeader)
            .tracking(Tracking.wide)
            .textCase(.uppercase)
            .foregroundStyle(AppColor.secondaryAccentInk)
        }

        DayScoreStripView(days: days, activity: place.preferredActivity)
    }
}

/// The card's masthead: name, region, and today's temperature.
private struct PlaceCardHeaderView: View {

    let place: Place
    let leadingDay: DayForecast?

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.medium) {
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text(place.name)
                    .font(AppFont.displayTitle)
                    .foregroundStyle(AppColor.primaryText)

                Text(leadingDay?.conditionsSummary ?? place.subtitle)
                    .font(AppFont.rowDetail)
                    .foregroundStyle(AppColor.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let leadingDay {
                Text(WeatherFormat.temperature(celsius: leadingDay.highTemperatureCelsius))
                    .font(AppFont.displayTitle)
                    .foregroundStyle(AppColor.primaryText)
                    .fixedSize()
            }
        }
    }
}

/// A per-card failure that keeps the rest of the list usable.
private struct PlaceCardFailureView: View {

    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text(message)
                .font(AppFont.rowDetail)
                .foregroundStyle(AppColor.secondaryText)

            Button("Try again", systemImage: "arrow.clockwise", action: retry)
                .font(AppFont.chip)
                .buttonStyle(.bordered)
                .tint(AppColor.accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Loaded") {
    ScrollView {
        VStack(spacing: Spacing.medium) {
            PlaceCardView(
                place: .previewZermatt,
                state: .loaded(PreviewData.zermattWeek),
                retry: {}
            )

            PlaceCardView(
                place: .previewLosAndes,
                state: .loaded(PreviewData.losAndesWeek),
                retry: {}
            )
        }
        .padding(Spacing.standard)
    }
    .screenBackground()
}

#Preview("Loading and failed") {
    VStack(spacing: Spacing.medium) {
        PlaceCardView(place: .previewKyoto, state: .loading, retry: {})

        PlaceCardView(
            place: .previewLongName,
            state: .failed(NetworkError.apiLimitReached.localizedDescription),
            retry: {}
        )
    }
    .padding(Spacing.standard)
    .screenBackground()
}

//
//  LocationHeaderView.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import SwiftUI

/// The forecast screen's masthead: where you are, and what it is doing there now.
///
/// Takes a place and, optionally, the nearest day — the header still reads correctly
/// while the forecast is loading or after it has failed.
struct LocationHeaderView: View {

    let place: Place
    let leadingDay: DayForecast?

    var body: some View {
        VStack(spacing: Spacing.small) {
            Text(place.name)
                .font(AppFont.displayLarge)
                .foregroundStyle(AppColor.primaryText)

            Text(place.detailedSubtitle)
                .font(AppFont.rowDetail)
                .foregroundStyle(AppColor.secondaryText)

            if let leadingDay {
                currentConditions(for: leadingDay)
                    .padding(.top, Spacing.small)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func currentConditions(for day: DayForecast) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.medium) {
            Label(WeatherFormat.temperature(celsius: day.highTemperatureCelsius),
                  systemImage: "thermometer.variable")
            .font(AppFont.rowTitle)
            .foregroundStyle(AppColor.secondaryText)
            
            Label(day.conditionsSummary, systemImage: day.condition.systemImage)
                .font(AppFont.rowTitle)
                .foregroundStyle(AppColor.secondaryText)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview("Standard") {
    LocationHeaderView(place: .previewZermatt, leadingDay: .previewSnowy)
        .padding(Spacing.standard)
        .screenBackground()
}

#Preview("Long name, no forecast yet") {
    LocationHeaderView(place: .previewLongName, leadingDay: nil)
        .padding(Spacing.standard)
        .screenBackground()
}

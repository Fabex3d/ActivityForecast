//
//  DayForecastRowView.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import SwiftUI

/// One day of the week, rated for the activity currently on screen.
///
/// The row reads as a single element to VoiceOver — hearing "Sat, Sep 5, 18 cm snow,
/// max minus 4 degrees, wind 14, Send it, 5" as five separate stops would be worse
/// than one sentence.
struct DayForecastRowView: View {

    let day: DayForecast
    let activity: Activity

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var rating: ActivityRating {
        day.rating(for: activity)
    }

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                stackedLayout
            } else {
                inlineLayout
            }
        }
        .padding(.vertical, Spacing.medium)
        .contentShape(.rect)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(day.accessibilityDescription(for: activity))
    }

    /// The default layout: date, reason, verdict and badge on one line.
    private var inlineLayout: some View {
        HStack(spacing: Spacing.medium) {
            DayStampView(day: day)

            Text(day.reason(for: activity))
                .font(AppFont.rowDetail)
                .foregroundStyle(AppColor.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            VerdictLabelView(rating: rating)

            SuitabilityBadgeView(rating: rating, prominence: .compact)
        }
    }

    /// At accessibility text sizes there is no room for four columns, so the row
    /// becomes a block. No text is dropped and nothing is scaled down.
    private var stackedLayout: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            HStack(spacing: Spacing.medium) {
                DayStampView(day: day)
                Spacer(minLength: Spacing.small)
                SuitabilityBadgeView(rating: rating, prominence: .compact)
            }

            VerdictLabelView(rating: rating)

            Text(day.reason(for: activity))
                .font(AppFont.rowDetail)
                .foregroundStyle(AppColor.secondaryText)
        }
    }
}

/// The leading date column: "Today" over "Sep 5".
private struct DayStampView: View {

    let day: DayForecast

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text(day.weekdayLabel)
                .font(AppFont.rowTitle)
                .foregroundStyle(AppColor.primaryText)

            Text(day.dateLabel)
                .font(AppFont.rowDetail)
                .foregroundStyle(AppColor.tertiaryText)
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview("A week of skiing") {
    List(PreviewData.zermattWeek) { day in
        DayForecastRowView(day: day, activity: .skiing)
    }
    .listStyle(.plain)
}

#Preview("A week of outdoor sights — mostly poor") {
    List(PreviewData.zermattWeek) { day in
        DayForecastRowView(day: day, activity: .outdoorSightseeing)
    }
    .listStyle(.plain)
}

#Preview("Accessibility text size") {
    List(PreviewData.zermattWeek) { day in
        DayForecastRowView(day: day, activity: .surfing)
    }
    .listStyle(.plain)
    .environment(\.dynamicTypeSize, .accessibility2)
}

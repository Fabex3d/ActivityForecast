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
    
    private var rating: ActivityRating {
        day.rating(for: activity)
    }

    var body: some View {
        VStack(spacing: Spacing.medium) {
            HStack {
                DayStampView(day: day)
                
                Spacer(minLength: Spacing.small)
                
                HStack {
                    VerdictLabelView(rating: rating)
                    SuitabilityBadgeView(rating: rating, prominence: .compact)
                }
            }
            
            Text(day.reason(for: activity))
                .font(AppFont.rowDetail)
                .foregroundStyle(AppColor.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, Spacing.medium)
        .contentShape(.rect)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(day.accessibilityDescription(for: activity))
    }
}

/// The leading date column: "Today" over "Sep 5".
private struct DayStampView: View {

    let day: DayForecast

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.small) {
            Text(day.weekdayLabel)
                .font(AppFont.rowTitle)
                .foregroundStyle(AppColor.primaryText)

            Text(day.dateLabel)
                .font(AppFont.rowTitle)
                .foregroundStyle(AppColor.tertiaryText)
        }
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

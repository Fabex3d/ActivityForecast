//
//  DayScoreStripView.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import SwiftUI

/// A week at a glance: one tile per day, scored for a single activity.
///
/// This is the home screen's whole value proposition in one row — you can tell a
/// good week from a bad one without reading a single number.
extension PlacesView {
    struct DayScoreStripView: View {
        let days: [DayForecast]
        let activity: Activity
        
        var body: some View {
            columns
                .accessibilityLabel("\(activity.title), next \(days.count) days")
        }
        
        private var columns: some View {
            HStack(spacing: Spacing.small) {
                ForEach(days) { day in
                    DayScoreColumnView(day: day, activity: activity)
                }
            }
        }
    }
}

extension PlacesView.DayScoreStripView {
    // One day of the strip: the score on its fill, over the weekday.
    private struct DayScoreColumnView: View {
        let day: DayForecast
        let activity: Activity
        
        private var rating: ActivityRating {
            day.rating(for: activity)
        }
        
        var body: some View {
            VStack(spacing: Spacing.small) {
                Text(rating == .notHere ? "—" : rating.rawValue.formatted())
                    .font(AppFont.displayBadge)
                    .monospacedDigit()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.medium)
                    .foregroundStyle(rating.style.ink)
                    .background(rating.style.fill, in: .rect(cornerRadius: CornerRadius.medium, style: .continuous))
                
                Text(day.shortWeekdayLabel)
                    .font(AppFont.sectionHeader)
                    .foregroundStyle(AppColor.tertiaryText)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(day.weekdayLabel): \(rating.accessibleLabel)")
        }
    }
}

#Preview("Skiing — strong start, thin middle") {
    PlacesView.DayScoreStripView(days: PreviewData.zermattWeek, activity: .skiing)
        .padding(Spacing.standard)
        .screenBackground()
}

#Preview("Outdoor sights — a poor week") {
    PlacesView.DayScoreStripView(days: PreviewData.zermattWeek, activity: .outdoorSightseeing)
        .padding(Spacing.standard)
        .screenBackground()
}

#Preview("Accessibility text size") {
    PlacesView.DayScoreStripView(days: PreviewData.losAndesWeek, activity: .outdoorSightseeing)
        .padding(Spacing.standard)
        .screenBackground()
        .environment(\.dynamicTypeSize, .accessibility3)
}

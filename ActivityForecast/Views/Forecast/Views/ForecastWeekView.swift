//
//  ForecastWeekView.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import SwiftUI

/// The loaded state of the forecast screen: a verdict for the nearest day, any
/// caveats worth reading, then the week row by row.
///
/// Deliberately takes plain values rather than the ViewModel, so it previews with
/// fixtures and holds no opinion about where the days came from.
struct ForecastWeekView: View {

    let days: [DayForecast]
    let activity: Activity

    /// A later day that scores better than the nearest one, if there is one.
    let bestDay: DayForecast?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.standard) {
            if let leadingDay = days.first {
                ActivityVerdictCardView(activity: activity, day: leadingDay)
            }

            if let bestDay {
                CalloutView(text: bestDayHint(for: bestDay), systemImage: "sparkles")
            }

            if let caveat = activity.dataCaveat {
                CalloutView(
                    text: caveat,
                    systemImage: "exclamationmark.circle.fill",
                    tone: .caution
                )
            }

            SectionHeaderView(title: "Next \(days.count) days · \(activity.title)")
                .padding(.top, Spacing.medium)

            weekRows
        }
    }

    private var weekRows: some View {
        VStack(spacing: 0) {
            ForEach(days) { day in
                DayForecastRowView(day: day, activity: activity)

                if day.id != days.last?.id {
                    Divider()
                }
            }
        }
    }

    private func bestDayHint(for day: DayForecast) -> String {
        let verdict = day.rating(for: activity).label.lowercased()
        return "\(day.weekdayLabel) \(day.dateLabel) is the pick of the week — \(verdict)."
    }
}

#Preview("Skiing at Zermatt") {
    ScrollView {
        ForecastWeekView(
            days: PreviewData.zermattWeek,
            activity: .skiing,
            bestDay: nil
        )
        .padding(Spacing.standard)
    }
    .screenBackground()
}

#Preview("Surfing — caveat and a better day later") {
    ScrollView {
        ForecastWeekView(
            days: PreviewData.losAndesWeek,
            activity: .surfing,
            bestDay: PreviewData.losAndesWeek.dropFirst(4).first
        )
        .padding(Spacing.standard)
    }
    .screenBackground()
}

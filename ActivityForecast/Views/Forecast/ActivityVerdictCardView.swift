//
//  ActivityVerdictCardView.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import SwiftUI

/// The hero card: the answer to "is today any good for this?", in one glance.
///
/// The whole card takes the rating's colour, so the verdict is carried by the fill,
/// the number and the wording together rather than by colour alone.
struct ActivityVerdictCardView: View {

    let activity: Activity
    let day: DayForecast

    private var rating: ActivityRating {
        day.rating(for: activity)
    }

    private var displayScore: String {
        rating == .notHere ? "—" : rating.rawValue.formatted()
    }

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.standard) {
            Text(displayScore)
                .font(AppFont.displayLarge)
                .monospacedDigit()

            VStack(alignment: .leading, spacing: Spacing.small) {
                Label(activity.title, systemImage: activity.systemImage)
                    .font(AppFont.sectionHeader)
                    .tracking(Tracking.wide)
                    .textCase(.uppercase)
                    .opacity(Opacity.prominent)

                Text(rating.label)
                    .font(AppFont.displayVerdict)

                Text(day.reason(for: activity))
                    .font(AppFont.rowDetail)
                    .opacity(Opacity.prominent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Spacing.standard)
        .foregroundStyle(rating.style.ink)
        .background(rating.style.fill, in: .rect(cornerRadius: CornerRadius.large, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(activity.title) \(day.weekdayLabel): \(rating.accessibleLabel)")
        .accessibilityValue(day.reason(for: activity))
    }
}

#Preview("Best case") {
    verdictPreview(activity: .skiing, day: DayForecast.previewSnowy)
}

#Preview("Worst case") {
    verdictPreview(activity: .outdoorSightseeing, day: DayForecast.previewSnowy)
}

#Preview("Every tier, one day") {
    ScrollView {
        VStack(spacing: Spacing.medium) {
            ForEach(Activity.allCases) { activity in
                if let day = DayForecast.previewSnowy {
                    ActivityVerdictCardView(activity: activity, day: day)
                }
            }
        }
        .padding(Spacing.standard)
    }
    .screenBackground()
}

@ViewBuilder
private func verdictPreview(activity: Activity, day: DayForecast?) -> some View {
    if let day {
        ActivityVerdictCardView(activity: activity, day: day)
            .padding(Spacing.standard)
            .screenBackground()
    } else {
        Text("No fixture available")
    }
}

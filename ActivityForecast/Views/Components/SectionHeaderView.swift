//
//  SectionHeaderView.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import SwiftUI

/// The quiet, tracked, uppercase label that introduces a group of content.
struct SectionHeaderView: View {

    let title: String

    var body: some View {
        Text(title)
            .font(AppFont.sectionHeader)
            .tracking(Tracking.wide)
            .textCase(.uppercase)
            .foregroundStyle(AppColor.tertiaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }
}

/// A soft-tinted callout: a hint or a caveat that should read as supporting
/// information rather than as an error.
struct CalloutView: View {

    enum Tone {
        /// The sage voice — helpful hints, e.g. a better day later in the week.
        case helpful
        /// The terracotta voice — limitations the reader should weigh.
        case caution
    }

    let text: String
    let systemImage: String
    var tone: Tone = .helpful

    private var fill: Color {
        tone == .helpful ? AppColor.secondaryAccentTint : AppColor.accentTint
    }

    private var ink: Color {
        tone == .helpful ? AppColor.secondaryAccentInk : AppColor.accentInk
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.medium) {
            Image(systemName: systemImage)
                .font(AppFont.chip)
                .accessibilityHidden(true)

            Text(text)
                .font(AppFont.chip)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, Spacing.standard)
        .padding(.vertical, Spacing.medium)
        .foregroundStyle(ink)
        .background(fill, in: .rect(cornerRadius: CornerRadius.standard, style: .continuous))
    }
}

#Preview("Headers and callouts") {
    VStack(alignment: .leading, spacing: Spacing.large) {
        SectionHeaderView(title: "Next 7 days · Skiing")

        CalloutView(
            text: "Sunday looks best — a 5 for skiing.",
            systemImage: "sparkles"
        )

        CalloutView(
            text: Activity.surfing.dataCaveat ?? "",
            systemImage: "exclamationmark.circle.fill",
            tone: .caution
        )
    }
    .padding(Spacing.standard)
    .screenBackground()
}

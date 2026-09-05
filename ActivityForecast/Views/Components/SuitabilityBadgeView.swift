//
//  SuitabilityBadgeView.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import SwiftUI

/// The score pill: one suitability tier as a number on its matched fill.
///
/// Takes a rating and nothing else, so it can be dropped into a row, a card header
/// or a strip without knowing what it is describing. The number is never the whole
/// message — pair it with `VerdictLabelView` or an accessibility label so the tier
/// is legible without colour vision.
struct SuitabilityBadgeView: View {

    enum Prominence {
        /// Inline in a dense row or strip.
        case compact
        /// The lead element of a card.
        case standard
    }

    let rating: ActivityRating
    var prominence: Prominence = .standard

    /// A rating the scoring engine gated off entirely has no number to show.
    private var displayValue: String {
        rating == .notHere ? "—" : rating.rawValue.formatted()
    }

    private var font: Font {
        prominence == .compact ? AppFont.chip : AppFont.displayBadge
    }

    var body: some View {
        Text(displayValue)
            .font(font)
            .monospacedDigit()
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.small)
            .frame(minWidth: ControlSize.badge)
            .foregroundStyle(rating.style.ink)
            .background(rating.style.fill, in: .capsule)
            .accessibilityLabel(rating.accessibleLabel)
    }
}

/// The verdict in words, drawn directly on the ground rather than on a fill.
struct VerdictLabelView: View {

    let rating: ActivityRating

    var body: some View {
        Text(rating.label)
            .font(AppFont.verdict)
            .foregroundStyle(rating.style.groundInk)
            .accessibilityLabel(rating.accessibleLabel)
    }
}

#Preview("Every tier") {
    VStack(alignment: .leading, spacing: Spacing.medium) {
        ForEach(ActivityRating.allTiers, id: \.rawValue) { rating in
            HStack(spacing: Spacing.standard) {
                SuitabilityBadgeView(rating: rating)
                SuitabilityBadgeView(rating: rating, prominence: .compact)
                VerdictLabelView(rating: rating)
            }
        }
    }
    .padding(Spacing.large)
    .screenBackground()
}

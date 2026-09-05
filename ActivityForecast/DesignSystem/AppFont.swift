//
//  AppFont.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import SwiftUI

/// The app's type scale.
///
/// The design handoff pairs Caprasimo (a heavy display serif) with Figtree. Neither
/// face ships with the app, so display type maps onto the system serif at a heavy
/// weight and body type onto the system sans. Every entry is built from a
/// `Font.TextStyle` rather than a point size, so all text scales with Dynamic Type.
public enum AppFont {

    // MARK: Display — stands in for Caprasimo

    /// Screen titles, e.g. the place name on the forecast screen.
    public static let displayLarge = Font.system(.largeTitle, design: .serif, weight: .bold)

    /// The verdict score on the hero card.
    public static let displayScore = Font.system(.title, design: .serif, weight: .bold)

    /// Card titles, e.g. a place name in the saved list.
    public static let displayTitle = Font.system(.title3, design: .serif, weight: .bold)

    /// The verdict wording on the hero card.
    public static let displayVerdict = Font.system(.headline, design: .serif, weight: .bold)

    /// The number inside a suitability badge.
    public static let displayBadge = Font.system(.subheadline, design: .serif, weight: .bold)

    // MARK: Body — stands in for Figtree

    /// Uppercase, tracked section headers. Pair with `sectionHeaderStyle()`.
    public static let sectionHeader = Font.system(.caption2, weight: .bold)

    /// The leading label of a list row, e.g. "Today".
    public static let rowTitle = Font.system(.subheadline, weight: .semibold)

    /// Supporting detail inside a row, e.g. the driving weather parameters.
    public static let rowDetail = Font.system(.caption, weight: .medium)

    /// The short verdict word rendered on the ground rather than on a fill.
    public static let verdict = Font.system(.caption, weight: .bold)

    /// Pills, chips and slot counters.
    public static let chip = Font.system(.caption, weight: .semibold)

    /// Standard running copy.
    public static let body = Font.system(.subheadline, weight: .medium)
}

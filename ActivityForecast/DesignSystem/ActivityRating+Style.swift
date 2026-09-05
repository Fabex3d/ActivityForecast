//
//  ActivityRating+Style.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import SwiftUI

/// How one step of the suitability scale is painted.
///
/// `fill`/`ink` are a matched pair for solid badges, so a badge reads the same on
/// either ground. `groundInk` is the same step re-toned for drawing the verdict
/// *word* directly on the page, where the badge fills would not carry enough
/// contrast for small text.
public struct RatingStyle: Sendable {
    public let fill: Color
    public let ink: Color
    public let groundInk: Color
}

/// Presentation for the scoring engine's output. The rating itself stays in the
/// domain layer with no knowledge of `Color` — the mapping lives here.
public extension ActivityRating {

    /// The scale as the design's legend shows it: best first, gated-off excluded.
    static let allTiers: [ActivityRating] = [.sendIt, .goForIt, .notBad, .ehMaybe, .stayIn]

    var style: RatingStyle {
        switch self {
            case .sendIt:
                return RatingStyle(
                    fill: .appDynamic(light: 0x56633F, dark: 0x6E7F4E),
                    ink: .appDynamic(light: 0xF0FAE1, dark: 0xF0FAE1),
                    groundInk: .appDynamic(light: 0x56633F, dark: 0xB8C79B)
                )
            case .goForIt:
                return RatingStyle(
                    fill: .appDynamic(light: 0x728157, dark: 0x8B9C67),
                    ink: .appDynamic(light: 0xF0FAE1, dark: 0x1B2011),
                    groundInk: .appDynamic(light: 0x56633F, dark: 0xB8C79B)
                )
            case .notBad:
                return RatingStyle(
                    fill: .appDynamic(light: 0xF6A06B, dark: 0xC97F49),
                    ink: .appDynamic(light: 0x402310, dark: 0x2A1607),
                    groundInk: .appDynamic(light: 0x8C491A, dark: 0xE9A470)
                )
            case .ehMaybe:
                return RatingStyle(
                    fill: .appDynamic(light: 0xB2622D, dark: 0x9E5525),
                    ink: .appDynamic(light: 0xFFF2EB, dark: 0xFFF2EB),
                    groundInk: .appDynamic(light: 0x8C491A, dark: 0xE08B4F)
                )
            case .stayIn:
                return RatingStyle(
                    fill: .appDynamic(light: 0x645C50, dark: 0x554E44),
                    ink: .appDynamic(light: 0xF9F4ED, dark: 0xE7DFD2),
                    groundInk: .appDynamic(light: 0x645C50, dark: 0xB0A695)
                )
            case .notHere:
                return RatingStyle(
                    fill: .appDynamic(light: 0xDCD3C4, dark: 0x3A342C),
                    ink: .appDynamic(light: 0x474238, dark: 0xC0B6A5),
                    groundInk: .appDynamic(light: 0x82796A, dark: 0xA19786)
                )
        }
    }

    /// A neutral, non-idiomatic rendering of the rating. The playful `label` carries
    /// the app's voice; this one is used for VoiceOver, where "Send it" is ambiguous.
    var accessibleLabel: String {
        switch self {
            case .sendIt: return "Excellent"
            case .goForIt: return "Good"
            case .notBad: return "Fair"
            case .ehMaybe: return "Poor"
            case .stayIn: return "Bad"
            case .notHere: return "Not applicable"
        }
    }
}

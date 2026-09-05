//
//  AppColor.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import SwiftUI

/// The "Organic" palette from the design handoff, declared once for the whole app.
///
/// Every role carries a light and a dark rendition so the app follows the system
/// appearance without any view having to branch on `colorScheme`. The warm ground
/// is deliberately kept warm in the dark rendition — the design system calls out
/// that desaturating the palette into greys defeats its purpose.
public enum AppColor {

    // MARK: Ground

    /// The page background.
    public static let background = Color.appDynamic(light: 0xF5EAD8, dark: 0x171310)

    /// Filled surfaces that sit on the ground: cards, tiles, search fields.
    public static let surface = Color.appDynamic(light: 0xEBDDC5, dark: 0x241E18)

    /// The lifted surface used by sheets and the highest elevation step.
    public static let raisedSurface = Color.appDynamic(light: 0xF9F4ED, dark: 0x2E2720)

    // MARK: Ink

    /// Primary body and heading colour.
    public static let primaryText = Color.appDynamic(light: 0x201E1D, dark: 0xF5EAD8)

    /// Supporting copy — subtitles, conditions, metadata.
    public static var secondaryText: Color { primaryText.opacity(Opacity.secondary) }

    /// The quietest ink: section headers, day-of-week captions.
    public static var tertiaryText: Color { primaryText.opacity(Opacity.tertiary) }

    // MARK: Accents

    /// The terracotta accent — primary actions and interactive chrome.
    public static let accent = Color.appDynamic(light: 0xC67139, dark: 0xE08B4F)

    /// The deep accent step used for accent-coloured *text* on the ground, where
    /// the base accent does not reach a body-copy contrast ratio.
    public static let accentInk = Color.appDynamic(light: 0x8C491A, dark: 0xF0A86C)

    /// A soft accent tint for badges and callouts.
    public static let accentTint = Color.appDynamic(light: 0xFFE1D0, dark: 0x40230F)

    /// The sage second accent — a genuine second voice, not just a highlight.
    public static let secondaryAccent = Color.appDynamic(light: 0x7A8A5E, dark: 0xA3B583)

    /// The deep sage step for sage-coloured text on the ground.
    public static let secondaryAccentInk = Color.appDynamic(light: 0x56633F, dark: 0xB8C79B)

    /// A soft sage tint for "best day" and informational callouts.
    public static let secondaryAccentTint = Color.appDynamic(light: 0xE1EECC, dark: 0x27301A)

    // MARK: Lines

    /// Row rules and hairline borders.
    public static var divider: Color { primaryText.opacity(Opacity.divider) }
}

// MARK: - Opacity tokens

/// The opacity scale. Like spacing and corner radius, opacity is a token — a bare
/// `0.55` in a view is a defect even when it happens to match a value here.
public enum Opacity {
    public static let opaque: Double = 1
    public static let prominent: Double = 0.85
    public static let secondary: Double = 0.6
    public static let tertiary: Double = 0.45
    public static let divider: Double = 0.12
    public static let disabled: Double = 0.4
}

// MARK: - Dynamic colour construction

extension Color {

    /// Builds a colour that resolves to `light` or `dark` from the trait environment.
    ///
    /// The two arguments are 24-bit `0xRRGGBB` literals. Raw colour values belong
    /// only to the `DesignSystem` folder — it *is* the token layer. No feature view
    /// should ever call this directly.
    static func appDynamic(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { traitCollection in
            let packed = traitCollection.userInterfaceStyle == .dark ? dark : light
            return UIColor(packedRGB: packed)
        })
    }
}

private extension UIColor {

    /// Component layout of a packed `0xRRGGBB` value.
    private enum RGB {
        static let redShift: UInt32 = 16
        static let greenShift: UInt32 = 8
        static let mask: UInt32 = 0xFF
        static let maxComponent: CGFloat = 255
    }

    convenience init(packedRGB packed: UInt32) {
        let red = CGFloat((packed >> RGB.redShift) & RGB.mask) / RGB.maxComponent
        let green = CGFloat((packed >> RGB.greenShift) & RGB.mask) / RGB.maxComponent
        let blue = CGFloat(packed & RGB.mask) / RGB.maxComponent
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}

//
//  AppStyleTokens.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import SwiftUI

/// Letter-spacing tokens. Only the tracked, uppercase section header needs one.
public enum Tracking {
    public static let none: CGFloat = 0
    public static let wide: CGFloat = 1
}

/// The elevation scale from the design system, tuned to the warm ground.
///
/// Views reach for these through `appShadow(_:)` rather than composing
/// `shadow(color:radius:x:y:)` by hand.
public struct Elevation: Sendable {
    fileprivate let radius: CGFloat
    fileprivate let verticalOffset: CGFloat
    fileprivate let opacity: Double

    /// Cards and tiles resting on the ground.
    public static let low = Elevation(radius: 2, verticalOffset: 1, opacity: 0.14)

    /// Floating containers.
    public static let medium = Elevation(radius: 10, verticalOffset: 3, opacity: 0.16)

    /// Sheets and modals at the top of the stack.
    public static let high = Elevation(radius: 32, verticalOffset: 12, opacity: 0.22)
}

/// Fixed control metrics that are not spacing values — icon boxes, badge widths and
/// the minimum tap target. Expressed as multiples of the spacing scale so they stay
/// on grid.
public enum ControlSize {
    /// Apple's minimum comfortable hit target.
    public static let minimumTapTarget: CGFloat = Spacing.large * 2

    /// The square icon well used by circular toolbar-style buttons.
    public static let iconWell: CGFloat = Spacing.large + Spacing.small

    /// Width of a suitability badge.
    public static let badge: CGFloat = Spacing.large + Spacing.medium

    /// Height of one column in the seven-day score strip.
    public static let scoreStripColumn: CGFloat = Spacing.large + Spacing.medium
}

// MARK: - Shared modifiers

public extension View {

    /// Applies one step of the elevation scale.
    func appShadow(_ elevation: Elevation) -> some View {
        modifier(AppShadowModifier(elevation: elevation))
    }

    /// Wraps content in the standard filled, over-rounded card surface.
    func cardSurface(cornerRadius: CGFloat = CornerRadius.large) -> some View {
        modifier(CardSurfaceModifier(cornerRadius: cornerRadius))
    }

    /// Fills content into a pill — the shape this system uses for every small control.
    func pillSurface(fill: Color, ink: Color) -> some View {
        modifier(PillSurfaceModifier(fill: fill, ink: ink))
    }

    /// Paints the warm ground behind a screen, ignoring safe areas.
    func screenBackground() -> some View {
        background(AppColor.background.ignoresSafeArea())
    }
}

private struct AppShadowModifier: ViewModifier {
    let elevation: Elevation

    func body(content: Content) -> some View {
        content.shadow(
            color: AppColor.primaryText.opacity(elevation.opacity),
            radius: elevation.radius,
            x: 0,
            y: elevation.verticalOffset
        )
    }
}

private struct CardSurfaceModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(Spacing.standard)
            .background(AppColor.surface, in: .rect(cornerRadius: cornerRadius, style: .continuous))
            .appShadow(.low)
    }
}

private struct PillSurfaceModifier: ViewModifier {
    let fill: Color
    let ink: Color

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.small)
            .foregroundStyle(ink)
            .background(fill, in: .capsule)
    }
}

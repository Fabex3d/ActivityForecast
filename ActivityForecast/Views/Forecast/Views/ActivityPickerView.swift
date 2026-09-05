//
//  ActivityPickerView.swift
//  ActivityForecast
//
//  Created by Sujit Thorat by 05/09/26.
//

import SwiftUI

/// The four-way activity selector.
///
/// A stock segmented `Picker` rather than a bespoke tile row: it already handles
/// Dynamic Type, VoiceOver, keyboard focus and the platform's own selection
/// animation, none of which a hand-rolled row of tappable rectangles would.
struct ActivityPickerView: View {

    @Binding var selection: Activity

    var body: some View {
        Picker("Activity", selection: $selection) {
            ForEach(Activity.allCases) { activity in
                Text(activity.shortTitle)
                    .tag(activity)
                    .accessibilityLabel(activity.title)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("Activity")
    }
}

#Preview("Picker") {
    @Previewable @State var selection: Activity = .skiing

    VStack(spacing: Spacing.large) {
        ActivityPickerView(selection: $selection)
        Text(selection.title)
            .font(AppFont.displayTitle)
    }
    .padding(Spacing.standard)
    .screenBackground()
}

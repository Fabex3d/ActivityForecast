//
//  ActivityPickerView.swift
//  ActivityForecast
//
//  Created by Sujit Thorat by 05/09/26.
//

import SwiftUI

extension ForecastView {
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
}


#Preview("Picker") {
    @Previewable @State var selection: Activity = .skiing

    VStack(spacing: Spacing.large) {
        ForecastView.ActivityPickerView(selection: $selection)
        Text(selection.title)
            .font(AppFont.displayTitle)
    }
    .padding(Spacing.standard)
    .screenBackground()
}

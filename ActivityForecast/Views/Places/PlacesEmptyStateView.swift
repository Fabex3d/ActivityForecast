//
//  PlacesEmptyStateView.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import SwiftUI

/// First run: no places saved yet.
///
/// States the ten-place allowance up front, so the cap reads as a generous
/// allowance rather than as a limit discovered later.
struct PlacesEmptyStateView: View {

    let findPlace: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Nowhere to be. Yet.", systemImage: "mountain.2.fill")
        } description: {
            Text(
                "Add up to \(AppLimits.maximumSavedPlaces) places and we'll rate every day of the week for skiing, surfing and sightseeing — indoors or out."
            )
        } actions: {
            Button("Find a place", systemImage: "magnifyingglass", action: findPlace)
                .buttonStyle(.borderedProminent)
        }
        .tint(AppColor.accent)
        .screenBackground()
    }
}

#Preview {
    PlacesEmptyStateView {}
}

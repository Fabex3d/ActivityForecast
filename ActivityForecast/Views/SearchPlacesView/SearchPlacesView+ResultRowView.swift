//
//  SearchPlacesView+ResultRowView.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import SwiftUI

extension SearchPlacesView {

    /// One search result, plus the affordance to add it.
    ///
    /// Composes the existing `LocationItemView` rather than duplicating its layout,
    /// and states *why* an add button is unavailable — already on the list, or no
    /// slots left — instead of just dimming it.
    struct ResultRowView: View {

        let place: Place
        let isSaved: Bool
        let hasRoom: Bool
        let add: () -> Void

        private var statusDescription: String? {
            if isSaved { return "Already on your list" }
            if !hasRoom { return "List is full" }
            return nil
        }

        var body: some View {
            HStack(spacing: Spacing.standard) {
                LocationItemView(
                    city: place.name,
                    stateOrRegion: place.region,
                    country: place.country
                )

                accessory
            }
            .padding(.vertical, Spacing.small)
            .opacity(isSaved ? Opacity.disabled : Opacity.opaque)
        }

        @ViewBuilder
        private var accessory: some View {
            if isSaved {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(AppColor.secondaryAccentInk)
                    .accessibilityLabel("Already on your list")
            } else {
                Button("Add \(place.name)", systemImage: "plus", action: add)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.circle)
                    .tint(AppColor.accent)
                    .disabled(!hasRoom)
                    .accessibilityHint(statusDescription ?? "Adds this place to your list")
            }
        }
    }
}

#Preview("Result states") {
    List {
        SearchPlacesView.ResultRowView(
            place: .previewZermatt,
            isSaved: false,
            hasRoom: true
        ) {}

        SearchPlacesView.ResultRowView(
            place: .previewEriceira,
            isSaved: true,
            hasRoom: true
        ) {}

        SearchPlacesView.ResultRowView(
            place: .previewLongName,
            isSaved: false,
            hasRoom: false
        ) {}
    }
    .listStyle(.plain)
}

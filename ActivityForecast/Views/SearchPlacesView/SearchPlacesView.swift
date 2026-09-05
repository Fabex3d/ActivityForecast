//
//  SearchPlacesView.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 04/09/26.
//

import SwiftUI

/// Search for a place and add it to the watch list.
///
/// Presented as a sheet from `PlacesView`. It reports an addition back through
/// `onAdd` rather than owning the list itself, which keeps the ten-place cap in one
/// place and lets this screen be previewed with nothing but an array.
struct SearchPlacesView: View {

    /// What is already on the list — drives the "already added" state and the
    /// remaining-slot count.
    let savedPlaces: [Place]

    let onAdd: (Place) -> Void

    @State private var viewModel: PlaceSearchViewModel
    @State private var searchText = ""

    @Environment(\.dismiss) private var dismiss

    /// `@MainActor` because it builds a main-actor-isolated ViewModel.
    @MainActor
    init(
        savedPlaces: [Place],
        service: PlaceSearching = PlaceSearchService(),
        onAdd: @escaping (Place) -> Void
    ) {
        // Plain stored properties are assigned before the `@State` ones: the macro
        // synthesises backing storage, which cannot be written to until `self` is
        // fully initialised.
        self.savedPlaces = savedPlaces
        self.onAdd = onAdd
        viewModel = PlaceSearchViewModel(service: service)
    }

    private var savedIdentifiers: Set<Place.ID> {
        Set(savedPlaces.map(\.id))
    }

    private var remainingSlots: Int {
        max(0, AppLimits.maximumSavedPlaces - savedPlaces.count)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                SlotCounterView(remainingSlots: remainingSlots)
                    .padding(.horizontal, Spacing.standard)

                results
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .screenBackground()
            .navigationTitle("Add a place")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search for a city or town")
        .submitLabel(.search)
        .onChange(of: searchText) { _, query in
            viewModel.search(query: query)
        }
        .onDisappear { viewModel.cancel() }
    }

    /// Each state of the search is rendered explicitly — in particular, "nothing
    /// typed yet" and "typed, but no matches" are different messages.
    @ViewBuilder
    private var results: some View {
        switch viewModel.state {
            case .prompt:
                ContentUnavailableView(
                    "Search for places",
                    systemImage: "magnifyingglass",
                    description: Text("Type at least \(AppLimits.minimumQueryLength) letters of a city or town.")
                )

            case .searching:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .results(let places):
                resultList(places)

            case .noMatches(let query):
                ContentUnavailableView.search(text: query)

            case .failed(let message):
                ContentUnavailableView {
                    Label("Search failed", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(message)
                } actions: {
                    Button("Try again") { viewModel.search(query: searchText) }
                        .buttonStyle(.borderedProminent)
                }
                .tint(AppColor.accent)
        }
    }

    private func resultList(_ places: [Place]) -> some View {
        List(places) { place in
            ResultRowView(
                place: place,
                isSaved: savedIdentifiers.contains(place.id),
                hasRoom: remainingSlots > 0
            ) {
                onAdd(place)
            }
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

/// How much room is left on the list, stated before anyone taps an add button.
private struct SlotCounterView: View {

    let remainingSlots: Int

    private var text: String {
        remainingSlots == 0
            ? "No slots left of \(AppLimits.maximumSavedPlaces) — remove a place first"
            : "\(remainingSlots) slots left of \(AppLimits.maximumSavedPlaces)"
    }

    var body: some View {
        Text(text)
            .font(AppFont.chip)
            .pillSurface(fill: AppColor.accentTint, ink: AppColor.accentInk)
    }
}

#Preview("With room") {
    SearchPlacesView(
        savedPlaces: [.previewZermatt],
        service: StubPlaceSearchService()
    ) { _ in }
}

#Preview("At capacity") {
    SearchPlacesView(
        savedPlaces: Place.previewCapacityList,
        service: StubPlaceSearchService()
    ) { _ in }
}

#Preview("Search failed") {
    SearchPlacesView(
        savedPlaces: [],
        service: StubPlaceSearchService(failure: .offline)
    ) { _ in }
}

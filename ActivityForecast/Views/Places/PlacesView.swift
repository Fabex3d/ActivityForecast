//
//  PlacesView.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import SwiftUI

/// The app's root screen: the places you're watching, each with this week's scores.
///
/// Navigation is a typed `NavigationStack` path of `Place` values — the whole place
/// travels to the forecast screen, so nothing has to be looked back up by identifier.
struct PlacesView: View {

    @State private var viewModel: PlacesViewModel
    @State private var route: [Place] = []
    @State private var isSearchPresented = false

    init(viewModel: PlacesViewModel? = nil) {
        _viewModel = State(wrappedValue: viewModel ?? PlacesViewModel())
    }

    var body: some View {
        NavigationStack(path: $route) {
            content
                .navigationTitle("Activity Forecast")
                .toolbar {
                    toolbarContent
                }
                .navigationDestination(for: Place.self) { place in
                    ForecastView(place: place) { activity in
                        viewModel.setPreferredActivity(activity, for: place)
                    }
                }
                .sheet(isPresented: $isSearchPresented) {
                    SearchPlacesView(savedPlaces: viewModel.places) { place in
                        viewModel.add(place)
                    }
                }
        }
        .task {
            viewModel.refresh()
        }
        .onDisappear {
            viewModel.cancel()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isEmpty {
            PlacesEmptyStateView {
                isSearchPresented = true
            }
        } else {
            placeList
        }
    }

    private var placeList: some View {
        List {
            ForEach(viewModel.places) { place in
                NavigationLink(value: place) {
                    PlaceCardView(place: place, state: viewModel.forecastState(for: place)) {
                        viewModel.loadForecast(for: place)
                    }
                }
                .listRowInsets(
                    EdgeInsets(
                        top: Spacing.medium,
                        leading: Spacing.standard,
                        bottom: Spacing.medium,
                        trailing: Spacing.standard
                    )
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .onDelete { offsets in
                viewModel.remove(atOffsets: offsets)
            }
            .onMove { source, destination in
                viewModel.move(fromOffsets: source, toOffset: destination)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .screenBackground()
        .refreshable {
            await viewModel.refreshAndWait()
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if !viewModel.isEmpty {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button("Add a place", systemImage: "plus") {
                isSearchPresented = true
            }
            .disabled(viewModel.isAtCapacity)
        }
    }
}

#Preview("Four places") {
    PlacesView(
        viewModel: PlacesViewModel(
            service: StubForecastService(days: PreviewData.zermattWeek),
            store: InMemorySavedPlacesStore(places: Place.previewList)
        )
    )
}

#Preview("First run") {
    PlacesView(
        viewModel: PlacesViewModel(
            service: StubForecastService(),
            store: InMemorySavedPlacesStore()
        )
    )
}

#Preview("At capacity") {
    PlacesView(
        viewModel: PlacesViewModel(
            service: StubForecastService(days: PreviewData.losAndesWeek),
            store: InMemorySavedPlacesStore(places: Place.previewCapacityList)
        )
    )
}

#Preview("Every place failing") {
    PlacesView(
        viewModel: PlacesViewModel(
            service: StubForecastService(failure: .offline),
            store: InMemorySavedPlacesStore(places: Place.previewList)
        )
    )
}

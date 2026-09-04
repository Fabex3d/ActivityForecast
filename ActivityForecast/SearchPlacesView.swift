//
//  SearchPlacesView.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 04/09/26.
//

import SwiftUI

struct SearchPlacesView: View {
    @State private var searchText: String = ""
    @State private var locations: Locations = []
    @State private var searchTask: Task<Void, Never>?
    
    var body: some View {
        NavigationStack {
            content
        }
        .onChange(of: searchText) { oldValue, newValue in
            onSearchTextChanged(newValue)
        }
        .searchable(text: $searchText, placement: .automatic, prompt: "Search for a city or town")
        .submitLabel(.search)
        .onSubmit(of: .search) {
            onSearchTextChanged(searchText)
        }
    }
    
    func onSearchTextChanged(_ searchText: String) {
        searchTask?.cancel()
        
        searchTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(300))
                try Task.checkCancellation()
                
                let data = try await NetworkService.shared.execute(
                    with: LocationSearchUri(name: searchText)
                )
                
                try Task.checkCancellation()
                self.locations = data.results ?? []
            } catch is CancellationError {
                // expected — superseded by a newer keystroke
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if !locations.isEmpty {
            List(locations) { location in
                LocationCellView(city: location.name,
                                 stateOrRegion: location.admin1,
                                 country: location.country
                )
                .onTapGesture {
                    Task {
                        if let data = try? await NetworkService.shared.execute(with: LocationForecastUri(latitude: location.latitude, longitude: location.longitude)) {
                            print(data.daily.weathercode)
                            print(data.activityRatings())
                        }
                        
                    }
                }
            }
        } else {
            ContentUnavailableView("Search for places", systemImage: "star")
        }
        
    }
}

#Preview {
    SearchPlacesView()
}


extension SearchPlacesView {
    struct LocationCellView: View {
        let city: String
        let stateOrRegion: String?
        let country: String
        
        private var subtitle: String {
            if let stateOrRegion, !stateOrRegion.isEmpty {
                return "\(stateOrRegion), \(country)"
            } else {
                return country
            }
        }
        
        var body: some View {
            HStack(spacing: Spacing.standard) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(width: 28)
                
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text(city)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

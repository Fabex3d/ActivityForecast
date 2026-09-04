//
//  ActivityForecastApp.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 04/09/26.
//

import SwiftUI

@main
struct ActivityForecastApp: App {
    var body: some Scene {
        WindowGroup {
            SearchPlacesView()
        }
    }
}

import SwiftUI

struct LocationCellView: View {
    let city: String
    let stateOrRegion: String?
    let country: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.circle.fill")
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(city)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var subtitle: String {
        if let stateOrRegion, !stateOrRegion.isEmpty {
            return "\(stateOrRegion), \(country)"
        } else {
            return country
        }
    }
}

// MARK: - Usage in a List

struct LocationListView: View {
    let locations: [(city: String, region: String?, country: String)] = [
        ("San Francisco", "California", "United States"),
        ("London", nil, "United Kingdom"),
        ("Kyoto", "Kyoto Prefecture", "Japan")
    ]
    
    var body: some View {
        List(locations, id: \.city) { location in
            LocationCellView(
                city: location.city,
                stateOrRegion: location.region,
                country: location.country
            )
        }
        .listStyle(.plain)
    }
}

#Preview {
    LocationListView()
}

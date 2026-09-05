//
//  LocationItemView.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//
import SwiftUI

extension SearchPlacesView {
    struct LocationItemView: View {
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

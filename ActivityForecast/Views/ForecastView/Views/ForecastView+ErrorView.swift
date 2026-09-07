//
//  ErrorView.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import SwiftUI

extension ForecastView {
    /// Shown when a forecast fetch fails. Always offers a way forward.
    struct ErrorView: View {
        
        let message: String
        let retry: () -> Void
        
        var body: some View {
            ContentUnavailableView {
                Label("No forecast yet", systemImage: "cloud.slash")
            } description: {
                Text(message)
            } actions: {
                Button("Try again", systemImage: "arrow.clockwise", action: retry)
                    .buttonStyle(.borderedProminent)
            }
            .tint(AppColor.accent)
        }
    }
}

#Preview("Network failure") {
    ForecastView.ErrorView(message: NetworkError.notfound.localizedDescription) {}
        .screenBackground()
}

#Preview("Malformed response") {
    ForecastView.ErrorView(
        message: ForecastMappingError.inconsistentDailyArrays.localizedDescription
    ) {}
        .screenBackground()
}

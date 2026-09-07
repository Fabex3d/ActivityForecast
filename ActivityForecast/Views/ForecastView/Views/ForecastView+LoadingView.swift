//
//  LoadingView.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import SwiftUI

extension ForecastView {
    /// Shown while a place's week is being fetched.
    struct LoadingView: View {
        
        var body: some View {
            VStack(spacing: Spacing.standard) {
                ProgressView()
                Text("Reading the week…")
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, Spacing.large * 2)
            .accessibilityElement(children: .combine)
        }
    }
}


#Preview {
    ForecastView.LoadingView()
        .screenBackground()
}

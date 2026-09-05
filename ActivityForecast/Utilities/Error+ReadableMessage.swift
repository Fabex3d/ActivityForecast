//
//  Error+ReadableMessage.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 05/09/26.
//

import Foundation

public extension Error {

    /// A message fit to put in front of a person.
    ///
    /// `NetworkError` declares `localizedDescription` on the concrete type rather
    /// than through `LocalizedError.errorDescription`, so calling
    /// `localizedDescription` on an `any Error` would miss it. This bridges the gap
    /// in one place instead of every call site casting.
    var readableMessage: String {
        if let networkError = self as? NetworkError {
            return networkError.localizedDescription
        }
        return localizedDescription
    }
}

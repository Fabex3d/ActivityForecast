//
//  NetworkError.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 04/09/26.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case unauthorized
    case badRequest
    case forbidden
    case notfound
    case apiLimitReached
    case dataParsingError
    case failedJsonConversion
    case failedRequestGen
    case failedAPI
    case timeout
    case unknown(Error)
}

extension NetworkError {
    var localizedDescription: String {
        switch self {
            case .unauthorized:
                return "🚫 Un-Authorized. Check or update API-Key/Token."
            case .forbidden:
                return "🚷 Forbidden. Contact support."
            case .notfound:
                return "🔍 Not found. Please try again."
            case .apiLimitReached:
                return "⏳ API limit reached. Try again later."
            case .dataParsingError:
                return "🔄 Oops! Data parsing error. Please try again."
            case .failedRequestGen:
                return "🛑 Request generation failed. Please try again."
            case .failedAPI:
                return "🔴 API failed. Please try again."
            case .timeout:
                return "⏰ The request timed out."
            case .unknown(let error):
                return "\(error.localizedDescription)"
            case .failedJsonConversion:
                return "Failed to convert JSON-String to data."
            case .badRequest:
                return "Bad Request"
        }
    }
}

//
//  NetworkService.swift
//  ActivityForecast
//
//  Created by Sujit Thorat on 04/09/26.
//

import Foundation

struct NetworkService {
    
    static let shared = NetworkService()
    
    private let session: URLSession
    
    private init() {
        // Configure the session
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 45 // Set a timeout of 45 seconds
        self.session = URLSession(configuration: configuration)
    }
    
    func execute<URNType>(with urnType: URNType) async throws -> URNType.Derived where URNType : URI {
        guard let request = urnType.getURLRequest() else {
            throw NetworkError.failedRequestGen
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            try validateResponse(for: response, data: data)
            return try decodeResponse(for: urnType, from: data)
        } catch {
            throw error
        }
    }
    
    private func decodeResponse<URNType>(for urnType: URNType, from data: Data) throws -> URNType.Derived where URNType : URI {
        let decoder = JSONDecoder()
        return try decoder.decode(URNType.Derived.self, from: data)
    }
}

private extension NetworkService {
    func validateResponse(for response: URLResponse, data: Data) throws {
        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.notfound
        }
        switch response.statusCode {
            case StatusCode.success.rawValue:
                break
            case StatusCode.badRequest.rawValue:
                throw NetworkError.badRequest
            case StatusCode.unauthorized.rawValue:
                throw NetworkError.unauthorized
            case StatusCode.forbidden.rawValue:
                throw NetworkError.forbidden
            case StatusCode.notFound.rawValue:
                throw NetworkError.notfound
            case StatusCode.apiLimitReached.rawValue:
                throw NetworkError.apiLimitReached
            case 202...500:
                throw NetworkError.dataParsingError
            default:
                throw NetworkError.failedAPI
        }
    }
}

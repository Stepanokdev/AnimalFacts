//
//  NetworkService.swift
//  AnimalFacts
//
//  Created by  Stepanok Ivan on 28.07.2024.
//

import Foundation
import ComposableArchitecture
import Combine

struct NetworkService {
    var fetchCategories: @Sendable () async throws -> [AnimalCategory]
}

extension NetworkService: DependencyKey {
    static let liveValue = Self(
        fetchCategories: {
            let url = URL(string: Constants.baseURL + "animals.json")!
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode)
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let categories = try decoder.decode([AnimalCategory].self, from: data)
                                
                return categories
            } catch {
                throw NetworkError.decodingError(error)
            }
        }
    )
}

extension DependencyValues {
    var networkService: NetworkService {
        get { self[NetworkService.self] }
        set { self[NetworkService.self] = newValue }
    }
}

enum NetworkError: Error {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return NSLocalizedString("Invalid response from the server", comment: "Invalid Response")
        case .httpError(let statusCode):
            return NSLocalizedString("HTTP error: \(statusCode)", comment: "HTTP Error")
        case .decodingError(let error):
            return NSLocalizedString("Failed to decode response: \(error.localizedDescription)", comment: "Decoding Error")
        }
    }
}
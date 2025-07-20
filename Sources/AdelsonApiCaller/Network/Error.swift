//
//  File.swift
//  AdelsonApiCaller
//
//  Created by ahmed on 18/07/2025.
//

import Foundation
enum AdelsonNetworkServiceWithTokenError: Error, LocalizedError {
    case badRequest // 400
    case unauthorized // 401
    case paymentRequired // 402
    case forbidden // 403
    case notFound // 404
    case tokenNotProvided
    case networkError(Error, statusCode: Int?)
    case decodingError(Error)
    case invalidURL
    case serverError(statusCode: Int)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .badRequest:
            return "Bad request (400)"
        case .unauthorized:
            return "Unauthorized - Token expired or invalid (401)"
        case .paymentRequired:
            return "Payment required (402)"
        case .forbidden:
            return "Access forbidden (403)"
        case .notFound:
            return "Resource not found (404)"
        case .tokenNotProvided:
            return "Authentication token is required."
        case .networkError(let error, let statusCode):
            return "Network error: \(error.localizedDescription) (Status: \(statusCode ?? 0))"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .invalidURL:
            return "Invalid URL or server unreachable."
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

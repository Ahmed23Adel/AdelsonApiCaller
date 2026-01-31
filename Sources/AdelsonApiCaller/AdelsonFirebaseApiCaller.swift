//
//  File.swift
//  AdelsonApiCaller
//
//  Created by ahmed on 31/01/2026.
//


import Alamofire
import AdelsonAuthManager

@available(macOS 10.15, *)
class AdelsonFirebaseApiCaller<T: Decodable & Sendable> {
    
    private let maxRetries = 1
    
    func call(url: String,
             params: [String : String],
             method: HTTPMethod,
             config: AdelsonFirebaseAuthConfig
    ) async throws -> T {
        return try await callWithRetry(
            url: url,
            params: params,
            method: method,
            config: config,
            retryCount: 0
        )
    }
    
    private func callWithRetry(
        url: String,
        params: [String : String],
        method: HTTPMethod,
        config: AdelsonFirebaseAuthConfig,
        retryCount: Int
    ) async throws -> T {
        do {
            let tokenId = await config.fnFirebaseIdToken()
            return try await callGivenUrl(
                url: url,
                params: params,
                method: method,
                token: tokenId
            )
        } catch let error as AdelsonNetworkServiceWithTokenError {
            switch error {
            case .unauthorized:
                guard retryCount < maxRetries else {
                    throw error
                }
                
                // Retry the call
                return try await callWithRetry(
                    url: url,
                    params: params,
                    method: method,
                    config: config,
                    retryCount: retryCount + 1
                )
            default:
                throw error
            }
        }
    }
    
    private func callGivenUrl(
        url: String,
        params: [String : String],
        method: HTTPMethod,
        token: String
    ) async throws -> T {
        let networkService = AdelsonNetworkServiceWithToken<T>()
        return try await networkService.request(
            url: url,
            method: method,
            parameters: params,
            responseType: T.self,
            token: token
        )
    }
    
}

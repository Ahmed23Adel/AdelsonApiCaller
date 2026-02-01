//
//  File.swift
//  AdelsonApiCaller
//
//  Created by ahmed on 31/01/2026.
//


import Alamofire
import AdelsonAuthManager

@available(macOS 10.15, *)
public final class AdelsonFirebaseApiCaller<T: Decodable & Sendable> {
    
    private let maxRetries = 1
    public init(){
        
    }
    public func call<R: Encodable & Sendable>(url: String,
             params: R,
             method: AdelsonHTTPMethod,
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
    
    public func callGet(
        url: String,
        queryParams: [String: String],
        config: AdelsonFirebaseAuthConfig
    ) async throws -> T {
        return try await callGetWithRetry(
            url: url,
            queryParams: queryParams,
            config: config,
            retryCount: 0
        )
    }
    
    private func callWithRetry<R: Encodable & Sendable>(
        url: String,
        params: R,
        method: AdelsonHTTPMethod,
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
    
    private func callGetWithRetry(
        url: String,
        queryParams: [String: String],
        config: AdelsonFirebaseAuthConfig,
        retryCount: Int
    ) async throws -> T {
        do {
            let tokenId = await config.fnFirebaseIdToken()
            return try await callGetGivenUrl(
                url: url,
                queryParams: queryParams,
                token: tokenId
            )
        } catch let error as AdelsonNetworkServiceWithTokenError {
            switch error {
            case .unauthorized:
                guard retryCount < maxRetries else {
                    throw error
                }
                return try await callGetWithRetry(
                    url: url,
                    queryParams: queryParams,
                    config: config,
                    retryCount: retryCount + 1
                )
            default:
                throw error
            }
        }
    }
    
    private func callGivenUrl<R: Encodable & Sendable>(
        url: String,
        params: R,
        method: AdelsonHTTPMethod,
        token: String
    ) async throws -> T {
        let networkService = AdelsonNetworkServiceWithToken<T>()
        return try await networkService.request(
            url: url,
            method: method.alamofireMethod,
            parameters: params,
            responseType: T.self,
            token: token
        )
    }
    
    private func callGetGivenUrl(
        url: String,
        queryParams: [String: String],
        token: String
    ) async throws -> T {
        let networkService = AdelsonNetworkServiceWithToken<T>()
        return try await networkService.requestGet(
            url: url,
            queryParams: queryParams,
            responseType: T.self,
            token: token
        )
    }
    
}

// The Swift Programming Language
// https://docs.swift.org/swift-book

import Alamofire
import AdelsonAuthManager



import Alamofire
import AdelsonAuthManager

@available(macOS 10.15, *)
class AdelsonApiCaller<T: Decodable & Sendable>: AdelsonApiCallerType {
    
    private let maxRetries = 1
    
    func call(url: String,
             params: [String : String],
             method: HTTPMethod,
             config: AdelsonAuthConfig
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
        config: AdelsonAuthConfig,
        retryCount: Int
    ) async throws -> T {
        do {
            guard let accessToken = await config.mainAuthConfig.accessToken else {
                throw AdelsonNetworkServiceWithTokenError.tokenNotProvided
            }
            
            return try await callGivenUrl(
                url: url,
                params: params,
                method: method,
                token: accessToken
            )
        } catch let error as AdelsonNetworkServiceWithTokenError {
            switch error {
            case .unauthorized:
                guard retryCount < maxRetries else {
                    throw error
                }
                
                try await handleUnauthorizedCall(config: config)
                
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
    
    private func handleUnauthorizedCall(config: AdelsonAuthConfig) async throws {
        // 1- refresh token
        do {
            try await refreshToken(config: config)
        } catch {
            // 2- login if refresh fails
            try await login(config: config)
        }
    }
    
    private func refreshToken(config: AdelsonAuthConfig) async throws {
        let networkService = AlamoFireNetworkService()
        
        // Safe unwrapping
        guard let refreshToken = await config.mainAuthConfig.refresh_token else {
            throw AdelsonNetworkServiceWithTokenError.tokenNotProvided
        }
        
        let params = ["refresh_token": refreshToken]
        
        let result = try await networkService.request(
            url: config.refreshTokenConfig.url,
            method: .post,
            parameters: params,
            responseType: ResponseBodyModel.self
        )
        
        await MainActor.run {
            config.mainAuthConfig.setAccessToken(accessToken: result.access_token)
            config.mainAuthConfig.setRefreshToken(refreshToken: result.refresh_token)
        }
    }
    
    private func login(config: AdelsonAuthConfig) async throws {
        let networkService = AlamoFireNetworkService()
        
        // Safe unwrapping
        guard let username = await config.mainAuthConfig.username,
              let password = await config.mainAuthConfig.password else {
            throw AdelsonNetworkServiceWithTokenError.tokenNotProvided // or create a more specific error
        }
        
        let params = ["username": username, "password": password]
        
        let result = try await networkService.request(
            url: config.traditionalLoginConfig.url,
            method: .post,
            parameters: params,
            responseType: ResponseBodyModel.self
        )
        
        await MainActor.run {
            config.mainAuthConfig.setAccessToken(accessToken: result.access_token)
            config.mainAuthConfig.setRefreshToken(refreshToken: result.refresh_token)
        }
    }
}

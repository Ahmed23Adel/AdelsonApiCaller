//
//  AdelsonNetworkServiceWithToken.swift
//  AdelsonApiCaller
//
//  Created by ahmed on 18/07/2025.
//


import Alamofire



@available(macOS 10.15, *)
final class AdelsonNetworkServiceWithToken<T: Decodable & Sendable>: AdelsonNetworkServiceWithTokenType {
    
    
    public func request<R: Encodable & Sendable>(
            url: String,
            method: Alamofire.HTTPMethod,
            parameters: R,
            responseType: T.Type,
            token: String
    ) async throws -> T {
        guard !token.isEmpty else {
            throw AdelsonNetworkServiceWithTokenError.tokenNotProvided
        }
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(
                url,
                method: method,
                parameters: parameters,
                encoder: JSONParameterEncoder.default,
                headers: HTTPHeaders([
                    "Authorization": "Bearer \(token)"
                ])
            )
            .validate(statusCode: 200..<300)
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                        let tokenError = self.handleTokenError(response: response, error: error)
                        continuation.resume(throwing: tokenError)
                    
                }
            }
        }
    }
    
    private func handleTokenError(response: DataResponse<T, AFError>, error: AFError) -> Error {
            // Check HTTP status code
            if let statusCode = response.response?.statusCode {
                print("❌ Error with status code:", statusCode)
                
                switch statusCode {
                case 400:
                    return AdelsonNetworkServiceWithTokenError.badRequest
                case 401:
                    return AdelsonNetworkServiceWithTokenError.unauthorized
                case 402:
                    return AdelsonNetworkServiceWithTokenError.paymentRequired
                case 403:
                    return AdelsonNetworkServiceWithTokenError.forbidden
                case 404:
                    return AdelsonNetworkServiceWithTokenError.notFound
                case 500...599:
                    return AdelsonNetworkServiceWithTokenError.serverError(statusCode: statusCode)
                default:
                    return AdelsonNetworkServiceWithTokenError.networkError(error, statusCode: statusCode)
                }
            }
            
            // Handle network-level errors
            if error.isSessionTaskError {
                print("🔌 Possibly unreachable server or invalid URL")
                return AdelsonNetworkServiceWithTokenError.invalidURL
            } else if error.isResponseSerializationError {
                return AdelsonNetworkServiceWithTokenError.decodingError(error)
            } else {
                return AdelsonNetworkServiceWithTokenError.networkError(error, statusCode: nil)
            }
        }
    
    
}

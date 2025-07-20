//
//  AdelsonNetworkService.swift
//  AdelsonApiCaller
//
//  Created by ahmed on 18/07/2025.
//


import Alamofire

public protocol AdelsonNetworkServiceWithTokenType<T>: Sendable{
    associatedtype T = Decodable & Sendable
    func request(
        url: String,
        method: HTTPMethod,
        parameters: [String: String],
        responseType: T.Type,
        token: String
    ) async throws-> T
}

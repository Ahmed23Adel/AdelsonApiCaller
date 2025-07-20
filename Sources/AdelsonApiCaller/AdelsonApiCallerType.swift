//
//  File.swift
//  AdelsonApiCaller
//
//  Created by ahmed on 18/07/2025.
//

import Foundation
import Alamofire
import AdelsonAuthManager

protocol AdelsonApiCallerType <T> {
    associatedtype T = Decodable
    
    func call(url: String, params: [String: String], method: HTTPMethod, config: AdelsonAuthConfig) async throws-> T
}

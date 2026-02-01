//
//  File.swift
//  AdelsonApiCaller
//
//  Created by ahmed on 01/02/2026.
//

import Foundation
import Alamofire
public enum AdelsonHTTPMethod {
    case get
    case post
    case put
    case delete
}


extension AdelsonHTTPMethod {
    internal var alamofireMethod: HTTPMethod {
        switch self {
        case .get:    return .get
        case .post:   return .post
        case .put:    return .put
        case .delete: return .delete
        }
    }
}

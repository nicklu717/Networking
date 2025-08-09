//
//  MockAPIEndpoint.swift
//  Networking
//
//  Created by 陸瑋恩 on 2025/7/5.
//

import Foundation

@testable import Networking

class MockAPIEndpoint: HTTPEndpoint<MockAPIEnvironment> {
    
    required init(
        path: String,
        method: HTTPMethod,
        headers: [HTTPHeader],
        parameter: HTTPParameter?
    ) {
        super.init(
            domain: {
                switch $0 {
                case .staging:
                    return "https://staging.example.com"
                case .production:
                    return "https://api.example.com"
                }
            },
            path: path,
            method: method,
            headers: headers,
            parameter: parameter
        )
    }
    
    static var plain: Self {
        Self(
            path: "/plain",
            method: .GET,
            headers: [],
            parameter: nil
        )
    }
    
    static func plainWithHeaderValue(accessToken: String) -> Self {
        Self(
            path: "/plainWithHeaderValue",
            method: .GET,
            headers: [
                .authorization(.bearer(accessToken)),
            ],
            parameter: nil
        )
    }
    
    static func url(queries: [String: String]) -> Self {
        Self(
            path: "/urlQueries",
            method: .GET,
            headers: [],
            parameter: .url(queries: queries)
        )
    }
    
    static func body(data: Data) -> Self {
        Self(
            path: "/bodyWithData",
            method: .POST,
            headers: [
                .contentType(.json)
            ],
            parameter: .body(.data(data))
        )
    }
    
    static func body(encodable: Encodable) -> Self {
        Self(
            path: "/bodyWithEncodable",
            method: .POST,
            headers: [
                .contentType(.json)
            ],
            parameter: .body(.json(encodable))
        )
    }
    
    static var invalidURL: Self {
        Self(
            path: " /invalidURL",
            method: .GET,
            headers: [],
            parameter: nil
        )
    }
    
    static func jsonEncodingFailure(encodable: Encodable) -> Self {
        Self(
            path: "/jsonEncodingFailure",
            method: .POST,
            headers: [],
            parameter: .body(.json(encodable))
        )
    }
}

//enum MockAPIEndpoint {
//    case plain
//    case plainWithHeaderValue(accessToken: String)
//    
//    case urlQueries([String: String])
//    case bodyWithData(Data)
//    case bodyWithEncodable(Encodable)
//    
//    case invalidURL
//    case jsonEncodingFailure(Encodable)
//}
//
//extension MockAPIEndpoint: HTTPEndpointProtocol {
//    
//    func domain(for environment: Environment) -> String {
//        switch self {
//        case .invalidURL:
//            return "https://invalid domain.example.com"
//        default:
//            switch environment {
//            case .staging:
//                return "https://staging.example.com"
//            case .production:
//                return "https://api.example.com"
//            }
//        }
//    }
//    
//    var path: String {
//        switch self {
//        case .plain:
//            return "/plain"
//        case .plainWithHeaderValue:
//            return "/plainWithHeaderValue"
//        case .urlQueries:
//            return "/urlQueries"
//        case .bodyWithData:
//            return "/bodyWithData"
//        case .bodyWithEncodable:
//            return "/bodyWithEncodable"
//        case .invalidURL:
//            return "/invalid URL"
//        case .jsonEncodingFailure:
//            return "/jsonEncodingFailure"
//        }
//    }
//    
//    var method: HTTPMethod {
//        switch self {
//        case .plain, .plainWithHeaderValue, .urlQueries, .invalidURL:
//            return .GET
//        case .bodyWithData, .bodyWithEncodable, .jsonEncodingFailure:
//            return .POST
//        }
//    }
//    
//    var headers: [HTTPHeader] {
//        switch self {
//        case .plain, .urlQueries, .invalidURL, .jsonEncodingFailure:
//            return []
//        case .plainWithHeaderValue(let accessToken):
//            return [
//                .authorization(.bearer(accessToken)),
//            ]
//        case .bodyWithData, .bodyWithEncodable:
//            return [
//                .contentType(.json)
//            ]
//        }
//    }
//    
//    var parameter: HTTPParameter? {
//        switch self {
//        case .plain, .plainWithHeaderValue, .invalidURL:
//            return nil
//        case .urlQueries(let queries):
//            return .url(queries: queries)
//        case .bodyWithData(let data):
//            return .body(.data(data))
//        case .bodyWithEncodable(let encodable), .jsonEncodingFailure(let encodable):
//            return .body(.json(encodable))
//        }
//    }
//}

//
//  HTTPEndpointProtocol.swift
//  Networking
//
//  Created by 陸瑋恩 on 2025/6/22.
//

import Foundation
import HTTPTypes

public protocol HTTPEndpointProtocol {
    associatedtype Environment
    
    func domain(for environment: Environment) -> String
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [HTTPHeader] { get }
    var parameter: HTTPParameter? { get }
    
    func makeRequest(for environment: Environment) throws -> URLRequest
}

extension HTTPEndpointProtocol {
    public func makeRequest(for environment: Environment) throws -> URLRequest {
        guard let url = URL(string: domain(for: environment) + path) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.requestMethod.rawValue
        headers.map(\.entry).forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.field.rawName)
        }
        if let parameter {
            switch parameter {
            case .url(let queries):
                let queryItems = queries.map { URLQueryItem(name: $0.key, value: $0.value) }
                request.url?.append(queryItems: queryItems)
            case .body(let bodyType):
                switch bodyType {
                case .data(let data):
                    request.httpBody = data
                case .json(let encodable):
                    request.httpBody = try JSONEncoder().encode(encodable)
                }
            }
        }
        return request
    }
}

// MARK: - Void Environment
extension HTTPEndpointProtocol where Environment == Void {
    public func domain() -> String {
        return domain(for: ())
    }
    
    public func makeRequest() throws -> URLRequest {
        return try makeRequest(for: ())
    }
}

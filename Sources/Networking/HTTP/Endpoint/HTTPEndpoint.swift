//
//  HTTPEndpoint.swift
//  Networking
//
//  Created by 陸瑋恩 on 2025/6/22.
//

import Foundation
import HTTPTypes

open class HTTPEndpoint<Environment> {
    let domain: (Environment) -> String
    let path: String
    let method: HTTPMethod
    let headers: [HTTPHeader]
    let parameter: HTTPParameter?
    
    public init(
        domain: @escaping (Environment) -> String,
        path: String,
        method: HTTPMethod,
        headers: [HTTPHeader],
        parameter: HTTPParameter?
    ) {
        self.domain = domain
        self.path = path
        self.method = method
        self.headers = headers
        self.parameter = parameter
    }
    
    open func makeRequest(for environment: Environment) -> Result<URLRequest, MakeRequestError> {
        let urlString = domain(environment) + path
        guard let url = URL(string: urlString) else { return .failure(.invalidURL(urlString)) }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
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
                    do {
                        request.httpBody = try JSONEncoder().encode(encodable)
                    } catch {
                        return .failure(.jsonEncodingFailure(error))
                    }
                }
            }
        }
        return .success(request)
    }
}

// MARK: - Make Request Error
extension HTTPEndpoint {
    public enum MakeRequestError: Error {
        case invalidURL(String)
        case jsonEncodingFailure(Error)
    }
}

// MARK: - Void Environment
extension HTTPEndpoint where Environment == Void {
    public func makeRequest() -> Result<URLRequest, MakeRequestError> {
        return makeRequest(for: ())
    }
}

//
//  HTTPEndpointProtocolTests.swift
//  Networking
//
//  Created by 陸瑋恩 on 2025/6/22.
//

import Testing
import Foundation
import Algorithms

@testable import Networking

@Suite
struct HTTPEndpointProtocolTests {
    
    @Suite
    struct MakeRequestTests {
        
        @Test(arguments: product(
            Array<MockAPIEndpoint>([
                .plain,
                .plainWithHeaderValue(accessToken: "mock_access_token"),
                .urlQueries(["product_id": "12345"]),
                .bodyWithData("mock_data".data(using: .utf8)!),
                .bodyWithEncodable(["product_id": "12345"]),
            ]),
            MockAPIEndpoint.Environment.allCases
        ))
        func success(endpoint: MockAPIEndpoint, environment: MockAPIEndpoint.Environment) throws {
            var successRequest: URLRequest?
            var failureError: HTTPEndpointMakeRequestError?
            
            switch endpoint.makeRequest(for: environment) {
            case .success(let request):
                successRequest = request
            case .failure(let error):
                failureError = error
            }
            
            let request = try #require(successRequest)
            
            var queryString = ""
            if case .url(let queries) = endpoint.parameter {
                guard !queries.isEmpty else { return }
                queryString = "?\(queries.map { "\($0)=\($1)" }.joined(separator: "&"))"
            }
            #expect(request.url?.absoluteString == endpoint.domain(for: environment) + endpoint.path + queryString)
            #expect(request.httpMethod == endpoint.method.rawValue)
            #expect(request.allHTTPHeaderFields?.count == endpoint.headers.count)
            endpoint.headers.map(\.entry).forEach {
                #expect(request.value(forHTTPHeaderField: $0.field.rawName) == $0.value)
            }
            if let parameter = endpoint.parameter {
                switch parameter {
                case .url(let queries):
                    guard !queries.isEmpty else { break }
                    queryString = "?\(queries.map { "\($0)=\($1)" }.joined(separator: "&"))"
                case .body(let bodyType):
                    switch bodyType {
                    case .data(let data):
                        #expect(request.httpBody == data)
                    case .json(let encodable):
                        let data = try #require(try JSONEncoder().encode(encodable))
                        #expect(request.httpBody == data)
                    }
                }
            }
            #expect(failureError == nil)
        }
        
        @Test(arguments: MockAPIEndpoint.Environment.allCases)
        func invalidURL(environment: MockAPIEndpoint.Environment) {
            let endpoint: MockAPIEndpoint = .invalidURL
            var successRequest: URLRequest?
            var invalidURLError: HTTPEndpointMakeRequestError?
            var otherFailureError: HTTPEndpointMakeRequestError?
            
            switch endpoint.makeRequest(for: environment) {
            case .success(let request):
                successRequest = request
            case .failure(let error):
                switch error {
                case .invalidURL:
                    invalidURLError = error
                default:
                    otherFailureError = error
                }
            }
            
            #expect(successRequest == nil)
            #expect(invalidURLError != nil)
            #expect(otherFailureError == nil)
        }
        
        @Test(arguments: MockAPIEndpoint.Environment.allCases)
        func jsonEncodingFailure(environment: MockAPIEndpoint.Environment) {
            let endpoint: MockAPIEndpoint = .jsonEncodingFailure(InvalidEncodable())
            var successRequest: URLRequest?
            var jsonEncodingFailureError: HTTPEndpointMakeRequestError?
            var otherFailureError: HTTPEndpointMakeRequestError?
            
            switch endpoint.makeRequest(for: environment) {
            case .success(let request):
                successRequest = request
            case .failure(let error):
                switch error {
                case .jsonEncodingFailure:
                    jsonEncodingFailureError = error
                default:
                    otherFailureError = error
                }
            }
            
            #expect(successRequest == nil)
            #expect(jsonEncodingFailureError != nil)
            #expect(otherFailureError == nil)
        }
    }
}

// MARK: - Mock Encodables
extension HTTPEndpointProtocolTests {
    
    struct InvalidEncodable: Encodable {
        let float: Float = .infinity
    }
}

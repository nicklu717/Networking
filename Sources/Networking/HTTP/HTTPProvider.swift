//
//  HTTPProvider.swift
//  Networking
//
//  Created by 陸瑋恩 on 2025/7/16.
//

import Foundation
import Combine

open class HTTPProvider<Endpoint, Environment> where Endpoint: HTTPEndpoint<Environment> {
    private let client: URLSessionClientProtocol
    private let environment: Environment
    
    public init(client: URLSessionClientProtocol, environment: Environment) {
        self.client = client
        self.environment = environment
    }
    
    // MARK: - Async
    open func sendRequest(for endpoint: Endpoint) async -> Result<Void, FetchError> {
        return await fetchData(for: endpoint).map { _ in () }
    }
    
    open func fetchObject<T>(for endpoint: Endpoint, type: T.Type) async -> Result<T, FetchError> where T: Decodable {
        return await fetchData(for: endpoint).flatMap { decode(data: $0) }
    }
    
    private func fetchData(for endpoint: Endpoint) async -> Result<Data, FetchError> {
        return await makeRequest(for: endpoint)
            .asyncFlatMap { await client.fetchData(request: $0).mapError { .urlSessionClientError($0) } }
    }
    
    // MARK: - Combine
    open func sendRequestPublisher(for endpoint: Endpoint) -> AnyPublisher<Void, FetchError> {
        return fetchDataPublisher(for: endpoint)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    open func fetchObjectPublisher<T>(for endpoint: Endpoint, type: T.Type) -> AnyPublisher<T, FetchError> where T: Decodable {
        return fetchDataPublisher(for: endpoint)
            .flatMap { [weak self] data -> AnyPublisher<T, FetchError> in
                guard let self = self else { return Fail(outputType: T.self, failure: .selfBeingReleased).eraseToAnyPublisher() }
                return self.decode(data: data).publisher.eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func fetchDataPublisher(for endpoint: Endpoint) -> AnyPublisher<Data, FetchError> {
        return makeRequest(for: endpoint).publisher
            .flatMap { [weak self] request -> AnyPublisher<Data, FetchError> in
                guard let self = self else { return Fail(outputType: Data.self, failure: .selfBeingReleased).eraseToAnyPublisher() }
                return client.fetchDataPublisher(request: request, resultAfterCancelledHandler: nil)
                    .mapError { .urlSessionClientError($0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

extension HTTPProvider {
    private func makeRequest(for endpoint: Endpoint) -> Result<URLRequest, FetchError> {
        return endpoint.makeRequest(for: environment).mapError { .makeRequestError($0) }
    }
    
    private func decode<T>(data: Data) -> Result<T, FetchError> where T: Decodable {
        do {
            return .success(try JSONDecoder().decode(T.self, from: data))
        } catch {
            return .failure(.jsonDecodingFailure(error))
        }
    }
}

// MARK: - Fetch Error
extension HTTPProvider {
    public enum FetchError: Error {
        case urlSessionClientError(URLSessionClient.FetchError)
        case makeRequestError(HTTPEndpoint<Environment>.MakeRequestError)
        case jsonDecodingFailure(Error)
        case selfBeingReleased
    }
}

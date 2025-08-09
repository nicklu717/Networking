//
//  HTTPProviderTests.swift
//  Networking
//
//  Created by 陸瑋恩 on 2025/7/17.
//

import Testing
import Foundation
import Combine

@testable import Networking

@Suite
struct HTTPProviderTests {
    
    @Suite
    struct SendRequestTests {
        
        @Test(arguments: MockAPIEnvironment.allCases)
        func success(environment: MockAPIEnvironment) async {
            let provider = HTTPProvider<MockAPIEndpoint, MockAPIEnvironment>(client: MockURLSessionClient(mockResult: .success(Data())), environment: environment)
            var isSuccess = false
            var failureError: HTTPProvider<MockAPIEndpoint, MockAPIEnvironment>.FetchError?
            
            switch await provider.sendRequest(for: .plain) {
            case .success:
                isSuccess = true
            case .failure(let error):
                failureError = error
            }
            
            #expect(isSuccess)
            #expect(failureError == nil)
        }
        
        @Test(arguments: MockAPIEnvironment.allCases)
        func urlSessionClientError(environment: MockAPIEnvironment) async throws {
            let requestFailureError: URLSessionClient.FetchError = .requestFailure(statusCode: 401, Data())
            let provider = HTTPProvider<MockAPIEndpoint, MockAPIEnvironment>(client: MockURLSessionClient(mockResult: .failure(requestFailureError)), environment: environment)
            var isSuccess = false
            var urlSessionClientError: HTTPProvider<MockAPIEndpoint, MockAPIEnvironment>.FetchError?
            var otherFailureError: HTTPProvider<MockAPIEndpoint, MockAPIEnvironment>.FetchError?
            
            switch await provider.sendRequest(for: .plain) {
            case .success:
                isSuccess = true
            case .failure(let error):
                switch error {
                case .urlSessionClientError:
                    urlSessionClientError = error
                default:
                    otherFailureError = error
                }
            }
            
            #expect(!isSuccess)
            #expect(urlSessionClientError != nil)
            #expect(otherFailureError == nil)
        }
    }
    
    @Suite
    struct FetchObjectTests {
        
        let mockID = 1
        let mockName = "Test"
        
        @Test(arguments: MockAPIEnvironment.allCases)
        func success(environment: MockAPIEnvironment) async throws {
            let data = "{\"id\": \(mockID), \"name\": \"\(mockName)\"}".data(using: .utf8)!
            let provider = HTTPProvider<MockAPIEndpoint, MockAPIEnvironment>(client: MockURLSessionClient(mockResult: .success(data)), environment: environment)
            var successObject: MockObject?
            var failureError: HTTPProvider<MockAPIEndpoint, MockAPIEnvironment>.FetchError?
            
            switch await provider.fetchObject(for: .plain, type: MockObject.self) {
            case .success(let object):
                successObject = object
            case .failure(let error):
                failureError = error
            }
            
            #expect(successObject == MockObject(id: mockID, name: mockName))
            #expect(failureError == nil)
        }
        
        @Test(arguments: MockAPIEnvironment.allCases)
        func jsonDecodingFailure(environment: MockAPIEnvironment) async throws {
            let data = "{}".data(using: .utf8)!
            let provider = HTTPProvider<MockAPIEndpoint, MockAPIEnvironment>(client: MockURLSessionClient(mockResult: .success(data)), environment: environment)
            var successObject: MockObject?
            var jsonDecodingFailureError: HTTPProvider<MockAPIEndpoint, MockAPIEnvironment>.FetchError?
            var otherFailureError: HTTPProvider<MockAPIEndpoint, MockAPIEnvironment>.FetchError?
            
            switch await provider.fetchObject(for: .plain, type: MockObject.self) {
            case .success(let object):
                successObject = object
            case .failure(let error):
                switch error {
                case .jsonDecodingFailure:
                    jsonDecodingFailureError = error
                default:
                    otherFailureError = error
                }
            }
            
            #expect(successObject == nil)
            #expect(jsonDecodingFailureError != nil)
            #expect(otherFailureError == nil)
        }
    }
    
    @Suite
    struct SendRequestPublisherTests {
        
        var cancellables = Set<AnyCancellable>()
        
        @Test(arguments: MockAPIEnvironment.allCases)
        mutating func success(environment: MockAPIEnvironment) async {
            let provider = HTTPProvider<MockAPIEndpoint, MockAPIEnvironment>(client: MockURLSessionClient(mockResult: .success(Data())), environment: environment)
            var isSuccess = false
            var isFinished = false
            var failureError: HTTPProvider<MockAPIEndpoint, MockAPIEnvironment>.FetchError?
            
            await withCheckedContinuation { continuation in
                provider.sendRequestPublisher(for: .plain)
                    .sink(
                        receiveCompletion: {
                            switch $0 {
                            case .finished:
                                isFinished = true
                            case .failure(let error):
                                failureError = error
                            }
                            continuation.resume()
                        },
                        receiveValue: {
                            isSuccess = true
                        }
                    )
                    .store(in: &cancellables)
            }
            
            #expect(isSuccess)
            #expect(isFinished)
            #expect(failureError == nil)
        }
        
        @Test(arguments: MockAPIEnvironment.allCases)
        mutating func urlSessionClientError(environment: MockAPIEnvironment) async throws {
            let requestFailureError: URLSessionClient.FetchError = .requestFailure(statusCode: 401, Data())
            let provider = HTTPProvider<MockAPIEndpoint, MockAPIEnvironment>(client: MockURLSessionClient(mockResult: .failure(requestFailureError)), environment: environment)
            var isSuccess = false
            var isFinished = false
            var urlSessionClientError: HTTPProvider<MockAPIEndpoint, MockAPIEnvironment>.FetchError?
            var otherFailureError: HTTPProvider<MockAPIEndpoint, MockAPIEnvironment>.FetchError?
            
            await withCheckedContinuation { continuation in
                provider.sendRequestPublisher(for: .plain)
                    .sink(
                        receiveCompletion: {
                            switch $0 {
                            case .finished:
                                isFinished = true
                            case .failure(let error):
                                switch error {
                                case .urlSessionClientError:
                                    urlSessionClientError = error
                                default:
                                    otherFailureError = error
                                }
                            }
                            continuation.resume()
                        },
                        receiveValue: {
                            isSuccess = true
                        }
                    )
                    .store(in: &cancellables)
            }
            
            #expect(!isSuccess)
            #expect(!isFinished)
            #expect(urlSessionClientError != nil)
            #expect(otherFailureError == nil)
        }
    }
    
    @Suite
    struct FetchObjectPublisherTests {
        
        var cancellables = Set<AnyCancellable>()
        
        let mockID = 1
        let mockName = "Test"
        
        @Test(arguments: MockAPIEnvironment.allCases)
        mutating func success(environment: MockAPIEnvironment) async {
            let data = "{\"id\": \(mockID), \"name\": \"\(mockName)\"}".data(using: .utf8)!
            let provider = HTTPProvider<MockAPIEndpoint, MockAPIEnvironment>(client: MockURLSessionClient(mockResult: .success(data)), environment: environment)
            var successObject: MockObject?
            var isFinished = false
            var failureError: HTTPProvider<MockAPIEndpoint, MockAPIEnvironment>.FetchError?
            
            await withCheckedContinuation { continuation in
                provider.fetchObjectPublisher(for: .plain, type: MockObject.self)
                    .sink(
                        receiveCompletion: {
                            switch $0 {
                            case .finished:
                                isFinished = true
                            case .failure(let error):
                                failureError = error
                            }
                            continuation.resume()
                        },
                        receiveValue: { object in
                            successObject = object
                        }
                    )
                    .store(in: &cancellables)
            }
            
            #expect(successObject == MockObject(id: mockID, name: mockName))
            #expect(isFinished)
            #expect(failureError == nil)
        }
        
        @Test(arguments: MockAPIEnvironment.allCases)
        mutating func selfBeingReleased(environment: MockAPIEnvironment) async {
            let data = "{\"id\": \(mockID), \"name\": \"\(mockName)\"}".data(using: .utf8)!
            var provider: HTTPProvider<MockAPIEndpoint, MockAPIEnvironment>? = HTTPProvider(client: MockURLSessionClient(mockResult: .success(data)), environment: environment)
            var successObject: MockObject?
            var isFinished = false
            var selfBeingReleasedError: HTTPProvider<MockAPIEndpoint, MockAPIEnvironment>.FetchError?
            var otherFailureError: HTTPProvider<MockAPIEndpoint, MockAPIEnvironment>.FetchError?
            
            await withCheckedContinuation { continuation in
                let publisher = provider!.fetchObjectPublisher(for: .plain, type: MockObject.self)
                provider = nil
                publisher
                    .sink(
                        receiveCompletion: {
                            switch $0 {
                            case .finished:
                                isFinished = true
                            case .failure(let error):
                                switch error {
                                case .selfBeingReleased:
                                    selfBeingReleasedError = error
                                default:
                                    otherFailureError = error
                                }
                            }
                            continuation.resume()
                        },
                        receiveValue: { object in
                            successObject = object
                        }
                    )
                    .store(in: &cancellables)
            }
            
            #expect(successObject == nil)
            #expect(!isFinished)
            #expect(selfBeingReleasedError != nil)
            #expect(otherFailureError == nil)
        }
    }
}

    class MockURLSessionClient: URLSessionClientProtocol {
        let mockResult: Result<Data, URLSessionClient.FetchError>
        
        init(mockResult: Result<Data, URLSessionClient.FetchError>) {
            self.mockResult = mockResult
        }
        
        func fetchData(request: URLRequest) async -> Result<Data, URLSessionClient.FetchError> {
            return mockResult
        }
        
        func fetchDataPublisher(request: URLRequest, resultAfterCancelledHandler: ((Result<Data, Networking.URLSessionClient.FetchError>) -> Void)?) -> AnyPublisher<Data, Networking.URLSessionClient.FetchError> {
            return mockResult.publisher.eraseToAnyPublisher()
        }
    }

extension HTTPProviderTests {
    
    struct MockObject: Decodable, Equatable {
        let id: Int
        let name: String
        
        init(id: Int, name: String) {
            self.id = id
            self.name = name
        }
    }
}

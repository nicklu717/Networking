//
//  URLSessionClient.swift
//  Networking
//
//  Created by 陸瑋恩 on 2025/6/21.
//

import Foundation
import Combine

public class URLSessionClient {
    private let urlSession: URLSession
    
    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    public func fetchData(request: URLRequest) async -> Result<Data, FetchError> {
        do {
            let (data, response) = try await urlSession.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.notHTTPResponse(response))
            }
            switch httpResponse.statusCode {
            case 200..<300:
                return .success(data)
            default:
                return .failure(.requestFailure(httpResponse.statusCode, data))
            }
        } catch {
            return .failure(.urlSessionError(error))
        }
    }
    
    public func fetchDataPublisher(
        request: URLRequest,
        resultAfterCancelledHandler: ((Result<Data, FetchError>) -> Void)? = nil
    ) -> AnyPublisher<Data, FetchError> {
        var underlyingTask: Task<Void, Never>?
        return Deferred { [weak self] in
            Future { promise in
                underlyingTask = Task {
                    let result: Result<Data, FetchError> = await {
                        guard let self = self else { return .failure(.selfBeingReleased) }
                        return await self.fetchData(request: request)
                    }()
                    if Task.isCancelled {
                        resultAfterCancelledHandler?(result)
                    } else {
                        promise(result)
                    }
                }
            }
        }
        .handleEvents(
            receiveCancel: {
                underlyingTask?.cancel()
            }
        )
        .eraseToAnyPublisher()
    }
}

// MARK: - Fetch Error
extension URLSessionClient {
    public typealias StatusCode = Int
    
    public enum FetchError: Error {
        case notHTTPResponse(URLResponse)
        case requestFailure(StatusCode, Data)
        case urlSessionError(Error)
        case selfBeingReleased
    }
}

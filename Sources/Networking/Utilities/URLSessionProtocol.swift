//
//  URLSessionProtocol.swift
//  Networking
//
//  Created by 陸瑋恩 on 2025/6/22.
//

import Foundation

public protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}
extension URLSession: URLSessionProtocol {}

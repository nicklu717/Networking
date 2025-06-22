//
//  HTTPMethod.swift
//  Networking
//
//  Created by 陸瑋恩 on 2025/6/22.
//

import HTTPTypes

public enum HTTPMethod {
    case get, head, post, put, delete, connect, options, trace, patch
    
    var requestMethod: HTTPRequest.Method {
        switch self {
        case .get:
            return .get
        case .head:
            return .head
        case .post:
            return .post
        case .put:
            return .put
        case .delete:
            return .delete
        case .connect:
            return .connect
        case .options:
            return .options
        case .trace:
            return .trace
        case .patch:
            return .patch
        }
    }
}

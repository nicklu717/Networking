//
//  HTTPHeader.swift
//  Networking
//
//  Created by 陸瑋恩 on 2025/6/22.
//

import HTTPTypes

public enum HTTPHeader {
    case authorization(AuthorizationType)
    case contentType(ContentType)
    
    var entry: (field: HTTPField.Name, value: String) {
        switch self {
        case .authorization(let type):
            return (.authorization, type.value)
        case .contentType(let type):
            return (.contentType, type.value)
        }
    }
}

extension HTTPHeader {
    
    public enum AuthorizationType {
        case bearer(String)
        
        var value: String {
            switch self {
            case .bearer(let token):
                return "Bearer \(token)"
            }
        }
    }
    
    public enum ContentType {
        case json
        
        var value: String {
            switch self {
            case .json:
                return "application/json"
            }
        }
    }
}

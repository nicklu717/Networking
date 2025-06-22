//
//  HTTPParameter.swift
//  Networking
//
//  Created by 陸瑋恩 on 2025/6/22.
//

import Foundation

public enum HTTPParameter {
    case url(queries: [String: String])
    case body(BodyType)
    
    public enum BodyType {
        case data(Data)
        case json(Encodable)
    }
}

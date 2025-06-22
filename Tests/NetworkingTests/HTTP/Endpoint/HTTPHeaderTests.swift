//
//  HTTPHeaderTests.swift
//  Networking
//
//  Created by 陸瑋恩 on 2025/6/22.
//

import Testing
import HTTPTypes

@testable import Networking

struct HTTPHeaderTests {
    
    @Test
    func authorization() {
        let mockToken = "mockToken"
        let header: HTTPHeader = .authorization(.bearer(mockToken))
        #expect(header.entry == (.authorization, "Bearer \(mockToken)"))
    }
    
    @Test
    func contentType() {
        let header: HTTPHeader = .contentType(.json)
        #expect(header.entry == (.contentType, "application/json"))
    }
}

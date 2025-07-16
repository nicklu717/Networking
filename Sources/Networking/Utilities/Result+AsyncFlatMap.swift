//
//  Result+AsyncFlatMap.swift
//  Networking
//
//  Created by 陸瑋恩 on 2025/7/17.
//

extension Result {
    
    func asyncFlatMap<NewSuccess>(_ transform: (Success) async -> Result<NewSuccess, Failure>) async -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let success):
            return await transform(success)
        case .failure(let failure):
            return .failure(failure)
        }
    }
}

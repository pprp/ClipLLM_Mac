//
//  NetworkErrors.swift
//  ClipLLM
//
//  Created by peyton on 9/8/2024.
//

import Foundation

enum NetError: Error {
    case invalidURL(error: Error?)
    case invalidResponse(error: Error?)
    case invalidData(error: Error?)
    case unreachable(error: Error?)
    case general(error: Error?)
}

//
//  Tags.swift
//  ClipLLM
//
//  Created by peyton on 9/8/2024.
//
import Foundation

// The tagsParent struct represents a collection of models, each described by the tagsModel struct.
// It conforms to Decodable and Hashable protocols to support decoding from JSON and to be used in collections that require hashing.
struct tagsParent: Decodable, Hashable {
    let models: [tagsModel]
}

// The tagsModel struct represents an individual model with its properties.
// It conforms to Decodable and Hashable protocols to support decoding from JSON and to be used in collections that require hashing.
struct tagsModel: Decodable, Hashable {
    let name: String
    let modifiedAt: String
    let size: Double
    let digest: String
}

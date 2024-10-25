//
//  InfluencersModel.swift
//  IndiaFantasy
//
//  Created by Harendra Singh Rathore on 11/06/24.
//

import Foundation

// MARK: - Influencers Response
struct InfluencersResponse: Codable {
    let success: Bool?
    let msg: String?
    let results: [InfluencersInfo]?
}

// MARK: - Influencers Info 
struct InfluencersInfo: Codable {
    let image, code, name: String?
    let useCount: Int?

    enum CodingKeys: String, CodingKey {
        case image, code, name, useCount
    }
}

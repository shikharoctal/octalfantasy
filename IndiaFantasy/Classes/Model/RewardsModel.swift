//
//  RewardsModel.swift
//
//  Created by Rahul Gahlot on 03/11/22.
//

import Foundation

// MARK: - Rewards
struct Reward: Codable {
    let totalDocs: Int?
    let rows: Rewards?
}

struct Rewards: Codable {
    let id, firstName, lastName, fullName: String?
    let username, email, phone: String?
    let credit: Double?
    let balance: Double?
    let type, transType, tokenName, remarks: String?
    let createdAt: String?
    let rewardText: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case fullName = "full_name"
        case username, email, phone, credit, balance, type
        case transType = "trans_type"
        case tokenName = "token_name"
        case remarks, createdAt
        case rewardText = "reward_text"
    }
}

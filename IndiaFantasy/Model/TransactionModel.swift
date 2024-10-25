//
//  TransactionModel.swift
//  IndiaFantasy
//
//  Created by Harendra Singh Rathore on 23/05/24.
//

import Foundation

struct Transaction : Codable {
    
    let  totalDocs: Int?
    let  details: TransactionDetails?
    
    enum CodingKeys: String, CodingKey {
        case totalDocs = "totalDocs"
        case details = "rows"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        totalDocs = values.decodeSafely(Int.self, forKey: .totalDocs)
        details = values.decodeSafely(TransactionDetails.self, forKey: .details)
    }
}


struct TransactionDetails : Codable {
    
    let id, first_name, last_name, username, email, type, remarks, createdAt, trans_type, token_name: String?
    let balance, credit, debit, withdrawalAmount: Double?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case first_name = "first_name"
        case last_name = "last_name"
        case username = "username"
        case email = "email"
        case type = "type"
        case remarks = "remarks"
        case createdAt = "createdAt"
        case balance = "balance"
        case credit = "credit"
        case debit = "debit"
        case trans_type = "trans_type"
        case token_name = "token_name"
        case withdrawalAmount = "withdrawledAmount"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodeSafely(String.self, forKey: .id)
        first_name = values.decodeSafely(String.self, forKey: .first_name)
        last_name = values.decodeSafely(String.self, forKey: .last_name)
        username = values.decodeSafely(String.self, forKey: .username)
        email = values.decodeSafely(String.self, forKey: .email)
        type = values.decodeSafely(String.self, forKey: .type)
        trans_type = values.decodeSafely(String.self, forKey: .trans_type)
        token_name = values.decodeSafely(String.self, forKey: .token_name)
        remarks = values.decodeSafely(String.self, forKey: .remarks)
        createdAt = values.decodeSafely(String.self, forKey: .createdAt)
        balance = values.decodeSafely(Double.self, forKey: .balance)
        credit = values.decodeSafely(Double.self, forKey: .credit)
        debit = values.decodeSafely(Double.self, forKey: .debit)
        withdrawalAmount = values.decodeSafely(Double.self, forKey: .withdrawalAmount)
    }
}

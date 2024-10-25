//
//  FaqsDataModel.swift
//
//  Created by Rahul Gahlot on 01/11/22.
//

import Foundation
// MARK: - Faqs
struct Faq: Codable {
    let success: Bool
    let msg: String
    let errors: [JSONAny]
    let FaqsList: FaqResults
}

// MARK: - Results
struct FaqResults: Codable {
    let docs: [Doc]
    let totalDocs, limit, totalPages, page: Int
    let pagingCounter: Int
    let hasPrevPage, hasNextPage: Bool
    let prevPage, nextPage: JSONNull?
}

// MARK: - Doc
struct Doc: Codable {
    let id, question, answer, status: String
    let createdAt, updatedAt: String
    let v: Int
    let docID: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case question, answer, status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case v = "__v"
        case docID = "id"
    }
}

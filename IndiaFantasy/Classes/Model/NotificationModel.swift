//
//  NotificationModel.swift
//  IndiaFantasy
//
//  Created by Harendra Singh Rathore on 23/05/24.
//

import Foundation

struct NotificationInfo : Codable {
    
    var id: String?
    var read: Bool?
    var title, userType, matchType: String?
    var userID: UserID?
    var message, type, status, createdAt: String?
    var updatedAt: String?
    var v: Int?
    var docID: String?
    var matchId: Int?
    var leagueType: String?
    var leagueName: String?
    var seriesId: Int?
    var contestType: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case read, title
        case userType = "user_type"
        case matchType = "match_type"
        case userID = "user_id"
        case message, type, status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case v = "__v"
        case docID = "id"
        case matchId = "match_id"
        case leagueType, leagueName
        case seriesId = "series_id"
        case contestType
    }
    
}

// MARK: - UserID
struct UserID: Codable {
    let id, firstName, lastName, image: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case image
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodeSafely(String.self, forKey: .id)
        firstName = values.decodeSafely(String.self, forKey: .firstName)
        lastName = values.decodeSafely(String.self, forKey: .lastName)
        image = values.decodeSafely(String.self, forKey: .image)

    }
}

struct NotificationAction : Codable {
    
    let id, type: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
    
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodeSafely(String.self, forKey: .id)
        type = values.decodeSafely(String.self, forKey: .type)
    }
    
}

//
//  MoneyPoolModel.swift
//  IndiaFantasy
//
//  Created by Harendra Singh Rathore on 15/03/24.
//

import Foundation

enum PoolType: String {
    case liveEvent
    case perception
}

struct PoolQuestionsRequest {
    var status = ""
    var type = ""
    var categoryId = ""
    var matchId = ""
    var page = 0
}

// MARK: - Pool Category Response
struct PoolCategoryData: Codable, Equatable {
    let id, title, type: String?
    let image: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, type, image
        case createdAt = "created_at"
    }
}

// MARK: - Pool Question Result
struct PoolQuestionResult: Codable {
    let id, questionText: String?
    let option, optionA, optionB, optionC, optionD: String?
    let optionAPercentage, optionBPercentage, optionCPercentage: Double?
    let matchID, seriesID: Int?
    let localteam, visitorteam: String?
    let localteamFlag, visitorteamFlag: String?
    let seriesName, status, createdAt, updatedAt: String?
    let winningData: WinningData?
    var isSelected: Bool = false
    let investedFee, entryFee: Double?
    let isCancelled: Int?
    let expireTime: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case questionText = "question_text"
        case optionA, optionB, optionC, optionD, optionAPercentage, optionBPercentage, optionCPercentage
        case seriesID = "series_id"
        case matchID = "match_id"
        case localteam, visitorteam
        case localteamFlag = "localteam_flag"
        case visitorteamFlag = "visitorteam_flag"
        case seriesName = "series_name"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case option, winningData
        case investedFee = "entry_fee"
        case entryFee, isCancelled
        case expireTime = "compare_start_time"
    }
}

// MARK: - WinningData
struct WinningData: Codable {
    let entryFee, winngsAmount: Double?
    let yourOption, matchResult: String?

    enum CodingKeys: String, CodingKey {
        case entryFee = "entry_fee"
        case winngsAmount = "winngs_amount"
        case yourOption = "your_option"
        case matchResult = "match_result"
    }
}

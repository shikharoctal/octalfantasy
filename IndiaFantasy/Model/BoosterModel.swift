//
//  BoosterModel.swift
//  India’s fantasy
//
//  Created by admin on 02/05/23.
//

import Foundation


// MARK: - Booster Result
struct BoosterData: Codable {
    let debuffBooster: [Booster]?
    let updatedBoostersList: [Booster]?
    let boosterHistoryList: [BoosterHistoryData]?
    
    enum CodingKeys: String, CodingKey {
        case debuffBooster
        case updatedBoostersList
        case boosterHistoryList = "PlayersTeamsData"
    }
}

// MARK: - Booster
struct Booster: Codable {
    let startDate, categoryID, subCategoryID, categoryName: String?
    let subCategoryName: String?
    let boosterImage: String?
    let boosterUniqueID: String?
    let gameType: [String]?
    let isApplied: Bool?
    let usedDate: String?
    let isCurrentlyUsed: Bool?
    let boosterCount, usedCount, remainingBoosterCount: Int?
    let id, boosterName: String?
    let boosterCode: Int?
    let title, additionalFactor, description: String?
    let image: String?
    let endDate: String?
    let boostedPlayer: [Int]?

    enum CodingKeys: String, CodingKey {
        case startDate
        case categoryID = "categoryId"
        case subCategoryID = "subCategoryId"
        case categoryName, subCategoryName
        case boosterImage = "booster_image"
        case boosterUniqueID = "boosterUniqueId"
        case gameType, isApplied, usedDate, isCurrentlyUsed, boosterCount, usedCount, remainingBoosterCount
        case id = "_id"
        case boosterName, boosterCode, title, additionalFactor, description, image, endDate, boostedPlayer
    }
}

// MARK: - Booster History Data
struct BoosterHistoryData: Codable {
    let id: String?
    let teamNumber: Double?
    //let totalPoint: Double?
    let localteamFlag: String?
    let localteamShortName, localteam, visitorteamShortName, visitorteam: String?
    let timestampStart: Int?
    let visitorteamFlag: String?
    let seriesID, matchID: Int?
    let matchDate: String?
    let boosterHistory: [BoosterHistory]?
    let boosterImageURL: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case teamNumber = "team_number"
        //case totalPoint = "total_point"
        case localteamFlag = "localteam_flag"
        case localteamShortName = "localteam_short_name"
        case localteam
        case visitorteamShortName = "visitorteam_short_name"
        case visitorteam
        case timestampStart = "timestamp_start"
        case visitorteamFlag = "visitorteam_flag"
        case seriesID = "series_id"
        case matchID = "match_id"
        case matchDate = "match_date"
        case boosterHistory, boosterImageURL
    }
}

// MARK: - BoosterHistory
struct BoosterHistory: Codable {
    let id: String?
    let isApplied: Bool?
    let usedDate: String?
    let isCurrentlyUsed: Bool?
    let categoryID, subCategoryID, categoryName, subCategoryName: String?
    let gameType: [String]?
    let title, description: String?
    let price: Double?
    let boosterImage, image, createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case isApplied, usedDate, isCurrentlyUsed
        case categoryID = "categoryId"
        case subCategoryID = "subCategoryId"
        case categoryName, subCategoryName, gameType, title, description, price
        case boosterImage = "booster_image"
        case image
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Contest User
struct ContestUser: Codable {
    let id, teamName: String?
    //let seriesID: Int?
    let contestID, userID: String?
    let rank: Int?
    let username: String?
    let teamCount: Int?
    let userImage: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case teamName
       // case seriesID = "series_id"
        case contestID = "contest_id"
        case userID = "user_id"
        case rank, username
        case teamCount = "team_count"
        case userImage
    }
}


enum BoosterType: String {
    case DOUBLE_UP = "doubleUp"
    case SUPER_TRANSFER = "superTransfer"
    case TRIPLE_SCORER = "tripleImpact"
    case POWER_WICKET_KEEPER = "powerWicketkeeper"
    case POWER_GOAL_KEEPER = "powerGoalkeeper"
    case POWER_DEFENDER = "powerDefender"
    case POWER_MIDFIELDER = "powerMidfielder"
    case POWER_STRIKER = "powerStriker"
    case POWER_BETTER = "powerBatter"
    case POWER_AR = "powerAllRounder"
    case POWER_BOWLER = "powerBowler"
    case AUTOPILOT = "autopilot"
    case EXTRA_CREDIT = "extraCredit"
    case PRE_EMPTIVE_STRIKE = "preEmptiveStrike"
    case ON_THE_HOUSE = "onTheHouse"
    case SPIRIT_OF_THE_GAME = "spiritOfTheGame"
    case MID_SEASON = "midSeason"
    case CAPTAIN_LESS = "captainLess"
    case SLIPPERY_PITCH = "slipperyPitch"
    case MISSING_VC = "missingVC"
    case YELLOW_CARD = "yellowCard"
    case FALLING_MAN = "fallingMan"
    case ALL_I_SEE_IS_RED = "allISeeIsRed"
    case DUAL_SACRIFICE = "dualSacrifice"
    case HAIL_MARY = "hailMary"
    case RED_CARD = "redCard"
    case GAME_DAY_BLUES = "gameDayBlues"
    case POWER_BACK = "powerBack"
    case POWER_FORWARD = "powerForward"
    case POWER_Overseas = "powerOverseas"
    case POWER_Indian = "powerIndian"
    
    var name: String {
        return self.rawValue.description
    }
}

struct DebuffApplyRequest {
    
    var seriesId: String = ""
    var matchId: Int = 0
    var teamName: Int = 0
    var otherUserTeamName: String = ""
    var teamId: String = ""
    var boosterCode: Int = 0
    var userId: String = ""
    var boosterUniqueId: String = ""
    var fromDailyContest: Bool = false
}

struct BoosterGiftRequest {
    
    var seriesId: String = ""
    var matchId: Int = 0
    var teamName: Int = 0
    var teamId: String = ""
    var userId: String = ""
    var boosterUniqueId: String = ""
    var sharedBoosterUniqueId: String = ""
    var fromDailyContest: Bool = false
}

struct BoosterValidateRequest {
    
    var seriesId: String = ""
    var matchId: String = ""
    var teamName: String = ""
    var boosterCode: [[String: Any]] = [[:]]
    var boostedPlayerId: String = ""
    var fromDailyContest: Bool = false
}

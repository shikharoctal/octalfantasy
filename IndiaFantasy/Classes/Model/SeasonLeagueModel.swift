//
//  SeasonMatchDeatilsModel.swift
//  India’s fantasy
//
//  Created by admin on 02/05/23.
//

import Foundation

// MARK: - LeagueList
struct LeagueList: Decodable {
    let status, winFlagLeague: Int?
    let showWinAmountLeague: Bool?
    let joinedTeamsCount: Int?
    let id: String?
    let idAPI: Int?
    let name, startDate, endDate, createdAt: String?
    let updatedAt: String?
    let v: Int?
    let shortName: String?
    let seriesStatus: String?
    let joinedContestLeague: [JoinedContestLeague]?
    let joinedContestLeagueFun: [JoinedContestLeague]?
    let resultID: String?

    enum CodingKeys: String, CodingKey {
        case status
        case winFlagLeague = "win_flag_league"
        case showWinAmountLeague = "show_win_amount_league"
        case joinedTeamsCount = "joined_teams_count"
        case id = "_id"
        case idAPI = "id_api"
        case name
        case startDate = "start_date"
        case endDate = "end_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case v = "__v"
        case shortName = "short_name"
        case seriesStatus = "series_status"
        case joinedContestLeague = "joined_contest_league"
        case joinedContestLeagueFun = "joined_contest_league_fun"
        case resultID = "id"
    }
}

// MARK: - JoinedContestLeague
struct JoinedContestLeague: Decodable {
    let joinedTeams: [String]?
    let userCreated: Bool?
    let id, contestID: String?

    enum CodingKeys: String, CodingKey {
        case joinedTeams = "joined_teams"
        case userCreated = "user_created"
        case id = "_id"
        case contestID = "contest_id"
    }
}

// MARK: - League Details
struct LeagueDetails: Codable {
    let availableTransfer, availableboosterCount: Double?
    let bannerImage: String?
    let totalBoosters, totalTransfer, totalPoints: Double?
    let isTeamCreated: Bool?
    let totalTeams, teamNumber: Int?
    let userTeams: [LeagueMyTeam]?
    let isMatchPlayed: Bool?
}

// MARK: - League My Teams
struct LeagueMyTeam: Codable {
    let totalSeriesPoint: Double?
    let teamCount: Int?
    let id, teamName, userTeamID: String?

    enum CodingKeys: String, CodingKey {
        case totalSeriesPoint
        case teamCount = "team_count"
        case id = "_id"
        case teamName
        case userTeamID = "id"
    }
}

struct TopPlayers: Codable {
    let title, subTitle: String?
    let list: [LeaguePlayers]?
}

// MARK: - League Players
struct LeaguePlayers: Codable {
    let listID: String?
    let id: IDType?
    let points: Double?
    let teamCount: Int?
    let username: String?
    let userImage: String?
    let rank: Int?
    let playerName: String?
    let playerID: Int?
    let playerImage, teamFlag: String?
    let selectedBy: Double?
    
    enum CodingKeys: String, CodingKey {
        case listID = "id"
        case id = "_id"
        case points
        case teamCount = "team_count"
        case username
        case userImage = "user_image"
        case rank
        case playerName = "player_name"
        case playerID = "player_id"
        case playerImage = "player_image"
        case teamFlag = "team_flag"
        case selectedBy = "selected_by"
    }
}

enum IDType: Codable {
    case integer(Int)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(ID.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ID"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

// MARK: - Match Transfers and Points
struct MatchTransfersPoints: Decodable {
    let totalTransfers, totalPoints, transferLeft: Double?
    let leagueStatsMatches: [LeagueStatsMatch]?
    
    enum CodingKeys: String, CodingKey {
        case totalTransfers, totalPoints, transferLeft
        case leagueStatsMatches = "PlayersTeamsData"
    }
}


// MARK: - Players Teams Data
struct LeagueStatsMatch: Decodable {
    
    let id: String?
    let teamNumber: Int?
    let totalPoint: Double?
    let localteamFlag: String?
    let localteamShortName, visitorteamShortName, localteam, visitorteam: String?
    let timestampStart: Int?
    let visitorteamFlag: String?
    let seriesID, matchID: Int?
    let matchDate: String?
    let playerTransferList: Double?
    let matchNumber: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case teamNumber = "team_number"
        case totalPoint = "total_point"
        case localteamFlag = "localteam_flag"
        case localteamShortName = "localteam_short_name"
        case visitorteamShortName = "visitorteam_short_name"
        case localteam, visitorteam
        case timestampStart = "timestamp_start"
        case visitorteamFlag = "visitorteam_flag"
        case seriesID = "series_id"
        case matchID = "match_id"
        case matchDate = "match_date"
        case playerTransferList, matchNumber
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodeSafely(String.self, forKey: .id)
        teamNumber = values.decodeSafely(Int.self, forKey: .teamNumber)
        localteamFlag = values.decodeSafely(String.self, forKey: .localteamFlag)
        localteamShortName = values.decodeSafely(String.self, forKey: .localteamShortName)
        visitorteamShortName = values.decodeSafely(String.self, forKey: .visitorteamShortName)
        localteam = values.decodeSafely(String.self, forKey: .localteam)
        visitorteam = values.decodeSafely(String.self, forKey: .visitorteam)
        visitorteamFlag = values.decodeSafely(String.self, forKey: .visitorteamFlag)
        timestampStart = values.decodeSafely(Int.self, forKey: .timestampStart)
        seriesID = values.decodeSafely(Int.self, forKey: .seriesID)
        matchID = values.decodeSafely(Int.self, forKey: .matchID)
        matchDate = values.decodeSafely(String.self, forKey: .matchDate)
        playerTransferList = values.decodeSafely(Double.self, forKey: .playerTransferList)
        matchNumber = values.decodeSafely(String.self, forKey: .matchNumber)
        
        do {
            let value = try values.decode(String.self, forKey: .totalPoint)
            totalPoint = Double(value)
        } catch DecodingError.typeMismatch {
            totalPoint = try values.decode(Double.self, forKey: .totalPoint)
        }
    }
}

// MARK: - League Joined Contest Data
struct LeagueJoinedContest: Codable {
    
    let fullContest, myTeamCount: Int?
    let data: JoinedContest?
    let seriesName: String?
    let matchesPlayed: Int?
    let points, rank: Double?
    
    let time: String?
    let totalMatches: Int?
    let totalPoints: Double?
    let totalUsers: Double?

    enum CodingKeys: String, CodingKey {
        case fullContest = "full_contest"
        case myTeamCount = "my_team_count"
        case data
        case seriesName = "series_name"
        case matchesPlayed = "matches_played"
        case points, rank
        case time
        case totalMatches = "total_matches"
        case totalPoints = "total_points"
        case totalUsers = "total_users"
    }
}

// MARK: - Transfer Preview Data
struct TransferPreviewData: Decodable {
    let transferdPlayer: [TransferdPlayer]?
    let totalPlayerTransfered, availableTransfer: Int?
    let nextMatch: NextMatch?
    let matchNumber: Int?
}

// MARK: - NextMatch
struct NextMatch: Decodable {
    let id, type: String?
    let winFlag: Int?
    let showWinAmount: Bool?
    let joinedTeamsCount: Int?
    let lineup: Bool?
    let status, seriesID: Int?
    let matchDate: String?
    let timestampStart: Int?
    let date, time, timeNew: String?
    let matchID: Int?
    let localteam: String?
    let localteamID: Int?
    let visitorteam: String?
    let visitorteamID: Int?
    let venue, matchStatus: String?
    let adminUpdate, toss: Int?
    let liveMatchURL, guruURL, createdAt, updatedAt: String?
    let v: Int?
    let visitorteamData, localteamData: TeamData?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case type
        case winFlag = "win_flag"
        case showWinAmount = "show_win_amount"
        case joinedTeamsCount = "joined_teams_count"
        case lineup, status
        case seriesID = "series_id"
        case matchDate = "match_date"
        case timestampStart = "timestamp_start"
        case date, time
        case timeNew = "time_new"
        case matchID = "match_id"
        case localteam
        case localteamID = "localteam_id"
        case visitorteam
        case visitorteamID = "visitorteam_id"
        case venue
        case matchStatus = "match_status"
        case adminUpdate = "admin_update"
        case toss
        case liveMatchURL = "live_match_url"
        case guruURL = "guru_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case v = "__v"
        case visitorteamData, localteamData
    }
}

// MARK: - TeamData
struct TeamData: Codable {
    let teamShortName: String?

    enum CodingKeys: String, CodingKey {
        case teamShortName = "team_short_name"
    }
}

// MARK: - TransferdPlayer
struct TransferdPlayer: Codable {
    let fromPlayer, toPlayer: Player?
}


// MARK: -  League History Response
struct LeagueHistoryResponse: Codable {
    let docs: [LeagueHistory]?
    let totalDocs: Int?
}

// MARK: - League History
struct LeagueHistory: Codable {
    let id: Int?
    let totalSeriesPoint: Double?
    let teamName: String?
    let seriesID: Int?
    let leagueName, startDate, endDate: String?
    let rank: Int?
    let winAmount: Double?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case totalSeriesPoint, teamName
        case seriesID = "series_id"
        case leagueName
        case startDate = "start_date"
        case endDate = "end_date"
        case rank
        case winAmount = "win_amount"
    }
}

// MARK: - Booster History Response
struct BoostersHistoryResponse: Codable {
    let docs: [BoostersHistory]?
    let totalDocs: Int?
}

// MARK: - Booster History
struct BoostersHistory: Codable {
    let id: String?
    let boosterCode: Int?
    let usedDate, teamName, title, description: String?
    let boosterImage: String?
    let categoryName, subCategoryName, leagueName, matchName: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case boosterCode, usedDate, teamName, title, description
        case boosterImage = "booster_image"
        case categoryName, subCategoryName, leagueName, matchName
    }
}

// MARK: - Season Winning Result
struct SeasonWinning: Codable {
    let rank: Int?
    let prize: String?
}

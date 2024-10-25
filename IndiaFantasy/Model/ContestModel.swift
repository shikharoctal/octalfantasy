//
//  ContestModels.swift
//
//  Created by Octal-Mac on 28/12/22.
//

import UIKit

struct Match : Codable {
    
    var  total_contest, series_status, match_id, win_flag, series_id, localteam_id, visitorteam_id, admin_update, toss, timestamp_start, my_total_contest, my_total_teams: Int?
    var  joined_contest:[JoinedMatchContest]?
    var  id, match_status, series_name, start_date, start_time, actual_start_time, match_date, type, localteam, localteam_flag, visitorteam, localteam_short_name, visitorteam_short_name, visitorteam_flag, venue, live_match_url, guru_url, full_contest, created_at, updated_at, server_time: String?
    var lineup, is_match_reminder, is_series_reminder, is_reminder:Bool?

    var mega, win_amount:Double?
    
    var timerText = ""
    var matchNumber: Int?
    var allMatches: [Match]?
    var reward: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case total_contest = "total_contest"
        case timestamp_start = "timestamp_start"
        case series_status = "series_status"
        case match_id = "match_id"
        case win_flag = "win_flag"
        case series_id = "series_id"
        case localteam_id = "localteam_id"
        case visitorteam_id = "visitorteam_id"
        case admin_update = "admin_update"
        case toss = "toss"
        case match_status = "match_status"
        case series_name = "series_name"
        case start_date = "start_date"
        case start_time = "start_time"
        case actual_start_time = "actual_start_time"
        case match_date = "match_date"
        case type = "type"
        case localteam = "localteam"
        case localteam_flag = "localteam_flag"
        case visitorteam = "visitorteam"
        case localteam_short_name = "localteam_short_name"
        case visitorteam_flag = "visitorteam_flag"
        case visitorteam_short_name = "visitorteam_short_name"
        case venue = "venue"
        case live_match_url = "live_match_url"
        case guru_url = "guru_url"
        case full_contest = "full_contest"
        case created_at = "created_at"
        case updated_at = "updated_at"
        case server_time = "server_time"
        case joined_contest = "joined_contest"
        case my_total_contest = "my_total_contest"
        case my_total_teams = "my_total_teams"
        case lineup = "lineup"
        case is_match_reminder = "is_match_reminder"
        case is_series_reminder = "is_series_reminder"
        case win_amount = "win_amount"

        case mega = "mega"
        case matchNumber
        case is_reminder, allMatches, reward
    }
    
}

struct JoinedMatchContest : Codable {
    
    let  id, contest_id: String?
    let  joined_teams : [String]?
    let  user_created:Bool?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case contest_id = "contest_id"
        case joined_teams = "joined_teams"
        case user_created = "user_created"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodeSafely(String.self, forKey: .id)
        contest_id = values.decodeSafely(String.self, forKey: .contest_id)
        joined_teams = values.decodeSafely([String].self, forKey: .joined_teams)
        user_created = values.decodeSafely(Bool.self, forKey: .user_created)
    }
}

struct Contest : Codable {
    
    var  id, status, category_title, category_desc, category_image : String?
    var  contestData : [ContestData]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case status = "status"
        case category_title = "category_title"
        case category_desc = "category_desc"
        case category_image = "category_image"
        case contestData = "contestData"
    }
}

struct JoinedContest : Codable {
    
    var id, user_id, contest_id: String?
    var rank, series_id, match_id, joined_teams_count, points:Int?
    var win_amount:Float = 0.0
    var is_joined:Bool?
    var my_team_ids:[String]?
    var contestData : ContestData?
    
    var seriesName, name: String?
    var time: String?
    var totalMatches: Int?
    var totalPoints: Double?
    var totalUsers: Double?
    
    var teams:[JoinedTeam]?


    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user_id = "user_id"
        case contest_id = "contest_id"
        case rank = "rank"
        case series_id = "series_id"
        case match_id = "match_id"
        case joined_teams_count = "joined_teams_count"
        case points = "points"
        case win_amount = "win_amount"
        case is_joined = "is_joined"
        case my_team_ids = "my_team_ids"
        case contestData = "contest_data"
        case teams = "teams"
        case seriesName = "series_name"
        case time
        case totalMatches = "total_matches"
        case totalPoints = "total_points"
        case totalUsers = "total_users"
        case name
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodeSafely(String.self, forKey: .id)
        user_id = values.decodeSafely(String.self, forKey: .user_id)
        contest_id = values.decodeSafely(String.self, forKey: .contest_id)
        rank = values.decodeSafely(Int.self, forKey: .rank)
        series_id = values.decodeSafely(Int.self, forKey: .series_id)
        match_id = values.decodeSafely(Int.self, forKey: .match_id)
        joined_teams_count = values.decodeSafely(Int.self, forKey: .joined_teams_count)
        points = values.decodeSafely(Int.self, forKey: .points)
        
        win_amount = values.decodeSafely(Float.self, forKey: .win_amount) ?? 0.0

        is_joined = values.decodeSafely(Bool.self, forKey: .is_joined)

        my_team_ids = values.decodeSafely([String].self, forKey: .my_team_ids)

        contestData = values.decodeSafely(ContestData.self, forKey: .contestData)

        teams = values.decodeSafely([JoinedTeam].self, forKey: .teams)
        
        seriesName = values.decodeSafely(String.self,forKey: .seriesName)
        time = values.decodeSafely(String.self,forKey: .time)
        totalMatches = values.decodeSafely(Int.self,forKey: .totalMatches)
        totalPoints = values.decodeSafely(Double.self,forKey: .totalPoints)
        totalUsers = values.decodeSafely(Double.self,forKey: .totalUsers)
        name = values.decodeSafely(String.self,forKey: .name)
    }
}

struct ContestData : Codable {
    
    var  id, contest_id, created_by, name, category_id, contest_type, status, invite_code, created_at, updated_at, contract_address, token_address, token_name : String?
    var isAuto_created, isPendingBreakup, isRanked, isPrizeDistributed, is_joined, confirm_winning, join_multiple_team, auto_create:Bool?
    var entry_fee, winning_amount, admin_profit, bonus, winners_percentage:Double?
    var price_breakup:[PriceBreakUp]?
    var total_winners, users_limit, v, joined_teams_count, match_id, series_id, my_teams_count, max_team_join_count:Int?
    var my_team_ids:[String]?
    var my_teams_ids:[String]?
    var joined_teams:[JoinedTeam]?
    var my_teams:[JoinedTeam]?
    var myJoinedTeams: [JoinedTeam]?
    var otherJoinedTeams: [JoinedTeam]?
    var league_id: Int?
    var leagueName: String?
    var contestJoinedCount: Int?
    var categoryType: String?
    var matchNumber: Int?
    var otherJoinedTeamsCount: Int?
    var loserPunishment: String?
    var isLeagueContest: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case contest_id = "contest_id"
        case created_by = "created_by"
        case name = "name"
        case category_id = "category_id"
        case contest_type = "contest_type"
        case status = "status"
        case invite_code = "invite_code"
        case created_at = "created_at"
        case updated_at = "updated_at"
        case winners_percentage = "winners_percentage"

        case isAuto_created = "isAuto_created"
        case isPendingBreakup = "isPendingBreakup"
        case isRanked = "isRanked"
        case isPrizeDistributed = "isPrizeDistributed"
        case is_joined = "is_joined"
        case confirm_winning = "confirm_winning"
        case join_multiple_team = "join_multiple_team"
        case auto_create = "auto_create"
        case match_id = "match_id"
        case series_id = "series_id"

        case entry_fee = "entry_fee"
        case winning_amount = "winning_amount"
        case admin_profit = "admin_profit"
        case bonus = "bonus"
        case my_teams_count = "my_teams_count"

        case contract_address = "contract_address"
        case token_address = "token_address"
        case token_name = "token_name"
        case max_team_join_count = "max_team_join_count"

        
        case price_breakup = "price_breakup"
        
        case total_winners = "total_winners"
        case users_limit = "users_limit"
        case v = "__v"
        case joined_teams_count = "joined_teams_count"

        case my_team_ids = "my_team_ids"
        case my_teams_ids = "my_teams_ids"
        case joined_teams = "joined_teams"
        case league_id, leagueName, contestJoinedCount, categoryType
        case myJoinedTeams, otherJoinedTeams, matchNumber, otherJoinedTeamsCount
        case loserPunishment = "looserPunishment"

    }
    
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        id = values.decodeSafely(String.self, forKey: .id)
//        contest_id = values.decodeSafely(String.self, forKey: .contest_id)
//        created_by = values.decodeSafely(String.self, forKey: .created_by)
//        name = values.decodeSafely(String.self, forKey: .name)
//        category_id = values.decodeSafely(String.self, forKey: .category_id)
//        contest_type = values.decodeSafely(String.self, forKey: .contest_type)
//        status = values.decodeSafely(String.self, forKey: .status)
//        invite_code = values.decodeSafely(String.self, forKey: .invite_code)
//        created_at = values.decodeSafely(String.self, forKey: .created_at)
//        updated_at = values.decodeSafely(String.self, forKey: .updated_at)
//
//        isAuto_created = values.decodeSafely(Bool.self, forKey: .isAuto_created)
//        isPendingBreakup = values.decodeSafely(Bool.self, forKey: .isPendingBreakup)
//        isRanked = values.decodeSafely(Bool.self, forKey: .isRanked)
//        isPrizeDistributed = values.decodeSafely(Bool.self, forKey: .isPrizeDistributed)
//        is_joined = values.decodeSafely(Bool.self, forKey: .is_joined)
//        confirm_winning = values.decodeSafely(Bool.self, forKey: .confirm_winning)
//        join_multiple_team = values.decodeSafely(Bool.self, forKey: .join_multiple_team)
//        auto_create = values.decodeSafely(Bool.self, forKey: .auto_create)
//
//
//        price_breakup = values.decodeSafely([PriceBreakUp].self, forKey: .price_breakup)
//
//        total_winners = values.decodeSafely(Int.self, forKey: .total_winners)
//        users_limit = values.decodeSafely(Int.self, forKey: .users_limit)
//        v = values.decodeSafely(Int.self, forKey: .v)
//        joined_teams_count = values.decodeSafely(Int.self, forKey: .joined_teams_count)
//
//        entry_fee = values.decodeSafely(Double.self, forKey: .entry_fee)
//        winning_amount = values.decodeSafely(Double.self, forKey: .winning_amount)
//        admin_profit = values.decodeSafely(Double.self, forKey: .admin_profit)
//        bonus = values.decodeSafely(Double.self, forKey: .bonus)
//
//        my_team_ids = values.decodeSafely([String].self, forKey: .my_team_ids)
//        my_teams_ids = values.decodeSafely([String].self, forKey: .my_teams_ids)
//        joined_teams = values.decodeSafely([JoinedTeam].self, forKey: .joined_teams)
//
//
//    }
}

struct WalletAmountResults: Codable {
    let useableBonousPercent, totalBalance, cashBalance, winningBalance: Double?
    let usableBonus, entryFee: Double?

    enum CodingKeys: String, CodingKey {
        case useableBonousPercent = "useable_bonous_percent"
        case totalBalance = "total_balance"
        case cashBalance = "cash_balance"
        case winningBalance = "winning_balance"
        case usableBonus = "usable_bonus"
        case entryFee = "entry_fee"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        useableBonousPercent = values.decodeSafely(Double.self, forKey: .useableBonousPercent)
        totalBalance = values.decodeSafely(Double.self, forKey: .totalBalance)
        cashBalance = values.decodeSafely(Double.self, forKey: .cashBalance)
        winningBalance = values.decodeSafely(Double.self, forKey: .winningBalance)
        usableBonus = values.decodeSafely(Double.self, forKey: .usableBonus)
        entryFee = values.decodeSafely(Double.self, forKey: .entryFee)

    }
}

struct PriceBreakUp : Codable {
    
    let is_completed:Bool?
    let start_rank, end_rank, each_percentage, each_price, total_percentage, total_price:Double?
    let reward: String?
    
    enum CodingKeys: String, CodingKey {
        case is_completed = "is_completed"
        case start_rank = "start_rank"
        case end_rank = "end_rank"
        case each_percentage = "each_percentage"
        case each_price = "each_price"
        case total_percentage = "total_percentage"
        case total_price = "total_price"
        case reward
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        is_completed = values.decodeSafely(Bool.self, forKey: .is_completed)
        start_rank = values.decodeSafely(Double.self, forKey: .start_rank)
        end_rank = values.decodeSafely(Double.self, forKey: .end_rank)
        each_percentage = values.decodeSafely(Double.self, forKey: .each_percentage)
        each_price = values.decodeSafely(Double.self, forKey: .each_price)
        total_percentage = values.decodeSafely(Double.self, forKey: .total_percentage)
        total_price = values.decodeSafely(Double.self, forKey: .total_price)
        reward = values.decodeSafely(String.self, forKey: .reward)
    }
}

struct JoinedTeam : Codable {
    
    let id, user_id, user_image, username, reward:String?
    let points, rank, win_amount:Double?
    let team_count:Int?
    var inMyTeam = false
    var totalSeriesPoint: Double?

    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user_id = "user_id"
        case user_image = "user_image"
        case username = "username"
        case points = "points"
        case rank = "rank"
        case team_count = "team_count"
        case win_amount = "win_amount"
        case totalSeriesPoint
        case reward

    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodeSafely(String.self, forKey: .id)
        user_id = values.decodeSafely(String.self, forKey: .user_id)
        user_image = values.decodeSafely(String.self, forKey: .user_image)
        username = values.decodeSafely(String.self, forKey: .username)
        points = values.decodeSafely(Double.self, forKey: .points)
        rank = values.decodeSafely(Double.self, forKey: .rank)
        team_count = values.decodeSafely(Int.self, forKey: .team_count)
        win_amount = values.decodeSafely(Double.self, forKey: .win_amount)
        totalSeriesPoint = values.decodeSafely(Double.self, forKey: .totalSeriesPoint)
        reward = values.decodeSafely(String.self, forKey: .reward)
    }
}

// MARK: - Info
struct WinningBreakUp: Codable {
    let winner: Int?
    let rankSize: String?
    let percent: JSONAny?

    enum CodingKeys: String, CodingKey {
        case winner = "winner"
        case rankSize = "rank_size"
        case percent = "percent"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        winner = values.decodeSafely(Int.self, forKey: .winner)
        rankSize = values.decodeSafely(String.self, forKey: .rankSize)
        percent = values.decodeSafely(JSONAny.self, forKey: .percent)

    }
}

// MARK: - Result
struct CAWinningBreakupDatum: Codable {
    let id: Int?
    let info: [WinningBreakUp]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case info = "info"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodeSafely(Int.self, forKey: .id)
        info = values.decodeSafely([WinningBreakUp].self, forKey: .info)
    }
}


struct Team : Codable {
    
    let  id, team_id, captain_player_id, vice_captain_player_id: String?
    let team_number, total_bowler, total_batsman, total_allrounder, total_wicketkeeper:Int?
    let seriesPlayer : [Player]?
    let benchPlayer: [Player]?
    let total_point: Double?
    let actualPoints: Double?
    var isSelected = false
    var isJoined = false
    var lineUpPlayerNotAnnounced = 0
    
    let matches_played: Int?
    let transfer_made: Double?
    let transfer_efficiency: Double?
    let next_match_number, available_transfer: Int?
    let localteam, localteam_flag, visitorteam, visitorteam_flag, booster_image: String?
    let boosterCode: Int?
    let boostedPlayer: [Int]?
    let matchDate: String?
    let playerTransferInMatch: Int?
    let visitorTeamShortName, localTeamShortName: String?
    let isLive: Bool?
    let boosterDetails: Booster?
    let isDebuffApplied: Bool?
    let center, flyHalf, hooker, lock, looseForwards, outsideBacks, prop, scrumHalf: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case team_id = "team_id"
        case team_number = "team_number"
        case total_point = "total_point"
        case captain_player_id = "captain_player_id"
        case vice_captain_player_id = "vice_captain_player_id"
        case total_bowler = "total_bowler"
        case total_batsman = "total_batsman"
        case total_allrounder = "total_allrounder"
        case total_wicketkeeper = "total_wicketkeeper"
        case seriesPlayer = "seriesPlayer"
        case matches_played, transfer_made, transfer_efficiency, next_match_number, available_transfer
        case localteam, localteam_flag, visitorteam, visitorteam_flag, booster_image, boosterCode, boostedPlayer
        case matchDate = "match_date"
        case playerTransferInMatch
        case visitorTeamShortName = "visitorteam_short_name"
        case localTeamShortName = "localteam_short_name"
        case isLive, boosterDetails, actualPoints, isDebuffApplied
        case center = "Centre"
        case flyHalf = "FlyHalf"
        case hooker = "Hooker"
        case lock = "Lock"
        case looseForwards = "LooseForwards"
        case outsideBacks = "OutsideBacks"
        case prop = "Prop"
        case scrumHalf = "ScrumHalf"
        case benchPlayer = "teamBenchPlayer"
    }
    
    enum AnotherCodingKeys: String, CodingKey {
        case total_bowler = "total_forward"
        case total_batsman = "total_defender"
        case total_allrounder = "total_midfielder"
        case total_wicketkeeper = "total_goalkeeper"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodeSafely(String.self, forKey: .id)
        team_id = values.decodeSafely(String.self, forKey: .team_id)
        team_number = values.decodeSafely(Int.self, forKey: .team_number)
        total_point = values.decodeSafely(Double.self, forKey: .total_point)
        actualPoints = values.decodeSafely(Double.self, forKey: .actualPoints)
        seriesPlayer = values.decodeSafely([Player].self, forKey: .seriesPlayer)
       
        total_bowler = values.decodeSafely(Int.self, forKey: .total_bowler)
        total_batsman = values.decodeSafely(Int.self, forKey: .total_batsman)
        total_allrounder = values.decodeSafely(Int.self, forKey: .total_allrounder)
        total_wicketkeeper = values.decodeSafely(Int.self, forKey: .total_wicketkeeper)
        
        matches_played = values.decodeSafely(Int.self, forKey: .matches_played)
        transfer_made = values.decodeSafely(Double.self, forKey: .transfer_made)
        transfer_efficiency = values.decodeSafely(Double.self, forKey: .transfer_efficiency)
        next_match_number = values.decodeSafely(Int.self, forKey: .next_match_number)
        available_transfer = values.decodeSafely(Int.self, forKey: .available_transfer)
        
        localteam = values.decodeSafely(String.self, forKey: .localteam)
        localteam_flag = values.decodeSafely(String.self, forKey: .localteam_flag)
        visitorteam = values.decodeSafely(String.self, forKey: .visitorteam)
        visitorteam_flag = values.decodeSafely(String.self, forKey: .visitorteam_flag)
        booster_image = values.decodeSafely(String.self, forKey: .booster_image)
        boosterCode = values.decodeSafely(Int.self, forKey: .boosterCode)
        boostedPlayer = values.decodeSafely([Int].self, forKey: .boostedPlayer)
        matchDate = values.decodeSafely(String.self, forKey: .matchDate)
        visitorTeamShortName = values.decodeSafely(String.self, forKey: .visitorTeamShortName)
        localTeamShortName = values.decodeSafely(String.self, forKey: .localTeamShortName)
        isLive = values.decodeSafely(Bool.self, forKey: .isLive)
        boosterDetails = values.decodeSafely(Booster.self, forKey: .boosterDetails)
        
        do {
            let value = try values.decode(Int.self, forKey: .captain_player_id)
            captain_player_id = value == 0 ? nil : String(value)
        } catch DecodingError.typeMismatch {
            captain_player_id = try values.decode(String.self, forKey: .captain_player_id)
        }
        
        do {
            let value = try values.decode(Int.self, forKey: .vice_captain_player_id)
            vice_captain_player_id = value == 0 ? nil : String(value)
        } catch DecodingError.typeMismatch {
            vice_captain_player_id = try values.decode(String.self, forKey: .vice_captain_player_id)
        }
        
        playerTransferInMatch = values.decodeSafely(Int.self, forKey: .playerTransferInMatch)
        isDebuffApplied = values.decodeSafely(Bool.self, forKey: .isDebuffApplied)
        
        flyHalf = values.decodeSafely(Int.self, forKey: .flyHalf)
        scrumHalf = values.decodeSafely(Int.self, forKey: .scrumHalf)
        center = values.decodeSafely(Int.self, forKey: .center)
        outsideBacks = values.decodeSafely(Int.self, forKey: .outsideBacks)
        prop = values.decodeSafely(Int.self, forKey: .prop)
        hooker = values.decodeSafely(Int.self, forKey: .hooker)
        lock = values.decodeSafely(Int.self, forKey: .lock)
        looseForwards = values.decodeSafely(Int.self, forKey: .looseForwards)
        benchPlayer = values.decodeSafely([Player].self, forKey: .benchPlayer)
    }
}

struct PlayerDetails {
    var name = String()
    var image = String()
    var role = String()
    var credits = String()
    var points = String()
    var player_id = String()
    var inDreamTeam = Bool()
    var inGuruTeam = Bool()
    var is_local_team = Bool()
    var is_playing = Bool()
    var toss = Bool()
    var isCaptain = Bool()
    var isViceCaptain = Bool()
    var teamShortName = String()
    var isDebuffed = Bool()
    var isBoosted = Bool()
    var boosterDetails = [Booster]()
    var debuffedDetails = [Booster]()
}


struct Player : Codable {
    
    var name, player_name, image, player_image, role, playing_role, id, series_name, team_name, player_role, batting_style, bowling_style, country, nationality, born, dob, selection_percent, status, team_short_name, team_flag: String?
    var player_id, team_id, series_id, isDream_player:Int?
    var player_credit, credits, player_points, points, total_points:Double?
    var is_playing, isSubstitute, my_team : Bool?
    var isCaptain : Bool?
    var isViceCaptain : Bool?
    var played_last_match : Bool?
    var isBoosterPlayer: Bool?
    var isBoosted, isDebuffed: Bool?

    var vice_captain_percent:Double?
    var captain_percent:Double?

    var selected_by:Double?
    var isSelected = false
    let team_number:[Int]?
    
    let playerBreckup: [String: PlayerBreckup]?

    
    var match_details:[MatchDetails]?
    var isHighLight:Bool?
    let boosterDetails: [Booster]?
    let debuffDetails: [Booster]?
    var isActivePlayer = false

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name = "name"
        case image = "image"
        case player_image = "player_image"
        case dob = "dob"
        case nationality = "nationality"
        case selection_percent = "selection_percent"
        case playerBreckup = "player_breckup"
        case status = "status"
        case selected_by = "selected_by"
        case team_short_name = "team_short_name"
        case captain_percent = "captain_percent"
        case vice_captain_percent = "vice_captain_percent"
        case played_last_match
        case playing_role = "playing_role"
        case role = "role"
        case player_id = "player_id"
        case team_id = "team_id"
        case series_id = "series_id"
        case credits = "credits"
        case points = "points"
        case is_playing = "is_playing"
        case my_team = "my_team"
        case isDream_player = "isDream_player"

        case series_name = "series_name"
        case team_name = "team_name"
        case player_name = "player_name"
        case player_role = "player_role"
        case player_credit = "player_credit"
        case total_points = "total_points"

        case batting_style = "batting_style"
        case bowling_style = "bowling_style"
        case country = "country"
        case born = "born"
        case player_points = "player_points"
        case match_details = "match_details"
        
        case team_number = "team_number"
        case isCaptain = "isCaptain"
        case isViceCaptain = "isViceCaptain"
        case team_flag, isBoosterPlayer
        case isBoosted, isDebuffed, boosterDetails
        case debuffDetails = "debuffboosterDetails"
        case isSubstitute = "is_substitute"

    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodeSafely(String.self, forKey: .id)
        dob = values.decodeSafely(String.self, forKey: .dob)
        name = values.decodeSafely(String.self, forKey: .name)
        image = values.decodeSafely(String.self, forKey: .image)
        player_image = values.decodeSafely(String.self, forKey: .player_image)
        role = values.decodeSafely(String.self, forKey: .role)
        playing_role = values.decodeSafely(String.self, forKey: .playing_role)
        selection_percent = values.decodeSafely(String.self, forKey: .selection_percent)
        status = values.decodeSafely(String.self, forKey: .status)
        selected_by = values.decodeSafely(Double.self, forKey: .selected_by)      
        team_short_name = values.decodeSafely(String.self, forKey: .team_short_name)
        played_last_match = values.decodeSafely(Bool.self, forKey: .played_last_match)

        series_name = values.decodeSafely(String.self, forKey: .series_name)
        team_name = values.decodeSafely(String.self, forKey: .team_name)
        player_name = values.decodeSafely(String.self, forKey: .player_name)
        player_role = values.decodeSafely(String.self, forKey: .player_role)
        batting_style = values.decodeSafely(String.self, forKey: .batting_style)
        bowling_style = values.decodeSafely(String.self, forKey: .bowling_style)
        country = values.decodeSafely(String.self, forKey: .country)
        born = values.decodeSafely(String.self, forKey: .born)
        nationality = values.decodeSafely(String.self, forKey: .nationality)
        team_number = values.decodeSafely([Int].self, forKey: .team_number)

        total_points = values.decodeSafely(Double.self, forKey: .total_points)
        player_credit = values.decodeSafely(Double.self, forKey: .player_credit)
        player_id = values.decodeSafely(Int.self, forKey: .player_id)
        team_id = values.decodeSafely(Int.self, forKey: .team_id)
        credits = values.decodeSafely(Double.self, forKey: .credits)
        points = values.decodeSafely(Double.self, forKey: .points)
        series_id = values.decodeSafely(Int.self, forKey: .series_id)
        player_points = values.decodeSafely(Double.self, forKey: .player_points)

        is_playing = values.decodeSafely(Bool.self, forKey: .is_playing)
        my_team = values.decodeSafely(Bool.self, forKey: .my_team)
        isDream_player = values.decodeSafely(Int.self, forKey: .isDream_player)
        isCaptain = values.decodeSafely(Bool.self, forKey: .isCaptain)
        isViceCaptain = values.decodeSafely(Bool.self, forKey: .isViceCaptain)
        isBoosterPlayer = values.decodeSafely(Bool.self, forKey: .isBoosterPlayer)
     
        vice_captain_percent = values.decodeSafely(Double.self, forKey: .vice_captain_percent)
        captain_percent = values.decodeSafely(Double.self, forKey: .captain_percent)

        
        match_details = values.decodeSafely([MatchDetails].self, forKey: .match_details)
        playerBreckup = values.decodeSafely([String: PlayerBreckup].self, forKey: .playerBreckup)
        team_flag = values.decodeSafely(String.self, forKey: .team_flag)
        
        isBoosted = values.decodeSafely(Bool.self, forKey: .isBoosted)
        isDebuffed = values.decodeSafely(Bool.self, forKey: .isDebuffed)
        boosterDetails = values.decodeSafely([Booster].self, forKey: .boosterDetails)
        debuffDetails = values.decodeSafely([Booster].self, forKey: .debuffDetails)
        isSubstitute = values.decodeSafely(Bool.self, forKey: .isSubstitute)
    }
}

struct PlayerType : Codable {
    
    var type: String?
    var players:[Player]?
}

struct MatchDetails : Codable {
    
    let  match, date: String?
    let player_points:Double?
    
    let player_credit:Double?
    let selection_percent:String?

    var isPlayerBreckupShow = false
    let playerBreckup: [String: PlayerBreckup]?

    enum CodingKeys: String, CodingKey {
        case match = "Match"
        case date = "date"
        case player_points = "player_points"
        case player_credit = "player_credit"
        case selection_percent = "selection_percent"
        case playerBreckup = "player_breckup"

    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        match = values.decodeSafely(String.self, forKey: .match)
        date = values.decodeSafely(String.self, forKey: .date)
        player_points = values.decodeSafely(Double.self, forKey: .player_points)
        player_credit = values.decodeSafely(Double.self, forKey: .player_credit)
        selection_percent = values.decodeSafely(String.self, forKey: .selection_percent)
        playerBreckup = values.decodeSafely([String: PlayerBreckup].self, forKey: .playerBreckup)

    }
}

struct PlayerBreckup: Codable {
    let actual: JSONAny?
    let points: JSONAny?
}


struct SelectedPlayerTypes {
    var playerId = ""
    var type = ""
    var captainId = ""
    var viceCaptainId = ""
    var teamId = ""
    var playerData:Player?
    
    var batsman : Int = 0
    var bowler : Int = 0
    var wicketkeeper : Int = 0
    var allrounder : Int = 0
    let maxExtraPlayers = 3
    var extraPlayers = 0
    let minimumBat = 1
    let minimumBowl = 1
    let minimumAllRound = 1
    let minimumWkt = 1
    let totalCredits = 100
    var usedCredits = 0.0
    var totalSelectedPlayers = 0

    var localPlayers = 0
    var visitorPlayers = 0
    
}

struct SelectedRugbyPlayers {
    var playerId = ""
    var type = ""
    var captainId = ""
    var viceCaptainId = ""
    var teamId = ""
    var playerData: Player?
    
    // Backs
    var flyHalf: Int = 0
    var scrumHalf: Int = 0
    var center: Int = 0
    var outsideBack: Int = 0
    
    // Forwards
    var prop: Int = 0
    var hooker: Int = 0
    var lock: Int = 0
    var looseForward: Int = 0
    
    //Minimum Backs
    let minFlyHalf: Int = 2
    let minScrumHalf: Int = 2
    let mincenter: Int = 3
    let minOutsideBack: Int = 4
    
    //Minimum Forwards
    let minProp: Int = 3
    let minHooker: Int = 2
    let minLock: Int = 3
    let minLooseForward: Int = 4
    
    let maxExtraPlayers = 3
    var extraPlayers = 0

    let totalCredits = 200
    var usedCredits = 0.0
    var totalSelectedPlayers = 0
    var totalSelectedBacks = 0
    var totalSelectedForwards = 0

    var localPlayers = 0
    var visitorPlayers = 0
    
}


struct GuruPlayers {
    var guruPlayerIds = [String]()
    var suggestGuruPlayers = SelectedPlayerTypes()
    var captainId = ""
    var viceCaptainId = ""
    var arrWicketKeeper = [Player]()
    var arrBatsman = [Player]()
    var arrBowler = [Player]()
    var arrAllRounder = [Player]()

}


struct Media {
    let key: String
    let filename: String
    let data: Data
    let mimeType: String
    
    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        self.mimeType = "image/jpeg"
        self.filename = "UserImage\(Date().millisecondsSince1970).jpg"
        
        guard let data = image.jpegData(compressionQuality: 0.3) else { return nil }
        self.data = data
    }
    
}

struct PlayerFilters: Hashable {
    var name: String
    var isSelected: Bool = false
}

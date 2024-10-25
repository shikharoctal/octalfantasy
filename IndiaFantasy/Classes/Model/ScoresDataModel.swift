// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation


struct ScoreDetails: Codable {
    var id: ID?
    var inningNumber = 0
    var records: [Record]?
    var batsman: [Record]?
    var bowlers: [Record]?
    var noBalls, legBye, bye, wideBalls: Int?
    var totalExtraRuns: AnyDecodable?
    var battingTeamID: Int?
    var isSelected:Bool?
    var totalInningScore:String?
    
    var players:[Record]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case records, batsman, bowlers
        case noBalls = "no_balls"
        case legBye = "leg_bye"
        case bye
        case wideBalls = "wide_balls"
        case totalExtraRuns = "total_extra_runs"
        case battingTeamID = "batting_team_id"
    }
    public func encode(to encoder: Encoder) throws {
            
    }
}

// MARK: - ID
struct ID: Codable {
    var teamID, inningNumber: Int?
    var teamName: String?

    enum CodingKeys: String, CodingKey {
        case teamID = "team_id"
        case inningNumber = "inning_number"
        case teamName = "team_name"
    }
}

// MARK: - Record
struct Record: Codable {
    var name: String
    var teamName: String?
    var teamType: String?
    var comment: String?
    var matchType: String?
    var matchStatus: String?
    var playerID: Int?
    var isplaying, notBat: Bool?
    var point: Double?
    var isCurrentBatsman: Bool?
    var inningNumber: Int?
    var runScored: String?
    var isCurrentBowler, isSubstitute: Bool?
    var currentInning: Int?
    var extraRunScored, wickets, runRate, overBowled: String?
    var maidensBowled: String?
    var runsConceded, wicketsTaken, wideBalls: Int?
    var economyRatesRunsConceded, noBalls: String?
    var stampCount, runOutCount: Int?
    var recordCatch: String?
    var bye, legBye: Int?
    var penaltyRun: Int?
    var status, ballFaced, s4, s6: String?
    var battingStrikeRate: String?
    var totalInningScore: String?
    
    var isSelected:Bool?
    
    var playerType:String?

    enum CodingKeys: String, CodingKey {
        case name
        case teamName = "team_name"
        case teamType = "team_type"
        case comment
        case matchType = "match_type"
        case matchStatus = "match_status"
        case playerID = "player_id"
        case isplaying
        case notBat = "not_bat"
        case point, isCurrentBatsman
        case inningNumber = "inning_number"
        case runScored = "run_scored"
        case isCurrentBowler
        case isSubstitute = "is_substitute"
        case currentInning = "current_inning"
        case extraRunScored = "extra_run_scored"
        case wickets
        case runRate = "run_rate"
        case overBowled = "over_bowled"
        case maidensBowled = "maidens_bowled"
        case runsConceded = "runs_conceded"
        case wicketsTaken = "wickets_taken"
        case wideBalls = "wide_balls"
        case economyRatesRunsConceded = "economy_rates_runs_conceded"
        case noBalls = "no_balls"
        case stampCount
        case runOutCount = "run_out_count"
        case recordCatch = "catch"
        case bye
        case legBye = "leg_bye"
        case penaltyRun = "penalty_run"
        case status
        case ballFaced = "ball_faced"
        case s4, s6, battingStrikeRate
        case totalInningScore = "total_inning_score"
    }
}

// MARK: - Score - Team
struct Score: Codable {
    let local_team_score: String?
    let visitor_team_score:String?
    let match_started: Bool?
    let comment: String?
    let finalComment: String?
    let commentaries: [Commentary]?
    let batsmen: [Batsman]?
    let bowlers: Bowlers?
    let battingTeamId:Int?
    let bowlingTeamId:Int?
    
    let localteam: String?
    let visitorteam: String?
    let teamScores: SoccerTeamScore?

    enum CodingKeys: String, CodingKey {
        case comment
        case finalComment = "final_comment"
        case battingTeamId = "batting_team_id"
        case bowlingTeamId = "bowling_team_id"

        case commentaries, batsmen, bowlers, match_started, local_team_score, visitor_team_score
        case localteam, visitorteam, teamScores
    }
}


// MARK: - Batsman
struct Batsman: Codable {
    let name: String?
    let batsmanID, runs, ballsFaced, fours: AnyDecodable?
    let sixes: AnyDecodable?
    let strikeRate: AnyDecodable?

    enum CodingKeys: String, CodingKey {
        case name
        case batsmanID = "batsman_id"
        case runs
        case ballsFaced = "balls_faced"
        case fours, sixes
        case strikeRate = "strike_rate"
    }
    
    public func encode(to encoder: Encoder) throws {
            
    }
}

// MARK: - Bowlers
struct Bowlers: Codable {
    let name: String?
    let bowlerID: Int?
    let overs: AnyDecodable?
    let runsConceded, wickets, maidens: AnyDecodable?
    let econ: String?

    enum CodingKeys: String, CodingKey {
        case name
        case bowlerID = "bowler_id"
        case overs
        case runsConceded = "runs_conceded"
        case wickets, maidens, econ
    }
    
    public func encode(to encoder: Encoder) throws {
            
    }
}


// MARK: - Commentary
struct Commentary: Codable {
    let event: String?
    let batsmanID, bowlerID: AnyDecodable?
    let over, ball: AnyDecodable?
    let score: AnyDecodable?
    let commentary: String?
    let noballDismissal: Bool?
    let text: String?
    let howOut, wicketBatsmanID, batsmanRuns, batsmanBalls: AnyDecodable?

    enum CodingKeys: String, CodingKey {
        case event
        case batsmanID = "batsman_id"
        case bowlerID = "bowler_id"
        case over, ball, score, commentary
        case noballDismissal = "noball_dismissal"
        case text
        case howOut = "how_out"
        case wicketBatsmanID = "wicket_batsman_id"
        case batsmanRuns = "batsman_runs"
        case batsmanBalls = "batsman_balls"
    }
    
    public func encode(to encoder: Encoder) throws {
            
    }
}

// MARK: - Soccer Team Score
struct SoccerTeamScore: Codable {
    
    let match_status: String?
    let score: TeamScore?
    let minutesPlayed: Double?
}

// MARK: - Team Score
struct TeamScore: Codable {
    let away, home: JSONAny?
    let winner: String?
    
    func goles() -> String {
        return "\(home?.value ?? 0) - \(away?.value ?? 0)"
    }
}

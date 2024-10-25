//
//  GlobalDataPersistance.swift
//  GymPod
//
//  Created by Octal Mac 217 on 18/01/22.
//

import Foundation
import UIKit
class GlobalDataPersistance{
    
    static let shared = GlobalDataPersistance()
    
    var myTeamCount = 0
    var myContestCount = 0
    var fullContestCount = 0

    var bank_verified = 0
    var user_id = ""
    var cash_app_id = ""
    var cash_secret = ""
    var cash_api_version = ""
    var cash_end_point = ""
    var unreadNotificationCount = 0
    var selectedContest:ContestData? = nil


    var isContestJoinFlow = false
    
    var isFromContestList = false

    var arrPoints = [PointSystem]()
    var emailverified = false
    var pan_verified = 0
    var identity_verified = 0
    var gameType = ""
    var isKeepLoggedIn = false
    
    var myTeams = [Team]()
    var leagueMyTeams = [LeagueMyTeam]()
    
    var timeFilterOptions = ""
    var transactionFilterOptions = ""
    var gameFilterOptions = ""
    var dateFromFilterOptions = ""
    var dateToFilterOptions = ""

    var globalCurrency = "₹"
    var fantasyURLType = "fantasy"
    var fantasyType = "cricket"
    var leagueType = "fantasy"
    var leagueSeriesId = ""
    var leagueName = ""
    
//    var isFantasySoccer = false
    
    var wc = "Wicketkeeper"
    var bat = "Batsman"
    var ar = "Allrounder"
    var bwl = "Bowler"
    
    var selectedMatch:Match? = nil
    
    var wkShort = "WK"
    var batShort = "BAT"
    var arShort = "AR"
    var bowlShort = "BOWL"
    
    var wicketKeeper = "Wicket Keeper"
    var allRounder = "All Rounder"
    
    //Initializer access level change now
    private init(){}
    
    func switchToCricket(){
        
        GDP.fantasyURLType = Constants.kCricketFantasyURL
        GDP.fantasyType = Constants.kCricketFantasy

        GDP.selectedMatch = nil
        wc = "Wicketkeeper"
        bat = "Batsman"
        ar = "Allrounder"
        bwl = "Bowler"
        wkShort = "WK"
        batShort = "BAT"
        arShort = "AR"
        bowlShort = "BOWL"
        wicketKeeper = "Wicket Keeper"
        allRounder = "All Rounder"
        
    }
    
    func getFantasyTitle() -> String {
        return "Fantasy"//"Cricket"
    }
    
    func showDebuffAppliedPopUp(data: [Any]) {
    
        guard let topVC = UIApplication.shared.topViewController else { return }
        
        if data.count > 0, let result = data[0] as? NSDictionary {
            debugPrint(result)
            let user_id = result["user_id"] as? String ?? ""
            guard user_id == (Constants.kAppDelegate.user?.id ?? "") else { return }
            
            let pushVC = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "DebuffAppliedVC") as! DebuffAppliedVC
            pushVC.bannerImg = result["bannerImage"] as? String ?? ""
            pushVC.bannerTitle = result["bannerText"] as? String ?? ""
            pushVC.modalPresentationStyle = .overCurrentContext
            pushVC.completion = {
                
                let leagueType = result["leagueType"] as? String ?? ""
                let leagueName = result["leagueName"] as? String ?? ""
                let seriesId = result["series_id"] as? String ?? ""
                let matchType = result["match_type"] as? String ?? ""
                let contestType = result["contestType"] as? String ?? ""
            
                switch matchType.lowercased() {
                case "cricket":
                    GDP.switchToCricket()
                    break
                default:
                    break
                }
                
                if contestType == "daily" {
                    
                    let matchId = result["match_id"] as? Int ?? 0
                    
                    WebCommunication.shared.getMatchDetail(hostController: topVC, match_id: matchId, showLoader: true) { match in
                        
                        guard let match = match else { return }
                        
                        if match.match_status?.uppercased() == "NOT STARTED" || match.match_status?.uppercased() == "UPCOMING" || (match.match_status?.uppercased() ?? "") == "FIXTURE"{
                            
                            let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "MatchContestViewController") as! MatchContestViewController
                            VC.isMyGames = true
                            GDP.selectedMatch = match
                            
                            Constants.kAppDelegate.window?.rootViewController?.dismiss(animated: false, completion: {
                                if let topVC  = UIApplication.topViewController {
                                    topVC.navigationController?.pushViewController(VC, animated: true)
                                }
                            })
                            
                        }else{
        
                            if (match.match_status?.uppercased() ?? "") == "CANCELLED"{
                                return
                            }
                            let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "LiveContestViewController") as! LiveContestViewController
                            GDP.selectedMatch = match
                            Constants.kAppDelegate.window?.rootViewController?.dismiss(animated: false, completion: {
                                if let topVC  = UIApplication.topViewController {
                                    topVC.navigationController?.pushViewController(VC, animated: true)
                                }
                            })
                        }
                    }
                    
                }else {
                    
                    GDP.leagueSeriesId = seriesId
                    GDP.leagueType = leagueType
                    GDP.leagueName = leagueName
                    
                    let vc = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonsTabBarVC") as! SeasonsTabBarVC
                    Constants.kAppDelegate.window?.rootViewController?.dismiss(animated: false, completion: {
                        if let topVC  = UIApplication.topViewController {
                            topVC.navigationController?.pushViewController(vc, animated: true)
                        }
                    })
                }
            }
            topVC.present(pushVC, animated: false, completion: nil)
        }
    }
    
    func showBoosterGiftPopUp(data: [Any]) {
    
        guard let topVC = UIApplication.shared.topViewController else { return }
        
        if data.count > 0, let result = data[0] as? NSDictionary {
            debugPrint(result)
            let user_id = result["user_id"] as? String ?? ""
            guard user_id == (Constants.kAppDelegate.user?.id ?? "") else { return }
            
            let pushVC = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "DebuffAppliedVC") as! DebuffAppliedVC
            pushVC.bannerImg = result["bannerImage"] as? String ?? ""
            pushVC.teamName = result["senderName"] as? String ?? ""
            pushVC.isFromGift = true
            
            pushVC.modalPresentationStyle = .overCurrentContext
            topVC.present(pushVC, animated: false, completion: nil)
        }
    }
}

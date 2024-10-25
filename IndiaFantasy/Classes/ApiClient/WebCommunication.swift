//
//  GlobalDataPersistance.swift
//  GymPod
//
//  Created by Octal Mac 217 on 18/01/22.
//

import Foundation
import UIKit

class WebCommunication{
    
    static let shared = WebCommunication()
    //Initializer access level change now
    private init(){}
    
    //MARK: - Common API Methods
    func getCommonContent(hostController:UIViewController, slug:String, showLoader:Bool, completion completionBlock: @escaping (_ data: [String:Any]?) -> Void){
        
        ApiClient.init().getRequest(method: slug, parameters: [:], view: hostController.view) { result in
            if result != nil {
                let msg = result?.object(forKey: "message") as? String ?? ""
                
                if msg == "UNAUTHORIZED"{
                    AppManager.showToast(msg, view: hostController.view)
                }else{
                    let data = result?.object(forKey: "result") as? [String:Any]
                    if data != nil{
                        completionBlock(data)
                        
                    }else{
                        completionBlock(nil)
                        AppManager.showToast(msg, view: hostController.view)
                    }
                }
                
            }else{
                AppManager.showToast("", view: hostController.view)
                completionBlock(nil)
            }
            if showLoader == true{
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    func getUserProfile(hostController:UIViewController, showLoader:Bool, completion completionBlock: @escaping (_ user: UserDataModel?) -> Void){
        
        let url = URLMethods.BaseURL + URLMethods.getProfile
        
        ApiClient.init().getRequest(method: url, parameters: [String:String](), view: hostController.view) { result in
            if result != nil {
                let status = result?.object(forKey: "success") as? Bool ?? false
                
                if let unread_msg = result?.object(forKey: "unread_msg") as? Int{
                    GlobalDataPersistance.shared.unreadNotificationCount = unread_msg
                }
                
                if status == true{
                    let data = result?.object(forKey: "results") as? [String:Any]
                    if data != nil{
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                              let user = try? JSONDecoder().decode(UserDataModel.self, from: jsonData),
                              let userData = try? JSONEncoder().encode(user) else {return }
                        Constants.kAppDelegate.user = user
                        GlobalDataPersistance.shared.identity_verified = user.identity_verified ?? 0
                        if GlobalDataPersistance.shared.isKeepLoggedIn == true{
                            Constants.kAppDelegate.user?.saveUser(userData)
                        }
                        
                        //                        Constants.kAppDelegate.authToken = user.token ?? ""
                        //                        Constants.kAppDelegate.user?.saveToken(user.token ?? "")
                        
                        // self.activeSubscription = activeInfo
                        completionBlock(user)
                        
                    }else{
                        completionBlock(nil)
                    }
                }
                else{
                    if let user = UserDataModel.isLoggedIn(){
                        print(user.full_name ?? "")
                        if let msg = result?.object(forKey: "msg") as? String {
                            AppManager.showToast(msg, view: hostController.view)
                        }
                        if let auth = result?.object(forKey: "auth") as? Int, auth == 0 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                Constants.kAppDelegate.logOutApp()
                            })
                        }
                    }
                    completionBlock(nil)
                }
                
                
            }else{
                AppManager.showToast("", view: hostController.view)
                completionBlock(nil)
            }
            if showLoader == true{
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    func getTeamScore(hostController:UIViewController, series_id:Int, match_id:Int, showLoader:Bool, completion completionBlock: @escaping (_ score: Score?) -> Void){
        
        let params:[String:Any] = ["is_player_state":1,
                                   "series_id":series_id,
                                   "match_id":match_id
        ]
        
        let url = URLMethods.BaseURL + URLMethods().getTeamScore
        
        ApiClient.init().postRequest(params, request: url, view: hostController.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                let status = result?.object(forKey: "success") as? Bool ?? false
                
                if status == true{
                    let data = result?.object(forKey: "results") as? [String:Any]
                    if data != nil{
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted)
                        else {return }
                        
                        do {
                            let tblData = try JSONDecoder().decode(Score.self, from: jsonData)
                            debugPrint("Score --->>>", tblData)
                            completionBlock(tblData)
                        }catch {
                            print("error: ", error)
                        }
                        
                        
                        
                    }else{
                        completionBlock(nil)
                    }
                }
                else{
                    completionBlock(nil)
                }
                
                
            }
            
            else{
                AppManager.showToast(msg ?? "", view: hostController.view)
            }
            if showLoader == true{
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    func getCommonDetails(hostController:UIViewController, showLoader:Bool, completion completionBlock: @escaping (_ user: UserDataModel?) -> Void){
        
        let url = URLMethods.BaseURL + URLMethods.getCommonDetails
        
        ApiClient.init().getRequest(method: url, parameters: [String:String](), view: hostController.view) { result in
            if result != nil {
                let status = result?.object(forKey: "success") as? Bool ?? false
                
                if status == true{
                    let data = result?.object(forKey: "results") as? [String:Any]
                    if data != nil{
                        GlobalDataPersistance.shared.bank_verified = (data?["bank_verified"] as? Int) ?? 0
                        GlobalDataPersistance.shared.emailverified = (data?["emailverified"] as? Bool) ?? false
                        GlobalDataPersistance.shared.pan_verified = (data?["pan_verified"] as? Int) ?? 0
                        GlobalDataPersistance.shared.user_id = (data?["_id"] as? String) ?? ""
                        GlobalDataPersistance.shared.cash_app_id = (data?["cash_app_id"] as? String) ?? ""
                        GlobalDataPersistance.shared.cash_secret = (data?["cash_secret"] as? String) ?? ""
                        GlobalDataPersistance.shared.cash_end_point = (data?["cash_end_point"] as? String) ?? ""
                        GlobalDataPersistance.shared.cash_api_version = (data?["cash_api_version"] as? String) ?? ""
                        
                        if let points = data?["point_system"] as? [[String:Any]]{
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: points, options: .prettyPrinted),
                                  let pointsSystem = try? JSONDecoder().decode([PointSystem].self, from: jsonData)else {return }
                            GlobalDataPersistance.shared.arrPoints = pointsSystem
                            
                        }
                        completionBlock(nil)
                        
                    }else{
                        completionBlock(nil)
                    }
                }
                else{
                    completionBlock(nil)
                }
                
                
            }else{
                AppManager.showToast("", view: hostController.view)
                completionBlock(nil)
            }
            if showLoader == true{
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    
    
    func getMatchDetail(hostController:UIViewController, match_id:Int, showLoader:Bool, completion completionBlock: @escaping (_ match: Match?) -> Void){
        
        let params:[String:Any] = ["match_id":match_id
        ]
        
        let url = URLMethods.BaseURL + URLMethods().getMatchDetail
        
        ApiClient.init().postRequest(params, request: url, view: hostController.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                let status = result?.object(forKey: "success") as? Bool ?? false
                
                if status == true{
                    let data = result?.object(forKey: "results") as? [String:Any]
                    if data != nil{
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted)
                        else {return }
                        
                        do {
                            let tblData = try JSONDecoder().decode(Match.self, from: jsonData)
                            completionBlock(tblData)
                        }catch {
                            print("error: ", error)
                        }
                        
                        
                        
                    }else{
                        completionBlock(nil)
                    }
                }
                else{
                    completionBlock(nil)
                }
                
                
            }
            
            else{
                AppManager.showToast(msg ?? "", view: hostController.view)
            }
            
            if showLoader == true{
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    func getContestDetail(hostController:UIViewController, contestId: String, selectedMatch:Match, showLoader:Bool, completion completionBlock: @escaping (_ contest: ContestData?) -> Void){
        
        let params:[String:String] = ["user_id": Constants.kAppDelegate.user?.id ?? "",
                                      "match_id":String(selectedMatch.match_id ?? 0),
                                      "series_id":String(selectedMatch.series_id ?? 0),
                                      "contest_id":contestId
        ]
        
        let url = URLMethods.BaseURL + URLMethods().getContestDetail
        
        ApiClient.init().postRequest(params, request: url, view: hostController.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                if result != nil {
                    let data = result?.object(forKey: "results") as? [String:Any]
                    if data != nil{
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                              let tblData = try? JSONDecoder().decode(ContestData.self, from: jsonData)else {return }
                        var contestData  = tblData
                        
                        if let arrTeams = contestData.joined_teams{
                            var myTeamsList = arrTeams.filter { m in GlobalDataPersistance.shared.myTeams.contains(where: { $0.team_id == m.id }) }
                            
                            for i in 0..<myTeamsList.count {
                                var temp = myTeamsList[i]
                                temp.inMyTeam = true
                                myTeamsList[i] = temp
                            }
                            
                            myTeamsList = myTeamsList.sorted(by: { ($0.rank ?? 0) < ($1.rank ?? 0) })
                            
                            
                            var otherTeamsList = arrTeams.filter { m in !GlobalDataPersistance.shared.myTeams.contains(where: { $0.team_id == m.id }) }
                            
                            
                            otherTeamsList = otherTeamsList.sorted(by: { ($0.rank ?? 0) < ($1.rank ?? 0) })
                            
                            contestData.joined_teams = [JoinedTeam]()
                            contestData.my_teams = [JoinedTeam]()
                            contestData.my_teams?.append(contentsOf: myTeamsList)
                            contestData.joined_teams?.append(contentsOf: otherTeamsList)
                        }
                        
                        completionBlock(contestData)
                    }else{
                        completionBlock(nil)
                    }
                }else{
                    completionBlock(nil)
                }
            }
            else{
                completionBlock(nil)
                AppManager.showToast(msg ?? "", view: hostController.view)
            }
            
            if showLoader == true{
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
        
    }
    
    func getRummyDetails(hostController:UIViewController, showLoader:Bool, completion completionBlock: @escaping (_ hashURL: String?) -> Void){
        
        let params:[String:String] = [
            "user_id": Constants.kAppDelegate.user?.id ?? "",
            "full_name":Constants.kAppDelegate.user?.full_name ?? "",
            "email":Constants.kAppDelegate.user?.email ?? "",
            "phone":Constants.kAppDelegate.user?.phone ?? "",
            "state":Constants.kAppDelegate.user?.state ?? "",
            "country":Constants.kAppDelegate.user?.country ?? "+27"
        ]
        
        let url = URLMethods.BaseURL + URLMethods().getRummyDetails
        
        ApiClient.init().postRequest(params, request: url, view: hostController.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                if result != nil {
                    let url = result?.object(forKey: "results") as? String
                    completionBlock(url)
                }else{
                    completionBlock(nil)
                }
            }
            else{
                completionBlock(nil)
                AppManager.showToast(msg ?? "", view: hostController.view)
            }
            
            AppManager.stopActivityIndicator(hostController.view)
        }
        AppManager.startActivityIndicator(sender: hostController.view)
        
    }
    
    
    func getTeams(hostController:UIViewController, match_id:Int, series_id:Int, showLoader:Bool, completion completionBlock: @escaping (_ team: [Team]?) -> Void){
        
        let params:[String:String] = ["team_id": "",
                                      "match_id":String(match_id),
                                      "series_id":String(series_id)
        ]
        
        let url = URLMethods.BaseURL + URLMethods().getTeamList
        
        ApiClient.init().postRequest(params, request: url, view: hostController.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                let status = result?.object(forKey: "success") as? Bool ?? false
                
                if status == true{
                    let data = result?.object(forKey: "results") as? [[String:Any]]
                    if data != nil{
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted)
                        else {return }
                        do {
                            let tblData = try JSONDecoder().decode([Team].self, from: jsonData)
                            completionBlock(tblData)
                        }catch {
                            print("error: ", error)
                        }
                        
                    }else{
                        completionBlock(nil)
                    }
                }
                else{
                    completionBlock(nil)
                }
            }
            
            else{
                AppManager.showToast(msg ?? "", view: hostController.view)
            }
            
            if showLoader == true{
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    func getCountriesList(showLoader:Bool, completion completionBlock: @escaping (_ states: [State]?) -> Void){
        
        guard let topVCview  = UIApplication.topViewController?.view else { return }
        
        let url = URLMethods.BaseURL + URLMethods.getCountries
        
        ApiClient().getRequest(method: url, parameters: [:], view: topVCview) { result in
            if result != nil {
                let status = result?.object(forKey: "success") as? Bool ?? false
                
                if status == true{
                    let data = result?.object(forKey: "result") as? [[String:Any]]
                    if data != nil{
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                              let states = try? JSONDecoder().decode([State].self, from: jsonData)else {return }
                        completionBlock(states)
                        
                    }else{
                        completionBlock(nil)
                    }
                }
                else{
                    completionBlock(nil)
                }
                
                
            }else{
                AppManager.showToast("", view: topVCview)
                completionBlock(nil)
            }
            AppManager.stopActivityIndicator(topVCview)
        }
        
        if showLoader == true{
            AppManager.startActivityIndicator(sender: topVCview)
        }
    }
    
    func getLeagueDetail(hostController: UIViewController, seriesId: String, showLoader: Bool, completion completionBlock: @escaping (_ leagueDetails: LeagueDetails?) -> Void) {
        
        let params:[String:String] = ["series_id": seriesId]
        
        let url = URLMethods.BaseURL + URLMethods().leagueDetails
        
        ApiClient().postRequest(params, request: url, view: hostController.view) { msg, result in
            
            if result != nil {
                
                let status = result?.object(forKey: "success") as? Bool ?? false
                
                if status == true {
                
                    if let data = result?.object(forKey: "results") as? [String:Any] {
                        
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                              let leagueData = try? JSONDecoder().decode(LeagueDetails.self, from: jsonData)else {return }
                            
                        completionBlock(leagueData)
                        
                    }else {
                        AppManager.showToast(msg ?? "", view: hostController.view)
                        completionBlock(nil)
                    }
                }else {
                    AppManager.showToast(msg ?? "", view: hostController.view)
                    completionBlock(nil)
                }
            }else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: hostController.view)
                completionBlock(nil)
            }
            
            if showLoader == true{
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    func getLeagueMatches(hostController: UIViewController, seriesId: String, showLoader: Bool, completion completionBlock: @escaping (_ matchDetails: Match?) -> Void) {
        
        let params:[String:String] = ["series_id": seriesId]
        
        let url = URLMethods.BaseURL + URLMethods().leagueMatches
        
        ApiClient().postRequest(params, request: url, view: hostController.view) { msg, result in
            
            if result != nil {
                
                let status = result?.object(forKey: "success") as? Bool ?? false
                
                if status == true {
                
                    if let data = result?.object(forKey: "results") as? [String:Any] {
                        
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                              let leagueData = try? JSONDecoder().decode(Match.self, from: jsonData)else {return }
                            
                        completionBlock(leagueData)
                        
                    }else {
                        AppManager.showToast(msg ?? "", view: hostController.view)
                        completionBlock(nil)
                    }
                }else {
                    AppManager.showToast(msg ?? "", view: hostController.view)
                    completionBlock(nil)
                }
            }else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: hostController.view)
                completionBlock(nil)
            }
            
            if showLoader == true{
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    func getSeasonLeagues(hostController: UIViewController, showLoader: Bool, completion completionBlock: @escaping (_ leagueList: [LeagueList]?) -> Void) {

        let url = URLMethods.BaseURL + URLMethods().leagueList

        ApiClient.init().getRequest(method: url, parameters: [:], view: hostController.view) { result in

            if result != nil {

                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "message") as? String ?? ""

                if status == true{

                    if let data = result?.object(forKey: "results") as? [[String:Any]] {

                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                              let tblData = try? JSONDecoder().decode([LeagueList].self, from: jsonData)else {return }

                        completionBlock(tblData)

                    }else {
                        AppManager.showToast(msg, view: hostController.view)
                        completionBlock(nil)
                    }
                }else{
                    AppManager.showToast(msg, view: hostController.view)
                    completionBlock(nil)
                }
            }else{
                AppManager.showToast("", view: hostController.view)
                completionBlock(nil)
            }

            if showLoader == true{
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    func getLeagueTopPlayersList(hostController: UIViewController, series_id: String, showLoader: Bool, completion completionBlock: @escaping (_ topPlayers: [TopPlayers]?) -> Void) {
        
        let params:[String:String] = ["series_id": series_id]
        
        let url = URLMethods.BaseURL + URLMethods().leagueTopPlayers
        
        ApiClient().postRequest(params, request: url, view: hostController.view) { msg, result in
            
            if result != nil {
                
                let status = result?.object(forKey: "success") as? Bool ?? false
                
                if status == true {
                
                    if let data = result?.object(forKey: "results") as? [[String:Any]] {
                        
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                              let topPlayers = try? JSONDecoder().decode([TopPlayers].self, from: jsonData)else {return }
                            
                        completionBlock(topPlayers)
                        
                    }else {
                        AppManager.showToast(msg ?? "", view: hostController.view)
                        completionBlock(nil)
                    }
                }else {
                    AppManager.showToast(msg ?? "", view: hostController.view)
                    completionBlock(nil)
                }
            }else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: hostController.view)
                completionBlock(nil)
            }
            
            if showLoader == true{
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    func getLeaguePlayersList(hostController: UIViewController, series_id: String, showLoader: Bool, completion completionBlock: @escaping (_ players: [Player]?) -> Void) {
        
        let params:[String:String] = ["series_id": series_id]
        
        let url = URLMethods.BaseURL + URLMethods().leaguePlayers
        
        ApiClient().postRequest(params, request: url, view: hostController.view) { msg, result in
            
            if result != nil {
                
                let status = result?.object(forKey: "success") as? Bool ?? false
                
                if status == true {
                
                    if let data = result?.object(forKey: "results") as? [[String:Any]] {
                        
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                              let leaguePlayers = try? JSONDecoder().decode([Player].self, from: jsonData)else {return }
                            
                        completionBlock(leaguePlayers)
                        
                    }else {
                        AppManager.showToast(msg ?? "", view: hostController.view)
                        completionBlock(nil)
                    }
                }else {
                    AppManager.showToast(msg ?? "", view: hostController.view)
                    completionBlock(nil)
                }
            }else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: hostController.view)
                completionBlock(nil)
            }
            
            if showLoader == true{
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    func getLeagueAllContests(hostController: UIViewController, seriesId: String, showLoader: Bool, completion completionBlock: @escaping (_ contests: [ContestData]?, _ contestCount: Int, _ myContestCount:Int, _ myTeamsCount: Int) -> Void) {
        
        let params:[String:String] = ["series_id":seriesId]
        
        let url = URLMethods.BaseURL + URLMethods().leagueAllContests
        
        ApiClient().postRequest(params, request: url, view: hostController.view) { msg, result in
            
            if result != nil {
                
                let status = result?.object(forKey: "success") as? Bool ?? false
                let contestCount = result?.object(forKey: "full_contest") as? Int ?? 0
                let myContestCount = result?.object(forKey: "my_contests") as? Int ?? 0
                let myTeamsCount = result?.object(forKey: "my_teams") as? Int ?? 0
                
                if status == true {
                
                    if let data = result?.object(forKey: "results") as? [[String:Any]] {
                        
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                              let joinedContests = try? JSONDecoder().decode([ContestData].self, from: jsonData)else {return }
                            
                        completionBlock(joinedContests, contestCount, myContestCount, myTeamsCount)
                        
                    }else {
                        AppManager.showToast(msg ?? "", view: hostController.view)
                        completionBlock(nil, contestCount, myContestCount, myTeamsCount)
                    }
                }else {
                    AppManager.showToast(msg ?? "", view: hostController.view)
                    completionBlock(nil, contestCount, myContestCount, myTeamsCount)
                }
            }else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: hostController.view)
                completionBlock(nil, 0, 0, 0)
            }
            
            if showLoader == true{
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    func getLeagueJoinedContests(hostController: UIViewController, seriesId: String, showLoader: Bool, completion completionBlock: @escaping (_ contests: [LeagueJoinedContest]?, _ contestCount: Int, _ myContestCount:Int, _ myTeamsCount: Int) -> Void) {
        
        let params:[String:String] = ["series_id":seriesId]
        
        let url = URLMethods.BaseURL + URLMethods().leaguejoinedContests
        
        ApiClient().postRequest(params, request: url, view: hostController.view) { msg, result in
            
            if result != nil {
                
                let status = result?.object(forKey: "success") as? Bool ?? false
                let contestCount = result?.object(forKey: "full_contest") as? Int ?? 0
                let myContestCount = result?.object(forKey: "my_contests") as? Int ?? 0
                let myTeamsCount = result?.object(forKey: "my_teams") as? Int ?? 0
                
                if status == true {
                
                    if let data = result?.object(forKey: "results") as? [[String:Any]] {
                        
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                              let joinedContests = try? JSONDecoder().decode([LeagueJoinedContest].self, from: jsonData)else {return }
                            
                        completionBlock(joinedContests, contestCount, myContestCount, myTeamsCount)
                        
                    }else {
                        AppManager.showToast(msg ?? "", view: hostController.view)
                        completionBlock(nil, contestCount, myContestCount, myTeamsCount)
                    }
                }else {
                    AppManager.showToast(msg ?? "", view: hostController.view)
                    completionBlock(nil, contestCount, myContestCount, myTeamsCount)
                }
            }else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: hostController.view)
                completionBlock(nil, 0, 0, 0)
            }
            
            if showLoader == true{
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    func createEditLeagueTeam(hostController: UIViewController, params: [String: Any], showLoader: Bool, completion completionBlock: @escaping (_ success: Bool, _ msg: String) -> Void) {
        
        let url = URLMethods.BaseURL + URLMethods().leagueCreateEditTeam
        
        ApiClient().postRequest(params, request: url, view: hostController.view) { msg, result in
            
            if result != nil {
                
                let status = result?.object(forKey: "success") as? Bool ?? false
                completionBlock(status, msg ?? "")
                
            }else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: hostController.view)
                completionBlock(false, msg ?? "")
            }
            
            if showLoader == true{
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    func transferPreviewTeam(hostController: UIViewController, params: [String: Any], showLoader: Bool, completion completionBlock: @escaping (_ transferPreviewData: TransferPreviewData?) -> Void) {
        
        let url = URLMethods.BaseURL + URLMethods().leagueTransferPreview
        
        ApiClient().postRequest(params, request: url, view: hostController.view) { msg, result in
            
            if result != nil {
                
                let status = result?.object(forKey: "success") as? Bool ?? false
                
                if status == true {
                
                    if let data = result?.object(forKey: "results") as? [String:Any] {
                        
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                              let transferPreviewData = try? JSONDecoder().decode(TransferPreviewData.self, from: jsonData)else {return }
                            
                        completionBlock(transferPreviewData)
                        
                    }else {
                        AppManager.showToast(msg ?? "", view: hostController.view)
                        completionBlock(nil)
                    }
                }else {
                    AppManager.showToast(msg ?? "", view: hostController.view)
                    completionBlock(nil)
                }
            }else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: hostController.view)
                completionBlock(nil)
            }
            
            if showLoader == true{
                DispatchQueue.main.async {
                    AppManager.stopActivityIndicator(hostController.view)
                }
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    func getMyTeams(hostController: UIViewController, seriesId: String, teamId: String = "", teamName: String = "", showLoader: Bool, completion completionBlock: @escaping (_ teams: [Team]?, _ contestCount: Int, _ myContestCount:Int, _ myTeamsCount: Int) -> Void) {
        
        let params:[String:String] = ["series_id":seriesId,
                                      "team_id": teamId,
                                      "teamName": teamName]
        
        let url = URLMethods.BaseURL + URLMethods().leagueMyTeams
        
        ApiClient().postRequest(params, request: url, view: hostController.view) { msg, result in
            
            if result != nil {
                
                let status = result?.object(forKey: "success") as? Bool ?? false
                let contestCount = result?.object(forKey: "full_contest") as? Int ?? 0
                let myContestCount = result?.object(forKey: "my_contests") as? Int ?? 0
                let myTeamsCount = result?.object(forKey: "my_teams") as? Int ?? 0
                
                if status == true {
                
                    if let data = result?.object(forKey: "results") as? [[String:Any]] {
                        
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                              let joinedContests = try? JSONDecoder().decode([Team].self, from: jsonData)else {return }
                            
                        completionBlock(joinedContests, contestCount, myContestCount, myTeamsCount)
                        
                    }else {
                        AppManager.showToast(msg ?? "", view: hostController.view)
                        completionBlock(nil, contestCount, myContestCount, myTeamsCount)
                    }
                }else {
                    AppManager.showToast(msg ?? "", view: hostController.view)
                    completionBlock(nil, contestCount, myContestCount, myTeamsCount)
                }
            }else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: hostController.view)
                completionBlock(nil, 0, 0, 0)
            }
            
            if showLoader == true{
                DispatchQueue.main.async {
                    AppManager.stopActivityIndicator(hostController.view)
                }
            }
        }
        if showLoader == true{
            DispatchQueue.main.async {
                AppManager.startActivityIndicator(sender: hostController.view)
            }
        }
    }
    
    func getMatchPointsTransfers(hostController: UIViewController, seriesId: String, teamName: String, showLoader: Bool, completion completionBlock: @escaping (_ match: MatchTransfersPoints?) -> Void) {
        
        let params:[String:String] = ["series_id": seriesId, "teamName": teamName]
        
        let url = URLMethods.BaseURL + URLMethods().leagueTransfersPoints
        
        ApiClient().postRequest(params, request: url, view: hostController.view) { msg, result in
            
            if result != nil {
                
                let status = result?.object(forKey: "success") as? Bool ?? false
                
                if status == true {
                
                    if let data = result?.object(forKey: "results") as? [String:Any] {
                        
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                              let joinedContests = try? JSONDecoder().decode(MatchTransfersPoints.self, from: jsonData)else {return }
                            
                        completionBlock(joinedContests)
                        
                    }else {
                        AppManager.showToast(msg ?? "", view: hostController.view)
                        completionBlock(nil)
                    }
                }else {
                    AppManager.showToast(msg ?? "", view: hostController.view)
                    completionBlock(nil)
                }
            }else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: hostController.view)
                completionBlock(nil)
            }
            
            if showLoader == true{
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    func getLeagueContestLeaderboard(hostController: UIViewController, seriesId: String, contestId: String, page: Int, showLoader: Bool, completion completionBlock: @escaping (_ contestDetails: ContestData?) -> Void) {
        
        let params:[String:String] = ["series_id": seriesId, "contest_id": contestId]
        
        let url = URLMethods.BaseURL + URLMethods().leagueContestLeaderboard + "\(page)"
        
        ApiClient().postRequest(params, request: url, view: hostController.view) { msg, result in
            
            if result != nil {
                
                let status = result?.object(forKey: "success") as? Bool ?? false
                
                if status == true {
                
                    if let data = result?.object(forKey: "results") as? [String:Any] {
                        
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                              let joinedContests = try? JSONDecoder().decode(ContestData.self, from: jsonData)else {return }
                            
                        completionBlock(joinedContests)
                        
                    }else {
                        AppManager.showToast(msg ?? "", view: hostController.view)
                        completionBlock(nil)
                    }
                }else {
                    AppManager.showToast(msg ?? "", view: hostController.view)
                    completionBlock(nil)
                }
            }else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: hostController.view)
                completionBlock(nil)
            }
            
            if showLoader == true{
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    func getLeagueSeriesPlayerList(hostController: UIViewController, seriesId: String, teamName: String, showLoader: Bool, completion completionBlock: @escaping (_ players: [Player]?) -> Void) {
        
        let params:[String:Any] = ["series_id": seriesId, "teamName": teamName, "is_player_state": 1]
        
        let url = URLMethods.BaseURL + URLMethods().leagueSeriesPlayers
        
        ApiClient().postRequest(params, request: url, view: hostController.view) { msg, result in
            
            if result != nil {
                
                let status = result?.object(forKey: "success") as? Bool ?? false
                let results = result?.object(forKey: "results") as? [String:Any]
                
                if status == true {
                
                    if let data = results?["seriesPlayerList"] as? [[String:Any]] {
                        
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                              let joinedContests = try? JSONDecoder().decode([Player].self, from: jsonData)else {return }
                            
                        completionBlock(joinedContests)
                        
                    }else {
                        AppManager.showToast(msg ?? "", view: hostController.view)
                        completionBlock(nil)
                    }
                }else {
                    AppManager.showToast(msg ?? "", view: hostController.view)
                    completionBlock(nil)
                }
            }else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: hostController.view)
                completionBlock(nil)
            }
            
            if showLoader == true{
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    func getBoosterList(fromDailyBooster: Bool = false, hostController: UIViewController, seriesId: String, matchId: String, teamName: String, teamId: String = "", showLoader: Bool, completion completionBlock: @escaping (_ boosterData: BoosterData?, _ totalBoosters: Int, _ availableBoosters: Int) -> Void) {
    
        var params:[String:String] = ["series_id": seriesId,
                                      "match_id": matchId,
                                      "team_id": teamId]
        var url = ""
        
        if fromDailyBooster {
            url =  URLMethods.BaseURL + URLMethods().dailyContestBoosterList
        }else {
            params["teamName"] = teamName
            url =  URLMethods.BaseURL + URLMethods().getBoosterList
        }
        
        ApiClient().postRequest(params, request: url, view: hostController.view) { msg, result in
            
            if result != nil {
                
                let status = result?.object(forKey: "success") as? Bool ?? false
                let totalBoosters = result?.object(forKey: "totalBoosters") as? Int ?? 0
                let availableBoosters = result?.object(forKey: "availableBoosters") as? Int ?? 0
                
                if status == true {
                
                    if let results = result?.object(forKey: "results") as? [String:Any] {
                        
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: results, options: .prettyPrinted),
                              let joinedContests = try? JSONDecoder().decode(BoosterData.self, from: jsonData)else {
                                  completionBlock(nil, 0, 0)
                                  return }
                            
                        completionBlock(joinedContests, totalBoosters, availableBoosters)
                        
                    }else {
                        AppManager.showToast(msg ?? "", view: hostController.view)
                        completionBlock(nil, totalBoosters, availableBoosters)
                    }
                }else {
                    //AppManager.showToast(msg ?? "", view: hostController.view)
                    completionBlock(nil, totalBoosters, availableBoosters)
                }
            }else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: hostController.view)
                completionBlock(nil, 0, 0)
            }
            
            if showLoader == true{
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    func checkUnJoinedTeam(hostController: UIViewController, seriesId: String, showLoader: Bool, completion completionBlock: @escaping (_ status: Bool) -> Void) {
        
        let params:[String:String] = ["series_id": seriesId]
        
        let url = URLMethods.BaseURL + URLMethods().leagueUnjoinedTeam
        
        ApiClient().postRequest(params, request: url, view: hostController.view) { msg, result in
            
            if result != nil {
                
                let status = result?.object(forKey: "success") as? Bool ?? false
                
                if status == true {
                    completionBlock(true)
                }else {
                    AppManager.showToast(msg ?? "", view: hostController.view)
                    completionBlock(false)
                }
            }else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: hostController.view)
                completionBlock(false)
            }
            
            if showLoader == true{
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    func leagueTeamPreview(hostController: UIViewController, seriesId: String, matchId: Int, teamName: String, userId: String, showLoader: Bool, completion completionBlock: @escaping (_ team: [Team]?) -> Void) {
        
        var params:[String:Any] = ["series_id":Int(seriesId) ?? 0,
                                   "teamName": teamName,
                                   "user_id": userId]
        
        if matchId != 0 {
            params["match_id"] = matchId
        }else {
            params["match_id"] = ""
        }
        
        let url = URLMethods.BaseURL + URLMethods().leagueTeamPreview
        
        ApiClient().postRequest(params, request: url, view: hostController.view) { msg, result in
            
            if result != nil {
                
                let status = result?.object(forKey: "success") as? Bool ?? false
                
                if status == true {
                
                    if let data = result?.object(forKey: "results") as? [[String:Any]], !data.isEmpty {
                        
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                              let team = try? JSONDecoder().decode([Team].self, from: jsonData)else {return }
                            
                        completionBlock(team)
                        
                    }else {
                        AppManager.showToast(msg ?? "", view: hostController.view)
                        completionBlock(nil)
                    }
                }else {
                    AppManager.showToast(msg ?? "", view: hostController.view)
                    completionBlock(nil)
                }
            }else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: hostController.view)
                completionBlock(nil)
            }
            
            if showLoader == true{
                DispatchQueue.main.async {
                    AppManager.stopActivityIndicator(hostController.view)
                }
            }
        }
        if showLoader == true{
            DispatchQueue.main.async {
                AppManager.startActivityIndicator(sender: hostController.view)
            }
        }
    }
    
    func getSeriesList(hostController:UIViewController, showLoader:Bool, completion completionBlock: @escaping (_ series: [MatchSeries]?) -> Void){
        
        
        let url = URLMethods.BaseURL + URLMethods().getSeriesList
        
        ApiClient.init().getRequest(method: url, parameters: [:], view: hostController.view) { result in
            if result != nil {
                let status = result?.object(forKey: "success") as? Bool ?? false
                
                if status == true{
                    let data = result?.object(forKey: "results") as? [[String:Any]]
                    if data != nil{
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                              let series = try? JSONDecoder().decode([MatchSeries].self, from: jsonData)else {return }
                        completionBlock(series)
                        
                    }else{
                        completionBlock(nil)
                    }
                }
                else{
                    completionBlock(nil)
                }
                
            }else{
                AppManager.showToast("", view: hostController.view)
                completionBlock(nil)
            }
            AppManager.stopActivityIndicator(hostController.view)
        }
        
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    func getCaptchaImage(hostController:UIViewController, showLoader:Bool, completion completionBlock: @escaping (_ captchaImage: String?, _ captchaKey: String?) -> Void){
        
        let url = URLMethods.BaseURL + URLMethods.getCaptcha
        
        ApiClient.init().getRequest(method: url, parameters: [:], view: hostController.view) { result in
            if result != nil {
                let status = result?.object(forKey: "success") as? Bool ?? false
                
                if status == true{
                    if let data = result?.object(forKey: "results") as? [String:Any] {
                        
                        let image = data["captchaImage"] as? String
                        let captchaKey = data["captchaKey"] as? String
                        
                        completionBlock(image, captchaKey)
                    }else {
                        completionBlock(nil, nil)
                    }
                }else {
                    completionBlock(nil, nil)
                }
                
            }else{
                AppManager.showToast("", view: hostController.view)
                completionBlock(nil, nil)
            }
            if showLoader == true {
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    
    func getDebuffContestList(forDailyContest: Bool = false, hostController: UIViewController, seriesId: String, teamName: String, showLoader: Bool, completion completionBlock: @escaping (_ leagueList: [ContestData]?) -> Void) {

        var params: [String: String] = [:]
        var url = ""
        
        if forDailyContest {
            params = ["team_id": teamName]
            url = URLMethods.BaseURL + URLMethods().debuffDailyContestList
            
        }else {
            params = ["series_id": seriesId,
                      "teamName": teamName]
            url = URLMethods.BaseURL + URLMethods().debuffContestList
        }
        
        

        ApiClient.init().getRequest(method: url, parameters: params, view: hostController.view) { result in

            if result != nil {

                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "msg") as? String ?? ""

                if status == true{

                    if let data = result?.object(forKey: "results") as? [[String:Any]] {

                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                              let tblData = try? JSONDecoder().decode([ContestData].self, from: jsonData)else {return }

                        completionBlock(tblData)

                    }else {
                        AppManager.showToast(msg, view: hostController.view)
                        completionBlock(nil)
                    }
                }else{
                    AppManager.showToast(msg, view: hostController.view)
                    completionBlock(nil)
                }
            }else{
                AppManager.showToast("", view: hostController.view)
                completionBlock(nil)
            }

            if showLoader == true{
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    func getContestUsers(forDailyContest: Bool = false, hostController: UIViewController, seriesId: String, contestId: String, matchId: String = "", keyword: String, page: Int, showLoader: Bool, completion completionBlock: @escaping (_ contestUsers: [ContestUser]?,_ teamCount: Int) -> Void) {
        
        var params:[String:String] = ["series_id": seriesId, "contest_id": contestId]
        var middleUrl = URLMethods().contestTeamList
        let searchBy = forDailyContest ? "username=\(keyword)" : "teamName=\(keyword)"
        
        if forDailyContest {
            params["match_id"] = matchId
            middleUrl = URLMethods().dailyContestTeamList
        }
        
        guard let url = (URLMethods.BaseURL + middleUrl + "\(page)&\(searchBy)&itemsPerPage=100").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        ApiClient().postRequest(params, request: url, view: hostController.view) { msg, result in
            
            if result != nil {
                
                let status = result?.object(forKey: "success") as? Bool ?? false
                let totalCount = result?.object(forKey: "totalCount") as? Int ?? 0
                
                if status == true {
                
                    if let data = result?.object(forKey: "results") as? [[String:Any]] {
                        
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                              let joinedContests = try? JSONDecoder().decode([ContestUser].self, from: jsonData)else {return }
                            
                        completionBlock(joinedContests, totalCount)
                        
                    }else {
                        AppManager.showToast(msg ?? "", view: hostController.view)
                        completionBlock(nil, totalCount)
                    }
                }else {
                    AppManager.showToast(msg ?? "", view: hostController.view)
                    completionBlock(nil, totalCount)
                }
            }else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: hostController.view)
                completionBlock(nil, 0)
            }
            
            if showLoader == true{
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    func applyDebuff(hostController: UIViewController, request: DebuffApplyRequest, showLoader: Bool, completion completionBlock: @escaping (_ success: Bool?, _ message:String?) -> Void) {

        var url = ""
        
        var params:[String: Any] = ["series_id": request.seriesId,
                                    "match_id": request.matchId,
                                    "team_id": request.teamId,
                                    "boosterCode": request.boosterCode,
                                    "user_id": request.userId,
                                    "boosterUniqueId": request.boosterUniqueId
        ]
        
        if request.fromDailyContest {
            params["otherUserTeamId"] = request.otherUserTeamName
            url = URLMethods.BaseURL + URLMethods().dailyContestDebuffApply
            
        }else {
            params["otherUserTeamName"] = request.otherUserTeamName
            params["teamName"] = request.teamName
            url = URLMethods.BaseURL + URLMethods().debuffApply
        }

        ApiClient().postRequest(params, request: url, view: hostController.view) { msg, result in

            if result != nil {
                
                let status = result?.object(forKey: "success") as? Bool ?? false
                
                if status == true {
                    completionBlock(true, msg)
                }else {
                    AppManager.showToast(msg ?? "", view: hostController.view)
                    completionBlock(status, msg)
                }
            }else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: hostController.view)
                completionBlock(false, msg)
            }
            
            if showLoader == true{
                DispatchQueue.main.async {
                    AppManager.stopActivityIndicator(hostController.view)
                }
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    func sendBoosterGift(hostController: UIViewController, request: BoosterGiftRequest, showLoader: Bool, completion completionBlock: @escaping (_ success: Bool?, _ message:String?) -> Void) {

        var url = ""
        var params:[String: Any] = ["user_id": request.userId,
                                    "boosterUniqueId": request.boosterUniqueId,
                                    "sharedBoosterUniqueId": request.sharedBoosterUniqueId
        ]
        
        if request.fromDailyContest {
            params["team_id"] = request.teamId
            url = URLMethods.BaseURL + URLMethods().dailyContestBoosterTransfer
        }else {
            
            params["series_id"] = request.seriesId
            params["match_id"] = request.matchId
            params["teamName"] = request.teamName
            url = URLMethods.BaseURL + URLMethods().boosterTransfer
        }

        ApiClient().postRequest(params, request: url, view: hostController.view) { msg, result in

            if result != nil {
                
                let status = result?.object(forKey: "success") as? Bool ?? false
                
                if status == true {
                    completionBlock(true, msg)
                }else {
                    AppManager.showToast(msg ?? "", view: hostController.view)
                    completionBlock(status, msg)
                }
            }else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: hostController.view)
                completionBlock(false, msg)
            }
            
            if showLoader == true{
                DispatchQueue.main.async {
                    AppManager.stopActivityIndicator(hostController.view)
                }
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    func validateBoosters(hostController: UIViewController, request: BoosterValidateRequest, showLoader: Bool, completion completionBlock: @escaping (_ status: Bool,_ msg: String) -> Void) {

        var url = ""
        var params:[String: Any] = ["series_id": request.seriesId,
                                    "match_id": request.matchId,
                                    "boosterCode": request.boosterCode
        ]

        
        if request.fromDailyContest {
            url = URLMethods.BaseURL + URLMethods().dailyContestBoosterValidate
        }else {
            
            params["boostedPlayerId"] = request.boostedPlayerId
            params["teamName"] = request.teamName
            url = URLMethods.BaseURL + URLMethods().boosterValidate
        }

        ApiClient().postRequest(params, request: url, view: hostController.view) { msg, result in
            
            if result != nil {
                let status = result?.object(forKey: "success") as? Bool ?? false
                completionBlock(status, msg ?? "")
            }else {
                completionBlock(false, ConstantMessages.somethingWrong)
            }
    
            if showLoader == true{
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    func dailyContestTeamPreview(hostController: UIViewController, seriesId: String, matchId: Int, teamId: String, userId: String, showLoader: Bool, completion completionBlock: @escaping (_ team: Team?) -> Void) {
        
        let params:[String:Any] = ["series_id":Int(seriesId) ?? 0,
                                   "match_id": matchId,
                                   "team_id": teamId,
                                   "user_id": userId]
        
        let url = URLMethods.BaseURL + URLMethods().dailyContestTeamPreview
        
        ApiClient().postRequest(params, request: url, view: hostController.view) { msg, result in
            
            if result != nil {
                
                let status = result?.object(forKey: "success") as? Bool ?? false
                
                if status == true {
                
                    if let data = result?.object(forKey: "results") as? [String:Any], !data.isEmpty {
                        
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                              let team = try? JSONDecoder().decode(Team.self, from: jsonData)else {return }
                            
                        completionBlock(team)
                        
                    }else {
                        AppManager.showToast(msg ?? "", view: hostController.view)
                        completionBlock(nil)
                    }
                }else {
                    AppManager.showToast(msg ?? "", view: hostController.view)
                    completionBlock(nil)
                }
            }else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: hostController.view)
                completionBlock(nil)
            }
            
            if showLoader == true{
                DispatchQueue.main.async {
                    AppManager.stopActivityIndicator(hostController.view)
                }
            }
        }
        if showLoader == true{
            DispatchQueue.main.async {
                AppManager.startActivityIndicator(sender: hostController.view)
            }
        }
    }
    
    
    func getSeasonLeagueHistory(page: Int, type: String, hostController: UIViewController, showLoader: Bool, completion completionBlock: @escaping (_ history: LeagueHistoryResponse?) -> Void) {

        let url = URLMethods.BaseURL + URLMethods().leagueHistory
        let params = ["page": "\(page)", "type": type]

        ApiClient.init().getRequest(method: url, parameters: params, view: hostController.view) { result in

            if result != nil {

                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "message") as? String ?? ""

                if status == true, let data = result?.object(forKey: "results") as? [String:Any] {
                    
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                          let tblData = try? JSONDecoder().decode(LeagueHistoryResponse.self, from: jsonData) else {
                              completionBlock(nil)
                              return
                          }
                    
                    completionBlock(tblData)
                    
                }else{
                    AppManager.showToast(msg, view: hostController.view)
                    completionBlock(nil)
                }
            }else{
                AppManager.showToast(ConstantMessages.somethingWrong, view: hostController.view)
                completionBlock(nil)
            }

            if showLoader == true{
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
    
    
    func getBoosterHistory(hostController: UIViewController, seriesId: Int, page: Int, showLoader: Bool, completion completionBlock: @escaping (_ team: BoostersHistoryResponse?) -> Void) {
        
        let params:[String:Any] = ["series_id": seriesId]
        
        let url = URLMethods.BaseURL + URLMethods().boosterHistory + "\(page)"
        
        ApiClient().postRequest(params, request: url, view: hostController.view) { msg, result in
            
            if result != nil {
                
                let status = result?.object(forKey: "success") as? Bool ?? false
                
                if status == true {
                
                    if let data = result?.object(forKey: "results") as? [String:Any], !data.isEmpty {
                        
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                              let team = try? JSONDecoder().decode(BoostersHistoryResponse.self, from: jsonData)else {return }
                            
                        completionBlock(team)
                        
                    }else {
                        AppManager.showToast(msg ?? "", view: hostController.view)
                        completionBlock(nil)
                    }
                }else {
                    AppManager.showToast(msg ?? "", view: hostController.view)
                    completionBlock(nil)
                }
            }else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: hostController.view)
                completionBlock(nil)
            }
            
            if showLoader == true{
                DispatchQueue.main.async {
                    AppManager.stopActivityIndicator(hostController.view)
                }
            }
        }
        if showLoader == true{
            DispatchQueue.main.async {
                AppManager.startActivityIndicator(sender: hostController.view)
            }
        }
    }
    
    func applyReferralCode(hostController: UIViewController, parameters: [String: Any], showLoader: Bool, completion completionBlock: @escaping (_ status: Bool,_ message: String) -> Void) {

        let url = URLMethods.BaseURL + URLMethods().applyReferralCode

        ApiClient.init().getRequest(method: url, parameters: parameters, view: hostController.view) { result in

            if result != nil {

                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "msg") as? String ?? ""

                completionBlock(status, msg)
    
            }else{
                completionBlock(false, ConstantMessages.somethingWrong)
            }

            if showLoader == true{
                AppManager.stopActivityIndicator(hostController.view)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: hostController.view)
        }
    }
        
    //MARK: Social Login/Signup
    func socialLogin(request: SocialLoginRequest, showLoader: Bool, completion completionBlock: @escaping (_ data: UserDataModel?, _ token: String?) -> Void) {
        
        guard let topVCview  = UIApplication.topViewController?.view else { return }
        
        let params:[String:Any] = ["email": request.email,
                                   "device_id": Constants.kAppDelegate.deviceTokenString,
                                   "device_type": Constants.kDeviceType,
                                   "referralCode": request.referralCode,
                                   "social_type" : request.social_type.value,
                                   "social_id" : request.social_id,
                                   "login_type": request.login_type.value
                                  ]
        
        let url = URLMethods.BaseURL + URLMethods.socialLogin
        
        ApiClient().postRequest(params, request: url, view: topVCview) { msg, result in
            
            guard let result = result else {
                if let topview  = UIApplication.topViewController?.view {
                    AppManager.showToast(ConstantMessages.somethingWrong, view: topview)
                }
                completionBlock(nil, nil)
                if showLoader { AppManager.stopActivityIndicator(topVCview) }
                return
            }

            let status = result.object(forKey: "success") as? Bool ?? false
            let data = result.object(forKey: "result") as? [String:Any]
            let token = result.object(forKey: "token") as? String ?? ""
            
            guard status == true, data != nil else {
                
                if let topview  = UIApplication.topViewController?.view {
                    AppManager.showToast(msg ?? "", view: topview)
                }
                if showLoader { AppManager.stopActivityIndicator(topVCview) }
                completionBlock(nil, nil)
                return
            }
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                  let user = try? JSONDecoder().decode(UserDataModel.self, from: jsonData) else {return }
            
            completionBlock(user, token)
            
            if showLoader == true{
                AppManager.stopActivityIndicator(topVCview)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: topVCview)
        }
    }
    
    func deleteAccountRequest(showLoader: Bool, completion completionBlock: @escaping (_ status: Bool,_ message: String) -> Void) {

        guard let topVCview  = UIApplication.topViewController?.view else { return }
        let url = URLMethods.BaseURL + URLMethods.deleteAccount

        ApiClient.init().getRequest(method: url, parameters: [:], view: topVCview) { result in

            if result != nil {

                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "msg") as? String ?? ""

                completionBlock(status, msg)
    
            }else{
                completionBlock(false, ConstantMessages.somethingWrong)
            }

            if showLoader == true{
                AppManager.stopActivityIndicator(topVCview)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: topVCview)
        }
    }
    
    func getMoneyPoolMatchList(showLoader: Bool, completion completionBlock: @escaping (_ matchList: [Match]?) -> Void) {

        guard let topVCview  = UIApplication.topViewController?.view else { return }
        let url = URLMethods.BaseURL + URLMethods().poolMatchList

        ApiClient.init().getRequest(method: url, parameters: [:], view: topVCview) { result in

            if result != nil {

                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "msg") as? String ?? ""

                if status == true, let data = result?.object(forKey: "results") as? [String:Any], let list = data["rows"] as? [[String:Any]]{
                    
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: list, options: .prettyPrinted),
                          let tblData = try? JSONDecoder().decode([Match].self, from: jsonData) else {return }
                    
                    completionBlock(tblData)
                    
                }else{
                    AppManager.showToast(msg, view: topVCview)
                    completionBlock(nil)
                }
            }else{
                AppManager.showToast(ConstantMessages.somethingWrong, view: topVCview)
                completionBlock(nil)
            }

            if showLoader == true{
                AppManager.stopActivityIndicator(topVCview)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: topVCview)
        }
    }
    
    func getPoolQuestionList(request: PoolQuestionsRequest, completion completionBlock: @escaping (_ list: [PoolQuestionResult]?,_ totalDocs:Int) -> Void) {
        
        guard let topVCview  = UIApplication.topViewController?.view else { return }
        let params:[String:Any] = ["match_id": request.matchId,
                                   "status": request.status,
                                   "type": request.type,
                                   "categoryId": request.categoryId]
        
        let url = URLMethods.BaseURL + URLMethods().poolQuestionsList + "\(request.page)"
        
        ApiClient().postRequest(params, request: url, view: topVCview) { msg, result in
            
            if result != nil {
                
                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "msg") as? String ?? ""
                let totalDocs = result?.object(forKey: "totalDocs") as? Int ?? 0

                if status == true, let data = result?.object(forKey: "results") as? [[String:Any]] {
                    
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                          let tblData = try? JSONDecoder().decode([PoolQuestionResult].self, from: jsonData) else {
                        AppManager.stopActivityIndicator(topVCview)
                        completionBlock(nil, 0)
                        return
                    }
                    
                    completionBlock(tblData, totalDocs)
                    
                }else{
                    AppManager.showToast(msg, view: topVCview)
                    completionBlock(nil, 0)
                }
            }else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: topVCview)
                completionBlock(nil, 0)
            }
            
            DispatchQueue.main.async {
                AppManager.stopActivityIndicator(topVCview)
            }
        }
        DispatchQueue.main.async {
            AppManager.startActivityIndicator(sender: topVCview)
        }
    }
    
    func joinPoolRequest(request: [String: Any], completion completionBlock: @escaping (_ success: Bool?,_ msg: String) -> Void) {
        
        guard let topVCview  = UIApplication.topViewController?.view else { return }
        
        let url = URLMethods.BaseURL + URLMethods().joinPool
        
        ApiClient().postRequest(request, request: url, view: topVCview) { msg, result in
            
            if result != nil {
                
                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "msg") as? String ?? ""

                if status == true {
                    completionBlock(true, msg)
                }else{
                    AppManager.showToast(msg, view: topVCview)
                    completionBlock(nil, msg)
                }
            }else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: topVCview)
                completionBlock(nil, "")
            }
            
            DispatchQueue.main.async {
                AppManager.stopActivityIndicator(topVCview)
            }
        }
        DispatchQueue.main.async {
            AppManager.startActivityIndicator(sender: topVCview)
        }
    }
    
    func validateWallet(request: [String: Any], showLoader: Bool, completion completionBlock: @escaping (_ data: WalletAmountResults?,_ status: Bool,_ msg: String) -> Void) {
        
        guard let topVCview  = UIApplication.topViewController?.view else { return }
        
        let url = URLMethods.BaseURL + URLMethods().joinContestCheckWallet
        
        ApiClient().postRequest(request, request: url, view: topVCview) { msg, result in
            
            if result != nil {
                
                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "msg") as? String ?? ""

                if let data = result?.object(forKey: "results") as? [String:Any] {
                    
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                          let walletData = try? JSONDecoder().decode(WalletAmountResults.self, from: jsonData) else {return }
                    
                    completionBlock(walletData, status, msg)
                    
                } else {
                    AppManager.showToast(msg, view: topVCview)
                    completionBlock(nil, status, msg)
                }
            }else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: topVCview)
                completionBlock(nil, false, "")
            }
            
            if showLoader == true{
                AppManager.stopActivityIndicator(topVCview)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: topVCview)
        }
    }
    
    func getMoneyPoolCategoryList(type: String, showLoader: Bool, completion completionBlock: @escaping (_ categoryList: [PoolCategoryData]?) -> Void) {

        guard let topVCview  = UIApplication.topViewController?.view else { return }
        let url = URLMethods.BaseURL + URLMethods().poolCategoryList + type

        ApiClient.init().getRequest(method: url, parameters: [:], view: topVCview) { result in

            if result != nil {

                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "msg") as? String ?? ""

                if status == true, let data = result?.object(forKey: "results") as? [[String:Any]] {
                    
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                          let tblData = try? JSONDecoder().decode([PoolCategoryData].self, from: jsonData) else {return }
                    
                    completionBlock(tblData)
                    
                }else{
                    AppManager.showToast(msg, view: topVCview)
                    completionBlock(nil)
                }
            }else{
                AppManager.showToast(ConstantMessages.somethingWrong, view: topVCview)
                completionBlock(nil)
            }

            if showLoader == true{
                AppManager.stopActivityIndicator(topVCview)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: topVCview)
        }
    }
    
    func addMoneyRequest(amount: Double, completion completionBlock: @escaping (_ success: Bool?,_ msg: String) -> Void) {
        
        guard let topVCview  = UIApplication.topViewController?.view else { return }
        
        let url = URLMethods.BaseURL + URLMethods.addMoneyInWallet
        let request = ["amount": amount]
        
        ApiClient().postRequest(request, request: url, view: topVCview) { msg, result in
            
            if result != nil {
                
                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "msg") as? String ?? ""

                if status == true {
                    completionBlock(true, msg)
                }else{
                    //AppManager.showToast(msg, view: topVCview)
                    completionBlock(nil, msg)
                }
            }else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: topVCview)
                completionBlock(nil, "")
            }
            
            DispatchQueue.main.async {
                AppManager.stopActivityIndicator(topVCview)
            }
        }
        DispatchQueue.main.async {
            AppManager.startActivityIndicator(sender: topVCview)
        }
    }
    
    func getSeasonWinningList(showLoader: Bool, completion completionBlock: @escaping (_ list: [SeasonWinning]?) -> Void) {

        guard let topVCview  = UIApplication.topViewController?.view else { return }
        let url = URLMethods.BaseURL + URLMethods().seasonWinning

        ApiClient.init().getRequest(method: url, parameters: [:], view: topVCview) { result in

            if result != nil {

                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "msg") as? String ?? ""

                if status == true, let data = result?.object(forKey: "results") as? [[String:Any]] {
                    
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                          let tblData = try? JSONDecoder().decode([SeasonWinning].self, from: jsonData) else {return }
                    
                    completionBlock(tblData)
                    
                }else{
                    AppManager.showToast(msg, view: topVCview)
                    completionBlock(nil)
                }
            }else{
                AppManager.showToast(ConstantMessages.somethingWrong, view: topVCview)
                completionBlock(nil)
            }

            if showLoader == true{
                AppManager.stopActivityIndicator(topVCview)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: topVCview)
        }
    }
    
    func startKYCRequest(params: [String: Any], completion completionBlock: @escaping (_ response: StartKYCResponse?) -> Void) {
        
        guard let topVCview  = UIApplication.topViewController?.view else { return }
        
        let url = URLMethods.BaseURL + URLMethods.startKYC
        
        ApiClient().postRequest(params, request: url, view: topVCview) { msg, result in
            
            if result != nil {
                
                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "msg") as? String ?? ""

                if status == true, let data = result?.object(forKey: "results") as? [String:Any] {
                    
                    
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                          let kycResponse = try? JSONDecoder().decode(StartKYCResponse.self, from: jsonData) else {return }
                    
                    completionBlock(kycResponse)
                    
                }else{
                    AppManager.showToast(msg, view: topVCview)
                    completionBlock(nil)
                }
            }else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: topVCview)
                completionBlock(nil)
            }
            
            DispatchQueue.main.async {
                AppManager.stopActivityIndicator(topVCview)
            }
        }
        DispatchQueue.main.async {
            AppManager.startActivityIndicator(sender: topVCview)
        }
    }
    
    func calculateGST(amount: Double, completion completionBlock: @escaping (_ response: TaxInfo?) -> Void) {
        
        guard let topVCview  = UIApplication.topViewController?.view else { return }
        
        let url = URLMethods.BaseURL + URLMethods.calculateGST
        let params = ["total_amount": amount]
        
        ApiClient.init().postRequest(params, request: url, view: topVCview) { msg, result in
            
            guard let result = result else {
                AppManager.showToast(ConstantMessages.somethingWrong, view: topVCview)
                completionBlock(nil)
                return
            }
            
            let status = result.object(forKey: "success") as? Bool ?? false
            let msg = result.object(forKey: "msg") as? String ?? ""

            if status == true, let data = result.object(forKey: "result") as? [String:Any] {
                
                guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                      let taxData = try? JSONDecoder().decode(TaxInfo.self, from: jsonData)else { return }
                completionBlock(taxData)
                
            } else {
                AppManager.showToast(msg, view: topVCview)
                completionBlock(nil)
            }
        }
    }
    
    func getInfluencersList(showLoader: Bool, completion completionBlock: @escaping (_ list: [InfluencersInfo]?) -> Void) {

        guard let topVCview  = UIApplication.topViewController?.view else { return }
        let url = URLMethods.BaseURL + URLMethods().influencersList

        ApiClient.init().getRequest(method: url, parameters: [:], view: topVCview) { result in

            if result != nil {

                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "msg") as? String ?? ""

                if status == true, let data = result?.object(forKey: "results") as? [[String:Any]] {
                    
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                          let tblData = try? JSONDecoder().decode([InfluencersInfo].self, from: jsonData) else {return }
                    
                    completionBlock(tblData)
                    
                }else{
                    AppManager.showToast(msg, view: topVCview)
                    completionBlock(nil)
                }
            }else{
                AppManager.showToast(ConstantMessages.somethingWrong, view: topVCview)
                completionBlock(nil)
            }

            if showLoader == true{
                AppManager.stopActivityIndicator(topVCview)
            }
        }
        if showLoader == true{
            AppManager.startActivityIndicator(sender: topVCview)
        }
    }
    
    func getAdminBanners(completion completionBlock: @escaping (_ user: AdminBannersResult?) -> Void){
        
        guard let topVCview  = UIApplication.topViewController?.view else { return }
        let url = URLMethods.BaseURL + URLMethods.adminBanners
        
        ApiClient().getRequest(method: url, parameters: [:], view: topVCview) { result in

            if result != nil {

                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "msg") as? String ?? ""

                if status == true, let data = result?.object(forKey: "results") as? [String:Any] {
                    
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                          let bannerData = try? JSONDecoder().decode(AdminBannersResult.self, from: jsonData) else {return }
                    
                    completionBlock(bannerData)
                    
                }else{
                    //AppManager.showToast(msg, view: topVCview)
                    debugPrint("Admin Banner Error = \(msg)")
                    completionBlock(nil)
                }
            }else{
                //AppManager.showToast(ConstantMessages.somethingWrong, view: topVCview)
                debugPrint("Admin Banner Error = \(ConstantMessages.somethingWrong)")
                completionBlock(nil)
            }
        }
    }
}



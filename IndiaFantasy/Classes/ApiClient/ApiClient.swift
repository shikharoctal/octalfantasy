//
//  ApiClient.swift
//  OlaDoctor
//
//  Created by Sourabh Sharma on 05/08/20.
//  Copyright © 2020 Octal. All rights reserved.
//

import UIKit
import Alamofire


// MARK: - Server side Methods serviceDetail
public struct URLMethods {

//    static let DomainURL                     = "https://api-india-fantasy.octallabs.com" //Staging
//    static let SocketDomainURL               = "https://socket-india-fantasy.octallabs.com/"//Socket
    
    
    static let DomainURL                     = "https://dev-api.indiasfantasy.com" //Staging
    static let SocketDomainURL               = "https://dev-socket.indiasfantasy.com/"//Socket
    
    
//    static let DomainURL                     = "https://api.indiasfantasy.com" //Production
//    static let SocketDomainURL               = "https://socket.indiasfantasy.com/"//Production
//    
    static let WebAppURL                     = "https://indiasfantasy.com/home"       //WebApp

    static let BaseURL                       = DomainURL + "/api/"
    static let URLVersion                    = "v1.1/"
    
    static let DeepLinkURL                   = "https://indiafantasy.page.link"
    
    static let referralWebAppLink            = WebAppURL + "sign-up?referral="
    static let contestInviteWebAppLink       = WebAppURL + "contestinvite?code="
    
    static let getTransactionsList           = "v2/users/account-statement"
    static let socialLogin                   = "users/social-login"
    static let verifyOTP                     = "users/verify-otp"
    static let verifyEmailOTP                = "\(URLVersion)fantasy/verify-email-otp"
    static let verifyEmail                   = "users/send-verify-email"
    static let getCountries                  = "users/countries"
    static let sendOTP                       = "users/send-otp"
    static let reSendOTP                     = "\(URLVersion)fantasy/resend-otp"
    static let register                      = "\(URLVersion)fantasy/register"
    static let login                         = "users/login"
    static let logout                        = "users/logout"
    static let deleteAccount                 = "users/delete-my-account"
    static let homebanner                    = "users/get-banners"
    static let getHomeBanner                 = "users/get-home-banners"
    static let verifyReferralCode            = "users/check-referal-code"
    static let getBottomBanner               = "users/get-bottom-banners"
    static let getNotifications              = "users/get-notification?"
    static let clearNotifications            = "users/clear-notification"
    static let readNotifications             = "users/read-notification"
    static let uploadImage                   = "users/profile"
    static let changePassword                = "users/change-password"
    static let updatePan                     = "users/pan-verification"
    static let sendAadharOTP                 = "users/send-otp-for-aadhar-verification"
    static let verifyAadharOTP               = "users/enter-otp-for-aadhar-verification"
    static let getProfile                    = "users/get-profile"
    static let getCommonDetails              = "users/get-comman-details"
    static let getUserAccountDetails         = "users/get-account-details"
    static let updateBankDetails             = "users/bank-verification"
    static let sendWithDrawRequest           = "v2/users/request-withdraw"
    static let applyCouppon                  = "users/apply-couppon"
    static let createTransactionId           = "users/create-transaction-v1"
    static let updateTransaction             = "users/update-transaction-v1"
    static let getCoupens                    = "users/get-coupons"
    static let getfaqs                       = "users/get-faqs"
    static let getUserRewards                = "users/rewards"
    static let getWithdrawlHistory           = "v2/users/get-withdrawal-list"
    static let sendContactRequest            = "users/contact-us"
    static let forgot_password               = "users/forgot-password"
    static let howToPlay_URL                 = "users/get-page-by-slug/how-to-play"
    static let HelpDesk_URL                  = "users/get-page-by-slug/help-desk"
    static let WorkWithUs_URL                = "users/get-page-by-slug/work-with-us"
    static let ContactUsWebView_URL          = "users/get-page-by-slug/contact-us"
    static let FantasyPointSystem_URL        = BaseURL + "admin/point-system"
    static let aboutUs                       = "users/get-page-by-slug/about-us"
    static let refundPolicy                  = "users/get-page-by-slug/refund-and-cancellation"
    static let contactUs                     = "page/contact-us"
    static let termsConditions               = "users/get-page-by-slug/terms-and-condition"
    static let privacyPolicy                 = "users/get-page-by-slug/privacy-policy"
    static let FAQ                           = "users/get-page-by-slug/faq"
    static let legality                      = "users/get-page-by-slug/legality"
    static let howToPlay                     = "users/get-page-by-slug/how-to-play"
    static let cricket                       = "users/get-page-by-slug/cricket"
    static let validateWithOtp               = "users/validate-with-otp"
    static let validateDocImg                = "users/validate-document-image"
    static let uploadPanImg                  = "users/upload-pan-image"
    static let getBankDetail                 = "users/get-bank-detail-by-ifsc"
    static let uploadCheque                  = "users/upload-cheque-image"
    static let uploadNID                     = "users/update-national-identity"
    static let getStates                     = "users/states"
    var joinContestCheckWallet               = "users/join-contest-check-wallet"
    static let getCaptcha                    = "users/get-captcha"
    static let addMoneyRequest               = "users/create-callpay-transaction"
    static let addMoneyInWallet              = "users/add-cash"
    static let startKYC                      = "users/start-kyc"
    static let calculateGST                  = "users/calculate-gst"
    static let adminBanners                  = "users/get-media-url"
    

    var saveMatchReminder                    = "fantasy/save-reminders"
    var getActiveMatchList                   = "fantasy/get-active-matches-list"
    var getMyMatchList                       = "fantasy/get-live-and-upcoming-matches"
    var getSeriesList                        = "fantasy/series-list"
    var getFantasyGames                      = "fantasy/get-fantasy-matches"
    var getMatchDetail                       = "fantasy/match-detail"
    var getJoinedMatchList                   = "fantasy/joined-matches-list"
    var getContestListByMatch                = "v1.1/fantasy/get-contest-list-byMatch-json"
    var getJoinedContests                    = "fantasy/joined-contest-list"
    var getContestDetail                     = "fantasy/get-contest-details"
    var getTeamList                          = "fantasy/player-team-list"
    var getPlayersList                       = "fantasy/get-players-list"
    var getSeriesPlayersList                 = "fantasy/get-series-player-list"
    var getScoreboard                        = "fantasy/live-score"
    var addEditTeam                          = "fantasy/create-team"
    var joinContest                          = "fantasy/join-contest"
//    var createContest                        = "\(URLVersion)fantasy/user-create-contest" // old
    
    var createContest                        = "fantasy/user-create-contest"
    
    var getCompleteProfile                   = "\(GDP.fantasyURLType)/complete-profile"
    var joinContestViaInviteCode             = "fantasy/apply-contest-invite-code"
    var getSeriesPlayerDetails               = "fantasy/series-player-details"
    var getPlayerStatsForSingleMatch         = "fantasy/player-stats-for-single-match"
    var getTeamScore                         = "fantasy/team-score"
    var getContestTeam                       = "fantasy/contest-team-pdf"
    var getEntryFees                         = "\(GDP.fantasyURLType)/get-entry-fees"
    var contestPriceBreakup                  = "\(GDP.fantasyURLType)/contest-prize-breakup"
    var dreamTeam                            = "\(GDP.fantasyURLType)/dream-team"
    var guruTeam                             = "\(GDP.fantasyURLType)/get-guru-team"
    var getRummyDetails                      = "\(GDP.fantasyURLType)/v1/hash"
    
    //Season League
    var leagueList                           = "\(GDP.fantasyURLType)/league/get-series-list"
    var leagueDetails                        = "\(GDP.fantasyURLType)/league/states"
    var leagueMatches                        = "\(GDP.fantasyURLType)/league/match-details"
    var leagueTopPlayers                     = "\(GDP.fantasyURLType)/league/get-top-players"
    var leaguePlayers                        = "\(GDP.fantasyURLType)/league/get-players-list"
    var leagueCreateEditTeam                 = "\(GDP.fantasyURLType)/league/create-team"
    var leagueTransferPreview                = "\(GDP.fantasyURLType)/league/transfer-preview"
    var getBoosterList                       = "\(GDP.fantasyURLType)/league/booster-list-by-team"
    var leaguePlayersList                    = "\(GDP.fantasyURLType)/league/get-players-list"
    
    var leagueAllContests                    = "\(GDP.fantasyURLType)/league/contest-list"
    var leaguejoinedContests                 = "\(GDP.fantasyURLType)/league/joined-contest-list"
    var leagueMyTeams                        = "\(GDP.fantasyURLType)/league/player-team-list"
    var leagueTransfersPoints                = "\(GDP.fantasyURLType)/league/matches"
    var leaguejoinContest                    = "\(GDP.fantasyURLType)/league/join_contest"
    var leagueContestLeaderboard             = "\(GDP.fantasyURLType)/league/get-leaderboard-data?page="
    var leagueSeriesPlayers                  = "\(GDP.fantasyURLType)/league/get-series-player-list"
    var leagueUnjoinedTeam                   = "\(GDP.fantasyURLType)/league/check-unjoined-team"
    var leagueTeamPreview                    = "\(GDP.fantasyURLType)/league/team-preview"
    
    
    var debuffContestList                    = "booster/getContestList"
    var contestTeamList                      = "booster/user-teamList?page="
    var debuffApply                          = "booster/applyDebuffBooster"
    var boosterTransfer                      = "booster/boosterTransfer"
    var boosterValidate                      = "booster/validate/booster"
    var boosterHistory                       = "booster/history?page="
    
    //Daily Contest Boosters
    var dailyContestBoosterList              = "\(URLVersion)fantasy/booster-list"
    var debuffDailyContestList               = "fantasy/getContestList"
    var dailyContestTeamList                 = "fantasy/user-teamList?page="
    var dailyContestDebuffApply              = "fantasy/applyDebuffBooster"
    var dailyContestBoosterTransfer          = "fantasy/boosterTransfer"
    var dailyContestTeamPreview              = "\(URLVersion)fantasy/team-preview"
    var dailyContestBoosterValidate          = "fantasy/validate/booster"
    var unUsedBoosterList                    = "fantasy/unUsed-booster"

    var leagueHistory                        = "users/league-history"
    var callPayPaymentMethods                = "users/get-available-callpay-services"
    var applyReferralCode                    = "users/apply-referral"
    var influencersList                      = "users/get-influencers"
    
    var poolCategoryList                     = "fantasy/get-category-list/"
    var poolMatchList                        = "fantasy/get-pool-match-list"
    var poolQuestionsList                    = "fantasy/get-questions-list?page="
    var joinPool                             = "fantasy/join-pool"
    var seasonWinning                        = "fantasy/get-winning-break-for-season"
}

public struct SocketEventNames {
    static let KSocket_EVENT_START_GAME      = "startGame"
    static let KSocket_EVENT_REFRESH         = "refresh"
    static let KSocket_EVENT_LIVE_SCORE      = "live_score"
//    static let KSocket_EVENT_KYC             = "idfy_resp"
    
    static let KSocket_EVENT_PAYMENT_SUCCESS = "payment_success"
    static let KSocket_EVENT_PAYMENT_FAILED  = "payment_failed"
    static var KSocket_EVENT_DEBUFF          = "team_debuffed_\(Constants.kAppDelegate.user?.id ?? "")"
    static var KSocket_EVENT_GIFT_BOOSTER    = "gift_booster_\(Constants.kAppDelegate.user?.id ?? "")"
}

// MARK: - API Call Methods
class ApiClient: NSObject {
    
    
    // MARK: - Get Post String
    func getPostString(params:[String:Any]) -> String {
        
        var data = [String]()
        for(key, value) in params
        {
            data.append(key + "=\(value)")
        }
        return data.map { String($0) }.joined(separator: "&")
    }
    
    
    // MARK: - Simple Post Request
    func postRequest(_ dict: [String:Any], request method: String?, view:UIView, completion completionBlock: @escaping (_ msg:String?, _ result: NSDictionary?) -> Void) {
        
        print("******************** Parameters =  ********************")
        print(dict)
        let requestURL = "\(method ?? "")"
        
        print("******************** URL =  ********************")
        print(requestURL)
        
        guard let serviceUrl = URL(string: requestURL) else { return }
            var request = URLRequest(url: serviceUrl)
            request.httpMethod = "POST"
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(GDP.fantasyType, forHTTPHeaderField: "game_type")
            request.setValue(GDP.leagueType, forHTTPHeaderField: "league_type")
        
        print("******************** Game Type  ********************")
        print(GDP.fantasyType)
        print("******************** League Type  ********************")
        print(GDP.leagueType)

//            if let appUser = UserDataModel.isLoggedIn() {
                if Constants.kAppDelegate.authToken != nil{
                    let authToken = Constants.kAppDelegate.authToken ?? ""
                    debugPrint("AuthToken = ",authToken)
                    request.setValue(authToken, forHTTPHeaderField: "x-access-token")
                }
//            }
            guard let httpBody = try? JSONSerialization.data(withJSONObject: dict, options: []) else {
                return
            }
            request.httpBody = httpBody
            request.timeoutInterval = 30
        
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 30.0
            sessionConfig.timeoutIntervalForResource = 30.0
        
            let session = URLSession(configuration: sessionConfig, delegate: self as? URLSessionDelegate, delegateQueue: OperationQueue.main)
            let task = session.dataTask(with: request) { (data, response, error) in
                guard let data = data, let _:URLResponse = response, error == nil else {
                  print("error")

                  // AppManager.showToast(error!.localizedDescription, view: view)
                  completionBlock(error!.localizedDescription, nil)
                  return
              }
              let dataString =  String(data: data, encoding: String.Encoding.utf8)
              print(dataString ?? "")

              guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {

                  //  AppManager.showToast(ConstantMessages.somethingWrong, view: view)
                  completionBlock(ConstantMessages.somethingWrong, nil)
                  return
              }
              //  print(json as Any)
                
               let status = json.object(forKey: "success") as? Bool ?? false
               print(json as Any)
                
                if let httpResponse = response as? HTTPURLResponse{
                    print(httpResponse.statusCode)
                    
                    if httpResponse.statusCode != 200 {
                        if httpResponse.statusCode == 403{
                            Constants.kAppDelegate.showAlert(msg: json.object(forKey: "msg") as? String ?? "", isLogout: true, isLocationAlert: false)
                        }else{
                            completionBlock(json.object(forKey: "msg") as? String ?? "",nil)
                        }
                    }else{
                        if status == true {
                            completionBlock(json.object(forKey: "msg") as? String ?? "",json)
                        }else {
                            completionBlock(json.object(forKey: "msg") as? String ?? "", json)
                        }
                    }
                }
               
        }
           task.resume()
    }
    
    func postRequestFilter( dict: [String:Any], request method: String?, view:UIView, completion completionBlock: @escaping ( _ msg:String?, _ result: NSDictionary?) -> Void) {
            var request = URLRequest(url: URL(string: method ?? "")!,timeoutInterval: Double.infinity)
            request.addValue("Bearer \(Constants.kAppDelegate.authToken ?? "")", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(GDP.fantasyType, forHTTPHeaderField: "game_type")

            request.httpMethod = "POST"
            let finalRequest = self.finalRequest(from: dict)
        
            let postJson = AppManager.init().json(from: finalRequest.parameters) ?? ""
                 print("******************* Post *******************\n\(postJson )")
            request.httpBody = postJson.data(using: .utf8)

            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data, let _:URLResponse = response, error == nil else {
                    // AppManager.showToast(error!.localizedDescription, view: view)
                    completionBlock(error!.localizedDescription, nil)
                    return
                }
                let dataString =  String(data: data, encoding: String.Encoding.utf8)
                print(dataString ?? "")
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                    //  AppManager.showToast(ConstantMessages.somethingWrong, view: view)
                    completionBlock(ConstantMessages.somethingWrong, nil)
                    return
                }
                let status = json.object(forKey: "success") as? Bool ?? false
                print(json as Any)
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        if httpResponse.statusCode == 403{
                            Constants.kAppDelegate.showAlert(msg: json.object(forKey: "msg") as? String ?? "", isLogout: true, isLocationAlert: false)
                        } else {
                            completionBlock(json.object(forKey: "msg") as? String ?? "",nil)
                        }
                    } else {
                        if status == true {
                            completionBlock(json.object(forKey: "msg") as? String ?? "",json)
                        } else {
                            completionBlock(json.object(forKey: "msg") as? String ?? "", json)
                        }
                    }
                }
                
            }
            task.resume()
        }
    
    // MARK: - Typical Post Request
    func typicalPostRequest(_ dict: [String:Any], request method: String?, view:UIView, completion completionBlock: @escaping (_ msg:String?, _ result: NSDictionary?) -> Void) {
        
        
        let requestURL = "\(method ?? "")"
        guard let serviceUrl = URL(string: requestURL) else { return }
            var request = URLRequest(url: serviceUrl)
            request.httpMethod = "POST"
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(GDP.fantasyType, forHTTPHeaderField: "game_type")

//            if let appUser = UserDataModel.isLoggedIn() {
                 if Constants.kAppDelegate.authToken != nil{
                     let authToken = Constants.kAppDelegate.authToken ?? ""
                     request.setValue(authToken, forHTTPHeaderField: "x-access-token")
                 }
//             }
            guard let httpBody = try? JSONSerialization.data(withJSONObject: dict, options: []) else {
                return
            }
            request.httpBody = httpBody
            request.timeoutInterval = 20
        
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 30.0
            sessionConfig.timeoutIntervalForResource = 30.0
        
            let session = URLSession(configuration: sessionConfig, delegate: self as? URLSessionDelegate, delegateQueue: OperationQueue.main)  
            let task = session.dataTask(with: request) { (data, response, error) in
                guard let data = data, let _:URLResponse = response, error == nil else {
                  print("error")

                  // AppManager.showToast(error!.localizedDescription, view: view)
                  completionBlock(error!.localizedDescription, nil)
                  return
              }
              let dataString =  String(data: data, encoding: String.Encoding.utf8)
              print(dataString ?? "")

              guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {

                  //  AppManager.showToast(ConstantMessages.somethingWrong, view: view)
                  completionBlock(ConstantMessages.somethingWrong, nil)
                  return
              }
              //  print(json as Any)
              completionBlock(json.object(forKey: "message") as? String ?? "",json)
            }
           task.resume()
    }
    
    
    func patchRequest(_ dict: [String:Any], request method: String?, view:UIView, completion completionBlock: @escaping (_ msg:String?, _ result: NSDictionary?) -> Void) {
        
        let finalRequest = self.finalRequest(from: dict)
        
        print(finalRequest.parameters)
        
        let post = self.getPostString(params: finalRequest.parameters)
        print(post)
        let postJson = AppManager.init().json(from: finalRequest.parameters) ?? ""
        print("******************** Post ********************\n\(postJson )")
        print(dict)
        
        //TODO: Shikhar
        //let postData = post.data(using: .ascii, allowLossyConversion: true)
        let postData = post.data(using: .utf8)
        let postLength = String(format: "%lu", UInt(post.count ))
        
        let requestURL = "\(method ?? "")"
        print("******************** Url =  ********************\n\(requestURL)")
        var request: NSMutableURLRequest? = nil
        if let url = URL(string: requestURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed) ?? "") {
            request = NSMutableURLRequest(url: url)
            request?.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//            if let appUser = UserDataModel.isLoggedIn() {
                if Constants.kAppDelegate.authToken != nil{
                    let authToken = Constants.kAppDelegate.authToken ?? ""
                    request?.setValue(authToken, forHTTPHeaderField: "x-access-token")
                }
//            }
        }
        
        request?.httpMethod = "PATCH"
        request?.setValue(postLength, forHTTPHeaderField: "Content-Length")
        request?.httpBody = postData
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 30.0
        sessionConfig.httpAdditionalHeaders = finalRequest.headers
        
        let session = URLSession(configuration: sessionConfig, delegate: self as? URLSessionDelegate, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request! as URLRequest) {
            (
                data, response, error) in
            
            guard let data = data, let _:URLResponse = response, error == nil else {
                print("error")
                
                // AppManager.showToast(error!.localizedDescription, view: view)
                completionBlock(error!.localizedDescription, nil)
                return
            }
            let dataString =  String(data: data, encoding: String.Encoding.utf8)
            print(dataString ?? "")
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                
                //  AppManager.showToast(ConstantMessages.somethingWrong, view: view)
                completionBlock(ConstantMessages.somethingWrong, nil)
                return
            }
            //  print(json as Any)
            
            if let httpResponse = response as? HTTPURLResponse{
                print(httpResponse.statusCode)
                
                if httpResponse.statusCode != 200 {
                    completionBlock(json.object(forKey: "message") as? String ?? "",nil)
                }else{
                    completionBlock(json.object(forKey: "message") as? String ?? "",json)
                }
            }
            
          
        }
        task.resume()
    }
    
    func putRequest(_ dict: [String:Any], request method: String?, view:UIView, completion completionBlock: @escaping (_ msg:String?, _ result: NSDictionary?) -> Void) {
        
        let requestURL = "\(method ?? "")"
        guard let serviceUrl = URL(string: requestURL) else { return }
            var request = URLRequest(url: serviceUrl)
            request.httpMethod = "PUT"
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(GDP.fantasyType, forHTTPHeaderField: "game_type")

//            if let appUser = UserDataModel.isLoggedIn() {
                 if Constants.kAppDelegate.authToken != nil{
                     let authToken = Constants.kAppDelegate.authToken ?? ""
                     request.setValue(authToken, forHTTPHeaderField: "x-access-token")
                 }
//             }
            guard let httpBody = try? JSONSerialization.data(withJSONObject: dict, options: []) else {
                return
            }
            request.httpBody = httpBody
            request.timeoutInterval = 20
        
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 30.0
            sessionConfig.timeoutIntervalForResource = 30.0
        
            let session = URLSession(configuration: sessionConfig, delegate: self as? URLSessionDelegate, delegateQueue: OperationQueue.main)
            let task = session.dataTask(with: request) { (data, response, error) in
                guard let data = data, let _:URLResponse = response, error == nil else {
                  print("error")

                  // AppManager.showToast(error!.localizedDescription, view: view)
                  completionBlock(error!.localizedDescription, nil)
                  return
              }
              let dataString =  String(data: data, encoding: String.Encoding.utf8)
              print(dataString ?? "")

              guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {

                  //  AppManager.showToast(ConstantMessages.somethingWrong, view: view)
                  completionBlock(ConstantMessages.somethingWrong, nil)
                  return
              }
              //  print(json as Any)
              completionBlock(json.object(forKey: "message") as? String ?? "",json)
            }
           task.resume()
    }
    
    // MARK: - Get Request
    func getRequest(method: String?,parameters: [String: Any], view:UIView, completion completionBlock: @escaping (_ result: NSDictionary?) -> Void) {
        
        
        let requestURL = "\(method ?? "")"
        print("******************** Url =  ********************\n\(requestURL)")
        
        print("******************** Parameters =  ********************\n\(parameters)")

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        sessionConfig.timeoutIntervalForResource = 60.0
        
        var components = URLComponents(string: requestURL)!
           components.queryItems = parameters.map { (key, value) in
               URLQueryItem(name: key, value: value as? String)
           }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")

        
        let session = URLSession(configuration: sessionConfig, delegate: self as? URLSessionDelegate, delegateQueue: OperationQueue.main)
        
        
        var request = URLRequest(url: components.url!)
        debugPrint(components.url ?? "")
        debugPrint("game_type = \(GDP.fantasyType)")
        debugPrint("league_type = \(GDP.leagueType)")
        request.setValue(GDP.fantasyType, forHTTPHeaderField: "game_type")
        request.setValue(GDP.leagueType, forHTTPHeaderField: "league_type")

//        if let appUser = UserDataModel.isLoggedIn() {
            if Constants.kAppDelegate.authToken != nil{
                let authToken = Constants.kAppDelegate.authToken ?? ""
                debugPrint("AuthToken = ",authToken)
                request.setValue(authToken, forHTTPHeaderField: "x-access-token")
            }
//        }
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request as URLRequest) {
            (
                data, response, error) in
            
            guard let data = data, let _:URLResponse = response, error == nil else {
                print("error")
                AppManager.showToast(error!.localizedDescription, view: view)
                completionBlock(nil)
                return
            }
            let dataString =  String(data: data, encoding: String.Encoding.utf8)
            print(dataString ?? "")
            
            guard let json = try? (JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary) else {
                
              //  AppManager.showToast(ConstantMessages.somethingWrong, view: view)
                completionBlock(nil)
                return
            }
            print(json as Any)
            
           
            completionBlock(json)
            
//            let status = json.object(forKey: "status") as? Int ?? 0
//
//            if status == 1 {
//                completionBlock(json)
//            } else {
//                completionBlock(nil)
//                AppManager.showToast(json.object(forKey: "message") as? String ?? "", view: view)
//            }
            
            
        }
        task.resume()
    }
    
    // MARK: - MultipartRequestNSURL
    func postMultipartRequest(_ dict: [String:Any], imageData: Data?, request method: String?, imageName: String, view:UIView, completion completionBlock: @escaping (_ msg: String?, _ result: NSDictionary?) -> Void) {
        
        let finalRequest = self.finalRequest(from: dict)
        
    
        
        let urlString           = NSString(format: "%@",method!)
        print("******* Request URL *******\n",urlString)
        print("******* Paremeters ********\n",finalRequest.parameters)
        // _ = try! JSONSerialization.data(withJSONObject: finalRequest.parameters, options: .prettyPrinted)
        
        var request = URLRequest(url: URL(string: urlString as String)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)
        request.setValue(GDP.fantasyType, forHTTPHeaderField: "game_type")

//        if let appUser = UserDataModel.isLoggedIn() {
            if Constants.kAppDelegate.authToken != nil{
                let authToken = Constants.kAppDelegate.authToken ?? ""
                request.setValue(authToken, forHTTPHeaderField: "x-access-token")
            }
//        }
        request.httpMethod = "POST"
        
        var body = Data()
        let boundary: String = "0xKhTmLbOuNdArY"
        let kNewLine: String = "\r\n"
        let contentType: String = "multipart/form-data; boundary=\(boundary)"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(GDP.fantasyType, forHTTPHeaderField: "game_type")

        request.allHTTPHeaderFields = (finalRequest.headers as! [String : String])
        
        
        
        // Add the parameters from the dictionary to the request body
        for dict in finalRequest.parameters {
            
            let val = dict.key
            let str = "\(dict.value)"
            // Add the parameters from the dictionary to the request body
            body.append("--\(boundary)\(kNewLine)".data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition: form-data; name=\(val)".data(using: String.Encoding.utf8)!)
            // For simple data types, such as text or numbers, there's no need to set the content type
            body.append("\(kNewLine)\(kNewLine)".data(using: String.Encoding.utf8)!)
            body.append(str.data(using: .utf8)!)
            body.append(kNewLine.data(using: String.Encoding.utf8)!)
        }
        
        
        // Add the image to the request body
        if imageData != nil {
            body.append("--\(boundary)\(kNewLine)".data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition: form-data; name=\(imageName); filename=\(imageName).jpg; Content-Type:\(imageName)/jpeg;".data(using: String.Encoding.utf8)!)
            body.append("\(kNewLine)\(kNewLine)".data(using: String.Encoding.utf8)!)
            body.append(imageData!)
            body.append(kNewLine.data(using: String.Encoding.utf8)!)
            
        }
        // Add the terminating boundary marker to signal that we're at the end of the request body
        body.append("--\(boundary)--".data(using: String.Encoding.utf8)!)
        
        request.httpBody = body;
        
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        sessionConfig.timeoutIntervalForResource = 60.0
        sessionConfig.httpAdditionalHeaders = finalRequest.headers
        
        let session = URLSession(configuration: sessionConfig, delegate: self as? URLSessionDelegate, delegateQueue: OperationQueue.main)
        
        let task = session.dataTask(with: request as URLRequest) {
            (
                data, response, error) in
            
            guard let data = data, let _:URLResponse = response, error == nil else {
                print("error")
                AppManager.showToast(error!.localizedDescription, view: view)
                completionBlock(error!.localizedDescription, nil)
                return
            }
            let dataString =  String(data: data, encoding: String.Encoding.utf8)
            print(dataString ?? "")
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                
                AppManager.showToast(ConstantMessages.somethingWrong, view: view)
                completionBlock(ConstantMessages.somethingWrong, nil)
                return
            }
            print(json as Any)
                      
            completionBlock(json.object(forKey: "message") as? String ?? "", json)

            
        }
        task.resume()
    }
    
    
    // MARK: - MultipartArrayRequestNSURL
    func postMultipartArrayRequest(_ dict: [String:Any], imageData: [Data], request method: String?, imageName: [String], view: UIView, completion completionBlock: @escaping (_ msg: String?, _ result: NSDictionary?) -> Void) {
        
        let finalRequest = self.finalRequest(from: dict)
        
        
        let urlString           = NSString(format: "%@",method!)
        print("******* Request URL *******\n",urlString)
        print("******* Paremeters ********\n",finalRequest.parameters)
        // _ = try! JSONSerialization.data(withJSONObject: finalRequest.parameters, options: .prettyPrinted)
        
        var request = URLRequest(url: URL(string: urlString as String)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60)
        request.setValue(GDP.fantasyType, forHTTPHeaderField: "game_type")

//        if let appUser = UserDataModel.isLoggedIn() {
            if Constants.kAppDelegate.authToken != nil{
                let authToken = Constants.kAppDelegate.authToken ?? ""
                request.setValue(authToken, forHTTPHeaderField: "x-access-token")
            }
//        }
        
        request.httpMethod = "POST"
        
        var body = Data()
        let boundary: String = "0xKhTmLbOuNdArY"
        let kNewLine: String = "\r\n"
        let contentType: String = "multipart/form-data; boundary=\(boundary)"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(GDP.fantasyType, forHTTPHeaderField: "game_type")

        request.allHTTPHeaderFields = (finalRequest.headers as! [String : String])
        
        // Add the parameters from the dictionary to the request body
        for dict in finalRequest.parameters {
            
            let val = dict.key
            let str = "\(dict.value)"
            // Add the parameters from the dictionary to the request body
            body.append("--\(boundary)\(kNewLine)".data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition: form-data; name=\(val)".data(using: String.Encoding.utf8)!)
            // For simple data types, such as text or numbers, there's no need to set the content type
            body.append("\(kNewLine)\(kNewLine)".data(using: String.Encoding.utf8)!)
            body.append(str.data(using: .utf8)!)
            body.append(kNewLine.data(using: String.Encoding.utf8)!)
        }
        
        // Add the image to the request body
        if imageData.count > 0 && imageName.count > 0{
            for i in 0..<imageData.count {
                let images = imageData[i]
                let imageName = imageName[i]
                body.append("--\(boundary)\(kNewLine)".data(using: String.Encoding.utf8)!)
                // body.append("Content-Disposition: form-data; name=custom_job_images[]; filename=\(imageName).jpeg; Content-Type:\(imageName)/jpeg;".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition: form-data; name=\(imageName); filename=\(imageName).jpeg; Content-Type:\(imageName)/jpeg;".data(using: String.Encoding.utf8)!)
                body.append("\(kNewLine)\(kNewLine)".data(using: String.Encoding.utf8)!)
                body.append(images as Data)
                body.append(kNewLine.data(using: String.Encoding.utf8)!)
            }
        }
        // Add the terminating boundary marker to signal that we're at the end of the request body
        body.append("--\(boundary)--".data(using: String.Encoding.utf8)!)
        
        request.httpBody = body;
        
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        sessionConfig.timeoutIntervalForResource = 60.0
        sessionConfig.httpAdditionalHeaders = finalRequest.headers
        
        let session = URLSession(configuration: sessionConfig, delegate: self as? URLSessionDelegate, delegateQueue: OperationQueue.main)
        
        let task = session.dataTask(with: request as URLRequest) {
            (
                data, response, error) in
            
            guard let data = data, let _:URLResponse = response, error == nil else {
                print("error")
                AppManager.showToast(error!.localizedDescription, view: view)
                completionBlock(error!.localizedDescription, nil)
                return
            }
            let dataString =  String(data: data, encoding: String.Encoding.utf8)
            print(dataString ?? "")
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                
                AppManager.showToast(ConstantMessages.somethingWrong, view: view)
                completionBlock(ConstantMessages.somethingWrong, nil)
                return
            }
            
            print(json as Any)
            
            let status = json.object(forKey: "status") as? Bool ?? false
            
            if status == true {
                completionBlock(json.object(forKey: "message") as? String ?? "", json)
            } else {
                completionBlock(json.object(forKey: "message") as? String ?? "", nil)
                AppManager.showToast(json.object(forKey: "message") as? String ?? "", view: view)
            }
        }
        task.resume()
    }
    
    
    // MARK: - FinalRequest
    private func finalRequest(from parameters: [String:Any]) -> (parameters: [String:Any], headers: [String:Any]) {
        
        
        var params = [String:Any]()
        params = parameters
        /// Configure Headers
        let headers = [String : String]()
        
     
        
        let finalParameters = params.merged(with: Constants.kAppInfo)
        
   
        return (finalParameters, headers)
        
    }
    
}

import Foundation
import SystemConfiguration
public class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
}
extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

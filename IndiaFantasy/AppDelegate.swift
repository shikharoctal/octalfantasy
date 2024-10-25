//
//  AppDelegate.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 02/03/22.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import Firebase
import FirebaseMessaging
import UserNotifications
import FirebaseDynamicLinks
import DropDown
import Toast_Swift
import FBSDKCoreKit
import AppTrackingTransparency

var isSocketConnected = ""
var isSocketReconnected = false
var GDP = GlobalDataPersistance.shared

@main

class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate,MessagingDelegate {

    var window: UIWindow?
    var deviceTokenString = "1221212"
    var myOrientation: UIInterfaceOrientationMask = .portrait
    var isFromDeepLink = false
    var responseMessage = ""
    var userInfoDic = [String : Any]()
    var authToken:String? = nil
    var tabbarController:TabBarVC? = nil
    var isRemoteNotificationLaunch = false
    var notificationType:String? = nil
    var notificationUserInfo:[AnyHashable: Any] = [:]
    
    var deepLinkURL = ""
    var referralCode = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UITabBar.appearance().backgroundImage = UIImage(named: "top_banner")
        ToastManager.shared.style.titleFont = UIFont(name: customFontSemiBold, size: 16.0)!
        ToastManager.shared.style.messageFont = UIFont(name: customFontRegular, size: 16.0)!
        ToastManager.shared.style.backgroundColor = UIColor.appHighlightedTextColor
        ToastManager.shared.style.titleColor = UIColor.black
        ToastManager.shared.style.messageColor = UIColor.black
        
        ApplicationDelegate.shared.application(application,didFinishLaunchingWithOptions: launchOptions)
        ApplicationDelegate.shared.initializeSDK()
        //self.perform(#selector(requestPermission), with: self, afterDelay: 5.0)
        
        DropDown.startListeningToKeyboard()
        //print(LocationManager.sharedInstance.latitude)

        window = UIWindow.init(frame: UIScreen.main.bounds)
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        IQKeyboardManager.shared.enable = true
        
        FirebaseApp.configure()
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self
            
          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self

        let remoteNotif = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any]
        swichToSplash()
        if remoteNotif != nil {
            debugPrint("remoteNotification", remoteNotif ?? [:])
            notificationUserInfo = remoteNotif ?? [:]
            notificationType = (remoteNotif?["type"] as? String) ?? ""
            isRemoteNotificationLaunch = true
       }
        
        return true
    }
    

    func application(_ app: UIApplication,open url: URL,options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            // Handle the deep link. For example, show the deep-linked content or
            // apply a promotional offer to the user's account.
            // ...
            print(dynamicLink)
            return true
        }
        
        return ApplicationDelegate.shared.application(app,open: url,sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

      let handled = DynamicLinks.dynamicLinks()
        .handleUniversalLink(userActivity.webpageURL!) { dynamiclink, error in
            
            self.isFromDeepLink = true
            self.deepLinkURL = dynamiclink?.url?.absoluteString ?? ""
        }

      return handled
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("Entering in foreground")
        //LocationManager.sharedInstance.locationManager.startUpdatingLocation()
        self.perform(#selector(callForeGroundDeepLinkMethod), with: self, afterDelay: 1.0)
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {

        if var topController = UIApplication.shared.windows.last?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            let nv:UINavigationController? = topController as? UINavigationController
            if nv != nil{
                if nv?.viewControllers.last is TabBarVC{
                    if let tabbarVC = nv?.viewControllers.last as? TabBarVC{
                        if tabbarVC.selectedIndex == 0{
                            if let tabNvs = tabbarVC.children as? [UINavigationController]{
                                if let firstNv = tabNvs.first{
                                    if firstNv.viewControllers.last is RummyWebViewController{
                                        return UIInterfaceOrientationMask.all
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return UIInterfaceOrientationMask.portrait
    }
    
    @objc func callForeGroundDeepLinkMethod(){
        if self.isFromDeepLink == true {
            self.isFromDeepLink = false
            if var topController = UIApplication.shared.windows.last?.rootViewController {
               while let presentedViewController = topController.presentedViewController {
                   topController = presentedViewController
               }
                
               
                let nv:UINavigationController? = topController as? UINavigationController
                if nv != nil{
                    self.handleDeepLinking(url: self.deepLinkURL, controller: nv?.viewControllers.last)
                }else {
                    self.handleDeepLinking(url: self.deepLinkURL, controller: nv?.viewControllers.last)
                }
           }
        }
    }
    
    
    func startSocketConnection() {
           SocketIOManager.sharedInstance.establishConnection()
    }
    
    func handleDeepLinking(url:String, controller:UIViewController?){
        if url.contains("inviteCode"){
            
            guard UserDataModel.isLoggedIn() != nil else { return }
            if let inviteCode = url.components(separatedBy: "=").last{
                self.joinContest(inviteCode: inviteCode)
//                let pushVC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "JoinContestViewController") as! JoinContestViewController
//                pushVC.inviteCode = inviteCode
//                controller?.navigationController?.pushViewController(pushVC, animated: true)
            }
        }
        if url.contains("referralCode"){
            if let appUser = UserDataModel.isLoggedIn() {
                print("\(appUser) Already logged in")
                
                guard appUser.isUsedReferral == false else { return }
                
                if let inviteCode = url.components(separatedBy: "=").last {
                    guard let vc = Constants.KLoginSignupStoryboard.instantiateViewController(withIdentifier: "ReferralCodeViewController") as? ReferralCodeViewController else {return}
                    vc.referralCode = inviteCode
                    
                    self.window?.rootViewController?.dismiss(animated: false, completion: {
                        if let topVC  = UIApplication.topViewController {
                            topVC.present(vc, animated: true, completion: nil)
                        }
                    })
                }
                
            }else{
                if let inviteCode = url.components(separatedBy: "=").last{
//                    let pushVC = Constants.KLoginSignupStoryboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
//                    pushVC.referralCode = inviteCode
//                    pushVC.isFromDeepLink = true
//                    //controller?.navigationController?.pushViewController(pushVC, animated: true)
//                    self.window?.rootViewController?.dismiss(animated: false, completion: {
//                        if let topVC  = UIApplication.topViewController {
//                            topVC.navigationController?.pushViewController(pushVC, animated: true)
//                        }
//                    })
                }
            }
            
        }
        
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        deviceTokenString = fcmToken ?? ""
        debugPrint("FCM Token = ", deviceTokenString)
        //let dataDict:[String: String] = ["token": fcmToken]
        // NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
   
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print(token)
        Messaging.messaging().apnsToken = deviceToken
    }
    //MARK: UNUserNotification Delegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        if var topController = UIApplication.shared.windows.last?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
             print(notification.request.content.userInfo["type"] ?? "" )
            
            let type = notification.request.content.userInfo["type"] ?? ""
                let nv:UINavigationController? = topController as? UINavigationController
                if nv != nil{
                    self.handlePresentedEvents(type: type as! String, controller: nv?.viewControllers.last)
                }
        }
        completionHandler([.alert, .sound, .badge])
       // completionHandler(UNNotificationPresentationOptions.alert)
        //required to show notification when in foreground
    }

    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if var topController = UIApplication.shared.windows.last?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
             print(response.notification.request.content.userInfo)
            let userInfo = response.notification.request.content.userInfo
            
            let type = response.notification.request.content.userInfo["type"] ?? ""
                let nv:UINavigationController? = topController as? UINavigationController
                if nv != nil{
                    self.handlePush(type: type as! String, controller: nv?.viewControllers.last, userInfo: userInfo)
                }else {
                    self.handlePush(type: type as! String, controller: nv?.viewControllers.last, userInfo: userInfo)
                }
        }
        completionHandler()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {

        if isRemoteNotificationLaunch == true {
            //isRemoteNotificationLaunch = false
            if var topController = UIApplication.shared.windows.last?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                
                 let nv:UINavigationController? = topController as? UINavigationController
                 if nv != nil{
                     self.handlePush(type: notificationType ?? "", controller: nv?.viewControllers.last, userInfo: notificationUserInfo)
                 }
            }
        }
        
//        if !SocketIOManager.sharedInstance.isSocketConnected() {
//            SocketIOManager.sharedInstance.establishConnection()
//        }
        SocketIOManager.sharedInstance.reconnect()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        SocketIOManager.sharedInstance.closeConnection()
    }
    
    func handlePush(type:String, controller:UIViewController?, userInfo: [AnyHashable: Any]) {
        
        if type == "cricket_contest"{
            tabbarController?.selectedIndex = 1
        }
        
        if type == "wallet_deposit" || type == "sign_in_bonus"{
            if let tabbarController = self.tabbarController {
                if tabbarController.selectedIndex == 4{
                    controller?.navigationController?.popToRootViewController(animated: true)
                }else{
                    tabbarController.selectedIndex = 4
                }
            }
        }
        if type == "debuff" {

            if self.isRemoteNotificationLaunch == true {
                return
            }
            
            self.appliedBoosterPopUp(userInfo: userInfo)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.kRefreshTopNavigation), object: nil, userInfo: nil)
    }
    
    func appliedBoosterPopUp(userInfo: [AnyHashable: Any]) {
        
        let pushVC = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "DebuffAppliedVC") as! DebuffAppliedVC
        pushVC.bannerImg = userInfo["bannerImage"] as? String ?? ""
        pushVC.bannerTitle = userInfo["bannerText"] as? String ?? ""
        pushVC.modalPresentationStyle = .overCurrentContext
        pushVC.completion = {

            let leagueType = userInfo["leagueType"] as? String ?? "pro"
            let leagueName = userInfo["leagueName"] as? String ?? ""
            let seriesId = userInfo["series_id"] as? String ?? ""
            let matchType = userInfo["match_type"] as? String ?? ""
            let contestType = userInfo["contestType"] as? String ?? ""
            
            switch matchType.lowercased() {
            case "cricket":
                GDP.switchToCricket()
                break
            default:
                break
            }
            
            if contestType == "daily" {
                
                guard let controller = UIApplication.topViewController else { return }
                
                let matchId = userInfo["match_id"] as? String ?? ""
                
                WebCommunication.shared.getMatchDetail(hostController: controller, match_id: Int(matchId) ?? 0, showLoader: true) { match in
                    
                    guard let match = match else { return }
                    
                    if match.match_status?.uppercased() == "NOT STARTED" || match.match_status?.uppercased() == "UPCOMING" || (match.match_status?.uppercased() ?? "") == "FIXTURE"{
                        
                        let vc = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "MatchContestViewController") as! MatchContestViewController
                        vc.isMyGames = true
                        GDP.selectedMatch = match
                        
                        self.window?.rootViewController?.dismiss(animated: false, completion: {
                            if let topVC  = UIApplication.topViewController {
                                topVC.navigationController?.pushViewController(vc, animated: true)
                            }
                        })
                        
                    }else{
    
                        if (match.match_status?.uppercased() ?? "") == "CANCELLED"{
                            return
                        }
                        let vc = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "LiveContestViewController") as! LiveContestViewController
                        GDP.selectedMatch = match
                        
                        self.window?.rootViewController?.dismiss(animated: false, completion: {
                            if let topVC  = UIApplication.topViewController {
                                topVC.navigationController?.pushViewController(vc, animated: true)
                            }
                        })
                    }
                }
                
            }else {
                let vc = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonsTabBarVC") as! SeasonsTabBarVC
                GDP.leagueType = leagueType
                GDP.leagueSeriesId = seriesId
                GDP.leagueName = leagueName
                
                self.window?.rootViewController?.dismiss(animated: false, completion: {
                    if let topVC  = UIApplication.topViewController {
                        topVC.navigationController?.pushViewController(vc, animated: true)
                    }
                })
            }
        }
        
        self.window?.rootViewController?.dismiss(animated: false, completion: {
            if let topVC  = UIApplication.topViewController {
                topVC.present(pushVC, animated: false, completion: nil)
            }
        })
    }
    
    
    func handlePresentedEvents(type:String, controller:UIViewController?){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.kUpdateTopNavigation), object: nil, userInfo: nil)

        if type == "lineup_out"{
            if tabbarController?.selectedIndex == 0{
                if (tabbarController?.selectedViewController?.navigationController?.viewControllers.count ?? 0) == 2{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.kRefreshLineUp), object: nil, userInfo: nil)
                }else{
                    print("No need to refresh")
                }
            }
        }
        
        if type == "free_cash"{
            if tabbarController?.selectedIndex == 4{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.kRefreshAccountDetails), object: nil, userInfo: nil)
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.kRefreshTopNavigation), object: nil, userInfo: nil)

    }
    
    func showAlert(msg:String, isLogout:Bool, isLocationAlert:Bool){
        var topWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
        topWindow?.rootViewController = UIViewController()
        topWindow?.windowLevel = UIWindow.Level.alert + 1

        let alert = UIAlertController(title: Constants.kAppDisplayName, message:msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized(), style: .cancel) { _ in
            // continue your work
            if isLogout == true{
                self.logOutApp()
            }
            else if isLocationAlert == true{
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            }
            // important to hide the window after work completed.
            // this also keeps a reference to the window until the action is invoked.
            topWindow?.isHidden = true // if you want to hide the topwindow then use this
            topWindow = nil // if you want to hide the topwindow then use this
         })

        topWindow?.makeKeyAndVisible()
        topWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

extension AppDelegate{
    // MARK:- Switch To Home
    func swichToLogin()  {
        let VC = Constants.KLoginSignupStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let nvc = UINavigationController(rootViewController: VC)
        nvc.isNavigationBarHidden = true
        self.window?.rootViewController = nvc
        self.window?.makeKeyAndVisible()
    }
    
    func swichToSignUp()  {
        let VC = Constants.KLoginSignupStoryboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        let nvc = UINavigationController(rootViewController: VC)
        nvc.isNavigationBarHidden = true
        self.window?.rootViewController = nvc
        self.window?.makeKeyAndVisible()
    }
    
    // MARK:- Switch To Splash
    func swichToSplash()  {
        let VC = Constants.kWelcomStoryboard.instantiateViewController(identifier: "SplashViewController") as! SplashViewController
        let nvc = UINavigationController(rootViewController: VC)
        nvc.isNavigationBarHidden = true
        self.window?.rootViewController = nvc
        self.window?.makeKeyAndVisible()
    }
    
    // MARK:- Switch To Dashboard
    func swichToHome()  {
        if tabbarController == nil{
            tabbarController = Constants.KTabbarStoryboard.instantiateViewController(identifier: "TabBarVC") as? TabBarVC
        }else{
            if let nv = tabbarController?.viewControllers?.first as? UINavigationController{
                nv.popToRootViewController(animated: false)
            }
        }
        tabbarController?.selectedIndex = 0
        let nvc = UINavigationController(rootViewController: tabbarController!)
        nvc.isNavigationBarHidden = true
        self.window?.rootViewController = nvc
        self.window?.makeKeyAndVisible()
    }
    
    // MARK:- Switch To Welcome
    func swichToWelcome()  {
        let tabBarVc = Constants.kWelcomStoryboard.instantiateViewController(identifier: "WelcomeViewController") as! WelcomeViewController
        let nvc = UINavigationController(rootViewController: tabBarVc)
        nvc.isNavigationBarHidden = true
        self.window?.rootViewController = nvc
        self.window?.makeKeyAndVisible()
    }
    
    
    // MARK:- clear All App Data

    func logOutApp()  {
        self.logOutUser()
        SocketIOManager.sharedInstance.socket.removeAllHandlers()
        UserDefaults.standard.removeObject(forKey: "user")
        UserDefaults.standard.removeObject(forKey: "auth_token")
        UserDefaults.standard.removeObject(forKey: "remember_me")
        defaults.removeDefaults()
        Constants.kAppDelegate.user = nil
        self.authToken = nil
        self.userInfoDic = [String : Any]()
        GlobalDataPersistance.shared.isKeepLoggedIn = false
        GDP.switchToCricket()
        self.tabbarController = nil
        
        UIView.transition(with: self.window!, duration: 0.5, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
            self.swichToLogin()
        })
        
    }
    
    func logOutUser()  {
                
        let url = URLMethods.BaseURL + URLMethods.logout
        
        ApiClient.init().getRequest(method: url, parameters: [String:String](), view: UIView()) { result in
            if result != nil {
            }
        }
    }
}

//MARK: - Join Contest Flow From Deeplinking Invite Code
extension AppDelegate {
    
    func joinContest(inviteCode: String) {
        
        guard let view = UIApplication.topViewController?.view else { return }
        let params:[String:String] = ["invite_code": inviteCode]
        let url = URLMethods.BaseURL + URLMethods().joinContestViaInviteCode
        
        ApiClient.init().postRequest(params, request: url, view: view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                if result != nil {
                    let data = result?.object(forKey: "results") as? [String:Any]
                    let matchType = (result?.object(forKey: "match_type") as? String) ?? ""
                    
                    if data != nil{
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                              var contest = try? JSONDecoder().decode(ContestData.self, from: jsonData)else {return }
                        
                        guard let jsonData1 = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                              let match = try? JSONDecoder().decode(Match.self, from: jsonData1)else {return }
                        
                        
                        switch matchType.lowercased() {
                        case "cricket":
                            GDP.switchToCricket()
                            break
                        default:
                            break
                        }
                        
                        GDP.selectedMatch = match
                        
                        var temp = contest
                        temp.id = contest.contest_id
                        contest = temp
                        
                        self.getContestDetails(contest_id: contest.id ?? "0", match_id: contest.match_id ?? 0, series: contest.series_id ?? 0)
                        
                    }else{
                        AppManager.stopActivityIndicator(view)
                    }
                }else{
                    AppManager.stopActivityIndicator(view)
                }
            }
            
            else{
                AppManager.stopActivityIndicator(view)
                AppManager.showToast(msg ?? "", view: view)
            }
        }
        AppManager.startActivityIndicator(sender: view)
    }
    
    func getContestDetails (contest_id:String, match_id:Int, series:Int) {
        
        guard let controller = UIApplication.topViewController, let view = controller.view else { return }
        
        let params:[String:String] = ["user_id": Constants.kAppDelegate.user?.id ?? "",
                                      "match_id":"\(match_id)",
                                      "series_id":"\(series)",
                                      "contest_id":contest_id
        ]
        
        let url = URLMethods.BaseURL + URLMethods().getContestDetail
        
        ApiClient.init().postRequest(params, request: url, view: view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            AppManager.stopActivityIndicator(view)
            
            if isSuccess == true{
                if result != nil {
                    let data = result?.object(forKey: "results") as? [String:Any]
                    if data != nil{
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                              let tblData = try? JSONDecoder().decode(ContestData.self, from: jsonData)else {return }
                        let contest = tblData
                        
                        let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "ContestDetailViewController") as! ContestDetailViewController
                        VC.contestData = contest
                        
                        self.window?.rootViewController?.dismiss(animated: false, completion: {
                            controller.navigationController?.popToRootViewController(animated: false)
                            if let topVC  = UIApplication.topViewController {
                                topVC.navigationController?.pushViewController(VC, animated: true)
                            }
                        })
                    }
                }
            }
            else{
                AppManager.showToast(msg ?? "", view: view)
            }
        }
        AppManager.startActivityIndicator(sender: view)
    }
}

//
//  SplashViewController.swift
//  VPAY
//
//  Created by Octal Mac 217 on 24/01/22.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let appUser = UserDataModel.isLoggedIn() {
            GlobalDataPersistance.shared.isKeepLoggedIn = true
            Constants.kAppDelegate.user = appUser
            Constants.kAppDelegate.authToken = UserDataModel.getToken()
        }
        self.perform(#selector(getIntoApp), with: self, afterDelay: 3.0)
        // Do any additional setup after loading the view.
    }
    
    @objc func getIntoApp(){
        // Override point for customization after application launch.
        NewUpdateAvailable().checkForUpdate()
        if let appUser = UserDataModel.isLoggedIn() {
            print(appUser)
            //Constants.kAppDelegate.startSocketConnection()
            if Constants.kAppDelegate.isRemoteNotificationLaunch == true {
                
                Constants.kAppDelegate.isRemoteNotificationLaunch = false
                Constants.kAppDelegate.swichToHome()
                self.perform(#selector(shopDebuffPopup), with: self, afterDelay: 2.0)
                
            }else{
//                Constants.kAppDelegate.swichToWelcome()

                Constants.kAppDelegate.swichToHome()
            }
        }else{
            if CommonFunctions.getWelcomeVisitStatus() == true {
                Constants.kAppDelegate.swichToLogin()
            }else{
                Constants.kAppDelegate.swichToWelcome()
            }
        }
        
        self.perform(#selector(handleDeepLinks), with: self, afterDelay: 1.0)
    }
    
    @objc func handleDeepLinks(){
        if Constants.kAppDelegate.isFromDeepLink == true{
            Constants.kAppDelegate.isFromDeepLink = false
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
               while let presentedViewController = topController.presentedViewController {
                   topController = presentedViewController
               }
                
               
                let nv:UINavigationController? = topController as? UINavigationController
                if nv != nil{
                    Constants.kAppDelegate.handleDeepLinking(url: Constants.kAppDelegate.deepLinkURL, controller: nv?.viewControllers.last)
                }
           }
        }
    }
    
    @objc func shopDebuffPopup() {
        if Constants.kAppDelegate.notificationType == "debuff" {
            let userInfo = Constants.kAppDelegate.notificationUserInfo
            Constants.kAppDelegate.appliedBoosterPopUp(userInfo: userInfo)
        }
    }
}

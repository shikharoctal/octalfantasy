//
//  SignUpVC.swift
//  India’s fantasy
//
//  Created by admin on 05/06/23.
//

import UIKit
import FBSDKCoreKit
import AppTrackingTransparency

class SignUpVC: UIViewController {
    
    var referralCode = ""
    var isFromDeepLink = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    //MARK: Setup UI
    private func setupUI() {
      //  requestPermission()
    }
    
    private func requestPermission() {
        
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    Settings.shared.isAutoLogAppEventsEnabled = true
                    Settings.shared.isAdvertiserTrackingEnabled = true
                    Settings.shared.isAdvertiserIDCollectionEnabled = true
                case .denied:
                    Settings.shared.isAutoLogAppEventsEnabled = false
                    Settings.shared.isAdvertiserTrackingEnabled = false
                    Settings.shared.isAdvertiserIDCollectionEnabled = false
                    print("Denied")
                case .notDetermined:
                    // Tracking authorization dialog has not been shown
                    print("Not Determined")
                case .restricted:
                    print("Restricted")
                @unknown default:
                    print("Unknown")
                }
            }
        } else {
            // Fallback on earlier versions
            Settings.shared.isAutoLogAppEventsEnabled = true
            Settings.shared.isAdvertiserTrackingEnabled = true
            Settings.shared.isAdvertiserIDCollectionEnabled = true
        }
    }

    //MARK: Email Sign-up Btn Action
    @IBAction func btnEmailSignUpPressed(_ sender: UIButton) {
        guard let vc = Constants.KLoginSignupStoryboard.instantiateViewController(withIdentifier: "SignUpEmailVC") as? SignUpEmailVC else { return }
        vc.referralCode = referralCode
        vc.isFromDeepLink = isFromDeepLink
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Google Sign-up Btn Action
    @IBAction func btnGoogleSignUpPressed(_ sender: UIButton) {
        SocialLoginHelper.shared.handleLogInWithGoogleButtonPress(controller: self)
        SocialLoginHelper.shared.completionHandler = { data in
            self.socialSignup(request: data)
        }
    }

    //MARK: Facebook Sign-up Btn Action
    @IBAction func btnFacebookSignUpPressed(_ sender: UIButton) {
        SocialLoginHelper.shared.handleLogInWithFacebookButtonPress()
        SocialLoginHelper.shared.completionHandler = { data in
            self.socialSignup(request: data)
        }
    }
    
    //MARK: Apple Sign-up Btn Action
    @IBAction func btnAppleSignUpPressed(_ sender: UIButton) {
        SocialLoginHelper.shared.handleLogInWithAppleIDButtonPress()
        SocialLoginHelper.shared.completionHandler = { data in
            self.socialSignup(request: data)
        }
    }

    //MARK: Sign In Btn Action
    @IBAction func btnSignInPressed(_ sender: UIButton) {
        guard let nav = self.navigationController, nav.viewControllers.count > 1 else {
            Constants.kAppDelegate.swichToLogin()
            return
        }
        nav.popViewController(animated: false)
    }
}

//MARK: - Social Signup API Call
extension SignUpVC {
    
    func socialSignup(request: SocialLoginRequest) {
        
        var request = request
        guard request.email != "" else {
            
            self.alertBoxWithAction(message: ConstantMessages.kSocialEmailNotFound, btn1Title: ConstantMessages.CancelBtn, btn2Title: ConstantMessages.ContinueBtn) {
             
                guard let vc = Constants.KLoginSignupStoryboard.instantiateViewController(withIdentifier: "SignUpEmailVC") as? SignUpEmailVC else { return }
                vc.referralCode = self.referralCode
                vc.isFromDeepLink = self.isFromDeepLink
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return
        }
        
        if isFromDeepLink {
            request.referralCode = referralCode
        }
        request.login_type = .register
       
        WebCommunication.shared.socialLogin(request: request, showLoader: true) { user, token in
            
            guard let user = user, let userData = try? JSONEncoder().encode(user), let token = token else { return }
            
            Constants.kAppDelegate.user = user
            Constants.kAppDelegate.authToken = token
            
            if (user.username ?? "") == "" {
                let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "UserNameViewController") as! UserNameViewController
                self.navigationController?.pushViewController(pushVC, animated: true)
            }else{
                GlobalDataPersistance.shared.isKeepLoggedIn = true
                Constants.kAppDelegate.user?.saveToken(token)
                Constants.kAppDelegate.user?.saveUser(userData)
                Constants.kAppDelegate.swichToHome()
            }
            
        }
    }
}

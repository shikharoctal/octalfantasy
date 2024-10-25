//
//  LoginViewController.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 03/03/22.
//

import UIKit
import FBSDKCoreKit
import AppTrackingTransparency

class LoginViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var btnFacebookSignIn: OctalButton!
    @IBOutlet weak var lblEnterDetails: OctalLabel!
    @IBOutlet weak var btnCountryCode: UIButton!
    @IBOutlet weak var txtFPhone: UITextField!
    @IBOutlet weak var txtFEmail: UITextField!
    @IBOutlet weak var lblSignIn: OctalLabel!
    @IBOutlet weak var txtFPassword: UITextField!
    @IBOutlet weak var btnForgotPassword: UIButton!
    
    @IBOutlet weak var btnAppleSignIn: OctalButton!
    @IBOutlet weak var btnGoogleSignIn: OctalButton!
    @IBOutlet weak var viewOr: UIView!
    //    @IBOutlet weak var btnMobile: UIButton!
//    @IBOutlet weak var viewMobileLine: UIView!
//    @IBOutlet weak var btnEmail: UIButton!
//    @IBOutlet weak var viewEmailLine: UIView!
    
    @IBOutlet weak var viewMobileNumber: UIView!
    @IBOutlet weak var viewEmailAddress: UIView!
    @IBOutlet weak var viewPassword: UIView!
    @IBOutlet weak var btnSignIn: UIButton!
    
    @IBOutlet weak var lblTermsConditions: UILabel!
    @IBOutlet weak var btnAgreeCheckbox: UIButton!
    
    var socialSignup = false
    var dictSocialData:SocialLoginRequest? = nil
    
    
    var referralCode = ""
    
    var fb_id = ""
    var apple_id = ""
    var google_id = ""
    
    
    var isFromDeepLink = true
    var country:Country? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
      //  requestPermission()
    }
    
    //MARK: Setup UI
    private func setupUI() {
     
        lblTermsConditions.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapLabel(gesture:))))
        self.country = Country(name: "India", code: "IN", phoneCode: "+91")
        //btnSwitchPressed(btnMobile)
    }
    
    @objc func requestPermission() {
        
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

//    @IBAction func btnSwitchPressed(_ sender: UIButton) {
//
//        self.view.endEditing(true)
//        btnMobile.isSelected = false
//        btnEmail.isSelected = false
//        sender.isSelected = true
//
//        if sender.tag == 1 {
//            viewMobileLine.isHidden = false
//            viewEmailLine.isHidden = true
//            viewMobileNumber.isHidden = false
//            viewEmailAddress.isHidden = true
//        }else {
//            viewMobileLine.isHidden = true
//            viewEmailLine.isHidden = false
//            viewMobileNumber.isHidden = true
//            viewEmailAddress.isHidden = false
//        }
//        btnSignIn.setTitle("Sign In", for: .normal)
//    }
    
    //MARK: Country Code Btn Action
    @IBAction func btnCountryCodePressed(_ sender: UIButton) {
        
        let vc = Constants.KLoginSignupStoryboard.instantiateViewController(withIdentifier: "CountryPickerVC") as! CountryPickerVC
        vc.modalPresentationStyle = .overFullScreen
        vc.completionHandler = { dic in
            self.country = dic
            if self.country != nil{
                self.btnCountryCode.setTitle(self.country?.phoneCode, for: .normal)
            }
        }
        DispatchQueue.main.async {
            self.present(vc, animated: true)
        }
    }
    
    //MARK: Hide Un-hide Password Btn Action
    @IBAction func btnPasswordHidePressed(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        txtFPassword.isSecureTextEntry = !txtFPassword.isSecureTextEntry
    }
    
    //MARK: Sign Up Btn Action
    @IBAction func btnSignUpPressed(_ sender: UIButton) {
    
        let vc = Constants.KLoginSignupStoryboard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    //MARK: Sign In Btn Action
    @IBAction func btnSignInPressed(_ sender: UIButton) {
        self.submitValidData()
    }
    
    //MARK: Google Sign-in Btn Action
    @IBAction func btnGoogleSignInPressed(_ sender: UIButton) {
        self.callGoogleLogin()
    }

    //MARK: Facebook Sign-in Btn Action
    @IBAction func btnFacebookSignInPressed(_ sender: UIButton) {
        self.callFBLogin()
    }
    
    //MARK: Apple Sign-in Btn Action
    @IBAction func btnAppleSignInPressed(_ sender: UIButton) {
        self.callAppleLogin()
    }
    
   
    //MARK: Forgot Password Btn Action
    @IBAction func btnForgotPasswordPressed(_ sender: Any) {
        
        let pushVC = Constants.KLoginSignupStoryboard.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
        self.navigationController?.pushViewController(pushVC, animated: true)
    }
    
    //MARK: Check Box Btn Action
    @IBAction func btnAgreeCheckboxPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc func tapLabel(gesture: UITapGestureRecognizer) {
        
        let termsRange = (lblTermsConditions.text! as NSString).range(of: "T’s & C’s.")
        
        if gesture.didTapAttributedTextInLabel(label: lblTermsConditions, inRange: termsRange) {
            let vc = Constants.KSideMenuStoryboard.instantiateViewController(withIdentifier: "WebPageViewController") as! WebPageViewController
            vc.url = URL(string: (URLMethods.BaseURL + URLMethods.termsConditions))
            vc.headerText = "Terms & Conditions"
            WebCommunication.shared.getCommonContent(hostController: self, slug: (URLMethods.BaseURL + URLMethods.termsConditions), showLoader: true) { data in
                vc.htmlData = data
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func callFBLogin(){
        SocialLoginHelper.shared.handleLogInWithFacebookButtonPress()
        SocialLoginHelper.shared.completionHandler = { data in
            self.fb_id = data.social_id
            let email = data.email
            
            self.dictSocialData = data
            
            let params: [String:Any] = [
                "email"           : email,
                "device_id":Constants.kAppDelegate.deviceTokenString,
                "device_type":"ios",
                "fb_id": self.fb_id,
                "google_id": "",
                "country_code":"+91",
                "referral_code":Constants.kAppDelegate.referralCode
            ]
            self.socialLogin(params: params)
        }
    }
    
    func callAppleLogin(){
        SocialLoginHelper.shared.handleLogInWithAppleIDButtonPress()
        SocialLoginHelper.shared.completionHandler = { data in
            self.apple_id = data.social_id
            let email = data.email
            
            self.dictSocialData = data

            let params: [String:Any] = [
                "email"           : email,
                "device_id":Constants.kAppDelegate.deviceTokenString,
                "device_type":"ios",
                "fb_id": "",
                "apple_id": self.apple_id,
                "country_code":"+91",
                "referral_code":Constants.kAppDelegate.referralCode
            ]
            self.socialLogin(params: params)
        }
    }
    
    func callGoogleLogin(){
        SocialLoginHelper.shared.handleLogInWithGoogleButtonPress(controller: self)
        SocialLoginHelper.shared.completionHandler = { data in
            self.google_id = data.social_id
            let email = data.email
            
            self.dictSocialData = data

            let params: [String:Any] = [
                "email"           : email,
                "device_id":Constants.kAppDelegate.deviceTokenString,
                "device_type":"ios",
                "fb_id": "",
                "apple_id": "",
                "google_id":self.google_id,
                "country_code":"+91",
                "referral_code":Constants.kAppDelegate.referralCode
            ]
            self.socialLogin(params: params)
        }
    }
    
}
extension LoginViewController {
    
    func submitValidData() {
        
        self.view.endEditing(true)
        var params: [String: Any] = [:]
        
        //        if btnMobile.isSelected {
        
        guard let phoneCode = self.country?.phoneCode  else {
            AppManager.showToast(ConstantMessages.CountryCode_Empty.localized(), view: self.view)
            return
        }
        guard let phone = txtFPhone.text, !phone.isEmptyOrWhitespace  else {
            AppManager.showToast(ConstantMessages.Phone_Empty.localized(), view: self.view)
            return
        }
        
        if phone.count < 10{
            AppManager.showToast(ConstantMessages.Phone_ValidateLength.localized(), view: self.view)
            return
        }
        
        if !btnAgreeCheckbox.isSelected {
            AppManager.showToast(ConstantMessages.ReadTermsConditions.localized(), view: self.view)
            return
        }
        
        params = [ "mobile": phone,
                   "user_type": "user",
                   "device_id": Constants.kAppDelegate.deviceTokenString,
                   "device_type": Constants.kDeviceType,
                   //                       "password": password,
                   "country_code": phoneCode
        ]
        
        
        self.login(params: params)
    }
    
    
    //MARK: - API Calls
    
    func login(params:[String:Any]) {
       
        ApiClient.init().postRequest(params, request: URLMethods.BaseURL + URLMethods.sendOTP, view: self.view) { (msg,result) in
            if result != nil {
                let data = result?.object(forKey: "result") as? [String:Any]
                    if data != nil{
                        let destinationVC = Constants.KLoginSignupStoryboard.instantiateViewController(withIdentifier: "VerifyOTPViewController") as! VerifyOTPViewController
                        destinationVC.userId = ""
                        if self.socialSignup == true{
                            destinationVC.isSocialLogin = self.socialSignup
                            destinationVC.dictSocialLogin = self.dictSocialData
                            destinationVC.fb_id = self.fb_id
                            destinationVC.google_id = self.google_id
                            destinationVC.apple_id = self.apple_id
                        }
                        destinationVC.routeType = Constants.kRouteLogin
                        destinationVC.mobileNumber = params["mobile"] as? String ?? ""
                        destinationVC.requestModal = params
                        self.navigationController?.pushViewController(destinationVC, animated: true)
                    }
                
            }else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
            AppManager.stopActivityIndicator(self.view)
        }
        AppManager.startActivityIndicator(sender: self.view)
    }
}

extension LoginViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      
        if (textField.text?.count ?? 0) == 0 && string == " "{
            return false
        }
        
        if textField == txtFPhone{

                if textField.text?.count == 0 && string == "0" {
                    
                    return false
                }
                
                //Limit the character count to 10.
                if ((textField.text!) + string).count > 10 {
                    
                    return false
                }
                
                //Have a decimal keypad. Which means user will be able to enter Double values. (Needless to say "." will be limited one)
                if (textField.text?.contains("."))! && string == "." {
                    
                    return false
                }

                //Only allow numbers. No Copy-Paste text values.
                let allowedCharacterSet = CharacterSet.init(charactersIn: "0123456789.")
                let textCharacterSet = CharacterSet.init(charactersIn: textField.text! + string)
                if !allowedCharacterSet.isSuperset(of: textCharacterSet) {
                    return false
                }
                return true
        }
         return true
    }

}

//MARK: - Social Signin API Call
extension LoginViewController {
    
    func socialLogin(params:[String:Any]) {

        ApiClient.init().postRequest(params, request: URLMethods.BaseURL + URLMethods.socialLogin, view: self.view) { (msg,result) in
            if result != nil {
                let data = result?.object(forKey: "result") as? [String:Any]
                let success = (result?.object(forKey: "success") as? Bool) ?? false
                if success == false{
                    self.socialSignup = true
                    self.lblSignIn.text = "Welcome \(self.dictSocialData?.name ?? "")"
                    self.viewOr.isHidden = true
                    self.btnGoogleSignIn.isHidden = true
                    self.btnAppleSignIn.isHidden = true
                    self.btnFacebookSignIn.isHidden = true
                }else{
                    if data != nil{
                        if (data?.keys.count ?? 0) > 0{
                            
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                                  let user = try? JSONDecoder().decode(UserDataModel.self, from: jsonData),
                                  let userData = try? JSONEncoder().encode(user) else {return }
                            
                            let otpVerified = user.otpverified ?? false
                            Constants.kAppDelegate.user = user
                            Constants.kAppDelegate.authToken = (result?.object(forKey: "token") as? String) ?? ""
                            
                            if otpVerified == true{
                                if (user.username ?? "") == ""{
                                    let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "UserNameViewController") as! UserNameViewController
                                        if let dictSocialData = self.dictSocialData{
                                            pushVC.fullName = dictSocialData.name
                                            pushVC.email = dictSocialData.email
                                        }
                                    self.navigationController?.pushViewController(pushVC, animated: true)
                                }else{
                                    Constants.kAppDelegate.user = user
                                    Constants.kAppDelegate.authToken = (result?.object(forKey: "token") as? String) ?? ""
                                    Constants.kAppDelegate.user?.saveToken((result?.object(forKey: "token") as? String) ?? "")
                                    Constants.kAppDelegate.user?.saveUser(userData)
                                    Constants.kAppDelegate.swichToHome()
                                }
                            }
                            else{
                                var reqParams = params
                                let destinationVC = Constants.KLoginSignupStoryboard.instantiateViewController(withIdentifier: "VerifyOTPViewController") as! VerifyOTPViewController
                                destinationVC.userId = ""
                                destinationVC.isSocialLogin = true
                                destinationVC.dictSocialLogin = self.dictSocialData
                                destinationVC.routeType = Constants.kRouteLogin
                                if let mobile = user.phone{
                                    reqParams["mobile"] = mobile
                                }
                                destinationVC.mobileNumber = reqParams["mobile"] as? String ?? ""
                                destinationVC.requestModal = reqParams
                                self.navigationController?.pushViewController(destinationVC, animated: true)
                            }
                            
                        }else{
                            AppManager.showToast(msg ?? "", view: self.view)
                        }
                    }else{
                        AppManager.showToast(msg ?? "", view: self.view)
                    }
                }
                                    
            }else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
            AppManager.stopActivityIndicator(self.view)
        }
        AppManager.startActivityIndicator(sender: self.view)
    }
}

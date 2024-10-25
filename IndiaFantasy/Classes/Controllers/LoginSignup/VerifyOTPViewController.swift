//
//  VerifyOTPViewController.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 03/03/22.
//

import UIKit

class VerifyOTPViewController: UIViewController {

    @IBOutlet weak var btnVerifyOTP: UIButton!
    @IBOutlet weak var lblPhoneNumber: UILabel!
    @IBOutlet weak var otpContainer: PHOTPView!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var btnTermCondition: UIButton!

    @IBOutlet weak var lblIncorrectOTP: UILabel!
    @IBOutlet weak var btnResendCode: UIButton!

    @IBOutlet weak var lblTermAndCondition: UILabel!
    var requestModal = [String:Any]()
    
    var userId:String? = ""
    var routeType = ""
    var mobileNumber = ""
    var referral_code = ""
    var loginWithEmail: Bool = false

//    var requestModal = [String:Any]()
    var dictSocialLogin:SocialLoginRequest? = nil
    var isSocialLogin = false
    var enteredOtp = String()
    var config:PinConfig! = PinConfig()
    
    var fb_id = ""
    var apple_id = ""
    var google_id = ""

    var timer : Timer? = nil {
        willSet {
          timer?.invalidate()
        }
      }
      var totalTime = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnVerifyOTP.alpha = 0.5
        btnVerifyOTP.isEnabled = false
        startTimer()
        setupVarificationPINView()
        
        let contryCode = requestModal["country_code"] ?? ""
        self.lblPhoneNumber.text = "(\(contryCode)) \(self.mobileNumber)"
                
        lblTermAndCondition.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapLabel(gesture:))))

        
        
        // Do any additional setup after loading the view.
    }

    
    @IBAction func tapLabel(gesture: UITapGestureRecognizer) {
        let termsRange = (lblTermAndCondition.text! as NSString).range(of: "Terms")
        // comment for now
        let privacyRange = (lblTermAndCondition.text! as NSString).range(of: "Conditions")
        if gesture.didTapAttributedTextInLabel(label: lblTermAndCondition, inRange: termsRange) {
            guard URL(string: URLMethods.BaseURL + URLMethods.termsConditions) != nil else { return }
            let vc = Constants.KSideMenuStoryboard.instantiateViewController(withIdentifier: "WebPageViewController") as! WebPageViewController
            vc.url = URL(string: (URLMethods.BaseURL + URLMethods.termsConditions))
            vc.headerText = "Terms & Conditions"
            WebCommunication.shared.getCommonContent(hostController: self, slug: (URLMethods.BaseURL + URLMethods.termsConditions), showLoader: true) { data in
                vc.htmlData = data
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if gesture.didTapAttributedTextInLabel(label: lblTermAndCondition, inRange: privacyRange) {
            guard URL(string: URLMethods.BaseURL + URLMethods.privacyPolicy) != nil else { return }
            let vc = Constants.KSideMenuStoryboard.instantiateViewController(withIdentifier: "WebPageViewController") as! WebPageViewController
            vc.url = URL(string: (URLMethods.BaseURL + URLMethods.termsConditions))
            vc.headerText = "Terms & Conditions"
            WebCommunication.shared.getCommonContent(hostController: self, slug: (URLMethods.BaseURL + URLMethods.termsConditions), showLoader: true) { data in
                vc.htmlData = data
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            print("Tapped none")
        }
        
    }
    
    @IBAction func btnResendPressed(_ sender: UIButton) {
        if !sender.isSelected{
            self.generateOTP()
            startTimer()
        }
    }

    @IBAction func btnVerifyPressed(_ sender: Any) {
        self.submitValidData()
    }
    
    @IBAction func btnBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnTermConditionSelected(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        GlobalDataPersistance.shared.isKeepLoggedIn = sender.isSelected
    }
}

extension VerifyOTPViewController {
    
    func submitValidData() {
        
        if enteredOtp.count == 4 {
            var params: [String:Any] = [
                "phone": self.mobileNumber,
                "otp": enteredOtp,
                "device_id":Constants.kDeviceId,
                "device_type":Constants.kDeviceType,
                "device_token": Constants.kAppDelegate.deviceTokenString,
                "country_code": requestModal["country_code"] ?? "",
                "referral_code": Constants.kAppDelegate.referralCode
            ]
            
            if self.isSocialLogin == true{
                if let dictSocialLogin = self.dictSocialLogin{
                    params["email"] = dictSocialLogin.email
                    params["fb_id"] = self.fb_id
                    params["google_id"] = self.google_id
                    params["apple_id"] = self.apple_id
                }
                
            }
            self.verifyOTP(params: params)
        }
    }
    
    //MARK: - API Calls
    
    func verifyOTP(params:[String:Any]) {
      
        ApiClient.init().postRequest(params, request: URLMethods.BaseURL + URLMethods.verifyOTP, view: self.view) { (msg,result) in
            if result != nil {
                let data = result?.object(forKey: "result") as? [String:Any]
                if ((result?.object(forKey: "success") as? Bool) ?? false) == true{
                    if data != nil{
                        if (data?.keys.count ?? 0) > 0 {
                            
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                                  let user = try? JSONDecoder().decode(UserDataModel.self, from: jsonData),
                                  let userData = try? JSONEncoder().encode(user) else {return }
                            Constants.kAppDelegate.user = user
                            Constants.kAppDelegate.authToken = (result?.object(forKey: "token") as? String) ?? ""
                            if (user.username ?? "") == ""{
                                let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "UserNameViewController") as! UserNameViewController
                                
                                if self.isSocialLogin == true{
                                    if let dictSocialLogin = self.dictSocialLogin{
                                        pushVC.fullName = dictSocialLogin.name
                                        pushVC.email = dictSocialLogin.email
                                    }
                                }
                                self.navigationController?.pushViewController(pushVC, animated: true)
                            }else{
                                GlobalDataPersistance.shared.isKeepLoggedIn = true
                                Constants.kAppDelegate.user?.saveToken((result?.object(forKey: "token") as? String) ?? "")
                                Constants.kAppDelegate.user?.saveUser(userData)
                                Constants.kAppDelegate.swichToHome()
                            }
                            
                        }else{
                            AppManager.showToast(msg ?? "", view: self.view)
                        }
                        
                    }
                }else{
                    AppManager.showToast(msg ?? "", view: self.view)
                }
            }else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
            AppManager.stopActivityIndicator(self.view)
        }
        AppManager.startActivityIndicator(sender: self.view)
    }
    
    func generateOTP() {
      
        let params: [String:Any] = [
            "mobile"           : requestModal["mobile"] ?? "",
            "user_type":"user",
            "device_id": Constants.kAppDelegate.deviceTokenString,
            "device_type": Constants.kDeviceType,
            "country_code":requestModal["country_code"] ?? "",
        ]
        
        ApiClient.init().postRequest(params, request: URLMethods.BaseURL + URLMethods.sendOTP, view: self.view) { (msg,result) in
            if result != nil {
                    let data = result?.object(forKey: "data") as? [String:Any]
                    AppManager.showToast(msg ?? "", view: self.view)

                    if data != nil{
                    if (data?.keys.count ?? 0) > 0{
//                        self.emailString = String(Int(data?["otp_email"] as? Int ?? 0))
//                        self.phoneString = String(Int(data?["otp_phone"] as? Int ?? 0))
//                        self.otpEmailView?.autoFillTextField(with: self.emailString ?? "")
//                        self.otpPhoneView?.autoFillTextField(with: self.phoneString ?? "")

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


//MARK: OTPView SetUp
extension VerifyOTPViewController: PHOTPViewDelegate {
    
    func hasEnteredAllOTP(hasEntered: Bool) -> Bool {
        print("Has entered all OTP? \(hasEntered)")
        btnVerifyOTP.isEnabled = hasEntered
        if hasEntered == true{
            btnVerifyOTP.alpha = 1.0
        }else{
            btnVerifyOTP.alpha = 0.5
        }
        return hasEntered
    }
    
    func shouldBecomeFirstResponderForOTP(otpFieldIndex index: Int) -> Bool {
        return true
    }
    
    func getenteredOTP(otpString: String) { enteredOtp = otpString }
    
    func getOTPFromView(otpString: String, sender: PHOTPView) {
    }
    
}

extension VerifyOTPViewController {
    
    private func setupVarificationPINView() {
        
        config.otpFieldDisplayType = .square
        config.otpFieldSeparatorSpace = 10
        config.otpFieldSize = 45
        config.otpFieldsCount = 4
        config.otpFieldBorderWidth = 1
        config.shouldAllowIntermediateEditing = false
        otpContainer.config = config
        otpContainer.delegate = self
        
        // Create the UI
        otpContainer.initializeUI()
    }
}
//MARK: - Expiring Time Functionality
extension VerifyOTPViewController {
  
  func startTimer() {
    stopTimer()
    guard self.timer == nil else { return }
      lblTimer.isHidden = false
      btnResendCode.isSelected = true
    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
  }
  
  func stopTimer() {
    guard timer != nil else { return }
    timer?.invalidate()
    timer = nil
  }
  
  @objc func updateTime() {
    
    totalTime -= 1
    
    if totalTime == 0 {
      stopTimer()
      totalTime = 60
      lblTimer.isHidden = true
      btnResendCode.isSelected = false
      self.lblTimer.text = ""
      return
    }
    
      lblTimer.text = totalTime.expiringTimeFormat
  }
}
extension Int {
  
  var expiringTimeFormat: String {
    let seconds: Int = self % 60
//    let minutes: Int = (self / 60) % 60
    return String(format: "%02d\nSec", seconds)
  }
}

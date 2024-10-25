//
//  SignUpVerifyOTPVC.swift
//  India’s fantasy
//
//  Created by admin on 05/06/23.
//

import UIKit

class SignUpVerifyOTPVC: UIViewController {
    
    @IBOutlet weak var btnVerifyOTP: UIButton!
    @IBOutlet weak var otpMobileContainer: PHOTPView!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var lblMobileIncorrectOTP: UILabel!
    @IBOutlet weak var btnResendCode: UIButton!
    
    @IBOutlet weak var lblSubTitleLine: OctalLabel!
    @IBOutlet weak var lblTitleLine: OctalLabel!
    var requestModal = [String:Any]()
    var enteredOtp = String()
    var config:PinConfig! = PinConfig()
    
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

        if ((requestModal["verification_type"] as? String) ?? "") == "mobile"{
            self.lblTitleLine.text = "We have sent a code to your Mobile Number."
            self.lblSubTitleLine.text = "Enter OTP for Mobile"
        }else{
            self.lblTitleLine.text = "We have sent a code to your Email Address."
            self.lblSubTitleLine.text = "Enter OTP for Email"
        }
        
    }
    
    @IBAction func btnResendPressed(_ sender: UIButton) {
        if sender.isSelected {
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
    
}

extension SignUpVerifyOTPVC {
    
    func submitValidData() {
        
        guard enteredOtp.count == 4 else {
            AppManager.showToast(ConstantMessages.ENT_OTP, view: self.view)
            return
        }
        self.view.endEditing(true)
        var params: [String: Any] = requestModal
        
        params["otp"] = enteredOtp
        self.verifyOTP(params: params)
    }
    
    //MARK: - API Calls
    
    func verifyOTP(params:[String:Any]) {
        
        self.lblMobileIncorrectOTP.isHidden = true
     //   self.lblEmailIncorrectOTP.isHidden = true
        
        ApiClient.init().postRequest(params, request: URLMethods.BaseURL + URLMethods.verifyEmailOTP, view: self.view) { (msg,result) in
            if result != nil {
                let data = result?.object(forKey: "result") as? [String:Any]
                if ((result?.object(forKey: "success") as? Bool) ?? false) == true {
                    if data != nil{
                        if (data?.keys.count ?? 0) > 0 {
                            self.lblMobileIncorrectOTP.isHidden = true
              //              self.lblEmailIncorrectOTP.isHidden = true
                            
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                                  let user = try? JSONDecoder().decode(UserDataModel.self, from: jsonData),
                                  let userData = try? JSONEncoder().encode(user) else {return }
                            Constants.kAppDelegate.user = user
                            Constants.kAppDelegate.authToken = (result?.object(forKey: "token") as? String) ?? ""
                            if (user.username ?? "") == "" {
                                let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "UserNameViewController") as! UserNameViewController
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
                    self.lblMobileIncorrectOTP.isHidden = false
                    //AppManager.showToast(msg ?? "", view: self.view)
//                    if msg == "Invalid mobile otp" {
//                        self.lblMobileIncorrectOTP.isHidden = false
//                    }else if msg == "Invalid email otp" {
//                        self.lblMobileIncorrectOTP.isHidden = false
//                    }else {
//
//                        //self.lblEmailIncorrectOTP.isHidden = false
//                    }
                }
                
                
            }else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
            AppManager.stopActivityIndicator(self.view)
        }
        AppManager.startActivityIndicator(sender: self.view)
    }
    
    func generateOTP() {
        
        var params = ["verification_type": (self.requestModal["verification_type"] as? String) ?? "",
                      "mobile": (self.requestModal["phone"] as? String) ?? "",
                      "country_code": (self.requestModal["country_code"] as? String) ?? "",
                      "email": (self.requestModal["email"] as? String) ?? ""
        ]
        
        if (self.requestModal["verification_type"] as? String) ?? "" == "email" {
            params["country_code"] = ""
            params["mobile"] = ""
        }
       
        ApiClient.init().postRequest(params, request: URLMethods.BaseURL + URLMethods.reSendOTP, view: self.view) { (msg,result) in
            if result != nil {
                
                if ((result?.object(forKey: "success") as? Bool) ?? false) == true {
                    if let data = result?.object(forKey: "result") as? [String:Any], (data.keys.count) > 0 {
                        AppManager.showToast(msg ?? "", view: self.view)
                    }else{
                        AppManager.showToast(msg ?? "", view: self.view)
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
}


//MARK: OTPView SetUp
extension SignUpVerifyOTPVC: PHOTPViewDelegate {
    
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
    
    func getenteredOTP(otpString: String) {}
    
    func getOTPFromView(otpString: String, sender: PHOTPView) {
        enteredOtp = otpString
    }
}

extension SignUpVerifyOTPVC {
    
    private func setupVarificationPINView() {
        
        config.otpFieldDisplayType = .square
        config.otpFieldSeparatorSpace = 10
        config.otpFieldSize = 45
        config.otpFieldsCount = 4
        config.otpFieldBorderWidth = 1
        config.shouldAllowIntermediateEditing = false
        otpMobileContainer.config = config
        otpMobileContainer.delegate = self                
        // Create the UI
        otpMobileContainer.initializeUI()
    }
}
//MARK: - Expiring Time Functionality
extension SignUpVerifyOTPVC {
    
    func startTimer() {
        stopTimer()
        guard self.timer == nil else { return }
        lblTimer.isHidden = false
        btnResendCode.isSelected = false
        btnVerifyOTP.isEnabled = false
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
            btnResendCode.isSelected = true
            btnVerifyOTP.isEnabled = true
            self.lblTimer.text = ""
            return
        }
        
        lblTimer.text = totalTime.expiringTimeFormat
    }
}


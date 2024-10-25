//
//  SignUpEmailVC.swift
//  India’s fantasy
//
//  Created by Harendra Singh Rathore on 03/11/23.
//

import UIKit

class SignUpEmailVC: UIViewController {
    
    //MARK: Outlets
    //@IBOutlet weak var btnCountryCode: UIButton!
    //@IBOutlet weak var txtFMobileNumber: UITextField!
    @IBOutlet weak var txtFEmail: UITextField!
    @IBOutlet weak var txtFPassword: UITextField!
    @IBOutlet weak var txtReferralCode: UITextField!
    @IBOutlet weak var lblTermsConditions: UILabel!
    @IBOutlet weak var btnAgreeCheckbox: UIButton!
    @IBOutlet weak var imageCaptcha: UIImageView!
    @IBOutlet weak var txtCaptchaCode: UITextField!
//    @IBOutlet weak var btnVerifyViaEmail: OctalButton!
//    @IBOutlet weak var btnVerifyViaMobile: OctalButton!
    
    //private var country:Country? = nil
    private var captchaKey: String = ""
    
    var referralCode = ""
    var isFromDeepLink = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    //MARK: Setup UI
    private func setupUI() {
        
        //self.country = Country(name: "South Africa", code: "ZA", phoneCode: "+27")
        lblTermsConditions.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapLabel(gesture:))))
        
        if isFromDeepLink {
            self.txtReferralCode.text = referralCode
        }
        getCaptcha()
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
    
    //MARK: Country Code Btn Action
//    @IBAction func btnCountryCodePressed(_ sender: UIButton) {
//
//        let vc = Constants.KLoginSignupStoryboard.instantiateViewController(withIdentifier: "CountryPickerVC") as! CountryPickerVC
//        vc.modalPresentationStyle = .overFullScreen
//        vc.completionHandler = { dic in
//            self.country = dic
//            if self.country != nil{
//                self.btnCountryCode.setTitle(self.country?.phoneCode, for: .normal)
//                self.btnVerifyViaMobile.isUserInteractionEnabled = true
//                self.btnVerifyViaMobile.alpha = 1
//                self.btnVerifyViaEmail.isSelected = false
//
//                if self.country?.phoneCode != "+27" {
//                    self.btnVerifyViaMobile.isUserInteractionEnabled = false
//                    self.btnVerifyViaMobile.alpha = 0.5
//                    self.btnVerifyViaMobile.isSelected = false
//                    self.btnVerifyViaEmail.isSelected = true
//                }
//            }
//        }
//        DispatchQueue.main.async {
//            self.present(vc, animated: true)
//        }
//    }
    
    //MARK: Hide Un-hide Password Btn Action
    @IBAction func btnPasswordHidePressed(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        txtFPassword.isSecureTextEntry = !txtFPassword.isSecureTextEntry
    }
    
    //MARK: Check Box Btn Action
    @IBAction func btnAgreeCheckboxPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }

    //MARK: Sign Up Btn Action
    @IBAction func btnSignUpPressed(_ sender: UIButton) {
        submitValidData()
    }

    //MARK: Sign In Btn Action
    @IBAction func btnSignInPressed(_ sender: UIButton) {
        guard let nav = self.navigationController, nav.viewControllers.count > 2 else {
            Constants.kAppDelegate.swichToLogin()
            return
        }
        nav.popToRootViewController(animated: false)
    }
    
    @IBAction func btnRefreshPressed(_ sender: UIButton) {
        getCaptcha()
    }
    
    //MARK: Verification Option Btn Action

//    @IBAction func btnMobileNumberPressed(_ sender: UIButton) {
//        btnVerifyViaEmail.isSelected = false
//        btnVerifyViaMobile.isSelected = false
//        sender.isSelected = true
//    }
//
//    @IBAction func btnEmailPressed(_ sender: UIButton) {
//        btnVerifyViaEmail.isSelected = false
//        btnVerifyViaMobile.isSelected = false
//
//        sender.isSelected = true
//    }
}

//MARK: Validation - API Call
extension SignUpEmailVC {
    
    func submitValidData() {
        
        self.view.endEditing(true)
        var params: [String: Any] = [:]
        
        let verificationType = self.getVerificationType()
        
//        guard let phoneCode = self.country?.phoneCode  else {
//            AppManager.showToast(ConstantMessages.CountryCode_Empty.localized(), view: self.view)
//            return
//        }
//        guard let phone = txtFMobileNumber.text, !phone.isEmptyOrWhitespace  else {
//            AppManager.showToast(ConstantMessages.Phone_Empty.localized(), view: self.view)
//            return
//        }
//
//        if phone.count < 8{
//            AppManager.showToast(ConstantMessages.Phone_ValidateLength.localized(), view: self.view)
//            return
//        }
        
        guard let email = txtFEmail.text, !email.isEmptyOrWhitespace  else {
            AppManager.showToast(ConstantMessages.Email_Empty.localized(), view: self.view)
            return
        }
        
        guard AppManager.validateEmail(with: email) else {
            AppManager.showToast(ConstantMessages.Email_Validate.localized(), view: self.view)
            return
        }
        
        guard let password = txtFPassword.text, !password.isEmptyOrWhitespace  else {
            AppManager.showToast(ConstantMessages.Password_Empty.localized(), view: self.view)
            return
        }
        
        if password.count < 8 {
            AppManager.showToast(ConstantMessages.Password_lengthValidate.localized(), view: self.view)
            return
        }
        
        if CommonFunctions.isValidPassword(password: password) == false{
            AppManager.showToast(ConstantMessages.Password_Validate.localized(), view: self.view)
            return
        }
        
        guard let captchaCode = txtCaptchaCode.text, !captchaCode.isEmptyOrWhitespace  else {
            AppManager.showToast(ConstantMessages.Captcha_Empty.localized(), view: self.view)
            return
        }
        
//        if verificationType == ""{
//            AppManager.showToast(ConstantMessages.Verification_Option.localized(), view: self.view)
//            return
//        }
        
        if !btnAgreeCheckbox.isSelected {
            AppManager.showToast(ConstantMessages.ReadTermsConditions.localized(), view: self.view)
            return
        }
        
        
        params = [ //"country_code": phoneCode,
                   //"phone": phone,
                   "email": email,
                   "password": password,
                   "device_id": Constants.kAppDelegate.deviceTokenString,
                   "device_type": Constants.kDeviceType,
                   "referralCode": txtReferralCode.text ?? "",
                   "captchaKey": captchaKey,
                   "captchaCode": captchaCode,
                   "verification_type": verificationType,
        ]
        
        self.resigterFromServer(params: params)
    }
    
    func resigterFromServer(params: [String:Any]) {
       
        ApiClient.init().postRequest(params, request: URLMethods.BaseURL + URLMethods.register, view: self.view) { (msg,result) in
            if result != nil {
                
                if ((result?.object(forKey: "success") as? Bool) ?? false) == true {
//                    if let data = result?.object(forKey: "result") as? [String:Any], (data.keys.count) > 0 {
//
//
//                    }else{
//                        AppManager.showToast(msg ?? "", view: self.view)
//                    }
                    
                    let destinationVC = Constants.KLoginSignupStoryboard.instantiateViewController(withIdentifier: "SignUpVerifyOTPVC") as! SignUpVerifyOTPVC
                    
                    destinationVC.requestModal = params
                    self.navigationController?.pushViewController(destinationVC, animated: true)
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
    
    func getCaptcha() {
        WebCommunication.shared.getCaptchaImage(hostController: self, showLoader: true) { captchaImage, captchaKey in
            
            if let imageData = Data(base64Encoded: captchaImage ?? "") {
                self.imageCaptcha.image = UIImage(data: imageData)
                self.captchaKey = captchaKey ?? ""
            }
        }
    }
    
    func getVerificationType() -> String{
//        if btnVerifyViaEmail.isSelected == true{
//            return "email"
//        }else if btnVerifyViaMobile.isSelected == true{
//            return "mobile"
//        }

        return "email" //""
    }
}

extension SignUpEmailVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      
        if (textField.text?.count ?? 0) == 0 && string == " "{
            return false
        }
        
//        if textField == txtFMobileNumber {
//
//                if textField.text?.count == 0 && string == "0" { return false }
//
//                //Limit the character count to 10.
//                if ((textField.text!) + string).count > 12 { return false}
//
//                //Have a decimal keypad. Which means user will be able to enter Double values. (Needless to say "." will be limited one)
//                if (textField.text?.contains("."))! && string == "." { return false }
//
//                //Only allow numbers. No Copy-Paste text values.
//                let allowedCharacterSet = CharacterSet.init(charactersIn: "0123456789.")
//                let textCharacterSet = CharacterSet.init(charactersIn: textField.text! + string)
//                if !allowedCharacterSet.isSuperset(of: textCharacterSet) { return false }
//                return true
//        }
        
        if textField == txtFPassword{
            let currentString: NSString = (textField.text ?? "") as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= Constants.kPasswordLength
        }
        
        if textField == txtCaptchaCode {
            let currentString: NSString = (textField.text ?? "") as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= Constants.kPasswordLength
        }
        
         return true
    }

}


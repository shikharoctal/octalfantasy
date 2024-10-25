//
//  SendAadharOTPVC.swift
//  CrypTech
//
//  Created by New on 16/03/22.
//

import UIKit
import Alamofire
import MaterialComponents.MaterialTextControls_OutlinedTextFields

class SendAadharOTPVC: BaseClassWithoutTabNavigation {

    @IBOutlet weak var navigationView: CustomNavigation!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var txtFAadharNumberNumber: MDCOutlinedTextField!
    @IBOutlet weak var txtFOTP: MDCOutlinedTextField!

    private var otpRefID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationView.configureNavigationBarWithController(controller: self, title: "Verify Aadhaar", hideNotification: false, hideAddMoney: true, hideBackBtn: false)
        self.setupMaterialTextFields()
        txtFAadharNumberNumber.addTarget(self, action: #selector(capitaliseText(_:)), for: .editingChanged)
        
    }
    
    func setupMaterialTextFields(){
        self.txtFAadharNumberNumber.label.text = "Enter your 12 digit Aadhaar Number*"
        self.txtFAadharNumberNumber.placeholder = "Enter your 12 digit Aadhaar Number*"
    
        self.txtFOTP.label.text = "Enter OTP*"
        self.txtFOTP.placeholder = "Enter OTP*"

        [txtFOTP, txtFAadharNumberNumber].forEach({$0?.setOutlineColor(UIColor.appTextFieldBorder, for: .normal)})
        [txtFOTP, txtFAadharNumberNumber].forEach({$0?.setOutlineColor(UIColor.appTextFieldBorder, for: .editing)})
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    @objc func capitaliseText (_ sender:UITextField){
        sender.text = sender.text?.uppercased()
    }

    func submitValidData() {
        
        guard let aadharNumber = txtFAadharNumberNumber.text, !aadharNumber.isEmptyOrWhitespace  else {
            AppManager.showToast(ConstantMessages.ENT_Aadhar_NUMBER.localized(), view: self.view)
            return
        }
        
        guard aadharNumber.count == 12 else {
            AppManager.showToast(ConstantMessages.ENT_Aadhar_NUMBER.localized(), view: self.view)
            return
        }
        
        let params:[String:Any] = ["aadhaar_number": aadharNumber]
        self.sendAadharOTPApi(params: params)
    }
    
    func validateOTP() {
        
        guard let otp = txtFOTP.text, !otp.isEmptyOrWhitespace  else {
            AppManager.showToast(ConstantMessages.ENT_Aadhar_OTP.localized(), view: self.view)
            return
        }
        
        guard otp.count == 6  else {
            AppManager.showToast(ConstantMessages.ENT_Valid_Aadhar_OTP.localized(), view: self.view)
            return
        }
        
        let params:[String:Any] = ["otp": otp, "ref_id": otpRefID]
        self.verifyAadharOTPApi(params: params)
    }
    
    @IBAction func btnNextPressed(_ sender: Any) {
        self.view.endEditing(true)
        guard !otpRefID.isEmpty else { submitValidData(); return }
        validateOTP()
    }
}

extension SendAadharOTPVC {
    
    func sendAadharOTPApi(params:[String:Any]) {
        
        ApiClient.init().postRequest(params, request: URLMethods.BaseURL + URLMethods.sendAadharOTP, view: self.view) { (msg,result) in
            AppManager.stopActivityIndicator(self.view)
            if result != nil {
                if (result?.object(forKey: "success") as? Bool ?? false) == true {
                    AppManager.showToast(msg ?? "", view: self.view)
                    
                    if let data = result?.object(forKey: "results") as? [String:Any], let refId = data["ref_id"] as? String {
                        self.otpRefID = refId
                        self.txtFAadharNumberNumber.isUserInteractionEnabled = false
                        self.txtFOTP.superview?.isHidden = false
                        self.btnNext.setTitle("Verify", for: .normal)
                    }
                }
                else {
                    AppManager.showToast(msg ?? "", view: self.view)
                }
            }else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
        }
        AppManager.startActivityIndicator(sender: self.view)
    }
    
    func verifyAadharOTPApi(params: [String:Any]) {
        
        ApiClient.init().postRequest(params, request: URLMethods.BaseURL + URLMethods.verifyAadharOTP, view: self.view) { (msg,result) in
            
            AppManager.stopActivityIndicator(self.view)
            
            guard let result = result else {
                AppManager.showToast(msg ?? "", view: self.view)
                return
            }
            
            if (result.object(forKey: "success") as? Bool ?? false) == true {
                AppManager.showToast(msg ?? "", view: self.view)
                self.navigationController?.popViewController(animated: true)
            }
            else {
                AppManager.showToast(msg ?? "", view: self.view)
            }
        }
        AppManager.startActivityIndicator(sender: self.view)
    }
}


//MARK: Date Picker -> UITextFieldDelegate
@available(iOS 13.4, *)
extension SendAadharOTPVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       
        if (textField.text?.count ?? 0) == 0 && string == " "{
            return false
        }
        if textField == txtFAadharNumberNumber{
            if ((textField.text!) + string).count > 12 {
                return false
            }
        }
        
        return true
    }
}


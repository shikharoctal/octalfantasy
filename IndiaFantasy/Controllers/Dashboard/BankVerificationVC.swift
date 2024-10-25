//
//  BankVerificationVC.swift
//  CrypTech
//
//  Created by New on 16/03/22.
//

import UIKit
import Alamofire
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import SocketIO
class BankVerificationVC: BaseClassWithoutTabNavigation {

    @IBOutlet weak var navigationView: CustomNavigation!
    @IBOutlet weak var txtHAccountHolderName: MDCOutlinedTextField!
    @IBOutlet weak var txtFConfirmAccountNumber: MDCOutlinedTextField!
    @IBOutlet weak var txtFAccountNumber: MDCOutlinedTextField!
    @IBOutlet weak var txtFIFSC: MDCOutlinedTextField!
    


    var bankImage:UIImage? = nil
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnUpload: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
       // SocketIOManager.sharedInstance.delegateToHandleSocketConnection = self

        navigationView.configureNavigationBarWithController(controller: self, title: "Verify Bank Account", hideNotification: false, hideAddMoney: true, hideBackBtn: false)
        self.setupMaterialTextFields()
        if GlobalDataPersistance.shared.bank_verified == 3{
            self.setupUI()
        }

        // Do any additional setup after loading the view.
    }
    func setupMaterialTextFields(){
        self.txtHAccountHolderName.label.text = "Account Holder Name*"
        self.txtFAccountNumber.label.text = "Account Number *"
        self.txtFConfirmAccountNumber.label.text = "Retype Account Number *"
        self.txtFIFSC.label.text = "IFSC Code*"
        
        [self.txtHAccountHolderName, self.txtFAccountNumber, self.txtFConfirmAccountNumber, self.txtFIFSC].forEach({$0?.setOutlineColor(UIColor.appTextFieldBorder, for: .normal)})
        [self.txtHAccountHolderName, self.txtFAccountNumber, self.txtFConfirmAccountNumber, self.txtFIFSC].forEach({$0?.setOutlineColor(UIColor.appTextFieldBorder, for: .editing)})
    }
    
    func setupUI(){
        btnSubmit.isHidden = true
        txtHAccountHolderName.isUserInteractionEnabled = false
        txtFAccountNumber.isUserInteractionEnabled = false
        txtFConfirmAccountNumber.isUserInteractionEnabled = false

        txtFIFSC.isUserInteractionEnabled = false
        btnUpload.isHidden = true
        
        self.txtHAccountHolderName.text = (Constants.kAppDelegate.user?.account_holder_name ?? "")
        
        self.txtFConfirmAccountNumber.text = (Constants.kAppDelegate.user?.account_no ?? "")
        self.txtFIFSC.text = (Constants.kAppDelegate.user?.ifsc_code ?? "")
        
        self.txtFAccountNumber.text = self.txtFAccountNumber.text?.replaceAll(with: (Constants.kAppDelegate.user?.account_no ?? "").count)
            
        let last4 = String((Constants.kAppDelegate.user?.account_no ?? "").suffix(4))
        let remailStarC = ((Constants.kAppDelegate.user?.account_no ?? "").count) - 4
        let star = self.txtFConfirmAccountNumber.text?.replaceAll(with: remailStarC) ?? ""
        self.txtFConfirmAccountNumber.text =  star + last4
    }
    
    @IBAction func btnUploadPressed(_ sender: Any) {
        MediaPicker.shared.showActionSheet(viewController: self, type: .image)
        MediaPicker.shared.imagePickerBlock = { (image) -> Void in
            self.bankImage = image
            self.btnUpload.setTitle("Bank Verification Proof Selected", for: .normal)
        }
    }
    
    @IBAction func btnSubmitPressed(_ sender: Any) {
        submitValidData()
    }
}

extension BankVerificationVC{
    
    func submitValidData(){
        
        if self.txtHAccountHolderName.text?.count == 0
        {
            AppManager.showToast(ConstantMessages.ENT_ACCOUNT_HOLDERNAME, view: (self.view)!)
            return
        }
        if self.txtFAccountNumber.text?.count == 0
        {
            AppManager.showToast(ConstantMessages.ENT_ACCOUNT_NUMBER, view: (self.view)!)
            return
        }
        if self.txtFConfirmAccountNumber.text?.count == 0
        {
            AppManager.showToast(ConstantMessages.ENT_CONFIRM_ACCOUNT_NUMBER, view: (self.view)!)
            return
        }
        if (self.txtFAccountNumber.text ?? "") != (self.txtFConfirmAccountNumber.text ?? "")
        {
            AppManager.showToast(ConstantMessages.ACCOUNT_NUMBER_MISMATCH, view: (self.view)!)
            return
        }
        if self.txtFIFSC.text?.count == 0
        {
            AppManager.showToast(ConstantMessages.ENT_BANK_IFSC_CODE, view: (self.view)!)
            return
        }
        
        if self.txtFIFSC.text?.count != 11
        {
            AppManager.showToast(ConstantMessages.VALID_BANK_IFSC_CODE, view: (self.view)!)
            return
        }
        
        if CommonFunctions.isValidIFSCCode(code: self.txtFIFSC.text ?? "") == false{
            AppManager.showToast(ConstantMessages.VALID_BANK_IFSC_CODE, view: (self.view)!)
            return
        }
        
        let params:[String:Any] = [
                                   "full_name":txtHAccountHolderName.text ?? "",
                                   "bank_account":txtFAccountNumber.text ?? "",
                                   "ifsc":txtFIFSC.text ?? "",
                                    ]
        
        self.updateBankDetails(params: params)
    
    }
    
    
    func getBankDetailsApi(params:[String:Any]) {
        ApiClient.init().postRequest(params, request: URLMethods.BaseURL + URLMethods.getBankDetail, view: self.view) { [self] (msg,result) in
            if result != nil {
                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "message") as? String ?? ""
                if status == true{
                    if let result = result?.object(forKey: "results") as? [String:Any] {
                        txtFIFSC.isUserInteractionEnabled = false
                    } else {
                        txtFIFSC.isUserInteractionEnabled = true
                    }
                    
                }else{
                    AppManager.showToast(msg, view: (self.view))
                }
            }else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
            AppManager.stopActivityIndicator(self.view)
        }
        AppManager.startActivityIndicator(sender: self.view)
    }
    

    func updateBankDetails(params:[String:Any]) {
        ApiClient.init().postRequest(params, request: URLMethods.BaseURL + URLMethods.updateBankDetails, view: self.view) { (msg,result) in
            AppManager.stopActivityIndicator(self.view)
            if result != nil {
                if (result?.object(forKey: "success") as? Bool ?? false) == true {
                    print(result ?? [:])
                    AppManager.showToast(msg ?? "", view: self.view)
                    self.navigationController?.popViewController(animated: true)
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

}
extension BankVerificationVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField.text?.count ?? 0) == 0 && string == " "{
            return false
        }
        
        if textField == txtHAccountHolderName{
            let currentString: NSString = (textField.text ?? "") as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            if newString.length <= Constants.kCommonFieldLength{
                do {
                    let regex = try NSRegularExpression(pattern: ".*[^A-Za-z ].*", options: [])
                    if regex.firstMatch(in: string, options: [], range: NSMakeRange(0, string.count)) != nil {
                        return false
                    }
                }
                catch {
                    print("ERROR")
                }
                return true
            }
            return false
        }
        else if textField == txtFIFSC {
            // Convert the replacement string to uppercase
            let uppercasedString = string.uppercased()
            
            // Replace the text in the range with the uppercase string
            if let text = textField.text as NSString? {
                let newText = text.replacingCharacters(in: range, with: uppercasedString)
                textField.text = newText
            }
            
            return false
        }
        
        return true
    }
    
}

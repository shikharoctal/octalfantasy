//
//  ChangePasswordViewController.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 07/03/22.
//

import UIKit
import SwiftyJSON

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet weak var txtFCurrentPassword: UITextField!
    @IBOutlet weak var txtFNewPassword: UITextField!
    @IBOutlet weak var txtFConfirmNewPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func bttnBackAction(_ sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showPasswordPressed(_ sender: UIButton!) {
        sender.isSelected = !sender.isSelected
        
        switch sender.tag{
        case 1:
            txtFCurrentPassword.isSecureTextEntry =  CommonFunctions.updateSecureTextEntry(txtf: txtFCurrentPassword)
            break
        case 2:
            txtFNewPassword.isSecureTextEntry = CommonFunctions.updateSecureTextEntry(txtf: txtFNewPassword)
            break
        case 3:
            txtFConfirmNewPassword.isSecureTextEntry = CommonFunctions.updateSecureTextEntry(txtf: txtFConfirmNewPassword)
            break
            
        default:
            print("")
        }
    }
    
    @IBAction func btnContinuePressed(_ sender: Any) {
        self.submitValidData()
    }
}

extension ChangePasswordViewController{
    
    func submitValidData() {
        
        guard let currentPassword = txtFCurrentPassword.text, txtFCurrentPassword.text?.count != 0  else {
            AppManager.showToast(ConstantMessages.CurrentPassword_Empty.localized(), view: self.view)
            return
        }
        
        guard let newPassword = txtFNewPassword.text, txtFNewPassword.text?.count != 0  else {
            AppManager.showToast(ConstantMessages.NewPassword_Empty.localized(), view: self.view)
            return
        }
        
        if newPassword.count < 8 {
            AppManager.showToast(ConstantMessages.Password_lengthValidate.localized(), view: self.view)
            return
        }
        
        if CommonFunctions.isValidPassword(password: newPassword) == false{
            AppManager.showToast(ConstantMessages.Password_Validate.localized(), view: self.view)
            return
        }
        
        guard let confirmNewPassword = txtFConfirmNewPassword.text, txtFConfirmNewPassword.text?.count != 0  else {
            AppManager.showToast(ConstantMessages.ConfirmPassword_Empty.localized(), view: self.view)
            return
        }
        
        if newPassword != confirmNewPassword{
            
            AppManager.showToast(ConstantMessages.Password_Matched.localized(), view: self.view)
            return
        }
        
        self.changePassword(params: ["oldPassword": currentPassword, "newPassword": newPassword])
    }
    
    func changePassword(params:[String:Any]) {
        
        ApiClient.init().postRequest(params, request: URLMethods.BaseURL + URLMethods.changePassword, view: self.view) { (msg,result) in
            if result != nil {
                if (result?.object(forKey: "success") as? Bool ?? false) == true {
                    //                if data != nil{
                    let alert = UIAlertController(title: Constants.kAppDisplayName, message: msg, preferredStyle:.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
            }
            else {
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
extension ChangePasswordViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      
        if (textField.text?.count ?? 0) == 0 && string == " "{
            return false
        }
        
      if textField == txtFNewPassword || textField == txtFConfirmNewPassword{
            let currentString: NSString = (textField.text ?? "") as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= Constants.kPasswordLength
        }
        else{
            return true
        }
        
    }

}

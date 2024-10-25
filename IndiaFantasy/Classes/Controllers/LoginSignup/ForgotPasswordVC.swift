//
//  ForgotPasswordVC.swift
//  CrypTech
//
//  Created by New on 11/03/22.
//

import UIKit

class ForgotPasswordVC: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionResetPassword(_ sender: Any) {
        
        guard let email = txtEmail.text, !email.isEmptyOrWhitespace  else {
            AppManager.showToast(ConstantMessages.Email_Empty.localized(), view: self.view)
            return
        }
        
        guard let validemail = txtEmail.text, AppManager.validateEmail(with: txtEmail.text) else {
            AppManager.showToast(ConstantMessages.Email_Validate.localized(), view: self.view)
            return
        }
        
        requestForgotPassword(["email":validemail])
    }
}

//MARK: Web Service Calling
extension ForgotPasswordVC {
    
    func requestForgotPassword(_ params:[String:Any]) {
       
        ApiClient.init().postRequest(params, request: URLMethods.BaseURL + URLMethods.forgot_password, view: self.view) { (msg,result) in
            if result != nil {
                
                if (result?.object(forKey: "success") as? Int ?? 0) == 1 {
                    let alert = UIAlertController(title: Constants.kAppDisplayName, message: (result?.object(forKey: "msg") as? String ?? ""), preferredStyle:.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                else
                {
                    AppManager.showToast((result?.object(forKey: "msg") as? String ?? ""), view: self.view)
                }
            }else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
            AppManager.stopActivityIndicator(self.view)
        }
        AppManager.startActivityIndicator(sender: self.view)
    }
}

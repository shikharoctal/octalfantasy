//
//  ReferralCodeViewController.swift
//
//  Created by Octal-Mac on 04/11/22.
//

import UIKit

class ReferralCodeViewController: UIViewController {

    @IBOutlet weak var txtFInviteCode: UITextField!
    @IBOutlet weak var viewGard: Gradient!

    var completionHandler : ((Bool) -> Void)?
    var referralCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtFInviteCode.text = referralCode
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.viewGard.roundCorners(corners: [.topLeft, .topRight], radius: 20.0)
    }
    
    @IBAction func btnBackPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    @IBAction func btnVerifyPressed(_ sender: UIButton) {
        if (txtFInviteCode.text ?? "") == ""{
            AppManager.showToast("Please enter referral code", view: self.view)
            return
        }
        
        applyReferralCode(code: txtFInviteCode.text ?? "")
    }
}
extension ReferralCodeViewController {
    
    func applyReferralCode(code: String) {
        
        let params = ["referralCode": code]
        
        WebCommunication.shared.applyReferralCode(hostController: self, parameters: params, showLoader: true) { status, message in
            
            if status == true {
                
                self.alertBoxWithAction(message: message, btnTitle: ConstantMessages.OkBtn) {
                    self.dismiss(animated: true) {
                        if let completion = self.completionHandler {
                            completion(true)
                        }
                    }
                }
                
            }else {
                AppManager.showToast(message, view: self.view)
            }
        }
    }
}

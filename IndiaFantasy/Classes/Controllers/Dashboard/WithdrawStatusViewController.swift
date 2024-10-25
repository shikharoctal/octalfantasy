//
//  WithdrawStatusViewController.swift
//
//  Created by Octal-Mac on 01/12/22.
//

import UIKit

class WithdrawStatusViewController: UIViewController {

    @IBOutlet weak var lblMessage: UILabel!
    var completionHandler : ((Bool) -> Void)?

    var msg = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblMessage.text = msg
    }
    
    @IBAction func btnGoToHomePressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            if let comp = self.completionHandler{
                comp(true)
            }
        }
    }
    
}

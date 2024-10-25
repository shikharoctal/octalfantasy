//
//  CongratulationViewController.swift
//
//  Created by Octal-Mac on 01/12/22.
//

import UIKit

class CongratulationViewController: BaseClassWithoutTabNavigation {

    @IBOutlet weak var navigationView: CustomNavigation!
    @IBOutlet weak var lblMessage: UILabel!
    
    var msg = ""
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationView.configureNavigationBarWithController(controller: self, title: "KYC", hideNotification: false, hideAddMoney: true, hideBackBtn: false)
        navigationView.isCongratulationScreen = true
        self.lblMessage.text = msg
    }
    
    @IBAction func btnGoToHomePressed(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}

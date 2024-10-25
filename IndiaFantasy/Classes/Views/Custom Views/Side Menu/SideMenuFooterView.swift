//
//  SideMenuFooterView.swift
//  GymPod
//
//  Created by Octal Mac 217 on 23/11/21.
//

import UIKit

class SideMenuFooterView: UIView {

    @IBOutlet weak var viewSeprator: UIView!
    @IBOutlet weak var lblVersionNumber: UILabel!
    @IBOutlet weak var lblApptoDateStatic: UILabel!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var btnUpdate: UIButton!
    var controller:MenusViewController? = nil
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "SideMenuFooterView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
      }
    
    func updateView(){
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        self.lblVersionNumber.text = "App Version: \(appVersion ?? "1.0")"
        
    }
    @IBAction func btnLogoutPressed(_ sender: Any) {
        let alert = UIAlertController(title: Constants.kAppDisplayName, message: ConstantMessages.LogoutApp, preferredStyle:.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            Constants.kAppDelegate.logOutApp()
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
            
        }))
        self.controller!.present(alert, animated: true, completion: nil)
    }
    @IBAction func btnUpdateAction(_ sender: UIButton) {
    }
    
    
    
}

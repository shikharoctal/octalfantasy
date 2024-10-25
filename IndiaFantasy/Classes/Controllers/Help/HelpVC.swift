//
//  HelpVC.swift
//  CrypTech
//
//  Created by New on 11/03/22.
//

import UIKit
import SideMenu

class HelpVC: UIViewController {
    @IBOutlet weak var lblNotificationCount: UILabel!

    @IBOutlet weak var btnLiveChat: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        WebCommunication.shared.getUserProfile(hostController: self, showLoader: false) { user in
            if GlobalDataPersistance.shared.unreadNotificationCount == 0{
                self.lblNotificationCount.isHidden = true
            }else{
                self.lblNotificationCount.isHidden = true
            }
            self.lblNotificationCount.text = "\(GlobalDataPersistance.shared.unreadNotificationCount)"
        }
    }
    
    @IBAction func btnSideMenuPressed(_ sender: UIButton) {
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)

    }
    @IBAction func btnLiveChatPressed(_ sender: UIButton) {
        let vc = Constants.KHelpStoryboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func btnNotificationAction(_ sender: UIButton) {
        let VC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "NotificationsViewController") as! NotificationsViewController
        self.navigationController?.pushViewController(VC, animated: true)
    }
}

//
//  VCDownloadTeam.swift
//  KnockOut11
//
//  Created by Octal Mac 217 on 21/09/22.
//

import UIKit

class VCDownloadTeam: UIViewController {

    
    @IBOutlet weak var viewRoundCorners: UIView!
    
    var downloadTeamClouser: ((Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        viewRoundCorners.roundCorners(corners: [.topLeft,.topRight], radius: 20)
    }
    
    @IBAction func btnDismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    
    @IBAction func btnDownloadTeams(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            if GDP.selectedMatch?.match_status?.uppercased() ?? "" == "LIVE" || GDP.selectedMatch?.match_status?.uppercased() ?? "" == "IN PROGRESS" || GDP.selectedMatch?.match_status?.uppercased() ?? "" == "RUNNING"{
                AppManager.showToast("Winnings teams are visible once match is completed!", view: self.view)
                return
            }
            self.dismiss(animated: true) {
                self.downloadTeamClouser?(true)
            }
        case 2:
            self.dismiss(animated: true) {
                self.downloadTeamClouser?(false)
            }
        default:
            break
        }
    }
}



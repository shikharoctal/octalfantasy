//
//  SetRemindersVC.swift
//
//  Created by Octal-Mac on 31/10/22.
//

import UIKit

class SetRemindersVC: UIViewController {
    
    @IBOutlet weak var viewGard: UIView!
    @IBOutlet weak var lblMatchReminder: UILabel!
    @IBOutlet weak var lblSeriesReminder: UILabel!
    @IBOutlet weak var btnSeriesReminder: UISwitch!
    @IBOutlet weak var btnMatchReminder: UISwitch!
    var completionHandler : ((Match, Bool) -> Void)?

    var selectedMatch:Match? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblMatchReminder.text = "Match - \(self.selectedMatch?.localteam_short_name?.uppercased() ?? "") vs \(self.selectedMatch?.visitorteam_short_name?.uppercased() ?? "")"
        self.lblSeriesReminder.text = "\(self.selectedMatch?.series_name ?? "")"

        btnMatchReminder.isOn = self.selectedMatch?.is_match_reminder ?? false
        btnSeriesReminder.isOn = self.selectedMatch?.is_series_reminder ?? false

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.viewGard.roundCorners(corners: [.topLeft, .topRight], radius: 20.0)
    }

    @IBAction func btnBackPressed(_ sender: UIButton) {
        if let comp = self.completionHandler{
            self.dismiss(animated: false) {
                if let selectedMatch = self.selectedMatch {
                    comp(selectedMatch, true)
                }
            }
        }
    }
    
    @IBAction func btnMatchReminderPressed(_ sender: UISwitch) {
        if let match = self.selectedMatch{
           // if match.is_reminder == false{
            self.saveMatch(match: match, sender: sender)
            //}
        }
    }
    
    @IBAction func btnSeriesReminderPressed(_ sender: UISwitch) {
        if let match = self.selectedMatch{
           // if match.is_reminder == false{
            self.saveMatch(match: match, sender: sender)
            //}
        }
        
    }
}
extension SetRemindersVC{
    func saveMatch(match:Match, sender:UISwitch) {
        
        var params = [String:Any]()
        
        if sender == btnMatchReminder{
            params = ["match_id":"\(match.match_id ?? 0)",
             ]
        }else{
            params = [
                         "series_id":"\(match.series_id ?? 0)",
             ]
        }
        
        ApiClient.init().postRequest(params, request: URLMethods.BaseURL + URLMethods().saveMatchReminder, view: self.view) { (msg,result) in
            if result != nil {
                if (result?.object(forKey: "success") as? Bool ?? false) == true {
                    
                    if let matchModal = self.selectedMatch{
                        var matc = matchModal
                        if sender == self.btnMatchReminder{
                            matc.is_match_reminder = true
                        }else{
                            matc.is_series_reminder = true
                        }
                        self.selectedMatch = matc
                        
                        sender.isOn = true
                    }
            }
            else {
                if let matchModal = self.selectedMatch{
                    var matc = matchModal
                    if sender == self.btnMatchReminder{
                        matc.is_match_reminder = false
                    }else{
                        matc.is_series_reminder = false
                    }
                    self.selectedMatch = matc
                    sender.isOn = false
                }
            }

        }else{
            AppManager.showToast(msg ?? "", view: self.view)
        }
            
            AppManager.stopActivityIndicator(self.view)
        }
        AppManager.startActivityIndicator(sender: self.view)
    }
}

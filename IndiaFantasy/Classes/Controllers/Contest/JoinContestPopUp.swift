//
//  JoinContestPopUp.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 15/03/22.
//

import UIKit

class JoinContestPopUp: UIViewController {

    @IBOutlet weak var viewGard: Gradient!
    @IBOutlet weak var txtFInviteCode: UITextField!
    @IBOutlet weak var viewJoinContest: UIView!
    @IBOutlet weak var imgJoinContestArrow: UIImageView!
    @IBOutlet weak var viewJoinContestDivider: UIView!
    
    var inviteCode = ""
    
    var completionHandler : ((ContestData, Bool) -> Void)?
   
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.inviteCode.count > 0{
            txtFInviteCode.text = self.inviteCode
            self.joinContest()
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.viewGard.roundCorners(corners: [.topLeft, .topRight], radius: 20.0)
    }
    
    @IBAction func btnBackPressed(_ sender: UIButton) {
        self.dismiss(animated:false)
    }
    
    @IBAction func btnJoinContestPressed(_ sender: UIButton) {
        if txtFInviteCode.text?.count == 0
        {
            AppManager.showToast(ConstantMessages.ENT_INVITE_CODE, view: self.view)
            return
        }
        self.view.endEditing(true)
        
        self.joinContest()
    }
    @IBAction func btnCreateContestPressed(_ sender: UIButton) {
        if let comp = self.completionHandler{
            self.dismiss(animated: true) {
                comp(ContestData(), false)
            }
        }
    }
    
    @IBAction func btnExpendJoinContestPressed(_ sender: UIButton) {
     
        if viewJoinContest.isHidden {
            viewJoinContest.isHidden = false
            viewJoinContestDivider.isHidden = true
            imgJoinContestArrow.transform = imgJoinContestArrow.transform.rotated(by: .pi / 2)
        }else {
            viewJoinContest.isHidden = true
            viewJoinContestDivider.isHidden = false
            imgJoinContestArrow.transform = imgJoinContestArrow.transform.rotated(by: .pi * 1.5)
        }
    }
    
}

extension JoinContestPopUp{
    func joinContest (){
        let params:[String:String] = ["invite_code": txtFInviteCode.text ?? ""
        ]
        
        let url = URLMethods.BaseURL + URLMethods().joinContestViaInviteCode

        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                if result != nil {
                    let data = result?.object(forKey: "results") as? [String:Any]
                    let matchType = (result?.object(forKey: "match_type") as? String) ?? ""

                        if data != nil{
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                                  var contest = try? JSONDecoder().decode(ContestData.self, from: jsonData)else {return }
                            
                            guard let jsonData1 = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                                  let match = try? JSONDecoder().decode(Match.self, from: jsonData1)else {return }
                            
                            switch matchType.lowercased() {
                            case "cricket":
                                GDP.switchToCricket()
                                break
                            default:
                                break
                            }
                            
                            GDP.selectedMatch = match
                            var temp = contest
                            temp.id = contest.contest_id
                            contest = temp
                            if self.inviteCode.count > 0{
                               // GDP.selectedMatch = match
                            }
                            self.getContestDetails(contest_id: contest.id ?? "0", match_id: contest.match_id ?? 0, series: contest.series_id ?? 0)

                        }else{
                            AppManager.stopActivityIndicator(self.view)
                        }
                }else{
                    AppManager.stopActivityIndicator(self.view)
                }
            }
            
            else{
                AppManager.stopActivityIndicator(self.view)
                AppManager.showToast(msg ?? "", view: self.view)
            }
        }
        AppManager.startActivityIndicator(sender: self.view)
    }
    
    func getContestDetails (contest_id:String, match_id:Int, series:Int){
        let params:[String:String] = ["user_id": Constants.kAppDelegate.user?.id ?? "",
                                      "match_id":"\(match_id)",
                                       "series_id":"\(series)",
                                      "contest_id":contest_id
        ]
        
        let url = URLMethods.BaseURL + URLMethods().getContestDetail

        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            AppManager.stopActivityIndicator(self.view)

            if isSuccess == true{
                if result != nil {
                    let data = result?.object(forKey: "results") as? [String:Any]
                        if data != nil{
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                                  let tblData = try? JSONDecoder().decode(ContestData.self, from: jsonData)else {return }
                            let contest = tblData
                            
//                            if contest.join_multiple_team == false{
//                                AppManager.showToast(ConstantMessages.ALREADY_JOINED_THIS_CONTEST, view: self.view)
//                                return
//                            }
                            if (contest.my_team_ids ?? [String]()).count == contest.max_team_join_count ?? 0
                            {
                                AppManager.showToast(ConstantMessages.CAN_NOT_JOIN_MORE_TEAMS, view: self.view)
                                return
                            }
                            
                            if let comp = self.completionHandler{
                                self.dismiss(animated: true) {
                                    comp(contest, true)
                                }
                            }else{
                                self.dismiss(animated: true, completion: nil)
                            }
                            
                        }
                }
            }
            
            else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
        }
        AppManager.startActivityIndicator(sender: self.view)
    }
}

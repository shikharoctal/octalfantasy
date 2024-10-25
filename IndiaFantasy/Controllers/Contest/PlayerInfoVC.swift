//
//  PlayerInfoVC.swift
//  CrypTech
//
//  Created by New on 15/03/22.
//

import UIKit
import SwiftUI
import CoreMIDI

class PlayerInfoVC: BaseClassWithoutTabNavigation {
    
    @IBOutlet weak var viewPlayerImage: UIView!
    @IBOutlet weak var navigationView: CustomNavigation!
    @IBOutlet weak var imgPlayer: UIImageView!
    @IBOutlet weak var lblPlayerName: UILabel!
    @IBOutlet weak var tblFantasyStats: UITableView!
    @IBOutlet weak var lblMatchPlayedStatus: UILabel!
    @IBOutlet weak var lblTotalPoints: UILabel!
    @IBOutlet weak var lblCredits: UILabel!
    @IBOutlet weak var lblNationality: UILabel!
    @IBOutlet weak var lblTeamName: UILabel!
    @IBOutlet weak var addToTeamBottom: NSLayoutConstraint!
    @IBOutlet weak var AddToTeamHeight: NSLayoutConstraint!
    @IBOutlet weak var btnAddToTeam: UIButton!
    var isCreateTeam = false
    var inMyTeam = false
    
    var selectedMatch: Match? = nil
    var playerId = ""
    var completionHandler : ((Player) -> Void)?

    var playerInfo:Player? = nil
    var isFromLeague: Bool = false
    
    var arrBoosters: [Booster] = []
    var arrDebuffed: [Booster] = []
    
    var isBoosterSeleced: Bool = false
    var isDebuffedSeleced: Bool = false
    
    var arrKeys = ["starting11",
                   "runs",
                   "fours",
                   "sixes" ,
                   "strike_rate" ,
                   "half_century" ,
                   "duck" ,
                   "wickets" ,
                   "maiden_over" ,
                   "eco_rate" ,
                   "bonus" ,
                   "catch" ,
                   "run_outStumping" ,
                   "thirty_runs",
                   "threeCatchCount",
                   "indirectRunOut",
                   "lbwOrBowledCount",
                   "total_point"  ]
    
    var arrValues = ["bonus" : "Bonus",
                     "run_outStumping" : "Run Out/Stumping",
                     "starting11" : "Starting 11",
                     "fours" : "4's",
                     "duck" : "Duck",
                     "strike_rate" : "S/R",
                     "maiden_over" : "Maiden Over",
                     "catch" : "Catches",
                     "total_point" : "Total",
                     "eco_rate" : "E/R",
                     "half_century" : "50",
                     "wickets" : "Wicket",
                     "sixes" : "6's",
                     "thirty_runs" : "30's",
                     "threeCatchCount": "Three Catches",
                     "indirectRunOut": "Indirect Run Out",
                     "lbwOrBowledCount": "LBW/Bowled",
                     "runs" : "Runs"] as NSDictionary
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationView.configureNavigationBarWithController(controller: self, title: "Player Info", hideNotification: isFromLeague, hideAddMoney: true, hideBackBtn: false)
        navigationView.img_BG.isHidden = true
        setupUI()
        nibSetUp()
    }
    
    func nibSetUp() {
        
        let nibCell = UINib(nibName: "PlayerPointsBreakupTVCell", bundle: nil)
        tblFantasyStats.register(nibCell, forCellReuseIdentifier: "PlayerPointsBreakupTVCell")
        
        let nibHeader = UINib(nibName: "FantasyStatsTVHeader", bundle: nil)
        tblFantasyStats.register(nibHeader, forHeaderFooterViewReuseIdentifier: "FantasyStatsTVHeader")
        
        let nibBoosterCell = UINib(nibName: "PlayerBoosterTVCell", bundle: nil)
        tblFantasyStats.register(nibBoosterCell, forCellReuseIdentifier: "PlayerBoosterTVCell")
        
        let nibBoosterHeader = UINib(nibName: "StatsBoosterTVHeader", bundle: nil)
        tblFantasyStats.register(nibBoosterHeader, forHeaderFooterViewReuseIdentifier: "StatsBoosterTVHeader")
    }
    
    func setupUI() {
        // Populate data here
        
        let playingRole = (playerInfo?.playing_role ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let battingStyle = (playerInfo?.batting_style ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let bowlingStyle = (playerInfo?.bowling_style ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        var matchPlayedStatus = ""
        
        if playingRole != "" {
            matchPlayedStatus = playingRole
        }else if battingStyle != "" {
            matchPlayedStatus += (matchPlayedStatus != "") ? (" & " + battingStyle) : battingStyle
        }else if bowlingStyle != "" {
            matchPlayedStatus += (matchPlayedStatus != "") ? (" & " + bowlingStyle) : bowlingStyle
        }
        
        imgPlayer.loadImage(urlS: playerInfo?.player_image, placeHolder: Constants.kNoPlayer)
        lblPlayerName.text = playerInfo?.player_name ?? ""
        lblTeamName.text = playerInfo?.team_short_name ?? ""
        
        lblMatchPlayedStatus.text = matchPlayedStatus
        
        lblTotalPoints.text = "\(playerInfo?.total_points ?? 0.0)"
        lblCredits.text = "\(playerInfo?.player_credit ?? 0.0)"
        lblNationality.text = playerInfo?.nationality ?? ""
        
        if self.isCreateTeam == true{
            if GDP.selectedMatch?.match_status?.uppercased() == "NOT STARTED" || GDP.selectedMatch?.match_status?.uppercased() == "UPCOMING" || GDP.selectedMatch?.match_status?.uppercased() == "FIXTURE" {
                self.AddToTeamHeight.constant = 50
                self.addToTeamBottom.constant = 25
                
                if self.inMyTeam == true{
                    btnAddToTeam.setTitle("Remove from My Team", for: .normal)
//                    btnAddToTeam.backgroundColor = UIColor.appHighlightedTextColor
                }else{
                    btnAddToTeam.setTitle("Add to My Team", for: .normal)
//                    btnAddToTeam.backgroundColor = UIColor.appHighlightedTextColor
                }
            }else{
                self.AddToTeamHeight.constant = 0
                self.addToTeamBottom.constant = 0
            }
        }else{
            self.AddToTeamHeight.constant = 0
            self.addToTeamBottom.constant = 0
        }
        
        if isFromLeague {
            self.viewPlayerImage.borderColor = UIColor.red
        }else {
            if (playerInfo?.team_id ?? 0) == (GDP.selectedMatch?.localteam_id ?? 0){
                self.viewPlayerImage.borderColor = UIColor.appLocalTeamBackgroundColor
            }else{
                self.viewPlayerImage.borderColor = UIColor.appVisitorTeamBackgroundColor
            }
        }
        
        
        
        tblFantasyStats.reloadData()
    }
    
    @IBAction func btnAddToTeamPressed(_ sender: UIButton) {
        if let comp = self.completionHandler{
           self.dismiss(animated: true) {
               if let playerInfo = self.playerInfo {
                   comp(playerInfo)
               }
           }
       }else{
           self.dismiss(animated: true, completion: nil)
       }
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


//MARK: UITableView Methods
extension PlayerInfoVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (self.playerInfo?.match_details?.count ?? 0) + 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return arrBoosters.count
        case 1:
            return arrDebuffed.count
        default:
            guard let playerBreckup = playerInfo?.match_details?[section-2].playerBreckup, !playerBreckup.isEmpty else {
                return 0
            }
            return self.arrKeys.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 || indexPath.section == 1 {
         
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerBoosterTVCell") as! PlayerBoosterTVCell
            
            let booster = (indexPath.section == 0) ? arrBoosters[indexPath.row] : arrDebuffed[indexPath.row]
            cell.setData = booster
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerPointsBreakupTVCell") as! PlayerPointsBreakupTVCell
        
        let key = self.arrKeys[indexPath.row]
        guard let playerBreakup = (playerInfo?.match_details?[indexPath.section-2].playerBreckup) else { return cell }
        
        let pointsData = playerBreakup["\(key)"]

        cell.lblEvents.text = "\(self.arrValues["\(key)"] ?? "")"
        cell.lblActualValue.text = "\(pointsData?.actual?.value ?? "" )"
        cell.lblPointsEarned.text = "\(self.getDouble(for: pointsData?.points?.value as Any))"

//        if indexPath.row == 5 && self.runsScored >= 100 {
//            cell.lblEvents.text = "100"
//        }else if indexPath.row == 1 {
//            self.runsScored = Int("\(pointsData?.actual?.value ?? "")") ?? 0
//        }

        if key == "starting11" || key == "duck" || key == "inPlaying11" || key == "isSubstitute" {
            cell.lblActualValue.text = cell.lblActualValue.text == "0" ? "No" : "Yes"
        }
        
        if indexPath.row == 4 || indexPath.row == 9 {
            cell.lblActualValue.text = cell.lblPointsEarned.text
        }
        
        cell.lblActualValue.isHidden = (indexPath.row == (arrKeys.count - 1)) ? true : false

        if cell.lblActualValue.text == "" {
           cell.lblActualValue.text = "0"
        }
        if cell.lblPointsEarned.text == "" {
           cell.lblPointsEarned.text = "0"
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      
        switch section {
        case 0,1:
            
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "StatsBoosterTVHeader") as! StatsBoosterTVHeader
            
            func getAttributedText(first: String, second: String) -> NSMutableAttributedString {
                let headertitle = first.withAttributes([
                    .textColor(UIColor.white),
                    .font(UIFont(name: Constants.kSemiBoldFont, size: header.lblTitle.font.pointSize)!)
                    ])
                let count = second.withAttributes([
                    .textColor(UIColor.appHighlightedTextColor),
                    .font(UIFont(name: Constants.kSemiBoldFont, size: header.lblTitle.font.pointSize)!)
                    ])
                
                let result = NSMutableAttributedString()
                result.append(headertitle)
                result.append(count)
                return result
            }
            
            
            if section == 0 {
                
                header.viewContanier.isHidden = arrBoosters.isEmpty
                header.btnDropDown.isSelected = isBoosterSeleced
                header.lblTitle.attributedText = getAttributedText(first: "Booster(s) on the player ", second: "(\(arrBoosters.count))")
            }else {
                
                header.viewContanier.isHidden = arrDebuffed.isEmpty
                header.btnDropDown.isSelected = isDebuffedSeleced
                header.lblTitle.attributedText = getAttributedText(first: "Debuff(s) on the player ", second: "(\(arrDebuffed.count))")
            }
            
            header.btnDropDown.tag = section
            header.btnDropDown.addTarget(self, action: #selector(showBoosterDebuffBtnTap(_:)), for: .touchUpInside)
            return header
        
        default:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FantasyStatsTVHeader") as! FantasyStatsTVHeader
            header.metchDetails = self.playerInfo?.match_details?[section-2]
            header.updateView()
            header.viewHeaderTitle.isHidden = (section == 2) ? false : true
            header.btnDropDown.tag = section
            header.btnDropDown.addTarget(self, action: #selector(showPlayerBreakupBtnTap(_:)), for: .touchUpInside)
            return header
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return UITableView.automaticDimension
    }
        
    @objc func showPlayerBreakupBtnTap(_ sender: UIButton) {
        
        if let matchDetails = self.playerInfo?.match_details?[sender.tag-2], let playerBreckup = matchDetails.playerBreckup, !playerBreckup.isEmpty {
            
            self.playerInfo?.match_details?[sender.tag-2].isPlayerBreckupShow = !matchDetails.isPlayerBreckupShow
            
            DispatchQueue.main.async {
                self.tblFantasyStats.reloadSections(IndexSet(integer: sender.tag), with: .automatic)
            }
        }
    }
    
    @objc func showBoosterDebuffBtnTap(_ sender: UIButton) {
        
        if sender.tag == 0 {
            isBoosterSeleced = !isBoosterSeleced
            
        }else {
            isDebuffedSeleced = !isDebuffedSeleced
        }
        
        DispatchQueue.main.async {
            self.tblFantasyStats.reloadSections(IndexSet(integer: sender.tag), with: .automatic)
        }
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        switch indexPath.section {
        case 0:
            return isBoosterSeleced ? UITableView.automaticDimension : 0
        case 1:
            return isDebuffedSeleced ? UITableView.automaticDimension : 0
        default:
            if let matchDetails = self.playerInfo?.match_details?[indexPath.section-2], let playerBreckup = matchDetails.playerBreckup, playerBreckup.isEmpty {
                return 0
            }else {
                if self.playerInfo?.match_details?[indexPath.section-2].isPlayerBreckupShow == false {
                    return 0
                }
            }
            return UITableView.automaticDimension
        }
    }
    
}
extension PlayerInfoVC{
    func getPlayerDetails(){
        let params:[String:Any] = ["player_id": Int(self.playerId ) ?? 0,
                                   "series_id":GDP.selectedMatch?.series_id ?? 0
        ]
        
        let url = URLMethods.BaseURL + URLMethods().getSeriesPlayerDetails
        
        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                if result != nil {
                    let data = result?.object(forKey: "results") as? [String:Any]
                    if data != nil{
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                              let tblData = try? JSONDecoder().decode(Player.self, from: jsonData)else {return }
                        self.playerInfo = tblData
                        if tblData.match_details?.isEmpty == true {
                            AppManager.showToast(ConstantMessages.NoMatchDetailsFound, view: self.view)
                        }
                        self.setupUI()
                    }
                }
            }
            
            else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
            AppManager.stopActivityIndicator(self.view)
        }
        AppManager.startActivityIndicator(sender: self.view)
    }
}

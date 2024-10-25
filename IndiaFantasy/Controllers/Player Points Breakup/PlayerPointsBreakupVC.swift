//
//  PlayerPointsBreakupVC.swift
//  CrypTech
//
//  Created by New on 23/03/22.
//

import UIKit

class PlayerPointsBreakupVC: BaseClassWithoutTabNavigation {

    @IBOutlet weak var viewPlayerImage: UIView!
    @IBOutlet weak var navigationView: CustomNavigation!
    @IBOutlet weak var lblTeamShortName: UILabel!
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var lblPlayerName: UILabel!
    @IBOutlet weak var imgPlayer: UIImageView!
    @IBOutlet weak var lblSelectedBy: UILabel!
    @IBOutlet weak var lblPoints: UILabel!
    @IBOutlet weak var lblCredits: UILabel!
    @IBOutlet weak var lblTeamName: UILabel!
    @IBOutlet weak var lblCreditsText: UILabel!
    
    var arrBoosters: [Booster] = []
    var arrDebuffed: [Booster] = []
    
    var isBoosterSeleced: Bool = false
    var isDebuffedSeleced: Bool = false
    
    var runsScored = 0
    var player_stats : Player? = nil
    var playerId = 0
    var arrKeys = [String]()
    var arrValues: NSDictionary = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationView.configureNavigationBarWithController(controller: self, title: "Player Info", hideNotification: false, hideAddMoney: true, hideBackBtn: false)
        navigationView.img_BG.isHidden = true
        
        setupTableView()
        
        if (player_stats?.team_id ?? 0) == (GDP.selectedMatch?.localteam_id ?? 0){
            self.viewPlayerImage.borderColor = UIColor.appLocalTeamBackgroundColor
        }else{
            self.viewPlayerImage.borderColor = UIColor.appVisitorTeamBackgroundColor
        }
        
        DispatchQueue.main.async {
            self.getPlayerDetails()
        }
        //self.setDataOnLables()
    }
    
    func setupTableView() {
        
        let nibSetUp = UINib(nibName: "PlayerPointsBreakupTVCell", bundle: nil)
        tblView.register(nibSetUp, forCellReuseIdentifier: "PlayerPointsBreakupTVCell")
        
        let nibHeader = UINib(nibName: "StatsBreakupTVHeader", bundle: nil)
        tblView.register(nibHeader, forHeaderFooterViewReuseIdentifier: "StatsBreakupTVHeader")
        
        let nibBoosterCell = UINib(nibName: "PlayerBoosterTVCell", bundle: nil)
        tblView.register(nibBoosterCell, forCellReuseIdentifier: "PlayerBoosterTVCell")
        
        let nibBoosterHeader = UINib(nibName: "StatsBoosterTVHeader", bundle: nil)
        tblView.register(nibBoosterHeader, forHeaderFooterViewReuseIdentifier: "StatsBoosterTVHeader")
    }
    
    func setDataOnLables(player: Player) {
        
        self.lblPlayerName.text = player.player_name ?? ""
        self.lblSelectedBy.text = (player.selection_percent ?? "")
        self.lblPoints.text = "\(player.points ?? Double())"
        self.lblCredits.text = "\(player.player_credit ?? Double())"
        self.lblTeamShortName.text = "\(player.team_short_name ?? "")"
        self.imgPlayer.loadImage(urlS: player.player_image, placeHolder: Constants.kNoPlayer)
        
        var battStyle = ""
        var bowlStyle = ""
        if let battingStyle = player.batting_style {
            battStyle = " & " + battingStyle
        }
        if let bowlingStyle = player.bowling_style {
            bowlStyle = "" + bowlingStyle
        }
        self.lblTeamName.text = (player.playing_role ?? "") + "\(battStyle) \(bowlStyle)"
        
        if let player_stats = player_stats {
            
            var teamNo = ""
            if let team_number = player_stats.team_number{
                for teamNumber in team_number {
                    teamNo = teamNo.count > 0 ? (teamNo + ", ") : ""
                    teamNo = teamNo + "T\(teamNumber)"
                }
            }
            
            teamNo = teamNo.count == 0 ? "Not in your team" : teamNo
        }
        
        if player.playerBreckup == nil || player.playerBreckup?.isEmpty == true {
            AppManager.showToast(ConstantMessages.PLAYER_STATS_NOT_AVL, view: self.view)
        }else {
            setupPlayerBreckup()
        }
        player_stats = player
        tblView.reloadData()
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension PlayerPointsBreakupVC : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return  3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return arrBoosters.count
        case 1:
            return arrDebuffed.count
        default:
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
        
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.appPrimaryColor
        cell.selectedBackgroundView = backgroundView
        
        let key = self.arrKeys[indexPath.row]
        if let playerBreakup = self.player_stats?.playerBreckup{
            let pointsData = playerBreakup["\(key)"]

            cell.lblEvents.text = "\(self.arrValues["\(key)"] ?? "")"
            cell.lblActualValue.text = "\(pointsData?.actual?.value ?? "" )"
            cell.lblPointsEarned.text = "\(self.getDouble(for: pointsData?.points?.value as Any))"

            if indexPath.row == 5 && self.runsScored >= 100 {
                cell.lblEvents.text = "100"
            }else if indexPath.row == 1 {
                self.runsScored = Int("\(pointsData?.actual?.value ?? "")") ?? 0
            }

            if key == "starting11" || key == "duck" {
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
            
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "StatsBreakupTVHeader") as! StatsBreakupTVHeader
            return header
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return isBoosterSeleced ? UITableView.automaticDimension : 0
        case 1:
            return isDebuffedSeleced ? UITableView.automaticDimension : 0
        default:
            return UITableView.automaticDimension
        }
    }
    
    @objc func showBoosterDebuffBtnTap(_ sender: UIButton) {
        
        if sender.tag == 0 {
            isBoosterSeleced = !isBoosterSeleced
        }else {
            isDebuffedSeleced = !isDebuffedSeleced
        }
        
        DispatchQueue.main.async {
            self.tblView.reloadSections(IndexSet(integer: sender.tag), with: .automatic)
        }
    }
}
extension PlayerPointsBreakupVC{
    func getPlayerDetails(){
        let params:[String:Any] = ["player_id": playerId,
                                   "series_id":GDP.selectedMatch?.series_id ?? 0,
                                   "match_id": GDP.selectedMatch?.match_id ?? 0
        ]
        
        let url = URLMethods.BaseURL + URLMethods().getPlayerStatsForSingleMatch
        
        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                if result != nil {
                    let data = result?.object(forKey: "results") as? [[String:Any]]
                    if data != nil{
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                              let tblData = try? JSONDecoder().decode([Player].self, from: jsonData)else {
                                  AppManager.stopActivityIndicator(self.view)
                                  return
                              }
                        if let pData = tblData.first {
                            self.setDataOnLables(player: pData)
                        }

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

extension PlayerPointsBreakupVC {
    
    func setupPlayerBreckup() {
        
        arrKeys = ["starting11",
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
                   "total_point"]
        
        arrValues = ["bonus" : "Bonus",
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
    }
}

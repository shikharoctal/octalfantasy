//
//  SeasonChooseCaptainVC.swift
//  India’s fantasy
//
//  Created by admin on 04/05/23.
//

import UIKit
import SDWebImage

class SeasonChooseCaptainVC: UIViewController {
    
    @IBOutlet weak var navigationView: SeasonNavigation!
    
    @IBOutlet weak var lblMatchName: UILabel!
    @IBOutlet weak var lblVisitorTeam: UILabel!
    @IBOutlet weak var lblHomeTeam: UILabel!
    @IBOutlet weak var imgVisitorTeam: UIImageView!
    @IBOutlet weak var imgLocalTeam: UIImageView!
    
    @IBOutlet weak var lblTransferInUse: UILabel!
    @IBOutlet weak var btnHistory: UIButton!
    
    @IBOutlet weak var btnPerVCSort: OctalButton!
    @IBOutlet weak var btnPerCSort: OctalButton!
    @IBOutlet weak var btnPointsSort: OctalButton!
    @IBOutlet weak var lblBoostersSort: UILabel!
    @IBOutlet weak var tblTeamPlayers: UITableView!
    @IBOutlet weak var btnSaveTeam: UIButton!
    
    @IBOutlet weak var imgFirstAppliedBooster: UIImageView!
    @IBOutlet weak var imgSecondAppliedBooster: UIImageView!
    
    var arrPlayers = [Player]()
    var arrWicketKeeper = [Player]()
    var arrBatsman = [Player]()
    var arrBowler = [Player]()
    var arrAllRounder = [Player]()
    
    var arrAllPlayers = [Player]()
    
    var substituteId = ""
    var strTeamID = ""
    
    var strViceCaptain = ""
    var strCaptain = ""
    var isFromVC  = ""
    var strTeamNumber = ""
    var strBoosterPlayerId = ""
    
//    var selectedCaptainRow = -2
//    var selectedViceCaptainRow = -2
//    var selectedBoosterPlayerRow = -2
    
    var captainPoints = ""
    var viceCaptainPoints = ""
    var isFromEdit = ""
    
    var playerTypeCount = SelectedPlayerTypes()
    var arrPlayerTypes = [PlayerType]()
    
    var selectedBooster: Booster? = nil
    var transfersUse = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        
        setupNavigationView()
        
        if #available(iOS 15.0, *) {
            self.tblTeamPlayers.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        
        if self.isFromVC == "Edit" {
            btnHistory.isHidden = false
            btnSaveTeam.setTitle("Next", for: .normal)
            lblTransferInUse.text = transfersUse
            lblTransferInUse.isHidden = false
        }
        
        if let match = GDP.selectedMatch {
            
            lblMatchName.text = "Match \(match.matchNumber ?? 0)"
            imgLocalTeam.loadImage(urlS: match.localteam_flag, placeHolder: Constants.kNoImageUser)
            lblHomeTeam.text = match.localteam_short_name
            imgVisitorTeam.loadImage(urlS: match.visitorteam_flag, placeHolder: Constants.kNoImageUser)
            lblVisitorTeam.text = match.visitorteam_short_name
            
            //CommonFunctions().timerStart(date: navigationView.lblSubTitle, strTime: match.start_time ?? "", strDate: match.start_date, viewcontroller: self)
            CommonFunctions().timerStart(lblTime: navigationView.lblSubTitle, strDate: match.match_date ?? "", viewcontroller: self, fromSeasonMyTeams: false)
        }
        
        getPlayerList()
        setupSelectedBooster(fromDidLoad: true)
        
        self.strCaptain = self.playerTypeCount.captainId
        self.strViceCaptain = self.playerTypeCount.viceCaptainId
        self.populatePlayerList(filterKey: "")
        
        tblTeamPlayers.reloadData()
    }
    
    private func setupNavigationView() {
        
        navigationView.setupUI(title: GDP.leagueName, hideBG: true)
    }
    
    func setupSelectedBooster(fromDidLoad: Bool = false) {
        
        imgFirstAppliedBooster.image = nil
        imgFirstAppliedBooster.isHidden = true
        imgSecondAppliedBooster.image = nil
        imgSecondAppliedBooster.isHidden = true
        
        guard let booster = selectedBooster, booster.boosterImage != nil else {
            
            for index in 0..<self.arrPlayerTypes.count {
                for subIndex in 0..<(self.arrPlayerTypes[index].players?.count ?? 0) {
                    self.arrPlayerTypes[index].players?[subIndex].isBoosterPlayer = false
                }
            }
            strBoosterPlayerId = ""
            lblBoostersSort.isHidden = true
            return
        }
        
        lblBoostersSort.isHidden = false
        imgFirstAppliedBooster.loadImage(urlS: booster.boosterImage, placeHolder: Constants.kNoImage)
        imgFirstAppliedBooster.isHidden = false
        
//        if let selectedBooster = selectedBooster, selectedBooster.contains(where: {$0.boosterName != BoosterType.TRIPLE_SCORER.name}) {
//            self.strBoosterPlayerId = ""
//        }
        
        if fromDidLoad == false && booster.boosterName == BoosterType.TRIPLE_SCORER.name {
            self.strBoosterPlayerId = ""
            
            for index in 0..<self.arrPlayerTypes.count {
                for subIndex in 0..<(self.arrPlayerTypes[index].players?.count ?? 0) {
                    self.arrPlayerTypes[index].players?[subIndex].isBoosterPlayer = false
                }
            }
        }
    }

    
    //MARK: - Booster Btn Pressed
    @IBAction func btnBoosterPressed(_ sender: UIButton) {
        let boostersVC = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "BoostersVC") as! BoostersVC
        
        boostersVC.teamId = strTeamID
        boostersVC.isFromCreateTeam = true
        if let selectedBooster = selectedBooster {
            boostersVC.selectedBooster = [selectedBooster]
        }
        boostersVC.teamName = Int(strTeamNumber) ?? 0
        
        boostersVC.completion = { booster in
            
            if booster.count > 1  {
                self.strBoosterPlayerId = ""
                for index in 0..<self.arrPlayerTypes.count {
                    for subIndex in 0..<(self.arrPlayerTypes[index].players?.count ?? 0) {
                        self.arrPlayerTypes[index].players?[subIndex].isBoosterPlayer = false
                    }
                }
            }
            
            self.selectedBooster = booster.first
            self.setupSelectedBooster()
            self.tblTeamPlayers.reloadData()
        }
        
        self.navigationController?.pushViewController(boostersVC, animated: false)
    }
    
    //MARK: - Sorting
    @IBAction func btnSortByPointsPressed(_ sender: UIButton) {
        
        if btnPointsSort.image(for: .selected)!.isEqualToImage(Constants.kSortUpHighLight!){
            btnPointsSort.setImage(Constants.kSortDownHighLight, for: .selected)
        }else{
            btnPointsSort.setImage(Constants.kSortUpHighLight, for: .selected)
        }
        
        self.populatePlayerList(filterKey: "Points")
    }
    
    @IBAction func btnSortByCaptainPercentPressed(_ sender: UIButton) {
        
        if btnPerCSort.image(for: .selected)!.isEqualToImage(Constants.kSortUpHighLight!){
            btnPerCSort.setImage(Constants.kSortDownHighLight, for: .selected)
        }else{
            btnPerCSort.setImage(Constants.kSortUpHighLight, for: .selected)
        }
        
        self.populatePlayerList(filterKey: "C")
    }
    
    @IBAction func btnSortByVCPercentPressed(_ sender: UIButton) {
        
        if btnPerVCSort.image(for: .selected)!.isEqualToImage(Constants.kSortUpHighLight!){
            btnPerVCSort.setImage(Constants.kSortDownHighLight, for: .selected)
        }else{
            btnPerVCSort.setImage(Constants.kSortUpHighLight, for: .selected)
        }
        
        sender.isSelected = !sender.isSelected
        self.populatePlayerList(filterKey: "VC")
    }
    
    @IBAction func btnSaveTeamPressed(_ sender: UIButton) {
        
        if self.strCaptain == "" || self.strViceCaptain == ""
        {
            let message = self.strCaptain == "" ? ConstantMessages.SELECT_CAPTAIN : ConstantMessages.SELECT_VICE_CAPTAIN
            AppManager.showToast(message, view: self.view)
            return
        }
        
        if let selectedBooster = selectedBooster, (selectedBooster.boosterName == BoosterType.TRIPLE_SCORER.name) && strBoosterPlayerId == "" {
            AppManager.showToast(ConstantMessages.SELECT_BOOSTER_PLAYER, view: self.view)
            return
        }
        
//        var appliedBooster = [[String: Any]]()
//        selectedBooster?.forEach({ booster in
//            appliedBooster.append(["code": booster.boosterCode ?? 0, "id": booster.boosterUniqueID ?? ""])
//        })

        let selectedPlayers = arrPlayers.map({"\($0.player_id ?? 0)"})
        debugPrint("SelectedPlayers", selectedPlayers)

        var params:[String:Any] = [
            "match_id": GDP.selectedMatch?.match_id ?? 0,
            "series_id": Int(GDP.leagueSeriesId) ?? 0,
            "player_id": selectedPlayers,
            "team_id": self.strTeamID,
            "captain": strCaptain,
            "vice_captain": strViceCaptain,
            "boosterCode": selectedBooster?.boosterCode ?? 0
        ]

        if let selectedBooster = selectedBooster, (selectedBooster.boosterName == BoosterType.TRIPLE_SCORER.name) {
            params["boostedPlayerId"] = Int(strBoosterPlayerId) ?? 0
        }

        if isFromEdit == "Edit" {

            let vc = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonTransferPreviewVC") as! SeasonTransferPreviewVC
            vc.requestParams = params
            vc.teamName = self.strTeamNumber
            vc.selectedBooster = self.selectedBooster
            self.navigationController?.pushViewController(vc, animated: true)

        }else {
            self.addEditTeam(params: params)
        }
        
    }
    
    
    @IBAction func btnPreviewTeamPressed(_ sender: Any) {
        
        let vc = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonTeamPreviewVC") as! SeasonTeamPreviewVC
        
        vc.teamNumber = ""
        vc.strFromVC = "CreateTeam"
        
        let arrPlayers = self.arrPlayers
        var arrPlayerData = [PlayerDetails]()
        var selectedPlayers = SelectedPlayerTypes()
        
        
        if arrPlayers.count > 0
        {
            for index  in 0..<arrPlayers.count {
                let player = arrPlayers[index]
                var playerData = PlayerDetails()
                playerData.name = "\(player.player_name ?? "")"
                playerData.credits = "\(player.player_credit ?? 0)"
                playerData.role = "\(player.player_role ?? "")"
                playerData.points = "\(player.player_points ?? 0)"
                playerData.image = "\(player.player_image ?? "")"
                playerData.player_id = "\(player.player_id ?? 0)"
                playerData.is_local_team = "\(player.team_id ?? 0)".caseInsensitiveCompare("\(GDP.selectedMatch?.localteam_id ?? 0)") == .orderedSame
                playerData.is_playing = player.is_playing ?? false
                playerData.teamShortName = player.team_short_name ?? ""
                
                arrPlayerData.append(playerData)
            }
        }
        
        selectedPlayers.batsman =  self.playerTypeCount.batsman
        selectedPlayers.allrounder =  self.playerTypeCount.allrounder
        selectedPlayers.bowler =   self.playerTypeCount.bowler
        selectedPlayers.wicketkeeper = self.playerTypeCount.wicketkeeper
        selectedPlayers.captainId = self.strCaptain
        selectedPlayers.viceCaptainId = self.strViceCaptain
        
        vc.playerDetails = arrPlayerData
        vc.selectedPlayers = selectedPlayers
        vc.teamName = "Team Preview"
        vc.strCaptainId = self.strCaptain
        vc.strViceCaptainId = self.strViceCaptain
        vc.strPointsSuffix = "Cr"
        vc.modalPresentationStyle = .custom
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnHistoryPressed(_ sender: UIButton) {
        let vc = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonsStatsVC") as! SeasonsStatsVC
        vc.fromCreateTeam = true
        vc.teamNumber = Int(strTeamNumber) ?? 0
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnPointPressed(_ sender: UIButton) {
        let vc = Constants.KSideMenuStoryboard.instantiateViewController(withIdentifier: "WebPageViewController") as! WebPageViewController
        vc.isFromLeague = true
        vc.url = URL(string: URLMethods.FantasyPointSystem_URL)
        vc.headerText = "Fantasy Points System"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnHelpPressed(_ sender: UIButton) {
        let vc = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonHelpVC") as! SeasonHelpVC
        vc.modalPresentationStyle = .custom
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension SeasonChooseCaptainVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrPlayerTypes.count;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let players = arrPlayerTypes[section].players{
            return players.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 11))
        headerView.backgroundColor = .Color.headerDark.value
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 11
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseCaptainPlayerTVCell", for: indexPath) as! ChooseCaptainPlayerTVCell
        
        cell.selectionStyle = .none
        cell.btnCaptain.titleLabel?.adjustsFontSizeToFitWidth = true
        cell.btnViceCaptain.titleLabel?.adjustsFontSizeToFitWidth = true
        
        guard let players = arrPlayerTypes[indexPath.section].players else { return cell }
        let player = players[indexPath.row]
        cell.setData = player
        
       // if (player.country ?? "") == "in" || (player.country ?? "") == "India" {
            cell.imgViewOverseas.isHidden = true
       // }else {
       //     cell.imgViewOverseas.isHidden = false
       // }
        
        cell.btnCaptain.tag = indexPath.row
        cell.btnCaptain.addTarget(self, action: #selector(btnCaptainPressed(_:)), for: .touchUpInside)
        
        cell.btnViceCaptain.tag = indexPath.row
        cell.btnViceCaptain.addTarget(self, action: #selector(btnViceCaptainPressed(_:)), for: .touchUpInside)
        
        cell.btnPlayerProfile.tag = indexPath.row
        cell.btnPlayerProfile.addTarget(self, action: #selector(btnPlayerProfileTapped(_:)), for: .touchUpInside)
        
        cell.btnBooster.tag = indexPath.row
        cell.btnBooster.addTarget(self, action: #selector(btnBoosterTapped(_:)), for: .touchUpInside)
        
        cell.btnBooster.setImage(nil, for: .normal)
        cell.btnBooster.isUserInteractionEnabled = false
        
        if let booster = selectedBooster {
            
            if booster.boosterName == BoosterType.TRIPLE_SCORER.name {
                cell.btnBooster.isUserInteractionEnabled = true
                cell.btnBooster.setImage(urlS: booster.boosterImage, placeHolder: Constants.kNoImage)
                if player.isBoosterPlayer == true {
                    cell.btnBooster.alpha = 1
                }else{
                    cell.btnBooster.alpha = 0.5
                }
                //return cell
            }else if booster.boosterName == BoosterType.POWER_Indian.name {
                if (player.country ?? "") == "in" || (player.country ?? "") == "India" {
                    cell.btnBooster.setImage(urlS: booster.boosterImage, placeHolder: nil)
                    cell.btnBooster.alpha = 1
                    cell.btnBooster.isUserInteractionEnabled = false
                }
            }else if booster.boosterName == BoosterType.POWER_Overseas.name {
                if (player.country ?? "") != "in" && (player.country ?? "") != "India" {
                    cell.btnBooster.setImage(urlS: booster.boosterImage, placeHolder: nil)
                    cell.btnBooster.alpha = 1
                    cell.btnBooster.isUserInteractionEnabled = false
                }
            }
            
            //else {
                
                //selectedBooster.forEach { booster in
                    
//                    switch booster.boosterName {
//                    case BoosterType.POWER_WICKET_KEEPER.name, BoosterType.POWER_GOAL_KEEPER.name:
//                        if (player.player_role ?? "").contains(GDP.wc) {
//                            cell.btnBooster.setImage(urlS: booster.boosterImage, placeHolder: nil)
//                            cell.btnBooster.alpha = 1
//                            cell.btnBooster.isUserInteractionEnabled = false
//                        }
//                    case BoosterType.POWER_AR.name, BoosterType.POWER_MIDFIELDER.name:
//                        if (player.player_role ?? "").contains(GDP.ar) {
//                            cell.btnBooster.setImage(urlS: booster.boosterImage, placeHolder: nil)
//                            cell.btnBooster.alpha = 1
//                            cell.btnBooster.isUserInteractionEnabled = false
//                        }
//                    case BoosterType.POWER_BETTER.name, BoosterType.POWER_DEFENDER.name:
//                        if (player.player_role ?? "").contains(GDP.bat) {
//                            cell.btnBooster.setImage(urlS: booster.boosterImage, placeHolder: nil)
//                            cell.btnBooster.alpha = 1
//                            cell.btnBooster.isUserInteractionEnabled = false
//                        }
//                    case BoosterType.POWER_BOWLER.name, BoosterType.POWER_STRIKER.name:
//                        if (player.player_role ?? "").contains(GDP.bwl) {
//                            cell.btnBooster.setImage(urlS: booster.boosterImage, placeHolder: nil)
//                            cell.btnBooster.alpha = 1
//                            cell.btnBooster.isUserInteractionEnabled = false
//                        }
//                    default:
//                        break
//                    }
                //}
            //}
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    @objc func btnPlayerProfileTapped(_ sender: UIButton) {
        
        guard let indexPath = tblTeamPlayers.indexPathForRow(at: sender.convert(sender.frame.origin, to: self.tblTeamPlayers)) else {
            return
        }
        
        guard let players = arrPlayerTypes[indexPath.section].players else { return }
        let player = players[indexPath.row]
        let vc = PlayerInfoVC(nibName:"PlayerInfoVC", bundle:nil)
        vc.modalPresentationStyle = .custom
        vc.playerInfo = player
        vc.playerId = "\(player.player_id ?? 0)"
        vc.isFromLeague = true
        self.present(vc, animated: true) {
            vc.getPlayerDetails()
        }
    }
    
    @objc func btnViceCaptainPressed(_ sender: UIButton) {
        
        self.resetPlayerDetails(selectType: "viceCaptain", senderTag: sender.tag)
       
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tblTeamPlayers)
        if let indexPath = self.tblTeamPlayers.indexPathForRow(at:buttonPosition){
            if let players = arrPlayerTypes[indexPath.section].players{
                var player = players[indexPath.row]
//                if (player.isCaptain ?? false) == true{
//                    self.strCaptain = ""
//                    player.isCaptain = false
//                    player.isViceCaptain = true
//                    self.strViceCaptain = "\(player.player_id ?? 0)"
//                }else{
//                    player.isViceCaptain = true
//                    self.strViceCaptain = "\(player.player_id ?? 0)"
//                }
                
                if (player.isCaptain ?? false) == true{
                    self.strCaptain = ""
                    player.isCaptain = false
                }
                if (player.isBoosterPlayer ?? false) == true{
                    self.strBoosterPlayerId = ""
                    player.isBoosterPlayer = false
                }
                
                player.isViceCaptain = true
                self.strViceCaptain = "\(player.player_id ?? 0)"
                
                self.arrPlayerTypes[indexPath.section].players?[indexPath.row] = player
            }
        }
        self.tblTeamPlayers.reloadData()
    }
    
    @objc func btnCaptainPressed(_ sender: UIButton) {
        
        self.resetPlayerDetails(selectType: "captain", senderTag: sender.tag)
        
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tblTeamPlayers)
        if let indexPath = self.tblTeamPlayers.indexPathForRow(at:buttonPosition){
            if let players = arrPlayerTypes[indexPath.section].players{
                var player = players[indexPath.row]
//                if (player.isViceCaptain ?? false) == true{
//                    self.strViceCaptain = ""
//                    player.isViceCaptain = false
//                    player.isCaptain = true
//                    self.strCaptain = "\(player.player_id ?? 0)"
//                }else{
//                    player.isCaptain = true
//                    self.strCaptain = "\(player.player_id ?? 0)"
//                }
                
                if (player.isViceCaptain ?? false) == true{
                    self.strViceCaptain = ""
                    player.isViceCaptain = false
                }
                if (player.isBoosterPlayer ?? false) == true{
                    self.strBoosterPlayerId = ""
                    player.isBoosterPlayer = false
                }
                
                player.isCaptain = true
                self.strCaptain = "\(player.player_id ?? 0)"
                
                
                self.arrPlayerTypes[indexPath.section].players?[indexPath.row] = player
            }
        }
        
        tblTeamPlayers.reloadData()
    }
    
    @objc func btnBoosterTapped(_ sender: UIButton) {
        
        self.resetPlayerDetails(selectType: "booster", senderTag: sender.tag)
        
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tblTeamPlayers)
        if let indexPath = self.tblTeamPlayers.indexPathForRow(at:buttonPosition){
            if let players = arrPlayerTypes[indexPath.section].players{
                var player = players[indexPath.row]
                if (player.isViceCaptain ?? false) == true{
                    self.strViceCaptain = ""
                    player.isViceCaptain = false
                }
                if (player.isCaptain ?? false) == true{
                    self.strCaptain = ""
                    player.isCaptain = false
                }
                
                self.strBoosterPlayerId = "\(player.player_id ?? 0)"
                player.isBoosterPlayer = true
                
                self.arrPlayerTypes[indexPath.section].players?[indexPath.row] = player
            }
        }

        tblTeamPlayers.reloadData()
    }
    
    func resetPlayerDetails(selectType: String, senderTag:Int) {
        for i in 0..<self.arrPlayerTypes.count {
            var player = self.arrPlayerTypes[i]
            if let players = player.players{
                var tempPlayers = players
                for j in 0..<tempPlayers.count {
                    var pl = tempPlayers[j]
                    
                    switch selectType {
                    case "captain":
                        pl.isCaptain = false
                        break
                    case "viceCaptain":
                        pl.isViceCaptain = false
                        break
                    case "booster":
                        pl.isBoosterPlayer = false
                        break
                    default:
                        break
                    }
                    tempPlayers[j] = pl
                }
                
                player.players = tempPlayers
            }
            self.arrPlayerTypes[i] = player
        }
    }
    
}

//extension SeasonChooseCaptainVC {
//
//    func sortByPoints(){
//        if btnPointsSort.isSelected == false{
//            btnPointsSort.isSelected = true
//        }
//        btnPerCSort.isSelected = false
//        btnPerVCSort.isSelected = false
//
//        if btnPointsSort.image(for: .selected)!.isEqualToImage(Constants.kSortUpHighLight!){
//            btnPointsSort.setImage(Constants.kSortDownHighLight, for: .selected)
//            self.arrPlayers.sort { (first, second) -> Bool in
//                return self.getDouble(for: first.player_points  as Any) > self.getDouble(for: second.player_points as Any)
//            }
//        }else{
//            btnPointsSort.setImage(Constants.kSortUpHighLight, for: .selected)
//            self.arrPlayers.sort { (first, second) -> Bool in
//                return self.getDouble(for: first.player_points  as Any) < self.getDouble(for: second.player_points as Any)
//            }
//        }
//
//        self.tblTeamPlayers.reloadData()
//    }
//
//    func sortByCaptainPercent(){
//        if btnPerCSort.isSelected == false{
//            btnPerCSort.isSelected = true
//        }
//        btnPointsSort.isSelected = false
//        btnPerVCSort.isSelected = false
//
//        if btnPerCSort.image(for: .selected)!.isEqualToImage(Constants.kSortUpHighLight!){
//            btnPerCSort.setImage(Constants.kSortDownHighLight, for: .selected)
//            self.arrPlayers.sort { (first, second) -> Bool in
//                return self.getDouble(for: first.captain_percent  as Any) > self.getDouble(for: second.captain_percent as Any)
//            }
//        }else{
//            btnPerCSort.setImage(Constants.kSortUpHighLight, for: .selected)
//            self.arrPlayers.sort { (first, second) -> Bool in
//                return self.getDouble(for: first.captain_percent  as Any) < self.getDouble(for: second.captain_percent as Any)
//            }
//        }

//        self.tblTeamPlayers.reloadData()
//    }
//
//    func sortByVCPercent(){
//        if btnPerVCSort.isSelected == false{
//            btnPerVCSort.isSelected = true
//        }
//        btnPointsSort.isSelected = false
//        btnPerCSort.isSelected = false
//
//        if btnPerVCSort.image(for: .selected)!.isEqualToImage(Constants.kSortUpHighLight!){
//            btnPerVCSort.setImage(Constants.kSortDownHighLight, for: .selected)
//            self.arrPlayers.sort { (first, second) -> Bool in
//                return self.getDouble(for: first.vice_captain_percent  as Any) > self.getDouble(for: second.vice_captain_percent as Any)
//            }
//        }else{
//            btnPerVCSort.setImage(Constants.kSortUpHighLight, for: .selected)
//            self.arrPlayers.sort { (first, second) -> Bool in
//                return self.getDouble(for: first.vice_captain_percent  as Any) < self.getDouble(for: second.vice_captain_percent as Any)
//            }
//        }
//
//        self.tblTeamPlayers.reloadData()
//    }
//
//}

//MARK: API Call
extension SeasonChooseCaptainVC {
 
    func addEditTeam(params: [String: Any]) {
        
        WebCommunication.shared.createEditLeagueTeam(hostController: self, params: params, showLoader: true) { status, msg in
            
            if status == true {
                let alert = UIAlertController(title: Constants.kAppDisplayName, message: msg, preferredStyle:.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in

                    if let tabVC = self.navigationController?.getViewController(of: SeasonsTabBarVC.self) {
                        
                        //postNotification(.LeagueTeamCreation, userInfo: [:])
                        self.navigationController?.popToViewController(tabVC, animated: true)
                        return
                    }
                }))
                
                self.present(alert, animated: true, completion: nil)

            }else {
                AppManager.showToast(msg, view: self.view)
            }
        }
    }
}

//MARK: - Filter Players By Types
extension SeasonChooseCaptainVC {
    
    func populatePlayerList(filterKey:String) {
        
        self.arrPlayerTypes.removeAll()
        
        if self.arrWicketKeeper.count > 0{
            var playerType = PlayerType()
            playerType.type = "WicketKeeper"
            let players = sortPlayers(type: "WicketKeeper", filterKey: filterKey)
            playerType.players = players
            self.arrPlayerTypes.append(playerType)
        }
        
        if self.arrBatsman.count > 0{
            var playerType = PlayerType()
            playerType.type = "Batsman"
            let players = sortPlayers(type: "Batsman", filterKey: filterKey)
            playerType.players = players
            self.arrPlayerTypes.append(playerType)
        }
        
        if self.arrAllRounder.count > 0{
            var playerType = PlayerType()
            playerType.type = "All Rounder"
            let players = sortPlayers(type: "All Rounder", filterKey: filterKey)
            playerType.players = players
            self.arrPlayerTypes.append(playerType)
        }
        
        if self.arrBowler.count > 0{
            var playerType = PlayerType()
            playerType.type = "Bowler"
            let players = sortPlayers(type: "Bowler", filterKey: filterKey)
            playerType.players = players
            self.arrPlayerTypes.append(playerType)
        }
        
        tblTeamPlayers.reloadData()
    }
    
    func getPlayerList() {
        
        self.arrWicketKeeper.removeAll()
        self.arrBatsman.removeAll()
        self.arrAllRounder.removeAll()
        self.arrBowler.removeAll()
        
        var players = arrAllPlayers
        var arrWicketK = Array<Int>()
        for index  in 0..<(players.count) {
            let player = players[index]
            if player.player_role!.contains(GDP.wc){
                arrWicketK.append(index)
                self.arrWicketKeeper.append(player)
            }
        }
        
        for index in arrWicketK.reversed() {
            players.remove(at: index)
        }
        
        self.arrBatsman = players.filter({($0.player_role!.contains(GDP.bat))})
        self.arrBowler = players.filter({($0.player_role!.contains(GDP.bwl))})
        self.arrAllRounder = players.filter({($0.player_role!.contains(GDP.ar))})
        
    }
    
    func getPlayers(arrSelectedPlayers:[Player]) -> [Player]{
        var players = [Player]()
        for player in arrSelectedPlayers{
            var pl = player
            if self.arrPlayers.contains(where: {($0.player_id ?? 0) == (player.player_id ?? 0)}){
                if pl.player_id == Int(strCaptain){
                    pl.isCaptain = true
                }
                if pl.player_id == Int(strViceCaptain){
                    pl.isViceCaptain = true
                }
                if pl.player_id == Int(strBoosterPlayerId){
                    pl.isBoosterPlayer = true
                }
                players.append(pl)
            }
        }
        return players
    }
    
    func sortPlayers(type: String, filterKey: String) -> [Player] {
        
        var players = [Player]()
        
        switch type {
        case "WicketKeeper":
            players = self.getPlayers(arrSelectedPlayers: self.arrWicketKeeper)
            break
        case "Batsman":
            players = self.getPlayers(arrSelectedPlayers: self.arrBatsman)
            break
        case "All Rounder":
            players = self.getPlayers(arrSelectedPlayers: self.arrAllRounder)
            break
        case "Bowler":
            players = self.getPlayers(arrSelectedPlayers: self.arrBowler)
            break
        default:
            break
        }
        
        if filterKey == "C" {
            
            if btnPerCSort.isSelected == false{
                btnPerCSort.isSelected = true
            }
            btnPointsSort.isSelected = false
            btnPerVCSort.isSelected = false

            if btnPerCSort.image(for: .selected)!.isEqualToImage(Constants.kSortDownHighLight!){
                players.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.captain_percent  as Any) > self.getDouble(for: second.captain_percent as Any)
                }
            }else{
                players.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.captain_percent  as Any) < self.getDouble(for: second.captain_percent as Any)
                }
            }
        }
        if filterKey == "VC" {
            
            if btnPerVCSort.isSelected == false{
                btnPerVCSort.isSelected = true
            }
            btnPointsSort.isSelected = false
            btnPerCSort.isSelected = false

            if btnPerVCSort.image(for: .selected)!.isEqualToImage(Constants.kSortDownHighLight!){
                players.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.vice_captain_percent  as Any) > self.getDouble(for: second.vice_captain_percent as Any)
                }
            }else{
                players.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.vice_captain_percent  as Any) < self.getDouble(for: second.vice_captain_percent as Any)
                }
            }
        }
        if filterKey == "Points" {
            
            if btnPointsSort.isSelected == false{
                btnPointsSort.isSelected = true
            }
            
            btnPerCSort.isSelected = false
            btnPerVCSort.isSelected = false

            if btnPointsSort.image(for: .selected)!.isEqualToImage(Constants.kSortDownHighLight!){
                players.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_points  as Any) > self.getDouble(for: second.player_points as Any)
                }
            }else{
                players.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_points  as Any) < self.getDouble(for: second.player_points as Any)
                }
            }
        }
        
        return players
    }
}
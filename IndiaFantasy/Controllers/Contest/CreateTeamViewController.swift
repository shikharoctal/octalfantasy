//
//  CreateTeamViewController.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 07/03/22.
//

import UIKit
import SDWebImage

class CreateTeamViewController: BaseClassWithoutTabNavigation {

    @IBOutlet weak var btnCreditSort: UIButton!
    @IBOutlet weak var btnSelSort: UIButton!
    @IBOutlet weak var btnPointSort: UIButton!
    @IBOutlet weak var navigationView: CustomNavigation!
    @IBOutlet weak var lblSelectedGenreText: UILabel!
    @IBOutlet weak var scrlViewIndicator: UIScrollView!
    @IBOutlet weak var btnBowl: UIButton!
    @IBOutlet weak var btnAr: UIButton!
    @IBOutlet weak var btnBat: UIButton!
    @IBOutlet weak var btnWk: UIButton!
    
    @IBOutlet weak var lblVisitorTeamCount: UILabel!
    @IBOutlet weak var lblLocalTeamCount: UILabel!
    
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lblCredits: UILabel!
    @IBOutlet weak var lblSelectedPlayers: UILabel!
    @IBOutlet weak var lblVisitorTeam: UILabel!
    @IBOutlet weak var lblHomeTeam: UILabel!
    @IBOutlet weak var imgVisitorTeam: UIImageView!
    @IBOutlet weak var imgLocalTeam: UIImageView!
    @IBOutlet weak var lblHeader: UILabel!
    
    var selectedPlayers = [Player]()
    var playerTypeCount = SelectedPlayerTypes()
 
    var currentTeamCount = 0
    
    var guruPlayers = GuruPlayers()
    
    var substituteId = ""
    var isFromEdit = ""
    var TeamData:Team?
    var strCaptainID = ""
    var strViceCaptainID = ""
    var teamID = ""
    var strTeamNumber = ""

    var strVCFrom = ""
    
    var isFromMainContest = false

    var arrAllPlayers = [Player]()

    var arrWicketKeeper = [Player]()
    var arrBatsman = [Player]()
    var arrBowler = [Player]()
   // @IBOutlet weak var btnFilter: UIButton!
    var arrAllRounder = [Player]()
    
    var strBoosterPlayerID = ""
    
    @IBOutlet weak var viewWK: UIView!
    @IBOutlet weak var viewBat: UIView!
    @IBOutlet weak var viewAR: UIView!
    @IBOutlet weak var viewBowl: UIView!
    
    @IBOutlet weak var tblTeamList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.isFromEdit.uppercased() == "EDIT"{
            navigationView.configureNavigationBarWithController(controller: self, title: "Edit Team \(self.strTeamNumber)", hideNotification: false, hideAddMoney: true, hideBackBtn: false)
        }else{
            navigationView.configureNavigationBarWithController(controller: self, title: "Create Team", hideNotification: false, hideAddMoney: true, hideBackBtn: false)
        }
        navigationView.img_BG.isHidden = true
        self.setupUI()
        
        self.btnPlayerTabPressed(btnWk)

        self.getPlayerList()
        // Do any additional setup after loading the view.
    }
    
    func setupUI(){
        lblHomeTeam.text = GDP.selectedMatch?.localteam_short_name ?? ""
        lblVisitorTeam.text = GDP.selectedMatch?.visitorteam_short_name ?? ""
        
        imgLocalTeam.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgLocalTeam.sd_setImage(with: URL(string: GDP.selectedMatch?.localteam_flag ?? ""), placeholderImage: Constants.kNoImageUser)

        imgVisitorTeam.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgVisitorTeam.sd_setImage(with: URL(string: GDP.selectedMatch?.visitorteam_flag ?? ""), placeholderImage: Constants.kNoImageUser)
        
        self.btnWk.setTitle("", for: .normal)
        self.btnBat.setTitle("", for: .normal)
        self.btnAr.setTitle("", for: .normal)
        self.btnBowl.setTitle("", for: .normal)
        
        if let matchDate = CommonFunctions.getDateFromString(date: GDP.selectedMatch?.match_date ?? "", format: "yyyy-MM-dd'T'HH:mm:ss"), Date() >= matchDate {
            self.alertBoxWithAction(message: ConstantMessages.kMatchNotStarted, btnTitle: ConstantMessages.OkBtn) {
                self.navigationController?.popToRootViewController(animated: false)
            }
            return
        }
        
        self.startTimer()
    }
    
    func startTimer()
    {
        //CommonFunctions().timerStart(date: self.lblHeader, strTime: GDP.selectedMatch?.start_time ?? "", strDate: GDP.selectedMatch?.start_date, viewcontroller: self)
        CommonFunctions().timerStart(lblTime: self.lblHeader, strDate: GDP.selectedMatch?.match_date ?? "", viewcontroller: self, fromSeasonMyTeams: false, isFromHome: true)
    }
    
    func populateScrollView(){
        
        self.resetScrollViewPoints()
        
        var currX = 0
        for i  in 0..<11 {
            let width = scrlViewIndicator.frame.size.width
            let itemWidth = width / 11
            let view = UIView(frame: CGRect(x: currX, y: 10, width: 20, height: 20))
            
            let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
            view.addSubview(lbl)
            lbl.font = UIFont(name: customFontRegular, size: 10)
            
            lbl.textAlignment = .center
            lbl.text = "\(i + 1)"

            scrlViewIndicator.addSubview(view)

            if i < self.playerTypeCount.totalSelectedPlayers{
                view.backgroundColor = UIColor.appGreenTextColor
                lbl.textColor = UIColor.white

            }else{
                view.backgroundColor = UIColor.white
                lbl.textColor = UIColor.hexStringToUIColor(hex: "#2B2B2B")

            }
            view.clipsToBounds = true
            view.cornerRadius = 2.0
            
            let margin:CGFloat = (itemWidth)
            currX = currX + Int(margin)
        }
        scrlViewIndicator.contentSize = CGSize(width: currX, height: 0)
    }
    
    func resetScrollViewPoints(){
        for view in scrlViewIndicator.subviews{
            view.removeFromSuperview()
        }
    }
    
    func resetButtons(){
        btnWk.isSelected = false
        btnBat.isSelected = false
        btnAr.isSelected = false
        btnBowl.isSelected = false
        
        viewWK.backgroundColor = UIColor.cellSepratorColor
        viewBat.backgroundColor = UIColor.cellSepratorColor
        viewAR.backgroundColor = UIColor.cellSepratorColor
        viewBowl.backgroundColor = UIColor.cellSepratorColor
    }
    
    @IBAction func btnPlayerTabPressed(_ sender: UIButton) {
       // btnFilter.isSelected = false
        self.resetButtons()
        sender.isSelected = true
        
        if sender == btnWk{
            self.lblSelectedGenreText.text = "Pick 1 - 8 \(GDP.wicketKeeper)"
            viewWK.backgroundColor = UIColor.appRedColor
        }else if sender == btnBat{
            self.lblSelectedGenreText.text = "Pick 1 - 8 \(GDP.bat)"
            viewBat.backgroundColor = UIColor.appRedColor
        }else if sender == btnAr{
            self.lblSelectedGenreText.text = "Pick 1 - 8 \(GDP.allRounder)"
            viewAR.backgroundColor = UIColor.appRedColor
        }else{
            self.lblSelectedGenreText.text = "Pick 1 - 8 \(GDP.bwl)"
            viewBowl.backgroundColor = UIColor.appRedColor
        }
        
        tblTeamList.reloadData()
    }
    
    @IBAction func btnBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPlusTapped(sender: UIButton){
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let cell = tblTeamList.cellForRow(at: indexPath) as? ChoosePlayerTVCell
        var player : Player
        
        if btnWk.isSelected == true{
            player = self.arrWicketKeeper[sender.tag]

        }else if btnBat.isSelected == true{
            player = self.arrBatsman[sender.tag]

        }else if btnAr.isSelected == true{
            player = self.arrAllRounder[sender.tag]

        }else{
            player = self.arrBowler[sender.tag]

        }
        self.addRemovePlayerFromTeam(cell: cell, player: player)
    }
    
    @IBAction func btnPlayerProfileTapped(sender: UIButton){
        
        guard let indexPath = tblTeamList.indexPathForRow(at: sender.convert(sender.frame.origin, to: self.tblTeamList)) else {
             return
          }
        let player : Player
        
        if btnWk.isSelected == true{
            player = self.arrWicketKeeper[sender.tag]

        }else if btnBat.isSelected == true{
            player = self.arrBatsman[sender.tag]

        }else if btnAr.isSelected == true{
            player = self.arrAllRounder[sender.tag]

        }else{
            player = self.arrBowler[sender.tag]

        }
        
        let vc = PlayerInfoVC(nibName:"PlayerInfoVC", bundle:nil)
        vc.playerId = "\(player.player_id ?? 0)"
        vc.playerInfo = player
        vc.isCreateTeam = true
        if self.selectedPlayers.contains(where: {$0.player_id == (player.player_id ?? 0)}) {
            vc.inMyTeam = true
        }else {
            vc.inMyTeam = false
        }
        
        if let cell = tblTeamList.cellForRow(at: indexPath) as? ChoosePlayerTVCell {
            vc.isCreateTeam = cell.viewGrayout.isHidden
        }
        vc.modalPresentationStyle = .custom
        
        vc.completionHandler =  { (playerInfo) in
            if let cell = self.tblTeamList.cellForRow(at: indexPath) as? ChoosePlayerTVCell{
                self.addRemovePlayerFromTeam(cell: cell, player: player)
            }
        }
        
        self.present(vc, animated: true) {
            vc.getPlayerDetails()
        }
    }
    
    @IBAction func btnPreviewTeamTapped(_ sender: Any) {
//        var arrSelectedTeam = [Player]()
//        for i  in 0..<(self.arrAllPlayers.count) {
//            let player = self.arrAllPlayers[i]
//            
//            for j  in 0..<(self.selectedPlayers.count){
//                if player.player_id == Int(self.selectedPlayers[j]){
//                arrSelectedTeam.append(player)
//            }
//        }
//        }
        
        let vc = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "TeamPreviewVC") as! TeamPreviewVC

        vc.teamNumber = ""
        vc.strFromVC = "CreateTeam"
        
        let arrPlayers = selectedPlayers
        var arrPlayerData = [PlayerDetails]()
        var selectedPlayers = SelectedPlayerTypes()
        
        
        if arrPlayers.count > 0
        {
            for index  in 0..<arrPlayers.count {
                let player = arrPlayers[index]
                var playerData = PlayerDetails()
                playerData.name = "\(player.player_name ?? "")"
                playerData.credits = "\(player.player_credit ?? 0)"
                playerData.role = player.player_role ?? ""
                playerData.points = "\(player.player_points ?? 0)"
                playerData.image = "\(player.player_image ?? "")"
                playerData.player_id = "\(player.player_id ?? 0)"
                playerData.is_local_team = "\(player.team_id ?? 0)".caseInsensitiveCompare("\(GDP.selectedMatch?.localteam_id ?? 0)") == .orderedSame
                playerData.is_playing = player.is_playing ?? false

                arrPlayerData.append(playerData)
            }
        }
        
        selectedPlayers.batsman =  self.playerTypeCount.batsman
        selectedPlayers.allrounder =  self.playerTypeCount.allrounder
        selectedPlayers.bowler =   self.playerTypeCount.bowler
        selectedPlayers.wicketkeeper = self.playerTypeCount.wicketkeeper
        
        selectedPlayers.captainId = TeamData?.captain_player_id ?? ""
        selectedPlayers.viceCaptainId = TeamData?.vice_captain_player_id ?? ""

        vc.otherUserId = Constants.kAppDelegate.user?.id ?? ""

        vc.playerDetails = arrPlayerData
        vc.selectedPlayers = selectedPlayers
        vc.teamName = "Team Preview"
        vc.strCaptainId = selectedPlayers.captainId
        vc.strViceCaptainId = selectedPlayers.viceCaptainId
        vc.strPointsSuffix = "Cr"
        vc.modalPresentationStyle = .custom
        self.present(vc, animated: true, completion: nil)
        
    }
    @IBAction func btnNextTapped(_ sender: UIButton) {
        
        if self.validateCricketPlayers() == false{
            return
        }
        
        let vc = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "ChooseCaptainViewController") as! ChooseCaptainViewController
  
        vc.arrAllPlayers = self.arrAllPlayers
        vc.arrPlayers = self.selectedPlayers
        vc.playerTypeCount = self.playerTypeCount
        vc.substituteId = self.substituteId
        vc.isFromEdit = self.isFromEdit
        
        vc.strTeamID = self.teamID
        if self.isFromEdit == "Edit"
        {
            vc.strCaptain = self.strCaptainID
            vc.strViceCaptain = self.strViceCaptainID
            vc.isFromVC = "Edit"
            //vc.strBoosterPlayerId = "\(TeamData?.boostedPlayer?.first ?? 0)"
            //vc.selectedBooster = TeamData?.boosterDetails
        }
        else if self.isFromEdit == "Clone"
        {
            vc.strCaptain = self.strCaptainID
            vc.strViceCaptain = self.strViceCaptainID
            vc.isFromVC = "Clone"
        }
        else
        {
            vc.isFromVC = self.strVCFrom
        }

        vc.strTeamNumber = self.strTeamNumber
        vc.currentTeamCount = "\(self.currentTeamCount)"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnGuruTeamPressed(_ sender: Any) {
        self.populateGuruTeam()
    }
    
    
    
    
    @IBAction func btnSortByPointsPressed(_ sender: UIButton) {
        if sender.isSelected == false{
            sender.isSelected = true
        }
        btnCreditSort.isSelected = false
        btnSelSort.isSelected = false
        if sender.image(for: .selected)!.isEqualToImage(Constants.kSortUpHighLight!){
            sender.setImage(Constants.kSortDownHighLight, for: .selected)
            if btnWk.isSelected{
                self.arrWicketKeeper.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_points  as Any) > self.getDouble(for: second.player_points as Any)
                }
            }
            if btnBat.isSelected{
                self.arrBatsman.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_points as Any) > self.getDouble(for: second.player_points as Any)
                }
            }
            if btnAr.isSelected{
                self.arrAllRounder.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_points as Any) > self.getDouble(for: second.player_points as Any)
                }
            }
            if btnBowl.isSelected{
                self.arrBowler.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_points as Any) > self.getDouble(for: second.player_points as Any)
                }
            }

        }else{
            sender.setImage(Constants.kSortUpHighLight, for: .selected)
            if btnWk.isSelected{
                self.arrWicketKeeper.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_points as Any) < self.getDouble(for: second.player_points as Any)
                }
            }
            if btnBat.isSelected{
                
                self.arrBatsman.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_points as Any) < self.getDouble(for: second.player_points as Any)
                }
            }
            if btnAr.isSelected{
                self.arrAllRounder.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_points as Any) < self.getDouble(for: second.player_points as Any)
                }
            }
            if btnBowl.isSelected{
                self.arrBowler.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_points as Any) < self.getDouble(for: second.player_points as Any)
                }
            }
        }
        

        
        tblTeamList.reloadData()

    }

    @IBAction func btnSortByCreditsPressed(_ sender: UIButton) {
        if sender.isSelected == false{
            sender.isSelected = true
        }
        btnPointSort.isSelected = false
        btnSelSort.isSelected = false
        if sender.image(for: .selected)!.isEqualToImage(Constants.kSortUpHighLight!){
            sender.setImage(Constants.kSortDownHighLight, for: .selected)
            if btnWk.isSelected{
                self.arrWicketKeeper.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_credit  as Any) > self.getDouble(for: second.player_credit as Any)
                }
            }
            if btnBat.isSelected{
                self.arrBatsman.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_credit as Any) > self.getDouble(for: second.player_credit as Any)
                }
            }
            if btnAr.isSelected{
                self.arrAllRounder.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_credit as Any) > self.getDouble(for: second.player_credit as Any)
                }
            }
            if btnBowl.isSelected{
                self.arrBowler.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_credit as Any) > self.getDouble(for: second.player_credit as Any)
                }
            }

        }else{
            sender.setImage(Constants.kSortUpHighLight, for: .selected)
            if btnWk.isSelected{
                self.arrWicketKeeper.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_credit as Any) < self.getDouble(for: second.player_credit as Any)
                }
            }
            if btnBat.isSelected{
                
                self.arrBatsman.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_credit as Any) < self.getDouble(for: second.player_credit as Any)
                }
            }
            if btnAr.isSelected{
                self.arrAllRounder.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_credit as Any) < self.getDouble(for: second.player_credit as Any)
                }
            }
            if btnBowl.isSelected{
                self.arrBowler.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_credit as Any) < self.getDouble(for: second.player_credit as Any)
                }
            }
        }
        

        
        tblTeamList.reloadData()

    }
    
    @IBAction func btnSortBySelPressed(_ sender: UIButton) {
        if sender.isSelected == false{
            sender.isSelected = true
        }
        btnPointSort.isSelected = false
        btnCreditSort.isSelected = false
        if sender.image(for: .selected)!.isEqualToImage(Constants.kSortUpHighLight!){
            sender.setImage(Constants.kSortDownHighLight, for: .selected)
            if btnWk.isSelected{
                self.arrWicketKeeper.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.selected_by  as Any) > self.getDouble(for: second.selected_by as Any)
                }
            }
            if btnBat.isSelected{
                self.arrBatsman.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.selected_by as Any) > self.getDouble(for: second.selected_by as Any)
                }
            }
            if btnAr.isSelected{
                self.arrAllRounder.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.selected_by as Any) > self.getDouble(for: second.selected_by as Any)
                }
            }
            if btnBowl.isSelected{
                self.arrBowler.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.selected_by as Any) > self.getDouble(for: second.selected_by as Any)
                }
            }

        }else{
            sender.setImage(Constants.kSortUpHighLight, for: .selected)
            if btnWk.isSelected{
                self.arrWicketKeeper.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.selected_by as Any) < self.getDouble(for: second.selected_by as Any)
                }
            }
            if btnBat.isSelected{
                
                self.arrBatsman.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.selected_by as Any) < self.getDouble(for: second.selected_by as Any)
                }
            }
            if btnAr.isSelected{
                self.arrAllRounder.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.selected_by as Any) < self.getDouble(for: second.selected_by as Any)
                }
            }
            if btnBowl.isSelected{
                self.arrBowler.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.selected_by as Any) < self.getDouble(for: second.selected_by as Any)
                }
            }
        }
        

        
        tblTeamList.reloadData()

    }
    
    @IBAction func btnFilterPressed(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected{
            if btnWk.isSelected{
                self.arrWicketKeeper.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_credit  as Any) < self.getDouble(for: second.player_credit as Any)
                }
            }
            if btnBat.isSelected{
                self.arrBatsman.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_credit as Any) < self.getDouble(for: second.player_credit as Any)
                }
            }
            if btnAr.isSelected{
                self.arrAllRounder.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_credit as Any) < self.getDouble(for: second.player_credit as Any)
                }
            }
            if btnBowl.isSelected{
                self.arrBowler.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_credit as Any) < self.getDouble(for: second.player_credit as Any)
                }
            }
            
        }else{
            if btnWk.isSelected{
                self.arrWicketKeeper.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_credit as Any) > self.getDouble(for: second.player_credit as Any)
                }
            }
            if btnBat.isSelected{
                
                self.arrBatsman.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_credit as Any)  > self.getDouble(for: second.player_credit as Any)
                }
            }
            if btnAr.isSelected{
                self.arrAllRounder.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_credit as Any)  > self.getDouble(for: second.player_credit as Any)
                }
            }
            if btnBowl.isSelected{
                self.arrBowler.sort { (first, second) -> Bool in
                    return self.getDouble(for: first.player_credit as Any) > self.getDouble(for: second.player_credit as Any)
                }
            }
        }
        
        tblTeamList.reloadData()
    }
    
    @IBAction func btnClearTeamPressed(_ sender: UIButton) {
        if self.selectedPlayers.count > 0{
            let alert = UIAlertController(title: Constants.kAppDisplayName, message: ConstantMessages.ALERT_CLEAR_Team, preferredStyle:.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.clearTeamSelection()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func clearTeamSelection(){
        self.selectedPlayers.removeAll()
        self.playerTypeCount = SelectedPlayerTypes()
        self.tblTeamList.reloadData()

        self.btnPlayerTabPressed(btnWk)
        self.showPlayerCount()
    }
    
    func addRemovePlayerFromTeam(cell : ChoosePlayerTVCell?, player : Player) {
        var changeCont = 0
        
        if self.selectedPlayers.contains(where: {$0.player_id == (player.player_id ?? 0)}) {
            cell?.btnAddPlayer.isSelected = false
            let arr = self.selectedPlayers.filter({$0.player_id != (player.player_id ?? 0)})
            self.selectedPlayers.removeAll()
            self.selectedPlayers.append(contentsOf: arr)
            changeCont = -1
        }else {
            cell?.btnAddPlayer.isSelected = true
            self.selectedPlayers.append(player)
            changeCont = 1
        }
        
        var credit = 0.0
//        credit = self.getDouble(for: player.playerCredit?.value) ?? 0.0
        credit = self.getDouble(for: player.player_credit as Any)
        //        credit = self.selectedType == 2 ? 15 : credit
        self.playerTypeCount.usedCredits += (Double(changeCont) * credit)
        
        self.playerTypeCount.totalSelectedPlayers += changeCont
        
        var extra = 0
        
        if btnWk.isSelected == true{
            self.playerTypeCount.wicketkeeper += changeCont
            extra = self.playerTypeCount.wicketkeeper - self.playerTypeCount.minimumWkt
        }else if btnBat.isSelected == true{
            self.playerTypeCount.batsman += changeCont
            extra = self.playerTypeCount.batsman - self.playerTypeCount.minimumBat
        }else if btnAr.isSelected == true{
            self.playerTypeCount.allrounder += changeCont
            extra = self.playerTypeCount.allrounder - self.playerTypeCount.minimumAllRound
        }else{
            self.playerTypeCount.bowler += changeCont
            extra = self.playerTypeCount.bowler - self.playerTypeCount.minimumBowl
        }
        
        self.playerTypeCount.extraPlayers += (extra > 0) ? changeCont : (extra == 0 && changeCont < 0) ? changeCont : 0

        
        if "\(GDP.selectedMatch?.localteam_id ?? 0)" == "\(player.team_id ?? 0)" {
            self.playerTypeCount.localPlayers += changeCont
        }else {
            self.playerTypeCount.visitorPlayers += changeCont
        }
        
        self.playerTypeCount.captainId = self.playerTypeCount.captainId == "\(player.player_id ?? 0)" ? "" : self.playerTypeCount.captainId
        self.playerTypeCount.viceCaptainId = self.playerTypeCount.viceCaptainId == "\(player.player_id ?? 0)" ? "" : self.playerTypeCount.viceCaptainId
        
        self.showPlayerCount()
    }
    
    func showPlayerCount()
    {
        self.lblSelectedPlayers.text = "\(self.playerTypeCount.totalSelectedPlayers) / 11 Players"
        self.lblCredits.text = "\((Double(self.playerTypeCount.totalCredits) - self.playerTypeCount.usedCredits).clean)";
//        self.lblCredits.attributedText =  CommonFunctions.getCombinedAttributedString(first: , second: "/\(self.playerTypeCount.totalCredits)")

        self.populateScrollView()
        //Show next button is Active
        //self.btnNext.borderColor = self.playerTypeCount.totalSelectedPlayers >= 11 ? .white : .lightGray
        
        // MARK
        if self.playerTypeCount.totalSelectedPlayers >= 11 {
            btnNext.backgroundColor = UIColor.appGreenTextColor
            btnNext.setTitleColor(UIColor.white, for: .normal)
        }else{
            btnNext.backgroundColor = UIColor.lightGray
            btnNext.setTitleColor(UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1.0), for: .normal)
        }
       
        self.lblLocalTeamCount.text = "(\(self.playerTypeCount.localPlayers))"
        self.lblVisitorTeamCount.text = "(\(self.playerTypeCount.visitorPlayers))"
        
        self.btnWk.setTitle("\(GDP.wkShort)(\(self.playerTypeCount.wicketkeeper))", for: .normal)
        self.btnBat.setTitle("\(GDP.batShort)(\(self.playerTypeCount.batsman))", for: .normal)
        self.btnAr.setTitle("\(GDP.arShort)(\(self.playerTypeCount.allrounder))", for: .normal)
        self.btnBowl.setTitle("\(GDP.bowlShort)(\(self.playerTypeCount.bowler))", for: .normal)

        self.tblTeamList.reloadData()
        
    }
    
    
}
extension CreateTeamViewController:UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if btnWk.isSelected == true{
            return arrWicketKeeper.count
        }else if btnBat.isSelected == true{
            return arrBatsman.count
        }else if btnAr.isSelected == true{
            return arrAllRounder.count
        }else{
            return arrBowler.count
        }
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView(tableView, cellForCricketAt: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForCricketAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChoosePlayerTVCell", for: indexPath) as! ChoosePlayerTVCell
        cell.selectionStyle = .none
        cell.contentView.backgroundColor = UIColor.clear

        var playerInfo:Player? = nil
        
        if btnWk.isSelected == true{
            playerInfo = arrWicketKeeper[indexPath.row]
            if (self.playerTypeCount.wicketkeeper >= 1 && self.playerTypeCount.extraPlayers >= 7) || self.playerTypeCount.wicketkeeper >= 8
            {
                cell.viewGrayout.isHidden = false
            }
            else
            {
                cell.viewGrayout.isHidden = true
            }
            cell.updateView(player: playerInfo, match: GDP.selectedMatch)
        }else if btnBat.isSelected == true{
            playerInfo = arrBatsman[indexPath.row]
            if (self.playerTypeCount.batsman >= 1 && self.playerTypeCount.extraPlayers >= 7) || self.playerTypeCount.batsman >= 8
            {
                cell.viewGrayout.isHidden = false
            }
            else
            {
                cell.viewGrayout.isHidden = true
            }
            cell.updateView(player: playerInfo, match: GDP.selectedMatch)

        }else if btnAr.isSelected == true{
            playerInfo = arrAllRounder[indexPath.row]
            if (self.playerTypeCount.allrounder >= 1 && self.playerTypeCount.extraPlayers >= 7) || self.playerTypeCount.allrounder >= 8 {
                cell.viewGrayout.isHidden = false
            }else {
                cell.viewGrayout.isHidden = true
            }
            cell.updateView(player: playerInfo, match: GDP.selectedMatch)

        }else{
            playerInfo = arrBowler[indexPath.row]
            if (self.playerTypeCount.bowler >= 1 && self.playerTypeCount.extraPlayers >= 7) || self.playerTypeCount.bowler >= 8 {
                cell.viewGrayout.isHidden = false
            }else {
                cell.viewGrayout.isHidden = true
            }
            cell.updateView(player: playerInfo, match: GDP.selectedMatch)
        }
        
        if self.selectedPlayers.contains(where: {$0.player_id == (playerInfo?.player_id ?? 0)}) {
            cell.viewGrayout.isHidden = true
        }
        
        else if (Double(self.playerTypeCount.totalCredits) - self.playerTypeCount.usedCredits) < self.getDouble(for:playerInfo?.player_credit as Any)
        {
            cell.viewGrayout.isHidden = false
        }
        else if self.playerTypeCount.visitorPlayers >= 10 && "\(GDP.selectedMatch?.visitorteam_id ?? 0)" == "\(playerInfo?.team_id ?? 0)" {
            cell.viewGrayout.isHidden = false
        }
        else if self.playerTypeCount.localPlayers >= 10 && "\(GDP.selectedMatch?.localteam_id ?? 0)" == "\(playerInfo?.team_id ?? 0)" {
            cell.viewGrayout.isHidden = false
        }
        
        cell.btnAddPlayer.isEnabled = cell.viewGrayout.isHidden
        
        if self.selectedPlayers.contains(where: {$0.player_id == (playerInfo?.player_id ?? 0)}) {
            cell.btnAddPlayer.isSelected = true
            cell.contentView.backgroundColor = UIColor.hexStringToUIColor(hex: "#0E4990")
        }
        else {
            cell.btnAddPlayer.isSelected = false
//            cell.contentView.backgroundColor = UIColor.white
        }
        
        if (playerInfo?.team_id ?? 0) == (GDP.selectedMatch?.localteam_id ?? 0){
            cell.imgViewCountryFlag.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imgViewCountryFlag.sd_setImage(with: URL(string: GDP.selectedMatch?.localteam_flag ?? ""), placeholderImage: Constants.kNoImageUser)
        }else{
            cell.imgViewCountryFlag.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imgViewCountryFlag.sd_setImage(with: URL(string: GDP.selectedMatch?.visitorteam_flag ?? ""), placeholderImage: Constants.kNoImageUser)
        }
        
        cell.lblPlayerName.text = playerInfo?.player_name ?? ""
        
        cell.imgViewPlayer.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.imgViewPlayer.sd_setImage(with: URL(string: playerInfo?.player_image ?? ""), placeholderImage: Constants.kNoImageUser)
        
        
        cell.lblCredits.text = "\(self.getDouble(for: playerInfo?.player_credit as Any))"
        
        if "\(GDP.selectedMatch?.localteam_id ?? 0)" == "\(playerInfo?.team_id ?? 0)" {
            cell.lblTeamShortName.text = (GDP.selectedMatch?.localteam_short_name ?? "")
            cell.lblSel.text = "\(playerInfo?.selected_by ?? 0)" + "%"

            cell.lblPoints.text = "\(Double("\(playerInfo?.player_points! ?? 0)")?.clean ?? "0")"


        }else {
            cell.lblTeamShortName.text = (GDP.selectedMatch?.visitorteam_short_name ?? "")
            cell.lblSel.text = "\(playerInfo?.selected_by ?? 0)" + "%"
            cell.lblPoints.text = "\(Double("\(playerInfo?.player_points! ?? 0)")?.clean ?? "0")"

        }

        cell.btnAddPlayer.tag = indexPath.row
        cell.btnAddPlayer.addTarget(self, action: #selector(btnPlusTapped), for: .touchUpInside)
        
        
        cell.btnPlayerProfile.tag = indexPath.row
        cell.btnPlayerProfile.addTarget(self, action: #selector(btnPlayerProfileTapped), for: .touchUpInside)
        
        if (GDP.selectedMatch?.lineup ?? false) == true{
            cell.viewAnnounced.isHidden = false
            if (playerInfo?.is_playing ?? false) == true{
                cell.lblAnnounced.text = "Announced"
                cell.lblAnnounced.textColor = UIColor.appHighlightedTextColor
                cell.imgViewAnnounced.image = nil
                cell.imgViewAnnounced.backgroundColor = UIColor.appHighlightedTextColor
            }else{
                cell.lblAnnounced.text = "Not-announced"
                cell.lblAnnounced.textColor = UIColor.appYellowColor
                cell.imgViewAnnounced.image = nil
                cell.imgViewAnnounced.backgroundColor = UIColor.appYellowColor

            }
        }
       else{
            cell.viewAnnounced.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let match = self.arrMatches?[indexPath.row]
//        let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "MatchContestViewController") as! MatchContestViewController
//        VC.selectedMatch = match
//        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return 75
    }
    
    func populateEditTeamData(dataResponse:[Player]){
        if dataResponse.count > 0
        {
           var localPlayersCount = 0
           var visitorPlayersCount = 0
            var usedCreditsCount = 0.0

           for i in 0..<dataResponse.count
           {
             for j in 0..<self.TeamData!.seriesPlayer!.count
             {
                if "\(dataResponse[i].player_id ?? 0)" == "\(self.TeamData!.seriesPlayer![j].player_id ?? 0)"
                {
                    self.selectedPlayers.append(dataResponse[i])
                    usedCreditsCount += self.getDouble(for: dataResponse[i].player_credit ?? "0")
                    //print("usedCreditsCount-->",usedCreditsCount)
                    if "\(GDP.selectedMatch?.localteam_id ?? 0)" == "\(dataResponse[i].team_id ?? 0)"
                    {
                        localPlayersCount += 1
                    }
                    else if "\(GDP.selectedMatch?.visitorteam_id ?? 0)" == "\(dataResponse[i].team_id ?? 0)"
                    {
                        visitorPlayersCount += 1
                    }
                    break
                }
             }
            
           }
            
            if usedCreditsCount == 0
            {
                usedCreditsCount = 100.0
            }
             
            self.playerTypeCount.wicketkeeper = self.TeamData!.total_wicketkeeper ?? 0
            self.playerTypeCount.batsman = self.TeamData!.total_batsman ?? 0
            self.playerTypeCount.bowler = self.TeamData!.total_bowler ?? 0
            self.playerTypeCount.allrounder = self.TeamData!.total_allrounder ?? 0
            self.playerTypeCount.totalSelectedPlayers = 11
            self.playerTypeCount.localPlayers = localPlayersCount
            self.playerTypeCount.visitorPlayers = visitorPlayersCount
            self.playerTypeCount.usedCredits = usedCreditsCount
            self.playerTypeCount.captainId = self.TeamData!.captain_player_id ?? ""
            self.playerTypeCount.viceCaptainId = self.TeamData!.vice_captain_player_id ?? ""
            self.playerTypeCount.teamId = self.TeamData!.team_id ?? ""
            self.playerTypeCount.extraPlayers = 7
        }
    }
    
    func populateCloneTeamData(dataResponse:[Player]){
        
        if dataResponse.count > 0
        {
           var localPlayersCount = 0
           var visitorPlayersCount = 0
           var usedCreditsCount = 0.0

           for i in 0..<dataResponse.count
           {
             for j in 0..<self.TeamData!.seriesPlayer!.count
             {
                if "\(dataResponse[i].player_id ?? 0)" == "\(self.TeamData!.seriesPlayer![j].player_id ?? 0)"
                {
                    self.selectedPlayers.append(dataResponse[i])
                    usedCreditsCount += self.getDouble(for: dataResponse[i].player_credit ?? "0")
                    //print("usedCreditsCount-->",usedCreditsCount)
                    if "\(GDP.selectedMatch?.localteam_id ?? 0)" == "\(dataResponse[i].team_id ?? 0)"
                    {
                        localPlayersCount += 1
                    }
                    else if "\(GDP.selectedMatch?.visitorteam_id ?? 0)" == "\(dataResponse[i].team_id ?? 0)"
                    {
                        visitorPlayersCount += 1
                    }
                    break
                }
             }
            
           }
             
            if usedCreditsCount == 0
            {
                usedCreditsCount = 100.0
            }
            
            self.playerTypeCount.wicketkeeper = self.TeamData!.total_wicketkeeper ?? 0
            self.playerTypeCount.batsman = self.TeamData!.total_batsman ?? 0
            self.playerTypeCount.bowler = self.TeamData!.total_bowler ?? 0
            self.playerTypeCount.allrounder = self.TeamData!.total_allrounder ?? 0
            self.playerTypeCount.totalSelectedPlayers = 11
            self.playerTypeCount.localPlayers = localPlayersCount
            self.playerTypeCount.visitorPlayers = visitorPlayersCount
            self.playerTypeCount.usedCredits = usedCreditsCount
            self.playerTypeCount.captainId = self.TeamData!.captain_player_id ?? ""
            self.playerTypeCount.viceCaptainId = self.TeamData!.vice_captain_player_id ?? ""
            self.playerTypeCount.teamId = self.TeamData!.team_id ?? ""
            self.playerTypeCount.extraPlayers = 7
            
        }
    }
    

}
extension CreateTeamViewController{
    func getPlayerList (){
        let params:[String:String] = [
            "match_id":String(GDP.selectedMatch?.match_id ?? 0),
            "series_id":String(GDP.selectedMatch?.series_id ?? 0),
            "local_team_id":String(GDP.selectedMatch?.localteam_id ?? 0),
            "visitor_team_id":String(GDP.selectedMatch?.visitorteam_id ?? 0)
        ]
        
        let url = URLMethods.BaseURL + URLMethods().getPlayersList

        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                if result != nil {
                    if self.isFromEdit.uppercased() != "EDIT"{
                        self.currentTeamCount = (result?.object(forKey: "playerTeamCount") as? Int) ?? 0
                        self.currentTeamCount = self.currentTeamCount + 1
                        self.navigationView.btnFantasyType.setTitle("Create Team \(self.currentTeamCount)", for: .normal)
                    }
                    let data = result?.object(forKey: "results") as? [[String:Any]]
                        if data != nil{
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                                  var tblData = try? JSONDecoder().decode([Player].self, from: jsonData)else {return }
                            self.arrAllPlayers = tblData
                            
                            if self.isFromEdit == "Edit"
                            {
                                self.populateEditTeamData(dataResponse: tblData)
                            }
                            else if self.isFromEdit == "Clone"
                            {
                                self.populateCloneTeamData(dataResponse: tblData)
                            }
                            else if self.isFromEdit == "GuruTeam"
                            {
                                self.isFromEdit = ""
                                //self.selectedPlayers = self.guruPlayers.guruPlayerIds
                                self.playerTypeCount = self.guruPlayers.suggestGuruPlayers
                            }
                            self.arrWicketKeeper.removeAll()
                            self.arrBatsman.removeAll()
                            self.arrAllRounder.removeAll()
                            self.arrBowler.removeAll()
                            
                            var arrWicketK = Array<Int>()
                            for index  in 0..<(tblData.count) {
                                let player = tblData[index]
                                if player.player_role!.contains(GDP.wc){
                                    arrWicketK.append(index)
                                    self.arrWicketKeeper.append(player)
                                }
                            }
                            
                            for index in arrWicketK.reversed() {
                                tblData.remove(at: index)
                            }
                            
                            self.arrBatsman = tblData.filter({($0.player_role!.contains(GDP.bat))})
                            self.arrBowler = tblData.filter({($0.player_role!.contains(GDP.bwl))})
                            self.arrAllRounder = tblData.filter({($0.player_role!.contains(GDP.ar))})
                            
                            
                            self.setupDefaultSorting()
                            
                            
                            self.tblTeamList.reloadData()
                            self.showPlayerCount()
                            
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
    
    
    func populateGuruTeam (){
        let params:[String:Any] = ["series_id":GDP.selectedMatch?.series_id ?? 0,
                                   "match_id":GDP.selectedMatch?.match_id ?? 0,
        ]
        
        let url = URLMethods.BaseURL + URLMethods().guruTeam

        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                if result != nil {
                    let data = result?["results"] as? [[String:Any]]
                        if data != nil{
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                                  let tblData = try? JSONDecoder().decode([Player].self, from: jsonData)else {return }
                            let arrPlayers = tblData
                            self.guruPlayers = GuruPlayers()
                            self.guruPlayers.guruPlayerIds = arrPlayers.map({ (player: Player) -> String in
                                "\(player.player_id ?? 0)"
                            })
                            self.guruPlayers.suggestGuruPlayers = SelectedPlayerTypes()
                            var arrPlayerData = [PlayerDetails]()
                            
                            var localTeamCount = 0
                            var playingCredits = 0.0
                            if arrPlayers.count > 0
                            {
                                for index  in 0..<arrPlayers.count {
                                    let player = arrPlayers[index]
                                    var playerData = PlayerDetails()
                                    playerData.name = "\(player.player_name ?? "")"
                                    playerData.credits = "\(self.getDouble(for: player.player_credit as Any))"
                                    playerData.role = "\(player.player_role ?? "")"
                                    playerData.points = "\(self.getDouble(for: player.points as Any))"
                                    playerData.image = "\(player.player_image ?? "")"
                                    playerData.player_id = "\(player.player_id ?? 0)"
                                    playerData.inGuruTeam = true
                                    playerData.isCaptain = player.isCaptain ?? false
                                    playerData.isViceCaptain = player.isViceCaptain ?? false

                                    playerData.is_local_team = "\(player.team_id ?? 0)".caseInsensitiveCompare("\(GDP.selectedMatch?.localteam_id ?? 0)") == .orderedSame
                                    
                                    if playerData.is_local_team == true{
                                        localTeamCount = localTeamCount + 1
                                    }

                                    playingCredits = playingCredits + (player.player_credit ?? 0)
                                    playerData.is_playing = player.is_playing ?? false

                                    arrPlayerData.append(playerData)
                                }
                                
                            }
                            
                            for index  in 0..<arrPlayerData.count {
                                let player = arrPlayerData[index]
                                if player.role.contains(GDP.wc) {
                                    arrPlayerData[index].role = GDP.wc
                                }
                            }
                            let arrBatsman = arrPlayerData.filter({$0.role.contains(GDP.bat)})
                            let arrBowlers = arrPlayerData.filter({$0.role.contains(GDP.bwl)})
                            let arrAllRoud = arrPlayerData.filter({$0.role.contains(GDP.ar)})
                            
                            
                            let captain = arrPlayerData.filter({$0.isCaptain == true})
                            let viceCaptain = arrPlayerData.filter({$0.isViceCaptain == true})
                            
                            
                            self.guruPlayers.suggestGuruPlayers.batsman = arrBatsman.count
                            self.guruPlayers.suggestGuruPlayers.allrounder = arrAllRoud.count
                            self.guruPlayers.suggestGuruPlayers.bowler =  arrBowlers.count
                            self.guruPlayers.suggestGuruPlayers.wicketkeeper = 1
                            
                            self.guruPlayers.suggestGuruPlayers.batsman = arrBatsman.count
                            self.guruPlayers.suggestGuruPlayers.bowler = arrBowlers.count
                            self.guruPlayers.suggestGuruPlayers.allrounder = arrAllRoud.count
                            self.guruPlayers.suggestGuruPlayers.totalSelectedPlayers = 11
                            self.guruPlayers.suggestGuruPlayers.localPlayers = localTeamCount
                            self.guruPlayers.suggestGuruPlayers.visitorPlayers = 11 - localTeamCount
                            self.guruPlayers.suggestGuruPlayers.usedCredits = playingCredits
                            self.guruPlayers.suggestGuruPlayers.captainId = captain.first?.player_id ?? ""
                            self.guruPlayers.suggestGuruPlayers.viceCaptainId = viceCaptain.first?.player_id ?? ""
                            self.guruPlayers.suggestGuruPlayers.teamId =  ""
                            self.guruPlayers.suggestGuruPlayers.extraPlayers = 3
                            
                            self.guruPlayers.arrWicketKeeper.removeAll()
                            var arrWicketK = Array<Int>()
                            for index  in 0..<(tblData.count) {
                                let player = tblData[index]
                                if player.player_role!.contains(GDP.wc){
                                    arrWicketK.append(index)
                                    self.guruPlayers.arrWicketKeeper.append(player)
                                }
                            }

                            
                            let vc = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "TeamPreviewVC") as! TeamPreviewVC
                            vc.delegate = self
                            vc.teamNumber = "Guru Team"
                            vc.strFromVC = "CreateTeam"
                            vc.playerDetails = arrPlayerData
                            vc.selectedPlayers = self.guruPlayers.suggestGuruPlayers
                            vc.teamName = "Guru Team"
                            vc.strCaptainId = captain.count > 0 ? captain[0].player_id : ""
                            vc.strViceCaptainId = viceCaptain.count > 0 ? viceCaptain[0].player_id : ""
                            vc.strPointsSuffix = "Cr"
                            vc.modalPresentationStyle = .custom
                            vc.userTeamName = "GuruTeam"
                            vc.isShowTopPlayer = true
                            UIApplication.getTopMostViewController()?.present(vc, animated: true, completion: nil)
                            
                        }else{
                            AppManager.showToast(msg ?? "", view: self.view)
                        }
                }else{
                    AppManager.showToast(msg ?? "", view: self.view)
                }
            }
            else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
            AppManager.stopActivityIndicator(self.view)
        }
        AppManager.startActivityIndicator(sender: self.view)
    }
    
    
    func setupDefaultSorting(){
        
        self.btnCreditSort.isSelected = true
        
        self.arrWicketKeeper.sort { (first, second) -> Bool in
            return self.getDouble(for: first.player_credit as Any) > self.getDouble(for: second.player_credit as Any)
        }

        self.arrBatsman.sort { (first, second) -> Bool in
                            return self.getDouble(for: first.player_credit as Any)  > self.getDouble(for: second.player_credit as Any)
                        }

          self.arrAllRounder.sort { (first, second) -> Bool in
                            return self.getDouble(for: first.player_credit as Any)  > self.getDouble(for: second.player_credit as Any)
                        }


        self.arrBowler.sort { (first, second) -> Bool in
                            return self.getDouble(for: first.player_credit as Any) > self.getDouble(for: second.player_credit as Any)
                        }
    }
    
    func validateCricketPlayers() -> Bool{
        if self.playerTypeCount.wicketkeeper < 1{
            self.btnPlayerTabPressed(btnWk)
            AppManager.showToast(ConstantMessages.kWKSelectionMessage, view: self.view)
            return false
        }
        if self.playerTypeCount.batsman < 1{
            self.btnPlayerTabPressed(btnBat)
            AppManager.showToast(ConstantMessages.kBatSelectionMessage, view: self.view)
            return false
        }
        
        if self.playerTypeCount.allrounder < 1{
            self.btnPlayerTabPressed(btnAr)
            AppManager.showToast(ConstantMessages.kAllRounderSelectionMessage, view: self.view)
            return false
        }
       
        if self.playerTypeCount.bowler < 1{
            self.btnPlayerTabPressed(btnBowl)
            AppManager.showToast(ConstantMessages.kBowlerSelectionMessage, view: self.view)
            return false
        }
        
        if self.playerTypeCount.totalSelectedPlayers < 11
        {
            AppManager.showToast("Please complete your team first with 11 players", view: self.view)
            return false
        }
        
        return true
    }

}
extension CreateTeamViewController : EditTeamDelegate
{
    func editMyTeam(index: Int) {
        
        self.isFromEdit = "GuruTeam"
        self.getPlayerList()
    }
}

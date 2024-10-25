//
//  SeasonCreateTeamVC.swift
//  India’s fantasy
//
//  Created by admin on 02/05/23.
//

import UIKit

class SeasonCreateTeamVC: UIViewController {
    
    @IBOutlet weak var btnCreditSort: UIButton!
    @IBOutlet weak var btnSelSort: UIButton!
    @IBOutlet weak var btnPointSort: UIButton!
    @IBOutlet weak var navigationView: SeasonNavigation!
    @IBOutlet weak var lblTransferUse: UILabel!
    @IBOutlet weak var btnHistory: UIButton!
    @IBOutlet weak var lblSelectedGenreText: UILabel!
    @IBOutlet weak var scrlViewIndicator: UIScrollView!
    @IBOutlet weak var btnBowl: UIButton!
    @IBOutlet weak var btnAr: UIButton!
    @IBOutlet weak var btnBat: UIButton!
    @IBOutlet weak var btnWk: UIButton!
    
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lblCredits: UILabel!
    @IBOutlet weak var lblSelectedPlayers: UILabel!
    @IBOutlet weak var lblVisitorTeam: UILabel!
    @IBOutlet weak var lblHomeTeam: UILabel!
    @IBOutlet weak var imgVisitorTeam: UIImageView!
    @IBOutlet weak var imgLocalTeam: UIImageView!
    
    @IBOutlet weak var viewWK: UIView!
    @IBOutlet weak var viewBat: UIView!
    @IBOutlet weak var viewAR: UIView!
    @IBOutlet weak var viewBowl: UIView!
    @IBOutlet weak var viewFilterApplied: UIView!
    
    @IBOutlet weak var tblTeamList: UITableView!
    
    private var selectedPreviousPlayers = [Int]()
    var selectedPlayers = [Player]()
    var playerTypeCount = SelectedPlayerTypes()
 
    var guruPlayers = GuruPlayers()
    
    var substituteId = ""
    var isFromEdit = ""
    var TeamData:Team?
    var strCaptainID = ""
    var strViceCaptainID = ""
    var strBoosterPlayerID = ""
    var teamID = ""
    var strTeamNumber = ""

    var strVCFrom = ""
    
    var arrAllPlayers = [Player]()

    var arrWicketKeeper = [Player]()
    var arrBatsman = [Player]()
    var arrBowler = [Player]()
    var arrAllRounder = [Player]()
    
    var transferMadeCount: Int = 0
    var availableTransfer: Int = 0
    //var selectedBooster: [Booster]? = nil
    
    var arrAllTeams: [PlayerFilters] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.btnPlayerTabPressed(btnWk)
        self.getPlayersList()
//        if isFromEdit == "Edit" {
//            btnHistory.isHidden = false
//            getBoosters()
//        }
    }
    
    private func setupNavigationView() {
        
        navigationView.setupUI(title: GDP.leagueName, hideBG: true)
    }
    
    func setupUI() {
        
        setupNavigationView()
        
        if let match = GDP.selectedMatch {
            
            imgLocalTeam.loadImage(urlS: match.localteam_flag, placeHolder: Constants.kNoImageUser)
            lblHomeTeam.text = match.localteam_short_name
            imgVisitorTeam.loadImage(urlS: match.visitorteam_flag, placeHolder: Constants.kNoImageUser)
            lblVisitorTeam.text = match.visitorteam_short_name
            
            //CommonFunctions().timerStart(date: navigationView.lblSubTitle, strTime: match.start_time ?? "", strDate: match.start_date, viewcontroller: self)
            CommonFunctions().timerStart(lblTime: navigationView.lblSubTitle, strDate: match.match_date ?? "", viewcontroller: self, fromSeasonMyTeams: false)
        }
        
        self.btnWk.setTitle("", for: .normal)
        self.btnBat.setTitle("", for: .normal)
        self.btnAr.setTitle("", for: .normal)
        self.btnBowl.setTitle("", for: .normal)
    }
    
    func populateScrollView(){
        
        self.resetScrollViewPoints()
        
        var currX = 0
        for i  in 0..<selectedPlayers.count {
            let width = scrlViewIndicator.frame.size.width
            let itemWidth = width / 11
            let view = UIView(frame: CGRect(x: CGFloat(currX), y: 0, width: itemWidth, height: 22))
            
            let img = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
            img.contentMode = .scaleAspectFit
            view.addSubview(img)
            scrlViewIndicator.addSubview(view)

            img.backgroundColor = .white
            img.loadImage(urlS: selectedPlayers[i].team_flag, placeHolder: Constants.kNoImageUser)
            
            view.clipsToBounds = true
            
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
    
    @IBAction func btnFilterPlayersPressed(_ sender: UIButton) {
        guard let vc = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "PlayersFilterVC") as? PlayersFilterVC else { return }
        vc.arrTeams = self.arrAllTeams.sorted(by: {$0.name < $1.name})
        vc.completion = { teams in
            self.arrAllTeams = teams
            self.applyFilters()
        }
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
        vc.isFromLeague = true
        //vc.isCreateTeam = true
        
        if self.selectedPlayers.contains(where: {$0.player_id == (player.player_id ?? 0)}) {
            vc.inMyTeam = true
        }else {
            vc.inMyTeam = false
        }
//        if self.selectedPlayers.contains("\(player.player_id ?? 0)"){
//            vc.inMyTeam = true
//        }else{
//            vc.inMyTeam = false
//        }
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
//                if player.player_id == Int(self.selectedPlayers[j].player_id){
//                arrSelectedTeam.append(player)
//            }
//        }
//        }
        
        let vc = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonTeamPreviewVC") as! SeasonTeamPreviewVC

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
        
        selectedPlayers.captainId = TeamData?.captain_player_id ?? ""
        selectedPlayers.viceCaptainId = TeamData?.vice_captain_player_id ?? ""

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
        
        let vc = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonChooseCaptainVC") as! SeasonChooseCaptainVC
       
        vc.arrAllPlayers = self.arrAllPlayers
        vc.arrPlayers = self.selectedPlayers
        vc.playerTypeCount = self.playerTypeCount
        vc.substituteId = self.substituteId
        vc.isFromEdit = self.isFromEdit
        vc.selectedBooster = TeamData?.boosterDetails
        
        vc.strTeamID = self.teamID
        if self.isFromEdit == "Edit"
        {
            vc.strCaptain = self.strCaptainID
            vc.strViceCaptain = self.strViceCaptainID
            vc.isFromVC = "Edit"
            vc.strBoosterPlayerId = self.strBoosterPlayerID
            vc.transfersUse = self.lblTransferUse.text ?? ""
        }
        else if self.isFromEdit == "Clone"
        {
            vc.strCaptain = self.strCaptainID
            vc.strViceCaptain = self.strViceCaptainID
            vc.isFromVC = "Clone"
            vc.strBoosterPlayerId = self.strBoosterPlayerID
        }
        else
        {
            vc.isFromVC = self.strVCFrom
        }

        vc.strTeamNumber = self.strTeamNumber
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
    
    func applyFilters()  {
                                                             
        let selectedTeams = self.arrAllTeams.filter({$0.isSelected == true}).map({$0.name})
        debugPrint("=========Selected Teams Short Name==========")
        debugPrint(selectedTeams)
        
        removeFilters()
        
        guard !selectedTeams.isEmpty else {
            viewFilterApplied.isHidden = true
            tblTeamList.reloadData()
            return
        }
        
        viewFilterApplied.isHidden = false
        
        self.arrWicketKeeper = self.arrWicketKeeper.filter { player in
            selectedTeams.contains(where: {$0 == (player.team_short_name ?? "")})
        }
        
        self.arrBatsman = self.arrBatsman.filter { player in
            selectedTeams.contains(where: {$0 == (player.team_short_name ?? "")})
        }
        
        self.arrAllRounder = self.arrAllRounder.filter { player in
            selectedTeams.contains(where: {$0 == (player.team_short_name ?? "")})
        }
        
        self.arrBowler = self.arrBowler.filter { player in
            selectedTeams.contains(where: {$0 == (player.team_short_name ?? "")})
        }
        
        tblTeamList.reloadData()
    }
    
    func removeFilters()  {
        
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
        
        //tblTeamList.reloadData()
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
        
//        if self.selectedPlayers.contains("\(player.player_id ?? 0)") {
//            cell?.btnAddPlayer.isSelected = false
//            let arr = self.selectedPlayers.filter({$0 != "\(player.player_id ?? 0)"})
//            self.selectedPlayers.removeAll()
//            self.selectedPlayers.append(contentsOf: arr)
//            changeCont = -1
//        }else {
//            cell?.btnAddPlayer.isSelected = true
//            self.selectedPlayers.append("\(player.player_id ?? 0)")
//            changeCont = 1
//        }
        
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
        }else if "\(GDP.selectedMatch?.visitorteam_id ?? 0)" == "\(player.team_id ?? 0)"{
            self.playerTypeCount.visitorPlayers += changeCont
        }
        
        self.playerTypeCount.captainId = self.playerTypeCount.captainId == "\(player.player_id ?? 0)" ? "" : self.playerTypeCount.captainId
        self.playerTypeCount.viceCaptainId = self.playerTypeCount.viceCaptainId == "\(player.player_id ?? 0)" ? "" : self.playerTypeCount.viceCaptainId
        self.playerTypeCount.playerData = player
        
        if !self.selectedPlayers.contains(where: {"\($0.player_id ?? 0)" == strCaptainID}) {
            strCaptainID = ""
        }
        
        if !self.selectedPlayers.contains(where: {"\($0.player_id ?? 0)" == strViceCaptainID}) {
            strViceCaptainID = ""
        }
        
        if !self.selectedPlayers.contains(where: {"\($0.player_id ?? 0)" == strBoosterPlayerID}) {
            strBoosterPlayerID = ""
        }
        
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
        if self.playerTypeCount.totalSelectedPlayers >= 11 {
            btnNext.backgroundColor = UIColor.appHighlightedTextColor
            btnNext.setTitleColor(UIColor.black, for: .normal)
        }else{
            btnNext.backgroundColor = UIColor.lightGray
            btnNext.setTitleColor(UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1.0), for: .normal)
        }
        
        self.btnWk.setTitle("\(GDP.wkShort)(\(self.playerTypeCount.wicketkeeper))", for: .normal)
        self.btnBat.setTitle("\(GDP.batShort)(\(self.playerTypeCount.batsman))", for: .normal)
        self.btnAr.setTitle("\(GDP.arShort)(\(self.playerTypeCount.allrounder))", for: .normal)
        self.btnBowl.setTitle("\(GDP.bowlShort)(\(self.playerTypeCount.bowler))", for: .normal)

        self.tblTeamList.reloadData()
        
        
        let arrSelectedPlayerIDs = self.selectedPlayers.map({$0.player_id ?? 0})
        
        print("*********Current Players*******\n\(arrSelectedPlayerIDs)")
        print("*********Previous Players*******\n\(self.selectedPreviousPlayers)")

        let newSelectedPlayerIDS = arrSelectedPlayerIDs.filter({!self.selectedPreviousPlayers.contains($0)})
        print("*********New Players*******\n\(newSelectedPlayerIDS)")
        
        if isFromEdit == "Edit" {
            lblTransferUse.isHidden = false
            lblTransferUse.text = "\(newSelectedPlayerIDS.count + transferMadeCount)/\(availableTransfer) transfer in use"
        }
        
    }
    
    
}
extension SeasonCreateTeamVC:UITableViewDataSource, UITableViewDelegate {
    
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
            //cell.updateView(player: playerInfo, match: GDP.selectedMatch)
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
            //cell.updateView(player: playerInfo, match: GDP.selectedMatch)

        }else if btnAr.isSelected == true{
            playerInfo = arrAllRounder[indexPath.row]
            if (self.playerTypeCount.allrounder >= 1 && self.playerTypeCount.extraPlayers >= 7) || self.playerTypeCount.allrounder >= 8 {
                cell.viewGrayout.isHidden = false
            }else {
                cell.viewGrayout.isHidden = true
            }
            //cell.updateView(player: playerInfo, match: GDP.selectedMatch)

        }else{
            playerInfo = arrBowler[indexPath.row]
            if (self.playerTypeCount.bowler >= 1 && self.playerTypeCount.extraPlayers >= 7) || self.playerTypeCount.bowler >= 8 {
                cell.viewGrayout.isHidden = false
            }else {
                cell.viewGrayout.isHidden = true
            }
            //cell.updateView(player: playerInfo, match: GDP.selectedMatch)
        }
        
        if self.selectedPlayers.contains(where: {$0.player_id == (playerInfo?.player_id ?? 0)}) {
            cell.viewGrayout.isHidden = true
        }
//        if self.selectedPlayers.contains("\(playerInfo?.player_id ?? 0)"){
//            cell.viewGrayout.isHidden = true
//        }
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
//        if self.selectedPlayers.contains("\(playerInfo?.player_id ?? 0)"){
//            cell.btnAddPlayer.isSelected = true
//            cell.contentView.backgroundColor = UIColor.hexStringToUIColor(hex: "#344452")
//        }
        else {
            cell.btnAddPlayer.isSelected = false
//            cell.contentView.backgroundColor = UIColor.white
        }
        
//        if (playerInfo?.team_id ?? 0) == (GDP.selectedMatch?.localteam_id ?? 0){
//            cell.imgViewCountryFlag.loadImage(urlS: GDP.selectedMatch?.localteam_flag, placeHolder: Constants.kNoImageUser)
//        }else{
//            cell.imgViewCountryFlag.loadImage(urlS: GDP.selectedMatch?.visitorteam_flag, placeHolder: Constants.kNoImageUser)
//        }
        
        cell.lblPlayerName.text = playerInfo?.player_name ?? ""
        
        cell.imgViewPlayer.loadImage(urlS: playerInfo?.player_image, placeHolder: Constants.kNoImageUser)
        
        cell.lblCredits.text = "\(self.getDouble(for: playerInfo?.player_credit as Any))"
        
        cell.lblTeamShortName.text = playerInfo?.team_short_name
        cell.lblSel.text = "\(playerInfo?.selected_by ?? 0)" + "%"
        cell.lblPoints.text = "\(Double("\(playerInfo?.player_points! ?? 0)")?.clean ?? "0")"

        cell.btnAddPlayer.tag = indexPath.row
        cell.btnAddPlayer.addTarget(self, action: #selector(btnPlusTapped), for: .touchUpInside)
        
        
        cell.btnPlayerProfile.tag = indexPath.row
        cell.btnPlayerProfile.addTarget(self, action: #selector(btnPlayerProfileTapped), for: .touchUpInside)
        cell.viewAnnounced.isHidden = true

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
                    self.selectedPreviousPlayers = self.selectedPlayers.map({$0.player_id ?? 0})
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
extension SeasonCreateTeamVC {
    
    func getPlayersList() {
        
       // guard let seriesId = GDP.selectedMatch?.series_id else { return }
        
        WebCommunication.shared.getLeaguePlayersList(hostController: self, series_id: GDP.leagueSeriesId, showLoader: true) { players in
            
            guard var players = players else {
                return
            }
            
            self.arrAllPlayers = players
            
            if self.isFromEdit == "Edit"
            {
                self.populateEditTeamData(dataResponse: players)
            }
            else if self.isFromEdit == "Clone"
            {
                self.populateCloneTeamData(dataResponse: players)
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
            
            self.arrAllTeams = Array(Set(players.map({ player in
                return .init(name: player.team_short_name ?? "", isSelected: false)
            })))
            
            debugPrint("-------------All Teams-----------/n", self.arrAllTeams)
            
            self.setupDefaultSorting()
            
            self.tblTeamList.reloadData()
            self.showPlayerCount()
        }
        
    }
    
    func getBoosters() {
        
        guard let team = TeamData else { return }
        
        WebCommunication.shared.getBoosterList(hostController: self, seriesId: GDP.leagueSeriesId, matchId: "\(GDP.selectedMatch?.match_id ?? 0)", teamName: "\(team.team_number ?? 0)", showLoader: false) { boosterData, totalBoosters, usedBoosters in
            
            let boosterList = boosterData?.updatedBoostersList ?? []
            if !boosterList.isEmpty {
//                self.selectedBooster = boosterList.first(where: {$0.boosterCode == team.boosterCode})
            }
        }
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

                            
                            let vc = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonTeamPreviewVC") as! SeasonTeamPreviewVC
                            vc.teamNumber = "Guru Team"
                            vc.strFromVC = "CreateTeam"
                            vc.playerDetails = arrPlayerData
                            vc.selectedPlayers = self.guruPlayers.suggestGuruPlayers
                            vc.teamName = "Guru Team"
                            vc.strCaptainId = captain.count > 0 ? captain[0].player_id : ""
                            vc.strViceCaptainId = viceCaptain.count > 0 ? viceCaptain[0].player_id : ""
                            vc.strPointsSuffix = "Cr"
                            vc.modalPresentationStyle = .custom
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
        if self.playerTypeCount.wicketkeeper < 1 {
            self.btnPlayerTabPressed(btnWk)
            AppManager.showToast(ConstantMessages.kWKSelectionMessage, view: self.view)
            return false
        }
        if self.playerTypeCount.batsman < 1 {
            self.btnPlayerTabPressed(btnBat)
            AppManager.showToast(ConstantMessages.kBatSelectionMessage, view: self.view)
            return false
        }
        
        if self.playerTypeCount.allrounder < 1 {
            self.btnPlayerTabPressed(btnAr)
            AppManager.showToast(ConstantMessages.kAllRounderSelectionMessage, view: self.view)
            return false
        }
       
        if self.playerTypeCount.bowler < 1 {
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

extension SeasonCreateTeamVC : EditTeamDelegate
{
    func editMyTeam(index: Int) {
        
        self.isFromEdit = "GuruTeam"
        self.getPlayersList()
    }
}


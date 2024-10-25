//
//  TeamPreviewVc.swift
//  Fantasy Sports
//
//  Created by Uttam on 18/12/18.
//  Copyright © 2018 mac307. All rights reserved.
//

import UIKit
import SDWebImage

@objc protocol EditTeamDelegate
{
    func editMyTeam(index : Int)
}
class TeamPreviewVC: UIViewController {
    
    @IBOutlet weak var lblWicketKeeper: OctalLabel!
    @IBOutlet weak var lblBatsman: OctalLabel!
    @IBOutlet weak var lblAllRounders: OctalLabel!
    @IBOutlet weak var lblBowlers: OctalLabel!
    
    
    @IBOutlet weak var lblTeamRank: UILabel!
    @IBOutlet weak var editWidth: NSLayoutConstraint!
    @IBOutlet weak var lblLocalTeamShortName: UILabel!
    @IBOutlet weak var lblVisitorTeamShortName: UILabel!
    @IBOutlet weak var imgStar: UIImageView!
    @IBOutlet weak var lblTopPlayer: UILabel!
    
    @IBOutlet weak var collectionWicketKeeper: UICollectionView!
    @IBOutlet weak var collectionBowler: UICollectionView!
    @IBOutlet weak var collectionAllrounder: UICollectionView!
    @IBOutlet weak var collectionBatsMan: UICollectionView!
    @IBOutlet weak var lblTeamName: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    
    @IBOutlet weak var viewTotalPoints: UIView!


    @IBOutlet weak var btnRefresh: UIButton!
    
    @IBOutlet weak var lblRemainingTime: UILabel!
    @IBOutlet weak var lblTotalPoints: UILabel!
    @IBOutlet weak var imgGroundBg: UIImageView!
    @IBOutlet weak var viewRound: UIView!

    weak var delegate : EditTeamDelegate?
    @IBOutlet weak var lblBoostedPoints: UILabel!
    @IBOutlet weak var lblActualPoints: UILabel!
    
    @IBOutlet weak var viewTeamDebuffed: UIView!
    
    @IBOutlet weak var heightWK: NSLayoutConstraint!
    @IBOutlet weak var heighBAT: NSLayoutConstraint!
    @IBOutlet weak var heightAR: NSLayoutConstraint!
    @IBOutlet weak var heightBowl: NSLayoutConstraint!
    
    var matchDetails:Match? = nil
    
    var teamName = String()
    var selectedPlayers = SelectedPlayerTypes()
    var playerDetails = [PlayerDetails]()
    var subPlayer:Player? = nil
    
    var playerData = [Player]()
    
    var strCaptainId = String()
    var strViceCaptainId = String()
    var strPointsSuffix = String()
    var totalPoints = 0.0
    
    var isShowTopPlayer = false
    var isEditTeam = false
    var isRefresh = false
    var teamEditIndex = 0
    var otherUserId = ""
    
    var gameType = ""
    var teamPlayerData = [SelectedPlayerTypes]()
    var MaxValue = 0.0
    var teamNumber = "1"
    var userTeamRank  = ""
    var userTeamName  = ""

    var strFromVC = ""
    
    var TeamData:Team?

    var selectedCaptainID = ""
    var selectedViceCaptainID = ""
    var validTeamID = ""
    
    var isLiveMatch = false
    
    var arrSelectedWicketKeepers = [PlayerDetails]()
    var arrSelectedBatsman = [PlayerDetails]()
    var arrSelectedBowler = [PlayerDetails]()
    var arrSelectedAllRounder = [PlayerDetails]()
    
    var arrAllPlayers = [PlayerDetails]()
    
    var isDreamTeam = false
    
    var boostedPoints: Double = 0
    var actualPoints: Double = 0
    var showActualPoints: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        //viewRound.cornerRadius = Constants.kScreenWidth / 2 + 50
        self.updateDidLoad()
     //   self.automaticallyAdjustsScrollViewInsets = false
        self.lblTeamName.text = teamName.uppercased()
        if matchDetails?.match_status?.uppercased() == "NOT STARTED" || matchDetails?.match_status?.uppercased() == "UPCOMING" || self.userTeamRank == "0" || self.userTeamRank == ""{
            self.lblTeamRank.text = ""
        }else{
            self.lblTeamRank.text = "#\(self.userTeamRank)"
        }

        self.arrAllPlayers.append(contentsOf: arrSelectedWicketKeepers)
        self.arrAllPlayers.append(contentsOf: arrSelectedBatsman)
        self.arrAllPlayers.append(contentsOf: arrSelectedBowler)
        self.arrAllPlayers.append(contentsOf: arrSelectedAllRounder)
        
        if GDP.selectedMatch?.match_status?.count ?? 0 > 0 && self.teamNumber != "" {
            self.btnRefresh.isHidden = false
        }
        else {
            self.btnRefresh.isHidden = true
        }
        
        if self.isLiveMatch == true{
            btnEdit.isHidden = true
            editWidth.constant = 0
        }
        
        let localPlayers = self.arrAllPlayers.filter({$0.is_local_team == true})
        lblLocalTeamShortName.text = "\(GDP.selectedMatch?.localteam_short_name ?? "") \(localPlayers.count)"
        let visitorPlayers = self.arrAllPlayers.filter({$0.is_local_team == false})
        lblVisitorTeamShortName.text = "\(GDP.selectedMatch?.visitorteam_short_name ?? "") \(visitorPlayers.count)"

        if self.userTeamName == "GuruTeam"{
            editWidth.constant = 30
            self.btnEdit.setImage(UIImage(), for: .normal)
            self.btnEdit.setTitle("Clone", for: .normal)
        }
        
       
        if GDP.selectedMatch?.match_status?.uppercased() == "NOT STARTED" || GDP.selectedMatch?.match_status?.uppercased() == "UPCOMING"{
            self.btnEdit.isHidden = false
            editWidth.constant = 30
            self.startTimer()
        }else{
            self.btnEdit.isHidden = true
            editWidth.constant = 0
            lblRemainingTime.isHidden = true
            //lblTeamRank.isHidden = false
            
            if let team = TeamData {
                self.lblBoostedPoints.isHidden = false
                self.lblActualPoints.isHidden = true
                self.lblBoostedPoints.text = "\(team.total_point?.formattedNumber() ?? "") Pts"
                self.lblActualPoints.text = ""//"Actual: \(team.actualPoints?.formattedNumber() ?? "") Pts"
            }
        }
        
        self.viewTeamDebuffed.isHidden = !(TeamData?.isDebuffApplied ?? false)
    }
    
    override func viewDidLayoutSubviews() {
        heightWK.constant = collectionWicketKeeper.collectionViewLayout.collectionViewContentSize.height + 30
        heighBAT.constant = collectionBatsMan.collectionViewLayout.collectionViewContentSize.height + 30
        heightBowl.constant = collectionBowler.collectionViewLayout.collectionViewContentSize.height + 30
        heightAR.constant = collectionAllrounder.collectionViewLayout.collectionViewContentSize.height + 30
        self.view.layoutIfNeeded()
    }

    func startTimer()
    {
        //CommonFunctions().timerStart(date: self.lblRemainingTime, strTime: GDP.selectedMatch?.start_time ?? "", strDate: GDP.selectedMatch?.start_date, viewcontroller: self)
        CommonFunctions().timerStart(lblTime: self.lblRemainingTime, strDate: GDP.selectedMatch?.match_date ?? "", viewcontroller: self, fromSeasonMyTeams: false, isFromHome: true)
    }
    
    func setupLayout(count : Int, collectionView : UICollectionView) {
        DispatchQueue.main.async {
            let cellWidth = (56.0/79.0) * collectionView.frame.size.height
            let cellSize = CGSize(width: cellWidth , height: collectionView.frame.size.height)
            
            var spacing =  collectionView.frame.size.width - (CGFloat(count)*cellWidth)
            spacing = spacing/CGFloat(count-(count > 1 ? 1 : -1))
            
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = cellSize
            layout.minimumInteritemSpacing = spacing
            layout.scrollDirection = .horizontal
            
            collectionView.collectionViewLayout = layout
            collectionView.reloadData()
        }
    }
    
    func updateDidLoad()  {
        self.playerDetails.sort { (first, second) -> Bool in
            return first.role == GDP.bwl
        }
        self.playerDetails.sort { (first, second) -> Bool in
            return first.role == GDP.ar
        }
        self.playerDetails.sort { (first, second) -> Bool in
            return first.role == GDP.bat
        }
        self.playerDetails.sort { (first, second) -> Bool in
            return first.role == GDP.wc
        }
        
        
        self.arrSelectedWicketKeepers = (self.playerDetails.filter({$0.role == GDP.wc}))
        self.arrSelectedBatsman = (self.playerDetails.filter({$0.role == GDP.bat}))
        self.arrSelectedAllRounder = (self.playerDetails.filter({$0.role == GDP.ar}))
        self.arrSelectedBowler = (self.playerDetails.filter({$0.role == GDP.bwl}))
        
        self.collectionWicketKeeper.reloadData()
        self.collectionBowler.reloadData()
        self.collectionBatsMan.reloadData()
        self.collectionAllrounder.reloadData()
        
        if self.strFromVC != ""
        {
            self.btnEdit.isHidden = false
            editWidth.constant = 30
        }
        else
        {
            self.btnEdit.isHidden = true
            editWidth.constant = 0
        }
        
        self.lblTopPlayer.isHidden = !self.isShowTopPlayer
        self.imgStar.isHidden = !self.isShowTopPlayer
        
    }
    
    func updateTotalPoints(){
        var totalPoints = 0.0

        for player in self.playerDetails {
            totalPoints += Double(player.points)!
        }
        
        DispatchQueue.main.async {
            self.lblRemainingTime.text = "\(totalPoints) Pts"
        }
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        DispatchQueue.main.async {
//            let layout = self.collectionBowler.collectionViewLayout as! UICollectionViewFlowLayout
//            layout.minimumInteritemSpacing = 7
//            self.collectionBowler.collectionViewLayout = layout
//            self.collectionBowler.reloadData()
//        }
//        
//        DispatchQueue.main.async {
//            let layout = self.collectionWicketKeeper.collectionViewLayout as! UICollectionViewFlowLayout
//            layout.minimumInteritemSpacing = 7
//            self.collectionWicketKeeper.collectionViewLayout = layout
//            self.collectionWicketKeeper.reloadData()
//        }
//    }
    
    @IBAction func btnCloseAction(_ sender : UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnEditTeamAction(_ sender: UIButton) {
        
        if let matchDate = CommonFunctions.getDateFromString(date: GDP.selectedMatch?.match_date ?? "", format: "yyyy-MM-dd'T'HH:mm:ss"), Date() >= matchDate {
            self.alertBoxWithAction(message: ConstantMessages.kMatchNotStarted, btnTitle: ConstantMessages.OkBtn) { }
            return
        }
        
        if self.delegate != nil
        {
            self.dismiss(animated: true, completion:  {
                self.delegate?.editMyTeam(index: self.teamEditIndex)
            })
        }
        else
        {
            self.dismiss(animated: true, completion:  {
//                let dataDict = self.TeamData
//                let navData = AppStoryboard.Cricket.instance.instantiateViewController(withIdentifier: "CAChooseTeamVc") as! CAChooseTeamVc
//                navData.GDP.selectedMatch = GDP.selectedMatch
//                navData.setSelectTeamDelegate = true
//                navData.isFromEdit = "Edit"
//                navData.TeamData = dataDict
//                navData.strCaptainID = "\(dataDict?.captainPlayerID ?? "0")"
//                navData.strViceCaptainID = "\(dataDict?.viceCaptainPlayerID ?? "0")"
//                navData.teamID = "\(dataDict?.teamID ?? "0")"
//                navData.strTeamNumber = "\(dataDict?.teamNumber ?? 1)"
//                self.navigationController?.pushViewController(navData, animated: true)
            })
            
        }
    }
    
    @IBAction func btnRefreshTapped(_ sender: Any)
    {
       // self.getTeamAPI(teamNumber: self.validTeamID, userId: self.otherUserId)
    }

    
    @IBAction func btnPointsTapped(_ sender: Any) {
        
        self.dismiss(animated: true) {
            let vc = Constants.KSideMenuStoryboard.instantiateViewController(withIdentifier: "WebPageViewController") as! WebPageViewController
            vc.url = URL(string: URLMethods.FantasyPointSystem_URL)
            vc.headerText = "Fantasy Points System"
            UIApplication.getTopViewController()?.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @IBAction func btnWicketKeeperDetailsAction(_ sender: UIButton) {
        let player = playerDetails[0]
        let vc = PlayerInfoVC(nibName:"PlayerInfoVC", bundle:nil)
        vc.modalPresentationStyle = .custom
        vc.playerId = player.player_id
        self.present(vc, animated: true) {
            vc.getPlayerDetails()
        }
//        let player = playerDetails[0]
//        if self.strFromVC == "LiveLeaderboard" || self.strFromVC == "CompletedLeaderboard"
//        {
//            let pIndex = self.playerData.firstIndex { (fPlayer) -> Bool in
//                return "\(fPlayer.player_id ?? 0)" == player.player_id
//            }
//            if self.playerData.count <= 0 {
//                self.getPlayersStatsAPI(pIndex: 0)
//            }else {
//                if self.playerData[pIndex ?? 0].playerBreckup != nil && pIndex != nil {
//                    let vc = AppStoryboard.Contest.instance.instantiateViewController(withIdentifier: "CAPlayerPointsBreakupVC") as! CAPlayerPointsBreakupVC
//                    vc.player_stats = self.playerData[pIndex ?? 0]
//                    vc.modalPresentationStyle = .custom
//                    self.present(vc, animated: true, completion: nil)
//                }else {
//                    self.showMessageFromTop(message: "Player stats not available.")
//                }
//            }
//        }
//        else
//        {
//            let vc = AppStoryboard.MyContest.instance.instantiateViewController(withIdentifier: "CATeamPlayerDetailVc" ) as! CATeamPlayerDetailVc
//            vc.playerId = player.player_id
//            vc.seriesId = "\(GDP.selectedMatch!.seriesID!.value)"
//            self.present(vc, animated: true, completion: nil)
//        }
        
    }
    
    @IBAction func btnSubstituteDetailsAction(_ sender: UIButton) {
//        if strPointsSuffix == "Cr" {
//            let vc = AppStoryboard.MyContest.instance.instantiateViewController(withIdentifier: "CATeamPlayerDetailVc" ) as! CATeamPlayerDetailVc
//            vc.playerId = subPlayer.player_id
//            vc.seriesId = self.matchDetails.series_id
//            self.present(vc, animated: true, completion: nil)
//        }else {
//            let pIndex = self.playerData.firstIndex { (fPlayer) -> Bool in
//                return "\(fPlayer.playerID ?? "0")" == self.subPlayer.player_id
//            }
//            if self.playerData.count <= 0 {
//                self.getPlayersStatsAPI(player: self.subPlayer)
//            }else {
////                if self.playerData[pIndex ?? 0].player_breckup != nil && pIndex != nil {
////                    let vc = AppStoryboard.Contest.instance.instantiateViewController(withIdentifier: "CAPlayerPointsBreakupVC") as! CAPlayerPointsBreakupVC
////                    vc.player_stats = self.playerData[pIndex ?? 0]
////                    vc.modalPresentationStyle = .custom
////                    self.present(vc, animated: true, completion: nil)
////                }else {
////                    HelperClass.showToastAlertMsg(msg: "Player stats not available.", owner: self)
////                }
//            }
//        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller usingf segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}

extension TeamPreviewVC: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
            return self.selectedPlayers.batsman
        }
        else if collectionView.tag == 1 {
            return self.selectedPlayers.allrounder
        }
        else if collectionView.tag == 2 {
            return self.selectedPlayers.bowler
        }
        if collectionView.tag == 3 {
            return self.selectedPlayers.wicketkeeper
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
                
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CABatsmenCollectionViewCell
        
        var player = PlayerDetails()
        
        if collectionView.tag == 0{
            player = self.arrSelectedBatsman[indexPath.row]
        }else if collectionView.tag == 1{
            player = self.arrSelectedAllRounder[indexPath.row]
        }else if collectionView.tag == 2{
            player = self.arrSelectedBowler[indexPath.row]
        }else if collectionView.tag == 3{
            player = self.arrSelectedWicketKeepers[indexPath.row]
        }
        
        cell.updateView(isLocalTeam: player.is_local_team)
                
        if let url = URL.init(string: player.image) {
            
            cell.imgPlayer.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imgPlayer.sd_setImage(with: url, placeholderImage: Constants.kNoImageUser)
        }else {
            cell.imgPlayer.image = Constants.kNoImageUser
        }
        cell.lblPlayerName.superview?.backgroundColor = player.is_local_team ? UIColor.appLocalTeamBackgroundColor : UIColor.appVisitorTeamBackgroundColor
        
        cell.imgBoosted.isHidden = !player.isBoosted
        cell.imgDebuffed.isHidden = !player.isDebuffed
        
        var playerName = player.name.components(separatedBy: " ")
        var strName = ""
        if playerName.count > 0 {
            strName = playerName.last ?? ""
            playerName.removeLast()
            var prefix = ""
            for str in playerName {
                if str != ""
                {
                    prefix = prefix + "\(String((str.first ?? player.name.character(at: 0))!)) "
                }
                
            }
            strName = prefix + strName
        }else {
            strName = player.name
        }
        
        cell.lblPlayerName.text = strName
        if self.strFromVC == "LiveLeaderboard" || self.strFromVC == "CompletedLeaderboard"
        {
            cell.lblPlayerCredit.text = player.points + " Pts"
        }
        else
        {
            cell.lblPlayerCredit.text = player.credits + " \(self.strPointsSuffix)"
        }
        
        //cell.imgStar.isHidden = !(player.inDreamTeam && self.isShowTopPlayer)
        
        cell.lblCaptain.isHidden = false
        if self.strCaptainId == player.player_id {
            cell.lblCaptain.backgroundColor = .appTitleColor
            cell.lblCaptain.text = "C"
        }else if self.strViceCaptainId == player.player_id {
            cell.lblCaptain.backgroundColor = .appTitleColor
            cell.lblCaptain.text = "VC"
        }else {
            cell.lblCaptain.isHidden = true
        }
        
        cell.lblLineup.backgroundColor = UIColor.clear

        if GDP.selectedMatch?.match_status?.uppercased() == "NOT STARTED" || GDP.selectedMatch?.match_status?.uppercased() == "UPCOMING"{
            
            if (GDP.selectedMatch?.lineup ?? false) == true {
                if player.is_playing == true{
                    cell.viewLineup.backgroundColor = UIColor.green
                }else{
                    cell.viewLineup.backgroundColor = UIColor.red
                }
            }else {
                cell.viewLineup.backgroundColor = UIColor.clear
            }
            
        }else{
            if isDreamTeam == true{
                cell.viewLineup.backgroundColor = UIColor.clear
            }else{
                if player.is_playing == true{
                    cell.viewLineup.backgroundColor = UIColor.green
                }else{
                    cell.viewLineup.backgroundColor = UIColor.red
                }
            }
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var player = PlayerDetails()
        
        if collectionView.tag == 0{
            player = self.arrSelectedBatsman[indexPath.row]
        }else if collectionView.tag == 1{
            player = self.arrSelectedAllRounder[indexPath.row]
        }else if collectionView.tag == 2{
            player = self.arrSelectedBowler[indexPath.row]
        }else if collectionView.tag == 3{
            player = self.arrSelectedWicketKeepers[indexPath.row]
        }
        
        
        if self.strFromVC == "LiveLeaderboard" || self.strFromVC == "CompletedLeaderboard"
        {
            
//            self.getSeriesPlayerList(playerDetail: player)
            
            let vc = PlayerPointsBreakupVC(nibName:"PlayerPointsBreakupVC", bundle:nil)
            vc.modalPresentationStyle = .custom
            vc.playerId = Int(player.player_id) ?? 0
            vc.arrBoosters = player.boosterDetails
            vc.arrDebuffed = player.debuffedDetails
            
            self.present(vc, animated: true)
            
//            if player.is_playing == true{
//                self.getSeriesPlayerList(playerDetail: player)
//            }else{
//                let vc = PlayerInfoVC(nibName:"PlayerInfoVC", bundle:nil)
//                vc.modalPresentationStyle = .custom
//
//                vc.playerId = player.player_id
//                vc.arrBoosters = player.boosterDetails
//                vc.arrDebuffed = player.debuffedDetails
//
//                self.present(vc, animated: true) {
//                    vc.getPlayerDetails()
//                }
//            }
        }
        else
        {
            let vc = PlayerInfoVC(nibName:"PlayerInfoVC", bundle:nil)
            vc.modalPresentationStyle = .custom

            vc.playerId = player.player_id
            vc.arrBoosters = player.boosterDetails
            vc.arrDebuffed = player.debuffedDetails
            
            self.present(vc, animated: true) {
                vc.getPlayerDetails()
            }
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var count = 1
        if collectionView == collectionWicketKeeper{
            count = self.selectedPlayers.wicketkeeper
        }
        if collectionView == collectionBatsMan{
            count = self.selectedPlayers.batsman
        }
        if collectionView == collectionBowler{
            count = self.selectedPlayers.bowler
        }
        if collectionView == collectionAllrounder{
            count = self.selectedPlayers.allrounder
        }
        var width =  collectionView.frame.size.width //CGFloat((count-1) * 5)
        width = width/4 - 40
        
        return CGSize(width: width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return .init(top: 8, left: 20, bottom: 0, right: 20)
    }
    
    
}


class CABatsmenCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgPlayer: UIImageView!
    @IBOutlet weak var lblPlayerName: UILabel!
    @IBOutlet weak var lblPlayerCredit: UILabel!
    @IBOutlet weak var lblCaptain: UILabel!
//    @IBOutlet weak var imgStar: UIImageView!
    @IBOutlet weak var lblLineup: UILabel!
    @IBOutlet weak var viewLineup: UIView!
    @IBOutlet weak var playingIcon: UIImageView!
   
    @IBOutlet weak var playingLeading: NSLayoutConstraint!
    @IBOutlet weak var playingWidth: NSLayoutConstraint!
    @IBOutlet weak var playingTrailing: NSLayoutConstraint!
    @IBOutlet weak var imgBoosted: UIImageView!
    @IBOutlet weak var imgDebuffed: UIImageView!
    
    func updateView(isLocalTeam: Bool){
        if isLocalTeam == true {
            self.imgPlayer.borderColor = .appLocalTeamBackgroundColor
        }else{
            self.imgPlayer.borderColor = .appVisitorTeamBackgroundColor
        }
    }
    
}

extension String {
 
    func index(at position: Int, from start: Index? = nil) -> Index? {
        let startingIndex = start ?? startIndex
        return index(startingIndex, offsetBy: position, limitedBy: endIndex)
    }
 
    func character(at position: Int) -> Character? {
        guard position >= 0, let indexPosition = index(at: position) else {
            return nil
        }
        return self[indexPosition]
    }
}
 

extension TeamPreviewVC{
    func getSeriesPlayerList (playerDetail:PlayerDetails){
        let params:[String:Any] = ["series_id":GDP.selectedMatch?.series_id ?? 0,
                                      "match_id":GDP.selectedMatch?.match_id ?? 0,
                                       "is_player_state":1
        ]
        
        let url = URLMethods.BaseURL + URLMethods().getSeriesPlayersList

        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                if result != nil {
                    let data = result?.object(forKey: "results") as? [[String:Any]]
                        if data != nil{
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                                  let tblData = try? JSONDecoder().decode([Player].self, from: jsonData)else {return }
                            let arrSeriesPlayers = tblData
                            var player:Player? = nil
                            
                            for players in arrSeriesPlayers{
                                if players.player_id == Int(playerDetail.player_id){
                                    player = players
                                }
                            }
                            
                            if let player = player {
                                let vc = PlayerPointsBreakupVC(nibName:"PlayerPointsBreakupVC", bundle:nil)
                                vc.modalPresentationStyle = .custom
                                vc.player_stats = player
                                vc.arrBoosters = playerDetail.boosterDetails
                                vc.arrDebuffed = playerDetail.debuffedDetails
                                
                                self.present(vc, animated: true)
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

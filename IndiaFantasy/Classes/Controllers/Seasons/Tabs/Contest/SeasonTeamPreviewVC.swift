//
//  SeasonTeamPreviewVC.swift
//  India’s fantasy
//
//  Created by admin on 15/05/23.
//

import UIKit

class SeasonTeamPreviewVC: UIViewController {
    
    @IBOutlet weak var lblWicketKeeper: OctalLabel!
    @IBOutlet weak var lblBatsman: OctalLabel!
    @IBOutlet weak var lblAllRounders: OctalLabel!
    @IBOutlet weak var lblBowlers: OctalLabel!
    
    @IBOutlet weak var lblBoostedPoints: UILabel!
    @IBOutlet weak var lblActualPoints: UILabel!
    @IBOutlet weak var lblTeamRank: UILabel!
    
    @IBOutlet weak var lblLocalTeamShortName: UILabel!
    @IBOutlet weak var lblVisitorTeamShortName: UILabel!
    @IBOutlet weak var imgStar: UIImageView!
    @IBOutlet weak var lblTopPlayer: UILabel!
    
    @IBOutlet weak var collectionWicketKeeper: UICollectionView!
    @IBOutlet weak var collectionBowler: UICollectionView!
    @IBOutlet weak var collectionAllrounder: UICollectionView!
    @IBOutlet weak var collectionBatsMan: UICollectionView!
    @IBOutlet weak var lblTeamName: UILabel!
    
    @IBOutlet weak var viewTotalPoints: UIView!
    
    @IBOutlet weak var lblTotalPoints: UILabel!
    @IBOutlet weak var imgGroundBg: UIImageView!
    @IBOutlet weak var viewRound: UIView!
    
    @IBOutlet weak var heightWK: NSLayoutConstraint!
    @IBOutlet weak var heighBAT: NSLayoutConstraint!
    @IBOutlet weak var heightAR: NSLayoutConstraint!
    @IBOutlet weak var heightBowl: NSLayoutConstraint!
    
    var teamPreviewFrom: TeamPreviewFrom = .Others
    var teamName = String()
    var selectedPlayers = SelectedPlayerTypes()
    var playerDetails = [PlayerDetails]()
   
    var strCaptainId = String()
    var strViceCaptainId = String()
    var strPointsSuffix = String()
    var totalPoints = 0.0
    var actualPoints = 0.0
    
    var isShowTopPlayer = false
    
    var teamNumber = "1"
    var userTeamRank  = ""
    
    var strFromVC = ""
    var localTeamShort = ""
    var visitorTeamShort = ""
    var isMatchLive = false
    
    var arrSelectedWicketKeepers = [PlayerDetails]()
    var arrSelectedBatsman = [PlayerDetails]()
    var arrSelectedBowler = [PlayerDetails]()
    var arrSelectedAllRounder = [PlayerDetails]()
    
    var arrAllPlayers = [PlayerDetails]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateDidLoad()
        
        self.lblTeamName.text = teamName
        
        if teamName != "Team Preview" {
            if userTeamRank != "" {
                self.lblTeamRank.text = "#\(self.userTeamRank)"
            }
            switch teamPreviewFrom {
            case .MyContestsMyTeams:
                self.lblBoostedPoints.text = "\(totalPoints.formattedNumber()) Pts"
                self.lblActualPoints.text = ""
            default :
                self.lblBoostedPoints.text = "Boosted: \(totalPoints.formattedNumber()) Pts"
                self.lblActualPoints.text = "Actual: \(actualPoints.formattedNumber()) Pts"
            }
           
        }else {
            lblTeamRank.isHidden = true
            lblBoostedPoints.isHidden = true
            lblActualPoints.isHidden = true
        }
        
        self.arrAllPlayers.append(contentsOf: arrSelectedWicketKeepers)
        self.arrAllPlayers.append(contentsOf: arrSelectedBatsman)
        self.arrAllPlayers.append(contentsOf: arrSelectedBowler)
        self.arrAllPlayers.append(contentsOf: arrSelectedAllRounder)
        
//        if strFromVC == "Points" {
//            lblLocalTeamShortName.text = localTeamShort
//            lblVisitorTeamShortName.text = visitorTeamShort
//        }else {
//            lblLocalTeamShortName.text = GDP.selectedMatch?.localteam_short_name ?? ""
//            lblVisitorTeamShortName.text = GDP.selectedMatch?.visitorteam_short_name ?? ""
//        }
        
        if localTeamShort == "" && visitorTeamShort == "" {
            lblLocalTeamShortName.text = GDP.selectedMatch?.localteam_short_name ?? ""
            lblVisitorTeamShortName.text = GDP.selectedMatch?.visitorteam_short_name ?? ""
        }else {
            lblLocalTeamShortName.text = localTeamShort
            lblVisitorTeamShortName.text = visitorTeamShort
        }
    }
    
    override func viewDidLayoutSubviews() {
        heightWK.constant = collectionWicketKeeper.collectionViewLayout.collectionViewContentSize.height + 30
        heighBAT.constant = collectionBatsMan.collectionViewLayout.collectionViewContentSize.height + 30
        heightBowl.constant = collectionBowler.collectionViewLayout.collectionViewContentSize.height + 30
        heightAR.constant = collectionAllrounder.collectionViewLayout.collectionViewContentSize.height + 30
        self.view.layoutIfNeeded()
    }
    
//    func setupLayout(count : Int, collectionView : UICollectionView) {
//        DispatchQueue.main.async {
//            let cellWidth = (56.0/79.0) * collectionView.frame.size.height
//            let cellSize = CGSize(width: cellWidth , height: collectionView.frame.size.height)
//            
//            var spacing =  collectionView.frame.size.width - (CGFloat(count)*cellWidth)
//            spacing = spacing/CGFloat(count-(count > 1 ? 1 : -1))
//            
//            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
//            layout.itemSize = cellSize
//            layout.minimumInteritemSpacing = spacing
//            layout.scrollDirection = .horizontal
//            
//            collectionView.collectionViewLayout = layout
//            collectionView.reloadData()
//        }
//    }
    
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
        
        self.lblTopPlayer.isHidden = !self.isShowTopPlayer
        self.imgStar.isHidden = !self.isShowTopPlayer
        
    }
    
    @IBAction func btnCloseAction(_ sender : UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnPointsTapped(_ sender: Any) {
        
        self.dismiss(animated: true) {
            let vc = Constants.KSideMenuStoryboard.instantiateViewController(withIdentifier: "WebPageViewController") as! WebPageViewController
            vc.url = URL(string: URLMethods.FantasyPointSystem_URL)
            vc.headerText = "Fantasy Points System"
            UIApplication.getTopViewController()?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension SeasonTeamPreviewVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SeasonTeamPreviewCVCell
        
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
        
        cell.imgPlayer.loadImage(urlS: player.image, placeHolder: Constants.kNoImageUser)
        cell.imgPlayer.contentMode = .scaleAspectFill
        cell.lblPlayerName.superview?.backgroundColor = UIColor.appVisitorTeamBackgroundColor
        
        cell.imgBooster.isHidden = !player.isBoosted
        
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
        if self.strFromVC == "Points"
        {
            cell.lblPlayerCredit.text = player.points + " Pts"
            
        }else if self.strFromVC == "Leaderboard"
        {
            let userName = (Constants.kAppDelegate.user?.username ?? "")
            if teamName.contains(userName) { //Check is my team
                if isMatchLive {
                    cell.lblPlayerCredit.text = player.points + " Pts"
                }else {
                    cell.lblPlayerCredit.text = player.credits + " \(self.strPointsSuffix)"
                }
            }else {
                cell.lblPlayerCredit.text = player.points + " Pts"
            }
        }
        else {
            if isMatchLive {
                cell.lblPlayerCredit.text = player.points + " Pts"
            }else {
                cell.lblPlayerCredit.text = player.credits + " \(self.strPointsSuffix)"
            }
        }
        
        if player.teamShortName == "" {
            cell.viewTeamShortTame.isHidden = true
        }else {
            cell.lblTeamShortName.text = player.teamShortName
        }
        
        if GDP.fantasyType == Constants.kCricketFantasy {
            cell.imgOverseasPlayer.isHidden = false
        }else {
            cell.imgOverseasPlayer.isHidden = true
        }
        
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
        cell.viewLineup.backgroundColor = UIColor.clear
        
        cell.imgOverseasPlayer.isHidden = true
        
        //        if GDP.selectedMatch?.match_status?.uppercased() == "NOT STARTED" || GDP.selectedMatch?.match_status?.uppercased() == "UPCOMING"{
        //            cell.viewLineup.backgroundColor = UIColor.clear
        //        }else{
        //            if isDreamTeam == true{
        //                cell.viewLineup.backgroundColor = UIColor.clear
        //            }else{
        //                if player.is_playing == true{
        //                    cell.viewLineup.backgroundColor = UIColor.green
        //                }else{
        //                    cell.viewLineup.backgroundColor = UIColor.red
        //                }
        //            }
        //
        //        }
        
        
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
        
        
//        if player.is_playing == true{
//            self.getSeriesPlayerList(playerDetail: player)
//        }else{
            let vc = PlayerInfoVC(nibName:"PlayerInfoVC", bundle:nil)
            vc.modalPresentationStyle = .custom
            vc.isFromLeague = true
            vc.playerId = player.player_id
            vc.arrBoosters = player.boosterDetails
        
            self.present(vc, animated: true) {
                vc.getPlayerDetails()
           // }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width =  collectionView.frame.size.width //CGFloat((count-1) * 5)
        width = width/4 - 40
        
        return CGSize(width: width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return .init(top: 8, left: 20, bottom: 0, right: 20)
    }
    
}

extension SeasonTeamPreviewVC {
    
    func getSeriesPlayerList(playerDetail: PlayerDetails) {
        
        WebCommunication.shared.getLeagueSeriesPlayerList(hostController: self, seriesId: GDP.leagueSeriesId, teamName: teamNumber, showLoader: true) { players in
            
            guard let arrSeriesPlayers = players else { return }
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
                self.present(vc, animated: true)
            }
        }
        
    }
}

enum TeamPreviewFrom {
    case MyContestsMyTeams
    case Points
    case LeaderBoard
    case Others
}

//
//  SeasonContestDetailsVC.swift
//  India’s fantasy
//
//  Created by admin on 01/05/23.
//

import UIKit
import SDWebImage

class SeasonContestDetailsVC: UIViewController {
    
    @IBOutlet weak var navigationView: SeasonNavigation!
    
    @IBOutlet weak var imgLocalTeam: UIImageView!
    @IBOutlet weak var lblLocalTeam: UILabel!
    @IBOutlet weak var lblLocalTeamScore: UILabel!
    @IBOutlet weak var imgVisitorTeam: UIImageView!
    @IBOutlet weak var lblVisitorTeam: UILabel!
    @IBOutlet weak var lblVisitorTeamScore: UILabel!
    @IBOutlet weak var lblMatchStatus: UILabel!
    @IBOutlet weak var lblMatchTime: UILabel!
    
    @IBOutlet weak var lblContestName: UILabel!
    @IBOutlet weak var lblTotalTeams: UILabel!
    
    @IBOutlet weak var viewLeaderboard: UIView!
    @IBOutlet weak var btnLeaderboard: UIButton!
    
    @IBOutlet weak var viewStats: UIView!
    @IBOutlet weak var btnStats: UIButton!
    
    @IBOutlet weak var tblContestDetails: UITableView!
    
    @IBOutlet weak var viewDownload: UIView!
    @IBOutlet weak var viewSortBy: UIView!
    @IBOutlet weak var btnDownloadPress: UIButton!
    
    var contestData:ContestData? = nil
    var fromMyContest: Bool = true
    private let statsTVCell = "PlayerStatsTVCell"
    private var refreshControl = UIRefreshControl()
    
    var arrSeriesPlayers: [Player] = [] {
        didSet {
            if arrSeriesPlayers.count == 0 {
                tblContestDetails.setEmptyMessage(ConstantMessages.NoStatsAvailable)
            }else {
                tblContestDetails.restoreEmptyMessage()
            }
            tblContestDetails.reloadData()
        }
    }
    
    var arrLeagueMyteam = [LeagueMyTeam]()
    var currentHighLightedTeam: LeagueMyTeam? = nil
    var pointSelected = false
    
    var arrMyTeams: [JoinedTeam] = []
    var arrOtherTeams: [JoinedTeam] = []
    
    private var currentPage = 1
    private var totalOtherteamsCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        btnTabActionPressed(btnLeaderboard)
    }
    
    private func setupUI() {
        
        setupNavigationView()
        setupRefreshControl()
        
        if #available(iOS 15.0, *) {
            self.tblContestDetails.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
       
        if  let match = GDP.selectedMatch {
            
            lblMatchStatus.text = "Match \(match.matchNumber ?? 0)"
            //CommonFunctions().timerStart(date: lblMatchTime, strTime: match.start_time ?? "", strDate: match.start_date, viewcontroller: self)
            CommonFunctions().timerStart(lblTime: lblMatchTime, strDate: match.match_date ?? "", viewcontroller: self, fromSeasonMyTeams: false )
            
            imgLocalTeam.loadImage(urlS: match.localteam_flag, placeHolder: Constants.kNoImageUser)
            lblLocalTeam.text = match.localteam_short_name
            imgVisitorTeam.loadImage(urlS: match.visitorteam_flag, placeHolder: Constants.kNoImageUser)
            lblVisitorTeam.text = match.visitorteam_short_name
        }
        
        if GDP.selectedMatch?.match_status?.uppercased() ?? "" == "LIVE" || GDP.selectedMatch?.match_status?.uppercased() ?? "" == "IN PROGRESS" || GDP.selectedMatch?.match_status?.uppercased() ?? "" == "RUNNING"{
           
            WebCommunication.shared.getTeamScore(hostController: self, series_id: GDP.selectedMatch?.series_id ?? 0, match_id: GDP.selectedMatch?.match_id ?? 0, showLoader: false) { score in
               
                self.lblLocalTeamScore.isHidden = false
                self.lblVisitorTeamScore.isHidden = false
            }
           
        }else{
            self.lblLocalTeamScore.text = ""
            self.lblVisitorTeamScore.text = ""
            self.lblLocalTeamScore.isHidden = true
            self.lblVisitorTeamScore.isHidden = true
        }
        
    }
    
    private func setupNavigationView() {
        
        navigationView.setupUI(title: GDP.leagueName, hideBG: true)
    }
    
    //MARK: - Setup Refresh Control
    private func setupRefreshControl() {
        
        refreshControl = UIRefreshControl()
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: attributes)
        refreshControl.addTarget(self, action: #selector(getDataFromServer), for: .valueChanged)
        refreshControl.tintColor = .white
        tblContestDetails.refreshControl = refreshControl
    }
    
    @objc func getDataFromServer() {
        
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
        
        if btnLeaderboard.isSelected {
            btnTabActionPressed(self.btnLeaderboard)
        }else {
            btnTabActionPressed(self.btnStats)
        }
    }
    
    @IBAction func btnTabActionPressed(_ sender: UIButton) {
        
        btnLeaderboard.isSelected = false
        btnStats.isSelected = false
        
        viewLeaderboard.backgroundColor = UIColor.clear
        viewStats.backgroundColor = UIColor.clear
        
        sender.isSelected = true
        
        if sender == btnLeaderboard {
            viewLeaderboard.backgroundColor = UIColor.appRedColor
            viewDownload.isHidden = true
            viewSortBy.isHidden = true
            currentPage = 1
            getContestLeaderBoardData()
        }
        else {
            viewStats.backgroundColor = UIColor.appRedColor
            viewDownload.isHidden = true
            viewSortBy.isHidden = true
            getLeagueDetail()
        }
        
        tblContestDetails.reloadData()
    }
    
    @IBAction func btnDownloadPressed(_ sender: Any) {
//        if GDP.selectedMatch?.match_status == "Not Started"{
//            AppManager.showToast("Match is not started yet.", view: self.view)
//            return
//        }
//        downloadTeam()
//
    }
    
    //MARK: download file
    func downloadTeam(){
        let VC = VCDownloadTeam(nibName: "VCDownloadTeam", bundle: nil)
        VC.downloadTeamClouser =  {(value) in
            self.getDownloadTeamFile(winningTeam: value)
        }
        self.present(VC, animated: true)
    }
    
    func openDownloadFile(url:String){
        
        let url = URL(string: url)
        AppManager.startActivityIndicator("", sender: view)
        FileDownloader.loadFileAsync(url: url!) { (path, error) in
            print("PDF File downloaded to : \(path!)")
            DispatchQueue.main.async {
                AppManager.stopActivityIndicator(self.view)
                if path != ""{
                    let vc = VCShowTeams(nibName: "VCShowTeams", bundle: nil)
                    vc.webUrl = path ?? ""
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
            
        }
    }
    
}

//MARK: - Table Delegate and DataSource Method
extension SeasonContestDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if btnLeaderboard.isSelected == true{
            return 2
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if btnLeaderboard.isSelected == true{
            if section == 0{
                return arrMyTeams.count
            }else{
                return arrOtherTeams.count
            }
        }else{
            return arrSeriesPlayers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if btnLeaderboard.isSelected {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderBoardTVCell", for: indexPath) as! LeaderBoardTVCell
            
            cell.selectionStyle = .none
            cell.lblPoints.isHidden = false
            cell.lblRank.isHidden = false
            
            var breakUp:JoinedTeam? = nil
            if indexPath.section == 0 {
                guard arrMyTeams.count > indexPath.row else { return cell }
                breakUp = arrMyTeams[indexPath.row]
            }else{
                guard arrOtherTeams.count > indexPath.row else { return cell }
                breakUp = arrOtherTeams[indexPath.row]
            }
            
            cell.contentView.backgroundColor = UIColor.bgDarkSepratorColor
            cell.lblTeamCount.textColor = UIColor.appRedColor
            cell.viewBackground.backgroundColor = UIColor.appPrimaryColor
            
            cell.imgViewProfile.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imgViewProfile.sd_setImage(with: URL(string: breakUp?.user_image ?? ""), placeholderImage: Constants.kNoImageUser)
            
            cell.lblTitle.text = "\(breakUp?.username ?? "")"
            cell.lblTeamCount.text = "T\(Int(breakUp?.team_count ?? 0))"
            cell.lblPoints.text = breakUp?.totalSeriesPoint?.formattedNumber() ?? "0"
            cell.lblRank.text = "#\(Int(breakUp?.rank ?? 0))"
            
            cell.winningAmountBottom.constant = 13
            
            if GDP.selectedMatch?.match_status == "Finished" || GDP.selectedMatch?.match_status == "Completed"{
                if (breakUp?.win_amount ?? 0) > 0{
                    var suffix = "Won Amount:"
                    if indexPath.section == 0{
                        suffix = "You Won:"
                    }
                    cell.lblReward.text = "\(suffix) \(GDP.globalCurrency)\(breakUp?.win_amount?.rounded(toPlaces: 2) ?? 0)"
                    cell.WinningAmountHeight.constant = 15
                }else{
                    cell.lblReward.text = ""
                    cell.WinningAmountHeight.constant = 0
                }
                
            }else{
                cell.lblReward.text = ""
                cell.WinningAmountHeight.constant = 0
            }
            
            return cell
        }else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: statsTVCell, for: indexPath) as! PlayerStatsTVCell
            
            cell.selectionStyle = .none
            
            let player = self.arrSeriesPlayers[indexPath.row]
            
            cell.lblPlayerName.text = player.player_name ?? ""
            cell.lblSelectionPercantage.text = player.selected_by?.clean ?? "0"
            cell.lblPoints.text =  (self.getDouble(for: player.player_points as Any)).clean

            if (GDP.selectedMatch?.match_status?.uppercased() ?? "") == "FINISHED" || (GDP.selectedMatch?.match_status?.uppercased() ?? "") == "COMPLETED"{
                
                cell.viewProfilePic.alpha = 1
            }
            
            if (player.my_team ?? false) == true{
                cell.contentView.backgroundColor = UIColor.cellStatsSelectedColor
            }else{
                cell.contentView.backgroundColor = UIColor.clear
            }
        
            cell.imgViewPlayer.loadImage(urlS: player.player_image, placeHolder: Constants.kNoImageUser)
            
            cell.lblPlayerRole.text = player.player_role ?? ""
            cell.lblPlayerTeamName.text = player.team_short_name ?? ""
            
            return cell
        }
    
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if btnLeaderboard.isSelected {
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))
            
            let leaderHeader:LeaderBoardHeaderView = LeaderBoardHeaderView.instanceFromNib() as! LeaderBoardHeaderView
            leaderHeader.controller = self
            if section == 0{
                leaderHeader.lblTitle.text = "My Teams (\(arrMyTeams.count))"
            }else{
                leaderHeader.lblTitle.text = "All Teams (\(totalOtherteamsCount))"
            }
            leaderHeader.lblPoints.isHidden = false
            leaderHeader.lblRank.isHidden = false
            leaderHeader.backgroundColor = .Color.backgroundDark.value
            leaderHeader.updateView()
            headerView.addSubview(leaderHeader)
            leaderHeader.frame = headerView.bounds
            return headerView
            
        }else {
            
            let headerView = PlayerStatsHeaderView.instanceFromNib() as? PlayerStatsHeaderView
            headerView?.controller = self
            headerView?.btnPoints.isSelected = self.pointSelected
            headerView?.btnPoints.addTarget(self, action: #selector(btnPointsSortPressed(_:)), for: .touchUpInside)
            headerView?.updateView()
            return headerView
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if btnLeaderboard.isSelected {
            if indexPath.section == 0 {
                guard arrMyTeams.count > indexPath.row else {return}
                let team = arrMyTeams[indexPath.row]
                getTeamPreviewData(userTeam: team, userId: "")
            }else {
                guard arrOtherTeams.count > indexPath.row else {return}
                let team = arrOtherTeams[indexPath.row]
                getTeamPreviewData(userTeam: team, userId: team.user_id ?? "")
            }
        }else {
            
            let player = self.arrSeriesPlayers[indexPath.row]
            if player.playerBreckup != nil {
                let vc = PlayerPointsBreakupVC(nibName:"PlayerPointsBreakupVC", bundle:nil)
                vc.playerId = player.player_id ?? 0
                vc.modalPresentationStyle = .custom
                self.present(vc, animated: true)
            }else{
                //AppManager.showToast(ConstantMessages.PLAYER_STATS_NOT_AVL, view: self.view)
                let vc = PlayerInfoVC(nibName:"PlayerInfoVC", bundle:nil)
                vc.modalPresentationStyle = .custom
                vc.playerId = "\(player.player_id ?? 0)"
                vc.isFromLeague = true
                self.present(vc, animated: true) {
                    vc.getPlayerDetails()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if btnLeaderboard.isSelected {
            return 40
        }else {
            return 90
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if btnStats.isSelected {
            return 70
        }
        return UITableView.automaticDimension
    }
    
    @objc func btnPointsSortPressed(_ sender: UIButton) {
        pointSelected = !pointSelected
        
        if pointSelected == true{
            self.arrSeriesPlayers.sort { (first, second) -> Bool in
                return self.getDouble(for: first.player_points  as Any) < self.getDouble(for: second.player_points as Any)
            }
        } else {
            self.arrSeriesPlayers.sort { (first, second) -> Bool in
                return self.getDouble(for: first.player_points  as Any) > self.getDouble(for: second.player_points as Any)
            }
        }
        
        tblContestDetails.reloadData()
    }
    
    //MARK: - Check TableView Scrolling To End
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == tblContestDetails && btnLeaderboard.isSelected else {
            return
        }
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
            
            if totalOtherteamsCount > arrOtherTeams.count {
                currentPage += 1
                self.getContestLeaderBoardData()
            }
        }
    }
}

//MARK: - API Calls
extension SeasonContestDetailsVC {
    
    //MARK: Api getDownloadTeamFile
    func getDownloadTeamFile(winningTeam:Bool) {
        
        let params:[String:Any] = ["contest_id": contestData?.id ?? "0",
                                   "match_id":String(GDP.selectedMatch?.match_id ?? 0),
                                   "series_id":String(GDP.selectedMatch?.series_id ?? 0),
                                   "winning_team": winningTeam
        ]
        // let params: [String:String] = [String:String]()
        
        let url = URLMethods.BaseURL + URLMethods().getContestTeam
        //+ "?series_id=\(String(selectedMatch?.series_id ?? 0))" + "&match_id=\(String(selectedMatch?.match_id ?? 0))" + "&contest_id=\(contestData?.id ?? "0")" + "&winning_team=\(true)"
        
        ApiClient.init().getRequest(method: url, parameters: params, view: (self.view)!) { result in
            if result != nil {
                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "message") as? String ?? ""
                if status == true{
                    let pdfUrl = result?.object(forKey: "result") as? String
                    if pdfUrl != ""{
                        self.openDownloadFile(url: pdfUrl ?? "")
                    }
                    
                }else{
                    AppManager.showToast(msg, view: (self.view)!)
                }
                
            }else{
                AppManager.showToast("", view: (self.view)!)
            }
        }
    }
    
    func getContestLeaderBoardData() {
        
        guard let contestId = contestData?.id  else { return }
        
        WebCommunication.shared.getLeagueContestLeaderboard(hostController: self, seriesId: GDP.leagueSeriesId, contestId: contestId, page: currentPage, showLoader: true) { contestData in
            
            self.contestData = contestData
            
            if let contest = contestData {
                self.lblContestName.text = contest.name
                
                self.totalOtherteamsCount = contest.otherJoinedTeamsCount ?? 0
                
                self.arrMyTeams = contest.myJoinedTeams ?? []
                if self.currentPage == 1 {
                    self.arrOtherTeams = contest.otherJoinedTeams ?? []
                }else {
                    self.arrOtherTeams += contest.otherJoinedTeams ?? []
                }
                
                let myTeamsCount = contest.myJoinedTeams?.count ?? 0
                let totalTeamsCount = self.totalOtherteamsCount + myTeamsCount

                if totalTeamsCount > 1 {
                    self.lblTotalTeams.text = "\(totalTeamsCount) Teams"
                }else {
                    self.lblTotalTeams.text = "\(totalTeamsCount) Team"
                }
            }
            
            self.tblContestDetails.reloadData()
        }
        
    }
    
    func getSeriesPlayers() {
        
        //guard let seriesId = GDP.selectedMatch?.series_id else { return }
        
        let teamName = currentHighLightedTeam?.teamCount ?? 0
        WebCommunication.shared.getLeagueSeriesPlayerList(hostController: self, seriesId: GDP.leagueSeriesId, teamName: "\(teamName)", showLoader: true) { players in
            
//            var allPlayers = players ?? []
//            allPlayers.sort { (first, second) -> Bool in
//                return self.getDouble(for: first.player_points  as Any) > self.getDouble(for: second.player_points as Any)
//            }
            self.pointSelected = false
            self.arrSeriesPlayers = players ?? []
        }
    }
    
    func getLeagueDetail(showLoader: Bool = true) {
        
        //guard let seriesId = GDP.selectedMatch?.series_id else { return }
        
        WebCommunication.shared.getLeagueDetail(hostController: self, seriesId: GDP.leagueSeriesId, showLoader: showLoader) { leagueDetails in
            
            if let leagueDetails = leagueDetails {
                GDP.leagueMyTeams = leagueDetails.userTeams ?? []
                self.arrLeagueMyteam = leagueDetails.userTeams ?? []
                
                if self.fromMyContest == true {
                    if !self.arrLeagueMyteam.isEmpty {
                        self.currentHighLightedTeam = self.arrLeagueMyteam.first
                    }
                }
                self.getSeriesPlayers()
            }
        }
    }
    
//    func getMyTeams(team: JoinedTeam) {
//
//        let selectedTeamName = "\(team.username ?? "") (Team \(Int(team.team_count ?? 0)))"
//
//        WebCommunication.shared.getMyTeams(hostController: self, seriesId: GDP.leagueSeriesId, teamId: team.id ?? "", teamName: "\(team.team_count ?? 0)", showLoader: true) { teams, _, _, myTeamCount in
//            self.showTeamPreview(teams: teams, teamName: selectedTeamName, teamRank: team.rank?.clean)
//
//        }
//    }
    
    func getTeamPreviewData(userTeam: JoinedTeam, userId: String) {
        
        let selectedTeamName = "\(userTeam.username ?? "") (Team \(Int(userTeam.team_count ?? 0)))"
        
        WebCommunication.shared.leagueTeamPreview(hostController: self, seriesId: GDP.leagueSeriesId, matchId: 0, teamName: "\(userTeam.team_count ?? 0)", userId: userId, showLoader: true) { teams in
         
            self.showTeamPreview(teams: teams, teamName: selectedTeamName, teamRank: userTeam.rank?.clean, totalPoints: userTeam.totalSeriesPoint ?? 0)
            
        }
    }
    
    func populateHighLightedPlayersForTeam(team: LeagueMyTeam) {
        self.currentHighLightedTeam = team
        getSeriesPlayers()
    }
    
    func showTeamPreview(teams: [Team]?, teamName: String, teamRank: String?, totalPoints: Double) {
        
        guard let teams = teams, !teams.isEmpty else { return }
        
        let dataDict = teams[0]
        let vc = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonTeamPreviewVC") as! SeasonTeamPreviewVC

        vc.teamNumber = "\(dataDict.team_number ?? 1)"
        vc.strFromVC = "Leaderboard"
        
        let arrPlayers = dataDict.seriesPlayer
        var arrPlayerData = [PlayerDetails]()
        var selectedPlayers = SelectedPlayerTypes()
        
        if arrPlayers?.count ?? 0 > 0 {
            for index  in 0..<arrPlayers!.count {
                let player = arrPlayers![index]
                var playerData = PlayerDetails()
                playerData.name = "\(player.name ?? "")"
                playerData.credits = "\(player.credits!)"
                playerData.role = "\(player.role ?? "")"
                playerData.points = "\(player.points ?? 0)"
                playerData.image = "\(player.image ?? "")"
                playerData.player_id = "\(player.player_id ?? 0)"
                playerData.is_local_team = "\(player.team_id ?? 0)".caseInsensitiveCompare("\(GDP.selectedMatch?.localteam_id ?? 0)") == .orderedSame
                playerData.is_playing = player.is_playing ?? false
                playerData.teamShortName = player.team_short_name ?? ""
                playerData.isBoosted = player.isBoosted ?? false
                playerData.boosterDetails = player.boosterDetails ?? []

                arrPlayerData.append(playerData)
            }
        }
        
        selectedPlayers.batsman = Int("\(dataDict.total_batsman ?? 0)") ?? 0
        selectedPlayers.allrounder = Int("\(dataDict.total_allrounder ?? 0)") ?? 0
        selectedPlayers.bowler =  Int("\(dataDict.total_bowler ?? 0)") ?? 0
        selectedPlayers.wicketkeeper = Int("\(dataDict.total_wicketkeeper ?? 0)") ?? 0
        
        let captain = arrPlayerData.filter({$0.player_id == "\(dataDict.captain_player_id ?? "0")"})
        let viceCaptain = arrPlayerData.filter({$0.player_id == "\(dataDict.vice_captain_player_id ?? "0")"})
       
        vc.playerDetails = arrPlayerData
        vc.selectedPlayers = selectedPlayers
        vc.teamName = teamName
        vc.strCaptainId = captain.count > 0 ? captain[0].player_id : ""
        vc.strViceCaptainId = viceCaptain.count > 0 ? viceCaptain[0].player_id : ""
        vc.strPointsSuffix = "Cr"
        vc.modalPresentationStyle = .custom
        vc.userTeamRank = teamRank ?? ""
        vc.localTeamShort = dataDict.localTeamShortName ?? ""
        vc.visitorTeamShort = dataDict.visitorTeamShortName ?? ""
        vc.isMatchLive = dataDict.isLive ?? false
        vc.totalPoints = dataDict.total_point ?? 0
        vc.actualPoints = dataDict.actualPoints ?? 0
        vc.teamPreviewFrom = .LeaderBoard
        
//        let userName = (Constants.kAppDelegate.user?.username ?? "")
//        if teamName.contains(userName) {
//            if (dataDict.isLive ?? false) == true {
//                vc.totalPoints = dataDict.total_point ?? 0
//            }else {
//                vc.totalPoints = totalPoints
//            }
//        }
        
        self.present(vc, animated: true, completion: nil)
    }
}

//
//  SeasonsContestVC.swift
//  India’s fantasy
//
//  Created by admin on 24/04/23.
//

import UIKit

class SeasonsContestVC: UIViewController {
    
    @IBOutlet weak var navigationView: SeasonNavigation!
    
    @IBOutlet weak var viewMatch: UIView!
    @IBOutlet weak var lblMatchName: UILabel!
    @IBOutlet weak var lblMatchTime: OctalLabel!
    @IBOutlet weak var imageLocalTeam: UIImageView!
    @IBOutlet weak var lblLocalTeam: UILabel!
    @IBOutlet weak var imageVisitorTeam: UIImageView!
    @IBOutlet weak var lblVisitorTeam: UILabel!
    
    @IBOutlet weak var tblContest: UITableView!
    
    @IBOutlet weak var viewAllContest: UIView!
    @IBOutlet weak var btnAllContest: UIButton!
    
    @IBOutlet weak var viewMyContest: UIView!
    @IBOutlet weak var btnMyContest: UIButton!
    
    @IBOutlet weak var viewMyTeam: UIView!
    @IBOutlet weak var btnMyTeam: UIButton!
    
    @IBOutlet weak var viewStats: UIView!
    @IBOutlet weak var btnStats: UIButton!
    @IBOutlet weak var btnJoinContest: UIButton!
    
    private let cellId = "LiveContestTVCell"
    private let myTeamCellId = "ContestMyTeamsTVCell"
    private let statsTVCell = "PlayerStatsTVCell"
    
    var arrAllContests: [ContestData] = [] {
        didSet {
            if arrAllContests.count == 0 {
                tblContest.setEmptyMessage(ConstantMessages.NoContestAvailable)
            }else {
                tblContest.restoreEmptyMessage()
            }
            tblContest.reloadData()
        }
    }
    var arrJoinedContests: [LeagueJoinedContest] = [] {
        didSet {
            if arrJoinedContests.count == 0 {
                tblContest.setEmptyMessage(ConstantMessages.NoContestAvailable)
            }else {
                tblContest.restoreEmptyMessage()
            }
            tblContest.reloadData()
        }
    }
    var arrTeamList: [Team] = [] {
        didSet {
            if arrTeamList.count == 0 {
                tblContest.setEmptyMessage(ConstantMessages.NoTeamAvailable)
            }else {
                tblContest.restoreEmptyMessage()
            }
            tblContest.reloadData()
        }
    }
    var arrSeriesPlayers: [Player] = [] {
        didSet {
            if arrSeriesPlayers.count == 0 {
                tblContest.setEmptyMessage(ConstantMessages.NoStatsAvailable)
            }else {
                tblContest.restoreEmptyMessage()
            }
            tblContest.reloadData()
        }
    }
    
    var arrLeagueMyteam = [LeagueMyTeam]()
    var currentHighLightedTeam: LeagueMyTeam? = nil
    var selectedMyTeam: LeagueMyTeam? = nil
    
    var tipView = EasyTipHelper()
    var pointSelected = false
    
    private var refreshControl = UIRefreshControl()
    
    var isFromNotification = false
    var selectionTab = UIButton()
    
    private var selectedMyTeamNumber: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectionTab = btnAllContest
        setupUI()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tipView.tipView.dismiss()
    }
    
    deinit {
        removeNotificationObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.isFromNotification == true{
            self.isFromNotification = false
        }else{
            btnTabActionPressed(self.selectionTab)
        }
    }
    
    private func setupUI() {
        
        setupNavigationView()
        setupTableView()
        setupRefreshControl()
        addNotificationObservers()

        if let match = GDP.selectedMatch {
            viewMatch.isHidden = false
            lblMatchName.text = "Match \(match.matchNumber ?? 0)"
            imageLocalTeam.loadImage(urlS: match.localteam_flag, placeHolder: Constants.kNoImageUser)
            lblLocalTeam.text = match.localteam_short_name
            imageVisitorTeam.loadImage(urlS: match.visitorteam_flag, placeHolder: Constants.kNoImageUser)
            lblVisitorTeam.text = match.visitorteam_short_name
            
            //CommonFunctions().timerStart(date: lblMatchTime, strTime: match.start_time ?? "", strDate: match.start_date, viewcontroller: self)
            
            CommonFunctions().timerStart(lblTime: lblMatchTime, strDate: match.match_date ?? "", viewcontroller: self, fromSeasonMyTeams: false)
        }else {
            viewMatch.isHidden = true
        }
        
    }
    
    //MARK: - Setup NavigationView
    private func setupNavigationView() {
        
        navigationView.setupUI(title: GDP.leagueName, hideBackBtn: true)
    }
    
    //MARK: - Setup TableView
    private func setupTableView() {
        
        let myTeamNib = UINib(nibName: myTeamCellId, bundle: nil)
        tblContest.register(myTeamNib, forCellReuseIdentifier: myTeamCellId)
    }
    
    //MARK: - Setup Refresh Control
    private func setupRefreshControl() {
        
        refreshControl = UIRefreshControl()
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: attributes)
        refreshControl.addTarget(self, action: #selector(getDataFromServer), for: .valueChanged)
        refreshControl.tintColor = .white
        tblContest.refreshControl = refreshControl
    }
    
    @objc func getDataFromServer() {
        
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
        
        btnTabActionPressed(self.selectionTab)

    }
    
    @IBAction func btnTabActionPressed(_ sender: UIButton) {
    
        tipView.tipView.dismiss()
        btnAllContest.isSelected = false
        btnMyContest.isSelected = false
        btnMyTeam.isSelected = false
        btnStats.isSelected = false
        
        tblContest.reloadData()
        
        viewAllContest.backgroundColor = .clear
        viewMyContest.backgroundColor = .clear
        viewMyTeam.backgroundColor = .clear
        viewStats.backgroundColor = .clear
        
        sender.isSelected = true
        btnJoinContest.isHidden = true
        navigationView.btnCreateTeam.isHidden = true
        self.selectionTab = sender
        if sender == btnAllContest {
            viewAllContest.backgroundColor = UIColor.appRedColor
            tblContest.contentInset = .init(top: 10, left: 0, bottom: 0, right: 0)
            getLeagueDetail()
            getAllContests()
        }
        else if sender == btnMyContest {
            viewMyContest.backgroundColor = UIColor.appRedColor
            tblContest.contentInset = .init(top: 10, left: 0, bottom: 0, right: 0)
            self.getMyContests()
        }
        else if sender == btnMyTeam {
            viewMyTeam.backgroundColor = UIColor.appRedColor
            tblContest.contentInset = .init(top: 10, left: 0, bottom: 0, right: 0)
            navigationView.btnCreateTeam.isHidden = false
            getLeagueDetail(fromMyTeams: true)
            //getMyTeams()
        }
        else {
            viewStats.backgroundColor = UIColor.appRedColor
            tblContest.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
            getLeagueDetail()
            getSeriesPlayers()
        }
        
    }
    
}

//MARK: - Table Delegate and DataSource Method
extension SeasonsContestVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if btnAllContest.isSelected {
            return arrAllContests.count
        }else if btnMyContest.isSelected {
            return arrJoinedContests.count
//        }else if btnMyTeam.isSelected {
//            return arrTeamList.count
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if btnAllContest.isSelected {
            return 0
            
        }else if btnMyContest.isSelected {
            
            if let contest = self.arrJoinedContests[section].data, let teams = contest.teams {
                return teams.count
            }
            return 0
            
        }else if btnMyTeam.isSelected {
            return arrTeamList.count
            
        }else if btnStats.isSelected{
            return arrSeriesPlayers.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if btnMyContest.isSelected {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! LiveContestTVCell
            
            cell.selectionStyle = .none
            
            guard arrJoinedContests.count > indexPath.section else { return cell }
            
            let contest = self.arrJoinedContests[indexPath.section].data
            guard let teams = contest?.teams, indexPath.row < teams.count else { return cell }
            let breakUp = teams[indexPath.row]
            
            cell.lblTeamName.text = "\(breakUp.username ?? "")"
            cell.lblPoints.text = breakUp.totalSeriesPoint?.formattedNumber() ?? "0"
            cell.lblRank.text = "#\(Int(breakUp.rank ?? 0))"
            cell.lblTeamNumber.text = "T\(Int(breakUp.team_count ?? 0))"
            
            if let status = GDP.selectedMatch?.match_status?.uppercased() {
                if status == "FINISHED" || status == "COMPLETED" {
                    if (breakUp.win_amount ?? 0) > 0{
                        cell.winningBottom.constant = 13
                        //cell.winningHeight.constant = 15
                        let strWin_amount = CommonFunctions.suffixNumberIndian(currency: (breakUp.win_amount ?? 0))
                        cell.lblPrizeWon.text = "WON AMOUNT: \(GDP.globalCurrency)\(strWin_amount)"
                    }else{
                        cell.lblPrizeWon.text = ""
                        cell.winningBottom.constant = 0
                        //cell.winningHeight.constant = 0
                    }
                }else{
                    cell.lblPrizeWon.text = ""
                    cell.winningBottom.constant = 0
                    //cell.winningHeight.constant = 0
                }
            }
            else{
                cell.lblPrizeWon.text = ""
                cell.winningBottom.constant = 0
                //cell.winningHeight.constant = 0
            }
            
            DispatchQueue.main.async {
                cell.viewContainer.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 0)
            }
            
            return cell
            
        }else if btnMyTeam.isSelected {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: myTeamCellId, for: indexPath) as! ContestMyTeamsTVCell
            
            guard arrTeamList.count > indexPath.row else { return cell }
            let team = arrTeamList[indexPath.row]
            cell.setData = team
            cell.selectionStyle = .none
            
            cell.btnMakeTransfer.tag = indexPath.row
            cell.btnMakeTransfer.addTarget(self, action: #selector(btnMakeTransferdPressed(_:)), for: .touchUpInside)
            
            cell.btnApplyBoosters.tag = indexPath.row
            cell.btnApplyBoosters.addTarget(self, action: #selector(btnApplyBoosters(_:)), for: .touchUpInside)
            
            CommonFunctions().timerStart(lblTime: cell.lblClosesTime, strDate: team.matchDate ?? "", viewcontroller: self)
            
            return cell
            
        }else if btnStats.isSelected {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: statsTVCell, for: indexPath) as! PlayerStatsTVCell
            cell.selectionStyle = .none
            
            let player = self.arrSeriesPlayers[indexPath.row]
            
            cell.lblPlayerName.text = player.player_name ?? ""
            cell.lblSelectionPercantage.text = (player.selected_by ?? 0).clean
            cell.lblPoints.text =  (self.getDouble(for: player.player_points as Any)).clean
//            cell.btnInMyTeam.alpha = (player?.my_team ?? false) ? 1 : 0.2
//            cell.contentView.backgroundColor = UIColor.white
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
        
        return .init()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if btnAllContest.isSelected {
            
            guard let cellMatch = LiveContestSectionView.instanceFromNib() as? LiveContestSectionView else {
                return .none
            }
            
            guard arrAllContests.count > section else { return cellMatch }
            
            let contestDataValue = self.arrAllContests[section]
            cellMatch.setLeagueContestData = contestDataValue
            cellMatch.controller = self
            cellMatch.tipView = self.tipView
        
            cellMatch.btnTap.tag = section
            cellMatch.btnTap.addTarget(self, action: #selector(btnTapPressed(_:)), for: .touchUpInside)
            cellMatch.contestData = contestDataValue
        
            if (contestDataValue.winning_amount ?? 0) == 0 {
                if let firstPrize = contestDataValue.price_breakup?.first(where: {$0.start_rank == 1}) {
                    cellMatch.lblPrizePool.text = firstPrize.reward ?? "-"
                }
            }else {
                let strWinning_amount = CommonFunctions.suffixNumberIndian(currency: (contestDataValue.winning_amount ?? 0 ))
                cellMatch.lblPrizePool.text = "\(GDP.globalCurrency)\(strWinning_amount)"
            }
            
            cellMatch.lblTotalSpots.text = "\(contestDataValue.users_limit ?? 0)"
            
            let firstWinnerPrize = Double(contestDataValue.total_winners ?? 0)/Double(contestDataValue.users_limit ?? 0)
            
            if Double(firstWinnerPrize * 100).rounded(toPlaces: 2).isInteger
            {
                cellMatch.btnTrophyPercantage.setTitle("\(Int(firstWinnerPrize * 100))%", for: .normal)
            }
            else
            {
                cellMatch.btnTrophyPercantage.setTitle("\(Double(firstWinnerPrize * 100).rounded(toPlaces: 2))%", for: .normal)
            }
            
            if (contestDataValue.entry_fee ?? 0).isZero {
                cellMatch.lblEntry.text = "Free"
            }else {
                let strEntry_fee = CommonFunctions.suffixNumberIndian(currency: (contestDataValue.entry_fee ?? 0).rounded(toPlaces: 2))
                
                cellMatch.lblEntry.text = "\(GDP.globalCurrency)\(strEntry_fee)"
            }
           
            
            if contestDataValue.price_breakup?.count ?? 0 > 0
            {
                let strPrice_breakup = CommonFunctions.suffixNumberIndian(currency: (contestDataValue.price_breakup?[0].each_price ?? 0))
                
                cellMatch.btnRewardAmount.setTitle("\(GDP.globalCurrency)\(strPrice_breakup)", for: .normal)
            }
            
//            if contestDataValue.confirm_winning == true{
//                cellMatch.btnGuaranteeStatus.isHidden = false
//            }else{
                cellMatch.btnGuaranteeStatus.isHidden = true
//            }
            
            if (contestDataValue.max_team_join_count ?? 0) == 1{
                cellMatch.btnMaxTeams.setTitle("Max 1 Team", for: .normal)
            }else{
                cellMatch.btnMaxTeams.setTitle("Max \(contestDataValue.max_team_join_count ?? 0) Teams", for: .normal)
            }
            
            DispatchQueue.main.async {
                cellMatch.containerView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
            }
            
            return cellMatch
            
        }
        
        if btnMyContest.isSelected {
            
            guard let cellMatch = LiveContestSectionView.instanceFromNib() as? LiveContestSectionView else {
                return .none
            }
            
            var contestDataValue:ContestData? = nil
            cellMatch.controller = self
            cellMatch.tipView = self.tipView
            
            guard arrJoinedContests.count > section else { return cellMatch }
            let contest = self.arrJoinedContests[section]
            cellMatch.setLeagueData = contest
            contestDataValue = contest.data?.contestData
            var temp = contestDataValue
            temp?.joined_teams_count = contest.data?.joined_teams_count ?? 0
            contestDataValue = temp
            cellMatch.btnTap.tag = section
            cellMatch.btnTap.addTarget(self, action: #selector(btnTapPressed(_:)), for: .touchUpInside)
            cellMatch.contestData = contestDataValue
            
            if (contestDataValue?.winning_amount ?? 0) == 0 {
                if let firstPrize = contestDataValue?.price_breakup?.first(where: {$0.start_rank == 1}) {
                    cellMatch.lblPrizePool.text = firstPrize.reward ?? "-"
                }
            }else {
                let strWinning_amount = CommonFunctions.suffixNumberIndian(currency: (contestDataValue?.winning_amount ?? 0 ))
                cellMatch.lblPrizePool.text = "\(GDP.globalCurrency)\(strWinning_amount)"
            }
        
            cellMatch.lblTotalSpots.text = "\(contestDataValue?.users_limit ?? 0)"
            
            let firstWinnerPrize = Double(contestDataValue?.total_winners ?? 0)/Double(contestDataValue?.users_limit ?? 0)
            
            if Double(firstWinnerPrize * 100).rounded(toPlaces: 2).isInteger
            {
                cellMatch.btnTrophyPercantage.setTitle("\(Int(firstWinnerPrize * 100))%", for: .normal)
            }
            else
            {
                cellMatch.btnTrophyPercantage.setTitle("\(Double(firstWinnerPrize * 100).rounded(toPlaces: 2))%", for: .normal)
            }
            
            
            if (contestDataValue?.entry_fee ?? 0).isZero {
                cellMatch.lblEntry.text = "Free"
            }else {
                let strEntry_fee = CommonFunctions.suffixNumberIndian(currency: (contestDataValue?.entry_fee ?? 0).rounded(toPlaces: 2))
                cellMatch.lblEntry.text = "\(GDP.globalCurrency)\(strEntry_fee)"
            }
            
            if contestDataValue?.price_breakup?.count ?? 0 > 0
            {
                let strPrice_breakup = CommonFunctions.suffixNumberIndian(currency: (contestDataValue?.price_breakup?[0].each_price ?? 0))
                
                cellMatch.btnRewardAmount.setTitle("\(GDP.globalCurrency)\(strPrice_breakup)", for: .normal)
            }
            
//            if contestDataValue?.confirm_winning == true{
//                cellMatch.btnGuaranteeStatus.isHidden = false
//            }else{
                cellMatch.btnGuaranteeStatus.isHidden = true
//            }
            
            if (contestDataValue?.max_team_join_count ?? 0) == 1{
                cellMatch.btnMaxTeams.setTitle("Max 1 Team", for: .normal)
            }else{
                cellMatch.btnMaxTeams.setTitle("Max \(contestDataValue?.max_team_join_count ?? 0) Teams", for: .normal)
            }
            
            DispatchQueue.main.async {
                cellMatch.containerView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
            }
            
            return cellMatch
            
        }else if btnStats.isSelected {
            
            let headerView = PlayerStatsHeaderView.instanceFromNib() as? PlayerStatsHeaderView
            headerView?.controller = self
            headerView?.btnPoints.isSelected = self.pointSelected
            headerView?.btnPoints.addTarget(self, action: #selector(btnPointsSortPressed(_:)), for: .touchUpInside)
            headerView?.updateView()
            return headerView
            
        }else if btnMyTeam.isSelected {
            
            let headerView = SeasonMyTeamHeaderView.instanceFromNib() as? SeasonMyTeamHeaderView
            
            if let team = selectedMyTeam {
                headerView?.btnTeam.setTitle("Team \(team.teamCount ?? 0) ", for: .normal)
            }
            
            headerView?.completion = { team in
                self.selectedMyTeam = team
                self.getMyTeams(teamId: team.id ?? "", teamName: "\(team.teamCount ?? 0)")
            }
            //headerView?.lblTeam.text = "Team \(team.team_number ?? 0)"
            
//            headerView?.btnExpand.tag = section
//            headerView?.btnExpand.addTarget(self, action: #selector(btnExpanSelectionPressed(_:)), for: .touchUpInside)
//            headerView?.btnExpand.isSelected = team.isSelected
//            if team.isSelected {
//                headerView?.imgArrow.image = UIImage(named: "Arrow_White_Up")
//                headerView?.viewSeparator.isHidden = true
//            }else {
//                headerView?.imgArrow.image = UIImage(named: "Arrow_White_Down")
//                headerView?.viewSeparator.isHidden = false
//            }
            return headerView
        }
        
        
        return .none
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if btnAllContest.isSelected {
            let footerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 100))
            footerView.backgroundColor = .clear
            
            let containerView = UIView(frame: CGRect(x: 15, y: 0, width: tableView.frame.width - 30, height: 40))
            containerView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10.0)
            containerView.backgroundColor = .Color.footerBackground.value
            
            let btnFooter = UIButton(frame: CGRect(x: 15, y: 0, width: 200, height: 40))
            btnFooter.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
            
            btnFooter.setTitle("View Leaderboard", for: .normal)
            btnFooter.setTitleColor(.appHighlightedTextColor, for: .normal)
            btnFooter.titleLabel?.font = UIFont(name: customFontLight, size: 14)
            
            btnFooter.tag = section
            btnFooter.addTarget(self, action: #selector(btnViewLeaderboardAction(_:)), for: .touchUpInside)
            
            let joinContestBtn = UIButton(frame: CGRect(x: 15, y: 50, width: tableView.frame.width - 30, height: 45))
            joinContestBtn.backgroundColor = .appHighlightedTextColor
            joinContestBtn.setTitle("JOIN", for: .normal)
            joinContestBtn.setTitleColor(.black, for: .normal)
            joinContestBtn.titleLabel?.font = UIFont(name: customFontSemiBold, size: 16)
            joinContestBtn.cornerRadius = 8
            
            joinContestBtn.tag = section
            joinContestBtn.addTarget(self, action: #selector(btnJoinContestAction(_:)), for: .touchUpInside)
            
            containerView.addSubview(btnFooter)
            footerView.addSubview(containerView)
            
            let contest = arrAllContests[section]
            if ((contest.users_limit ?? 0) > (contest.joined_teams_count ?? 0)) && ((contest.max_team_join_count ?? 0) > (contest.my_team_ids?.count ?? 0)){
                footerView.addSubview(joinContestBtn)
            }
            
            return footerView
        }
        else if btnMyContest.isSelected {
            let footerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 46))
            footerView.backgroundColor = .clear
            
            let containerView = UIView(frame: CGRect(x: 15, y: 0, width: tableView.frame.width - 30, height: 40))
            containerView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10.0)
            containerView.backgroundColor = .Color.footerBackground.value
            
            let btnFooter = UIButton(frame: CGRect(x: 15, y: 0, width: 200, height: 40))
            btnFooter.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
            
            btnFooter.setTitle("View Leaderboard", for: .normal)
            btnFooter.setTitleColor(.appHighlightedTextColor, for: .normal)
            btnFooter.titleLabel?.font = UIFont(name: customFontLight, size: 14)
            
            btnFooter.tag = section
            btnFooter.addTarget(self, action: #selector(btnViewLeaderboardAction(_:)), for: .touchUpInside)
            
            containerView.addSubview(btnFooter)
            footerView.addSubview(containerView)
            
            return footerView
        }
        
        return .none
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if btnMyTeam.isSelected {
            
            let team = arrTeamList[indexPath.row]
            let teamName = "\(Constants.kAppDelegate.user?.username ?? "") (Team \(indexPath.row + 1))"
            getMyTeamPreviewData(userTeam: team, teamName: teamName)
            
            //showTeamPreview(dataDict: team, teamName: teamName, teamRank: "", totalPoints: team.total_point ?? 0)
            
        }else if btnMyContest.isSelected {
            
            if let contest = self.arrJoinedContests[indexPath.section].data, let team = contest.teams?[indexPath.row] {
                
                //getMyTeams(teamId: team.id ?? "", teamName: "\(team.team_count ?? 0)", teamRank: team.rank?.clean ?? "", showTeamPreview: true)
                
                getTeamPreviewData(userTeam: team)
            }
            
        }else if btnStats.isSelected == true {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if btnAllContest.isSelected {
            return 0
        }else if btnMyContest.isSelected {
            if arrJoinedContests.isEmpty {
                return 0
            }
        }else if btnStats.isSelected {
            return 70
        }else if btnMyTeam.isSelected {
            if arrTeamList.isEmpty {
                return 0
            }
        }
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if btnAllContest.isSelected {
            return arrAllContests.isEmpty ? 0 : 180
        }else if btnMyContest.isSelected {
            return arrJoinedContests.isEmpty ? 0 : 261
        }else if btnStats.isSelected {
            return arrSeriesPlayers.isEmpty ? 0 : 90
        }else if btnMyTeam.isSelected {
            return GDP.leagueMyTeams.isEmpty ? 0 : 40
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if btnAllContest.isSelected {
            if !arrAllContests.isEmpty {
                let contest = arrAllContests[section]
                if ((contest.users_limit ?? 0) > (contest.joined_teams_count ?? 0)) && ((contest.max_team_join_count ?? 0) > (contest.my_team_ids?.count ?? 0)){
                    return 115
                }else {
                    return 56
                }
            }
            
            return 0
        }else if btnMyContest.isSelected {
            return arrJoinedContests.isEmpty ? 0 : 56
        }
        
        return 0
    }
    
    @objc func btnViewLeaderboardAction(_ sender: UIButton) {
        debugPrint("View Leaderboard \(sender.tag) tap")
        btnTapPressed(sender)
    }
    
    @objc func btnJoinContestAction(_ sender: UIButton) {
        
        WebCommunication.shared.getUserProfile(hostController: self, showLoader: false) { user in
            if let user = user{
                if (user.state ?? "") == "" || (user.dob ?? "") == ""{
                    let VC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "DOBStateViewController") as! DOBStateViewController
                    VC.completionHandler =   { (success) in
                        if success == true{
                            var contest = self.arrAllContests[sender.tag]
                            contest.isLeagueContest = true
                            self.arrAllContests[sender.tag] = contest
                            self.initJoinContestFlow(contestData: contest)
                        }
                    }
                    UIApplication.getTopMostViewController()?.present(VC, animated: true, completion: nil)
                }
                else{
                    var contest = self.arrAllContests[sender.tag]
                    contest.isLeagueContest = true
                    self.arrAllContests[sender.tag] = contest
                    self.initJoinContestFlow(contestData: contest)
                }
            }
        }
    }
    
    @objc func btnPointsSortPressed(_ sender: UIButton) {
        pointSelected = !pointSelected
        
        if pointSelected == true{
            self.arrSeriesPlayers.sort { (first, second) -> Bool in
                return self.getDouble(for: first.player_points  as Any) < self.getDouble(for: second.player_points as Any)
            }
        }
        else{
            self.arrSeriesPlayers.sort { (first, second) -> Bool in
                return self.getDouble(for: first.player_points  as Any) > self.getDouble(for: second.player_points as Any)
            }
        }
        
        tblContest.reloadData()
    }
    
    @objc func btnTapPressed(_ sender: UIButton) {
       
        let vc = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonContestDetailsVC") as! SeasonContestDetailsVC
        
        if btnAllContest.isSelected {
            vc.contestData = arrAllContests[sender.tag]
            
        }else if btnMyContest.isSelected {
            let contestDataValue = self.arrJoinedContests[sender.tag].data?.contestData
            vc.contestData = contestDataValue
            vc.fromMyContest = true
        }
    
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func btnExpanSelectionPressed(_ sender: UIButton) {
        
        guard arrTeamList.count > sender.tag else { return }
        arrTeamList[sender.tag].isSelected = !arrTeamList[sender.tag].isSelected
        tblContest.reloadData()
    }
    
    @objc func btnMakeTransferdPressed(_ sender: UIButton) {
        
        let team = self.arrTeamList[sender.tag]
        let navData = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonCreateTeamVC") as! SeasonCreateTeamVC
//        navData.setSelectTeamDelegate = true
        navData.isFromEdit = "Edit"
        navData.TeamData = team
        navData.availableTransfer = team.available_transfer ?? 0
        
        if let appliedBooster = team.boosterDetails, appliedBooster.boosterName == BoosterType.TRIPLE_SCORER.name, !(team.boostedPlayer?.isEmpty ?? true) {
            navData.strBoosterPlayerID = "\(team.boostedPlayer?.first ?? 0)"
        }

        navData.strCaptainID = "\(team.captain_player_id ?? "0")"
        navData.strViceCaptainID = "\(team.vice_captain_player_id ?? "0")"
        navData.teamID = "\(team.team_id ?? "0")"
        navData.strTeamNumber = "\(team.team_number ?? 1)"
        navData.transferMadeCount = team.playerTransferInMatch ?? 0
        self.navigationController?.pushViewController(navData, animated: true)
    }
    
    @objc func btnApplyBoosters(_ sender: UIButton) {
        
        let team = self.arrTeamList[sender.tag]
        
        WebCommunication.shared.getLeaguePlayersList(hostController: self, series_id: GDP.leagueSeriesId, showLoader: true) { players in
            
            guard let players = players else { return }
            self.populateEditTeamData(dataResponse: players, team: team)
        }

    }
    
    func populateEditTeamData(dataResponse:[Player], team: Team){
        
        if dataResponse.count > 0 {
            
            var selectedPlayers = [Player]()
            var playerTypeCount = SelectedPlayerTypes()
            
            var localPlayersCount = 0
            var visitorPlayersCount = 0
            var usedCreditsCount = 0.0
            
            for i in 0..<dataResponse.count
            {
                for j in 0..<team.seriesPlayer!.count
                {
                    if "\(dataResponse[i].player_id ?? 0)" == "\(team.seriesPlayer![j].player_id ?? 0)"
                    {
                        selectedPlayers.append(dataResponse[i])
                        //self.selectedPreviousPlayers = self.selectedPlayers.map({$0.player_id ?? 0})
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
            
            playerTypeCount.wicketkeeper = team.total_wicketkeeper ?? 0
            playerTypeCount.batsman = team.total_batsman ?? 0
            playerTypeCount.bowler = team.total_bowler ?? 0
            playerTypeCount.allrounder = team.total_allrounder ?? 0
            playerTypeCount.totalSelectedPlayers = 11
            playerTypeCount.localPlayers = localPlayersCount
            playerTypeCount.visitorPlayers = visitorPlayersCount
            playerTypeCount.usedCredits = usedCreditsCount
            playerTypeCount.captainId = team.captain_player_id ?? ""
            playerTypeCount.viceCaptainId = team.vice_captain_player_id ?? ""
            playerTypeCount.teamId = team.team_id ?? ""
            playerTypeCount.extraPlayers = 3
            
            let vc = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonChooseCaptainVC") as! SeasonChooseCaptainVC
            
            vc.arrAllPlayers = dataResponse
            vc.arrPlayers = selectedPlayers
            vc.playerTypeCount = playerTypeCount
            vc.isFromEdit = "Edit"
            vc.selectedBooster = team.boosterDetails
            
            vc.strTeamID = "\(team.team_id ?? "0")"
            vc.strCaptain = "\(team.captain_player_id ?? "0")"
            vc.strViceCaptain = "\(team.vice_captain_player_id ?? "0")"
            vc.isFromVC = "Edit"
            
            if let appliedBooster = team.boosterDetails, appliedBooster.boosterName == BoosterType.TRIPLE_SCORER.name, !(team.boostedPlayer?.isEmpty ?? true) {
                vc.strBoosterPlayerId = "\(team.boostedPlayer?.first ?? 0)"
            }
            
            vc.transfersUse = "\(team.playerTransferInMatch ?? 0)/\(team.available_transfer ?? 0) transfer in use"
            
            vc.strTeamNumber = "\(team.team_number ?? 1)"
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func showTeamPreview(dataDict: Team, teamName: String, teamRank: String?, totalPoints: Double) {
        
        let vc = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonTeamPreviewVC") as! SeasonTeamPreviewVC

        vc.teamNumber = "\(dataDict.team_number ?? 1)"
        vc.strFromVC = "MyTeams"
        
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
        vc.userTeamRank = teamRank ?? ""
        vc.localTeamShort = dataDict.localTeamShortName ?? ""
        vc.visitorTeamShort = dataDict.visitorTeamShortName ?? ""
        vc.isMatchLive = dataDict.isLive ?? false
        
        if (dataDict.isLive ?? false) == true {
            vc.totalPoints = dataDict.total_point ?? 0
        }else {
            vc.totalPoints = totalPoints
        }
        vc.teamPreviewFrom = .MyContestsMyTeams
        
        vc.modalPresentationStyle = .custom

        self.present(vc, animated: true, completion: nil)
    }
    
    func initJoinContestFlow(contestData: ContestData) {
        
        if arrLeagueMyteam.count > (contestData.my_teams_ids?.count ?? 0){
            let VC = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonSelectTeamVC") as! SeasonSelectTeamVC
            VC.contestData = contestData
            VC.modalPresentationStyle = .custom
            VC.completionHandler = { (team, teamCount) in
                print(team, teamCount)
                
                var isAlreadyJoined = false
                for i in 0..<(contestData.joined_teams?.count ?? 0) {
                    let jTeam = contestData.joined_teams?[i]
                    if (jTeam?.id ?? "") == team.team_id{
                        isAlreadyJoined = true
                        break
                    }
                }
                
                if isAlreadyJoined == true{
                    Constants.kAppDelegate.showAlert(msg: "You already have joined with this team. Please select another team or create a new one.", isLogout: false, isLocationAlert: false)
                }else{
                    if (contestData.entry_fee ?? 0) == 0{
                        self.setTeamId(team: team, teamCount: String(teamCount), contestData: contestData)
                    }
                    else if LocationManager.sharedInstance.isPLayingInLegalState() == true{
                        self.setTeamId(team: team, teamCount: String(teamCount), contestData: contestData)
                    }
                }
            }
            VC.createTeamcompletionHandler = { (success) in
                let VC = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonCreateTeamVC") as! SeasonCreateTeamVC
                self.navigationController?.pushViewController(VC, animated: true)
            }
            
            VC.editTeamcompletionHandler = { (dataDict) in
                let navData = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonCreateTeamVC") as! SeasonCreateTeamVC
                //navData.setSelectTeamDelegate = true
                navData.isFromEdit = "Edit"
                navData.availableTransfer = dataDict.available_transfer ?? 0
                navData.TeamData = dataDict
                navData.strCaptainID = "\(dataDict.captain_player_id ?? "0")"
                navData.strViceCaptainID = "\(dataDict.vice_captain_player_id ?? "0")"
                navData.teamID = "\(dataDict.team_id ?? "0")"
                navData.strTeamNumber = "\(dataDict.team_number ?? 1)"
                self.navigationController?.pushViewController(navData, animated: true)
                
            }
            self.present(VC, animated: false, completion: {
                VC.getTeamLists()
            })
        }
        else{
            let VC = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonCreateTeamVC") as! SeasonCreateTeamVC
            self.navigationController?.pushViewController(VC, animated: true)
        }

    }

}

//MARK: API Call
extension SeasonsContestVC {
    
    func getAllContests(showLoader: Bool = true) {
        
       // guard let match = GDP.selectedMatch else { return }
        
        WebCommunication.shared.getLeagueAllContests(hostController: self, seriesId: GDP.leagueSeriesId, showLoader: showLoader) { contests, allContestCount, myContestCount, myTeamCaount in
            
            self.arrAllContests = contests ?? []
            self.setupTabCounts(allContestCount: allContestCount, myContestCount: myContestCount, myTeamCaount: myTeamCaount)
        }
    }
    
    func getMyContests() {
        
//        guard let match = GDP.selectedMatch else {
//            self.arrJoinedContests = []
//            return
//        }
        
        WebCommunication.shared.getLeagueJoinedContests(hostController: self, seriesId: GDP.leagueSeriesId, showLoader: true) { joinedContests, allContestCount, myContestCount, myTeamCaount in
            
            self.arrJoinedContests = joinedContests ?? []
            self.setupTabCounts(allContestCount: allContestCount, myContestCount: myContestCount, myTeamCaount: myTeamCaount)
        }
    }
    
    func getMyTeams(teamId: String = "", teamName: String = "", teamRank: String = "", showTeamPreview: Bool = false) {
        
        //guard let match = GDP.selectedMatch else { return }
        
        WebCommunication.shared.getMyTeams(hostController: self, seriesId: GDP.leagueSeriesId, teamId: teamId, teamName: teamName, showLoader: true) { teams, allContestCount, myContestCount, myTeamCaount in
            
            self.arrTeamList = teams ?? []
            self.setupTabCounts(allContestCount: allContestCount, myContestCount: myContestCount, myTeamCaount: myTeamCaount)
            if self.arrTeamList.count > 0 {
                self.arrTeamList[0].isSelected = true
            }
            
//            if showTeamPreview {
//                self.showTeamPreview(index: 0, teamRank: teamRank)
//            }
           
        }
    }
    
    func getTeamPreviewData(userTeam: JoinedTeam) {
        
        let selectedTeamName = "\(userTeam.username ?? "") (Team \(Int(userTeam.team_count ?? 0)))"
        
        WebCommunication.shared.leagueTeamPreview(hostController: self, seriesId: GDP.leagueSeriesId, matchId: 0, teamName: "\(userTeam.team_count ?? 0)", userId: "", showLoader: true) { teams in
            
            guard let teams = teams, let firstTeam = teams.first else {
                return
            }
         
            self.showTeamPreview(dataDict: firstTeam, teamName: selectedTeamName, teamRank: userTeam.rank?.clean ?? "", totalPoints: userTeam.totalSeriesPoint ?? 0)
        }
    }
    
    func getMyTeamPreviewData(userTeam: Team, teamName: String) {
        
        //let selectedTeamName = "\(userTeam.username ?? "") (Team \(Int(userTeam.team_count ?? 0)))"
        
        WebCommunication.shared.leagueTeamPreview(hostController: self, seriesId: GDP.leagueSeriesId, matchId: 0, teamName: "\(userTeam.team_number ?? 0)", userId: "", showLoader: true) { teams in
            
            guard let teams = teams, let firstTeam = teams.first else {
                return
            }
            self.showTeamPreview(dataDict: firstTeam, teamName: teamName, teamRank: "", totalPoints: userTeam.total_point ?? 0)
        }
    }
    
    func getLeagueDetail(showLoader: Bool = true, fromMyTeams: Bool = false) {
        
        WebCommunication.shared.getLeagueDetail(hostController: self, seriesId: GDP.leagueSeriesId, showLoader: showLoader) { leagueDetails in
            
            if let leagueDetails = leagueDetails {
               
                self.arrLeagueMyteam = leagueDetails.userTeams ?? []
                self.arrLeagueMyteam = self.arrLeagueMyteam.sorted(by: {($0.teamCount ?? 0) < ($1.teamCount ?? 0)})
                GDP.leagueMyTeams = self.arrLeagueMyteam
                
                guard !self.arrLeagueMyteam.isEmpty else {
                    if fromMyTeams {
                        self.arrTeamList = []
                    }
                    return
                }
                self.currentHighLightedTeam = self.arrLeagueMyteam.first
                
                if fromMyTeams == true {
                    if self.selectedMyTeam == nil {
                        self.selectedMyTeam = self.arrLeagueMyteam.first
                    }
                    
                    self.getMyTeams(teamId: self.selectedMyTeam?.id ?? "", teamName: "\(self.selectedMyTeam?.teamCount ?? 0)")
                }
            }
        }
    }
    
    func getSeriesPlayers() {
        
//        guard let seriesId = GDP.selectedMatch?.series_id else { return }
        
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
    
    func populateHighLightedPlayersForTeam(team: LeagueMyTeam) {
        
        self.currentHighLightedTeam = team
        getSeriesPlayers()
    }
    
    func setupTabCounts(allContestCount: Int, myContestCount: Int, myTeamCaount: Int) {
        
        if allContestCount != 0 {
            self.btnAllContest.setTitle("All Contests(\(allContestCount))", for: .normal)
        }
        
        if myContestCount != 0 {
            self.btnMyContest.setTitle("My Contests(\(myContestCount))", for: .normal)
        }
        
        if myTeamCaount != 0 {
            self.btnMyTeam.setTitle("My Teams(\(myTeamCaount))", for: .normal)
        }
    }
}

//MARK: Check Wallet Validation
extension SeasonsContestVC {
    
    func setTeamId(team: Team, teamCount:String, contestData:ContestData?)
    {
        print("teamId--->",team.team_id ?? "")
        if GDP.selectedMatch != nil
        {
            var findCurrentCount = GDP.selectedMatch?.my_total_teams ?? 0
            findCurrentCount += 1
            GDP.selectedMatch?.my_total_teams = findCurrentCount
        }
        self.checkWalletValidation(team: team, teamcount: GlobalDataPersistance.shared.myTeamCount, contestData: contestData)
    }
    
    func checkWalletValidation (team:Team, teamcount:Int, contestData:ContestData?){
        
        if (contestData?.users_limit ?? 0) == (contestData?.joined_teams_count ?? 0) && contestData?.is_joined ?? false == true
        {
            if (contestData?.users_limit ?? 0) == (contestData?.joined_teams_count ?? 0){
                Constants.kAppDelegate.showAlert(msg:"You cannot join this contest more than \((contestData?.users_limit ?? 0)) teams", isLogout: false, isLocationAlert: false)

            }else{
                Constants.kAppDelegate.showAlert(msg: ConstantMessages.ALREADY_JOINED_THIS_CONTEST, isLogout: false, isLocationAlert: false)
            }
            return
        }
        
        if contestData?.join_multiple_team ?? false == false && contestData?.is_joined ?? false == true
        {
            Constants.kAppDelegate.showAlert(msg: ConstantMessages.CANNOT_JOINED_MORETHANSINGLETEAM, isLogout: false, isLocationAlert: false)
            return
        }
        
        if (contestData?.my_teams_ids?.count ?? 0) > (contestData?.max_team_join_count ?? 0)
        {
            Constants.kAppDelegate.showAlert(msg: ConstantMessages.CAN_NOT_JOIN_MORE_TEAMS, isLogout: false, isLocationAlert: false)
            return
        }
        
        let params:[String:String] = ["contest_id": contestData?.id ?? "",
                                      "match_id":String(GDP.selectedMatch?.match_id ?? 0),
                                      "series_id":String(GDP.selectedMatch?.series_id ?? 0),
                                      "league_type": GDP.fantasyType
        ]
        
        let url = URLMethods.BaseURL + URLMethods().joinContestCheckWallet

        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                if result != nil {
                    let data = result?.object(forKey: "results") as? [String:Any]
                    if data != nil{
                        self.parseWalletData(data: data!, team: team, teamcount: teamcount, contestData: contestData)
                    }
                }
            }
            else{
                if result != nil {
                    let data = result?.object(forKey: "results") as? [String:Any]
                    if data != nil{
                        self.parseWalletData(data: data!, team: team, teamcount: teamcount, contestData: contestData)
                    }
                    else{
                        AppManager.showToast(msg ?? "", view: self.view)
                    }
                }else{
                    AppManager.showToast(msg ?? "", view: self.view)
                }
            }
            AppManager.stopActivityIndicator(self.view)
        }
        AppManager.startActivityIndicator(sender: self.view)
    }
    
    func parseWalletData(data:[String:Any], team:Team, teamcount:Int, contestData:ContestData?){
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
              let tblData = try? JSONDecoder().decode(WalletAmountResults.self, from: jsonData)else {return }
       
        var contestBalance = ContestFeeBalances()
        contestBalance.cashBalance = Double("\(tblData.cashBalance ?? 0.0)") ?? 0.0
        contestBalance.winningBalance = Double("\(tblData.winningBalance ?? 0.0)") ?? 0.0
        contestBalance.usableBalance = Double("\(tblData.usableBonus ?? 0.0)") ?? 0.0
        contestBalance.entryFee = Double("\(tblData.entryFee ?? 0.0)") ?? 0.0
        contestBalance.useableBonousPercent = "\(tblData.useableBonousPercent ?? 0)"
        
        if contestBalance.entryFee - (contestBalance.usableBalance + contestBalance.cashBalance + contestBalance.winningBalance) <= 0
        {
            if contestData != nil{
                
                self.showWalletPopupView(contestBalance, matchData: GDP.selectedMatch,team: team, gameTypeValue: "", contestData:contestData!, completionHandler: { receiveData in
                    print(receiveData)
                    
//                    if self.btnAllContest.isSelected == true{
//                        self.getAllContests()
//                    }else{
//                        self.getMyContests()
//                    }
                    
                    self.selectionTab = self.btnMyContest
                    self.btnTabActionPressed(self.selectionTab)

                })
            }else{
                AppManager.showToast("Something went wrong", view: self.view)
            }

        }
        else
        {
            let remainingBalance = contestBalance.entryFee - (contestBalance.usableBalance + contestBalance.cashBalance + contestBalance.winningBalance)
            let alert = UIAlertController(title: Constants.kAppDisplayName, message: "Low balance!. Please add \(GDP.globalCurrency)\(String.init(format: "%.2f", arguments: [ceil(remainingBalance*100)/100])) to join contest.", preferredStyle:.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                let vc = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "AddCashViewController") as! AddCashViewController
                vc.requiredCash = ceil(remainingBalance*100)/100
                vc.completionHandler = { (balance) in
                                print(balance)
                    if teamcount == 0
                    {
                        self.checkWalletValidation(team: team, teamcount: 1, contestData: contestData)
                    }
                    else
                    {
                        self.checkWalletValidation(team: team, teamcount: teamcount, contestData: contestData)
                    }
                }
                self.navigationController?.pushViewController(vc, animated: false)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK: - Notification Observer
extension SeasonsContestVC {
    
    func addNotificationObservers() {
        
        //NotificationCenter.default.addObserver(self, selector: #selector(refreshTeamList(notification:)), name: .LeagueTeamCreation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTeamList(notification:)), name: .MoveToMyTeam, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshAllContest(notification:)), name: .MoveToMyContest, object: nil)
    }
    
    @objc func refreshTeamList(notification: NSNotification) {
        isFromNotification = true
        self.selectionTab = btnMyTeam
        //self.getAllContests(showLoader: false)
        self.btnTabActionPressed(self.selectionTab)
    }
    
    @objc func refreshAllContest(notification: NSNotification) {
        isFromNotification = true
        self.selectionTab = btnMyContest
        self.btnTabActionPressed(self.selectionTab)
    }
    
    func removeNotificationObservers() {
        print("Removed NotificationCenter Observer")
        //NotificationCenter.default.removeObserver(self, name: .LeagueTeamCreation, object: nil)
        NotificationCenter.default.removeObserver(self, name: .MoveToMyTeam, object: nil)
        NotificationCenter.default.removeObserver(self, name: .MoveToMyContest, object: nil)
    }
}

//
//  LiveContestViewController.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 07/03/22.
//

import UIKit
import SDWebImage
import SocketIO

class LiveContestViewController: BaseClassWithoutTabNavigation {

    @IBOutlet weak var navigationView: CustomNavigation!
    @IBOutlet weak var lblMatchStatus: UILabel!
    @IBOutlet weak var btnMyTeams: UIButton!
    @IBOutlet weak var btnSelfContents: UIButton!
    @IBOutlet weak var tblContests: UITableView!
    
    var selectedBoard = 0
    
    @IBOutlet weak var viewLiveIndicator: UIView!
    @IBOutlet weak var viewLiveScore: LiveScoreBallView!
    @IBOutlet weak var lblLocalTeamScore: UILabel!
    @IBOutlet weak var lblVisitorTeamScore: UILabel!
    @IBOutlet weak var lblCommentScore: UILabel!
    @IBOutlet weak var btnStats: UIButton!
    @IBOutlet weak var btnScoreCard: UIButton!
    var selectedTab:UIButton!
    
    @IBOutlet weak var btnVisitorTeam: UIButton!
    @IBOutlet weak var btnHomeTeam: UIButton!
    @IBOutlet weak var imgVisitorTeam: UIImageView!
    @IBOutlet weak var imgLocalTeam: UIImageView!
    @IBOutlet weak var viewStats: UIView!
    @IBOutlet weak var viewScoreCard: UIView!
    @IBOutlet weak var viewMyTeams: UIView!
    @IBOutlet weak var viewSelfContests: UIView!
    
    @IBOutlet weak var viewLiveScoreHeight: NSLayoutConstraint!
    @IBOutlet weak var headerHeight: NSLayoutConstraint!  //260 , 264
    
    @IBOutlet weak var tabStackView: UIStackView!
    @IBOutlet weak var scorecardTabView: UIView!
    
    var arrContests:[Contest]? = nil
    var arrTeamList:[Team]? = nil
    var arrScoreBoard:[ScoreDetails]? = nil
    
    var arrJoinedContests:[JoinedContest]? = nil
    var arrSeriesPlayers:[Player]? = nil
    var arrAllSeriesPlayers:[Player]? = nil

    
    var matchTotalScore:Score? = nil
    let refreshControl = UIRefreshControl()
    
    var arrMyTeams:[JoinedTeam]? = nil
    
    var currentHighLightedTeam:JoinedTeam? = nil
    
    var tipView = EasyTipHelper()
    
    var pointSelected = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblMatchStatus.text = ""
        
        let title = GDP.getFantasyTitle()
        navigationView.configureNavigationBarWithController(controller: self, title: title, hideNotification: false, hideAddMoney: true, hideBackBtn: false)

        navigationView.img_BG.isHidden = true
        
        selectedTab = btnSelfContents
        self.tblContests.rowHeight = UITableView.automaticDimension;
        self.tblContests.estimatedRowHeight = 44.0; //
        if #available(iOS 15.0, *) {
            self.tblContests.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: attributes)
        refreshControl.tintColor = .white
        self.refreshControl.addTarget(self, action: #selector(self.refreshTableData(_:)), for: .valueChanged)
        tblContests.addSubview(refreshControl)
        
        self.setupUI()
        
        SocketIOManager.sharedInstance.delegateToHandleSocketConnection = self

        // Do any additional setup after loading the view.
    }
    
    @objc func refreshTableData(_ sender: AnyObject) {
        self.loadData()
    }
    
    
    override func viewDidLayoutSubviews() {
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tipView.tipView.dismiss()
    }
    
    func loadData(){
        self.getTeamScore()
        self.btnTabActionPressed(selectedTab)
    }
    
    func populatePrizeView(){
        let totalPrize = self.arrJoinedContests!.map({ $0.win_amount }).reduce(0, +)
        print(totalPrize)
        if totalPrize > 0{
            let viewHeader = PrizeHeaderView.instanceFromNib() as? PrizeHeaderView
            if let view = viewHeader{
                let strPrize = CommonFunctions.suffixNumberIndian(currency: (Double(totalPrize) ))

                view.lblPrizeAmount.text = "\(GDP.globalCurrency)\(strPrize)"
                
                let count = self.arrJoinedContests!.filter({ $0.win_amount > 0 }).count
                if count > 1{
                    view.lblMessage.text = "Congratulations! You have won \(count) contests"
                }else{
                    view.lblMessage.text = "Congratulations! You have won \(count) contest"
                }
                tblContests.tableHeaderView = view
            }
        }
    }
    
    func populateDreamTeamView(){
        let viewHeader = DreamTeamView.instanceFromNib() as? DreamTeamView
        if let view = viewHeader{
            view.controller = self
            view.updateView()
            tblContests.tableHeaderView = view

        }
    }
    
    func setupUI(){
        btnHomeTeam.setTitle(GDP.selectedMatch?.localteam_short_name ?? "", for: .normal)
        btnVisitorTeam.setTitle(GDP.selectedMatch?.visitorteam_short_name ?? "", for: .normal)
        
        imgLocalTeam.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgLocalTeam.sd_setImage(with: URL(string: GDP.selectedMatch?.localteam_flag ?? ""), placeholderImage: Constants.kNoImageUser)

        imgVisitorTeam.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgVisitorTeam.sd_setImage(with: URL(string: GDP.selectedMatch?.visitorteam_flag ?? ""), placeholderImage: Constants.kNoImageUser)
        
        if GDP.selectedMatch?.match_status?.uppercased() ?? "" == "LIVE" || GDP.selectedMatch?.match_status?.uppercased() ?? "" == "IN PROGRESS" || GDP.selectedMatch?.match_status?.uppercased() ?? "" == "RUNNING"{
            self.viewLiveScore.isHidden = false
            self.viewLiveScore.controller = self
            self.viewLiveScore.updateView(selectedMatch: GDP.selectedMatch)
            self.headerHeight.constant = 264
            viewLiveScoreHeight.constant = 64
        }else{
            self.btnHomeTeam.setImage(nil, for: .normal)
            self.btnVisitorTeam.setImage(nil, for: .normal)
            self.viewLiveScore.isHidden = true
            self.headerHeight.constant = 200
            viewLiveScoreHeight.constant = 0
        }
       
    }
    
    @IBAction func btnBackPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnTabActionPressed(_ sender: UIButton) {
        tipView.tipView.dismiss()
        btnSelfContents.isSelected = false
        btnMyTeams.isSelected = false
        btnScoreCard.isSelected = false
        btnStats.isSelected = false
        
        viewSelfContests.backgroundColor = UIColor.clear
        viewMyTeams.backgroundColor = UIColor.clear
        viewScoreCard.backgroundColor = UIColor.clear
        viewStats.backgroundColor = UIColor.clear
        
        tblContests.backgroundColor = UIColor.clear
        
        self.arrContests?.removeAll()
        tblContests.reloadData()
        
        sender.isSelected = true
        selectedTab = sender
        
        
        if sender == btnSelfContents{
            viewSelfContests.backgroundColor = UIColor.appRedColor
        }else if sender == btnMyTeams{
            viewMyTeams.backgroundColor = UIColor.appRedColor
        }else if sender == btnScoreCard{
//            tblContests.backgroundColor = UIColor.white
            viewScoreCard.backgroundColor = UIColor.appRedColor
        }else{
            viewStats.backgroundColor = UIColor.appRedColor
        }

        if sender == btnSelfContents{
            self.getJoinedContests()
        }
        else if sender == btnMyTeams{
            self.tblContests.tableHeaderView = nil
            self.getTeamLists()
        }
        else if sender == btnScoreCard{
            self.tblContests.tableHeaderView = nil
            self.getTeamScore()
        }
        else {
            self.tblContests.tableHeaderView = nil
            self.currentHighLightedTeam = nil
            if GDP.selectedMatch?.match_status?.uppercased() == "FINISHED" || GDP.selectedMatch?.match_status?.uppercased() == "COMPLETED"{
              // self.populateDreamTeamView()
            }
            self.getSeriesPlayerList()
        }
    }
    
    func highLightBattingBowlingTeams(score:Score?){
        if (score?.battingTeamId ?? 0 == GDP.selectedMatch?.localteam_id ?? 0){
            self.btnHomeTeam.setImage(Constants.kBattingImage, for: .normal)
            self.btnVisitorTeam.setImage(Constants.kBowlingImage, for: .normal)

        }else{
            self.btnHomeTeam.setImage(Constants.kBowlingImage, for: .normal)
            self.btnVisitorTeam.setImage(Constants.kBattingImage, for: .normal)
        }
    }
    
    @IBAction func btnContestsTapped(_ sender: UIButton) {
        
        self.tabBarController?.selectedIndex = 1

    }
    
    @IBAction func btnJoinContestPressed(_ sender: UIButton) {
        let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "JoinContestViewController") as! JoinContestViewController
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func btnCreateContestPressed(_ sender: UIButton) {
        
    }
    
    func resetSelections(){
        for i in 0..<(arrScoreBoard?.count ?? 0){
            var board = arrScoreBoard?[i]
            board?.isSelected = false
            arrScoreBoard?[i] = board!
        }
    }
        
    @objc @IBAction func btnExpanSelectionPressed(_ sender: UIButton) {
        self.resetSelections()
        var board = self.arrScoreBoard?[sender.tag]
        board?.isSelected = true
        self.selectedBoard = sender.tag
        self.arrScoreBoard?[sender.tag] = board!
        
        tblContests.reloadData()
    }
    
    @objc @IBAction func btnTapPressed(_ sender: UIButton) {
        let contestDataValue = self.arrJoinedContests![sender.tag].contestData
        
        if (GDP.selectedMatch?.match_status?.uppercased() ?? "") == "NOT STARTED" || (GDP.selectedMatch?.match_status?.uppercased() ?? "") == "FIXTURE" {
            let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "ContestDetailViewController") as! ContestDetailViewController
            VC.contestData = contestDataValue
            self.navigationController?.pushViewController(VC, animated: true)
        }else{
            let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "LiveContestDetailViewController") as! LiveContestDetailViewController
            VC.isLiveContest = true
            VC.contestData = contestDataValue
            VC.strFromVC = "Live"
            self.navigationController?.pushViewController(VC, animated: true)
        }
         
    }
    
    @objc @IBAction func btnPointsSortPressed(_ sender: UIButton) {
        pointSelected = !pointSelected
        
        if pointSelected == true{
            self.arrSeriesPlayers?.sort { (first, second) -> Bool in
                return self.getDouble(for: first.points  as Any) < self.getDouble(for: second.points as Any)
            }
        }
        else{
            self.arrSeriesPlayers?.sort { (first, second) -> Bool in
                return self.getDouble(for: first.points  as Any) > self.getDouble(for: second.points as Any)
            }
        }
         
        tblContests.reloadData()
    }
}
extension LiveContestViewController:UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if btnMyTeams.isSelected{
            return arrTeamList?.count ?? 0
        }
        else if btnSelfContents.isSelected{
            let contest = self.arrJoinedContests?[section]
            
            if let teams = contest?.teams{
                return teams.count
            }
            return 0
        }
        else if btnStats.isSelected{
            return arrSeriesPlayers?.count ?? 0

        }
        else if btnScoreCard.isSelected{
            let board = self.arrScoreBoard?[section]
            if (board?.isSelected ?? false) == true{
                return board?.players?.count ?? 0
            }else{
                return 0
            }
        }
        else{
            let model = arrContests?[section]
            return model?.contestData?.count ?? 0
        }
       
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if btnScoreCard.isSelected {
            return arrScoreBoard?.count ?? 1
        }
        else if btnMyTeams.isSelected{
            return 1;

        }else if  btnSelfContents.isSelected{
            return arrJoinedContests?.count ?? 0
        }
        else{
            return arrContests?.count ?? 1;
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if btnMyTeams.isSelected{
            return 0
        }
        
        if btnSelfContents.isSelected{
            return 218
        }
        if btnScoreCard.isSelected{
            let board = self.arrScoreBoard?[section]
            if (board?.isSelected ?? false) == true{
                return 69
            }else{
                return 38
            }
        }
        return 90;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if btnScoreCard.isSelected{
            let board = self.arrScoreBoard?[section]
            let headerView = ScoreBoardHeaderView.instanceFromNib() as? ScoreBoardHeaderView
            headerView?.lblTeamShortName.text = self.getTeamName(teamId: board?.id?.teamID ?? 0)
            headerView?.btnExpand.tag = section
            headerView?.btnExpand.addTarget(self, action: #selector(btnExpanSelectionPressed(_:)), for: .touchUpInside)
            headerView?.btnExpand.isSelected = board?.isSelected ?? false
            headerView?.lblTeamScore.text =  self.getTeamScoreFromData(scores: board ?? ScoreDetails())

            return headerView
        }
        else if btnSelfContents.isSelected{
            if (self.arrJoinedContests?.count ?? 0 > 0){
                let cellMatch = LiveContestSectionView.instanceFromNib() as? LiveContestSectionView
                var contestDataValue:ContestData? = nil
                cellMatch?.controller = self
                cellMatch?.tipView = self.tipView
                let contest = self.arrJoinedContests?[section]
                contestDataValue = self.arrJoinedContests?[section].contestData
                var temp = contestDataValue
                temp?.joined_teams_count = contest?.joined_teams_count ?? 0
                contestDataValue = temp
                cellMatch?.btnTap.tag = section
                cellMatch?.btnTap.addTarget(self, action: #selector(btnTapPressed(_:)), for: .touchUpInside)
                cellMatch?.contestData = contestDataValue

                cellMatch?.viewContestName.isHidden = false
                cellMatch?.lblContestTitle.text = contestDataValue?.name ?? ""
                //cellMatch?.lblContestNamr.text = contestDataValue?.name ?? ""
                
                cellMatch?.lblTotalSpots.text = "\(contestDataValue?.users_limit ?? 0)"
                
                let firstWinnerPrize = Double(contestDataValue?.total_winners ?? 0)/Double(contestDataValue?.users_limit ?? 0)
                
                if Double(firstWinnerPrize * 100).rounded(toPlaces: 2).isInteger
                {
                    cellMatch?.btnTrophyPercantage.setTitle("\(Int(firstWinnerPrize * 100))%", for: .normal)
                }
                else
                {
                    cellMatch?.btnTrophyPercantage.setTitle("\(Double(firstWinnerPrize * 100).rounded(toPlaces: 2))%", for: .normal)
                }
                
                if (contestDataValue?.entry_fee ?? 0) == 0 {
                    cellMatch?.lblEntry.text = "Free"
                }else {
                    let strEntry_fee = CommonFunctions.suffixNumberIndian(currency: (contestDataValue?.entry_fee ?? 0).rounded(toPlaces: 2))
                    cellMatch?.lblEntry.text = "\(GDP.globalCurrency)\(strEntry_fee)"
                }
                
                cellMatch?.viewPrizePool.backgroundColor = .clear
                cellMatch?.lblPrizePool.textColor = .appHighlightedTextColor
                cellMatch?.lblPrizePool.font = .init(name: Constants.kSemiBoldFont, size: 16)
                cellMatch?.viewPrizePool.layer.cornerRadius = 0
                cellMatch?.lblPrizePool.text = ""
                
                if (contestDataValue?.winning_amount ?? 0) == 0 {
                    if let firstPrize = contestDataValue?.price_breakup?.first(where: {$0.start_rank == 1}) {
                        let reward = firstPrize.reward ?? ""//"XP"
                        cellMatch?.btnRewardAmount.setTitle(reward == "" ? "" : reward, for: .normal)
                        cellMatch?.lblPrizePool.text = firstPrize.reward
                    }else {
                        cellMatch?.btnRewardAmount.setTitle("", for: .normal)
                        
                        if contestDataValue?.created_by == "user" {
                            cellMatch?.lblPrizePool.text = " Punishment "
                            cellMatch?.viewPrizePool.backgroundColor = .appHighlightedTextColor
                            cellMatch?.lblPrizePool.textColor = .black
                            cellMatch?.lblPrizePool.font = .init(name: Constants.kSemiBoldFont, size: 14)
                            cellMatch?.viewPrizePool.layer.cornerRadius = 5
                        }
                    }
                }else {
                    
                    let strWinning_amount = CommonFunctions.suffixNumberIndian(currency: (contestDataValue?.winning_amount ?? 0 ))

                    cellMatch?.lblPrizePool.text = "\(GDP.globalCurrency)\(strWinning_amount)"
                    
                    if contestDataValue?.price_breakup?.count ?? 0 > 0
                    {
                        let strPrice_breakup = CommonFunctions.suffixNumberIndian(currency: (contestDataValue?.price_breakup?[0].each_price ?? 0))

                        if (contestDataValue?.price_breakup?[0].each_price ?? 0) > 0{
                            cellMatch?.btnRewardAmount.setTitle("\(GDP.globalCurrency)\(strPrice_breakup)", for: .normal)
                        }else{
                            cellMatch?.btnRewardAmount.setTitle(ConstantMessages.kGloryMessageShort, for: .normal)
                        }
                    }
                }
                
                if contestDataValue?.confirm_winning == true{
                    cellMatch?.btnGuaranteeStatus.isHidden = false
                }else{
                    cellMatch?.btnGuaranteeStatus.isHidden = true
                }
                
                if (contestDataValue?.max_team_join_count ?? 0) == 1{
                    cellMatch?.btnMaxTeams.setTitle("Max 1 Team", for: .normal)
                }else{
                    cellMatch?.btnMaxTeams.setTitle("Max \(contestDataValue?.max_team_join_count ?? 0) Teams", for: .normal)
                }
                
                return cellMatch
            }
            return UIView()
           
        }
        else{
            let headerView = PlayerStatsHeaderView.instanceFromNib() as? PlayerStatsHeaderView
            headerView?.controller = self
            headerView?.btnPoints.isSelected = self.pointSelected
            headerView?.btnPoints.addTarget(self, action: #selector(btnPointsSortPressed(_:)), for: .touchUpInside)
            headerView?.updateView()
            return headerView
        }
        
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if btnMyTeams.isSelected{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TeamListTVCell", for: indexPath) as! TeamListTVCell

            cell.selectionStyle = .none

            let team = self.arrTeamList?[indexPath.row]
            
            let players:[Player]? = self.arrTeamList?[indexPath.row].seriesPlayer

            cell.lblTeamTitle.text = "TEAM \(String(team?.team_number ?? 0))"
            
            cell.lblWk.text = "\(GDP.wkShort)(\(String(team?.total_wicketkeeper ?? 0)))"
            cell.lblBat.text = "\(GDP.batShort)(\(String(team?.total_batsman ?? 0)))"
            cell.lblAr.text = "\(GDP.arShort)(\(String(team?.total_allrounder ?? 0)))"
            cell.lblBowl.text = "\(GDP.bowlShort)(\(String(team?.total_bowler ?? 0)))"
            cell.viewForwards.isHidden = true
            
            cell.lblTotalPoints.text = "\(team?.total_point ?? 0) Pts"
            if let players = players{
                let arrlocalTeamPlayers = players.filter({($0.team_id! == GDP.selectedMatch?.localteam_id)})
                cell.lblTeamOne.text = "\(GDP.selectedMatch?.localteam_short_name?.uppercased() ?? "") (\(arrlocalTeamPlayers.count))"
                
                let arrVisitorTeamPlayers = players.filter({($0.team_id! == GDP.selectedMatch?.visitorteam_id)})
                cell.lblTeamTwo.text = "\(GDP.selectedMatch?.visitorteam_short_name?.uppercased() ?? "") (\(arrVisitorTeamPlayers.count))"
            }
            
            if let captianRow = players?.firstIndex(where: {$0.player_id == (Int(team?.captain_player_id ?? "0"))}) {
                let player = players?[captianRow]
                
                cell.btnCaptain.setTitle(player?.name ?? "", for: .normal)
                cell.imgViewCaptain.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.imgViewCaptain.sd_setImage(with: URL(string: player?.image ?? ""), placeholderImage: Constants.kNoImageUser)
            }

            if let vcRow = players?.firstIndex(where: {$0.player_id == (Int(team?.vice_captain_player_id ?? "0"))}) {
                let player = players?[vcRow]
                
                cell.btnViceCaptain.setTitle(player?.name ?? "", for: .normal)
                cell.imgViewViceCaptain.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.imgViewViceCaptain.sd_setImage(with: URL(string: player?.image ?? ""), placeholderImage: Constants.kNoImageUser)
            }
            
            if (team?.lineUpPlayerNotAnnounced ?? 0) == 0{
                cell.viewLineUp.isHidden = true
            }else{
                cell.viewLineUp.isHidden = false
                if (team?.lineUpPlayerNotAnnounced ?? 0) > 1{
                    cell.lblNotAnnouncedTeamLabel.text = "\(team?.lineUpPlayerNotAnnounced ?? 0) players are not announced in playing XI."
                }else{
                    cell.lblNotAnnouncedTeamLabel.text = "\(team?.lineUpPlayerNotAnnounced ?? 0) player is not announced in playing XI."
                }
            }
            
            cell.viewBooster.isHidden = true
            cell.imgBoosterFirst.isHidden = true
            cell.imgBoosterSecond.isHidden = true
                    
            cell.selectionStyle = .none
            
            return cell
        }
        else if btnStats.isSelected == true{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerStatsTVCell", for: indexPath) as! PlayerStatsTVCell
            cell.selectionStyle = .none

            let player = self.arrSeriesPlayers?[indexPath.row]
            cell.updateView(player: player, match: GDP.selectedMatch)
            cell.lblPlayerName.text = player?.player_name ?? ""
            cell.lblSelectionPercantage.text = (player?.selection_percent ?? "0")
            cell.lblPoints.text =  "\(self.getDouble(for: player?.points as Any))"
//            cell.btnInMyTeam.alpha = (player?.my_team ?? false) ? 1 : 0.2
//            cell.contentView.backgroundColor = UIColor.white
           if (GDP.selectedMatch?.match_status?.uppercased() ?? "") == "FINISHED" || (GDP.selectedMatch?.match_status?.uppercased() ?? "") == "COMPLETED"{
//                if (player?.my_team ?? false) == true
//                {
//                    cell.viewProfilePic.alpha = 1
//                }
//                else
//                {
//                    cell.viewProfilePic.alpha = 0.2
//                }
               cell.viewProfilePic.alpha = 1

           }
            
            if (player?.isHighLight ?? false) == true{
                cell.contentView.backgroundColor = UIColor.cellStatsSelectedColor
            }else{
                cell.contentView.backgroundColor = UIColor.clear
            }
                    
            cell.imgViewPlayer.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imgViewPlayer.sd_setImage(with: URL(string: player?.player_image ?? ""), placeholderImage: Constants.kNoImageUser)
            
            cell.lblPlayerRole.text = player?.playing_role ?? ""
            cell.lblPlayerTeamName.text = player?.team_short_name ?? ""

            return cell

        }
        else if btnScoreCard.isSelected == true{
            let board = self.arrScoreBoard?[indexPath.section].players?[indexPath.row]

            let boardName = board?.name ?? ""
            if boardName == "YET TO BAT" || boardName.contains("EXTRAS") || boardName == "TOTAL"{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ExtraScoreTVCell", for: indexPath) as! ExtraScoreTVCell
                cell.selectionStyle = .none

                cell.lblTitle.text = board?.name ?? ""
                cell.lblRuns.text = "\(board?.runScored ?? "")"

                return cell


            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreBoardTVCell", for: indexPath) as! ScoreBoardTVCell
                cell.selectionStyle = .none
                if board?.status != nil{
                    if (board?.playerType?.lowercased() ?? "") == "batter"{
                        cell.lblTitle.text = (board?.name ?? "") + "\n(" + (board?.status ?? "") + ")"
                    }else{
                        cell.lblTitle.text = (board?.name ?? "")
                    }
                }else{
                    cell.lblTitle.text = (board?.name ?? "")
                }

                if board?.name == "Bowler".uppercased(){
                    cell.updateColors(highlight: true)
                }else{
                    cell.updateColors(highlight: false)
                }
                if (board?.playerType?.lowercased() ?? "") == "batter" || board?.name.uppercased() == "BOWLER"{
                    cell.lblRuns.text = "\(board?.runScored ?? "0")"
                    cell.lblBalls.text = "\(board?.ballFaced ?? "0")"
                    cell.lblFours.text = board?.s4 ?? "0"
                    cell.lblSixes.text = board?.s6 ?? "0"
                    cell.lblSR.text = board?.battingStrikeRate ?? "0"
                }else{
                    cell.lblRuns.text = "\(board?.overBowled ?? "0")"
                    cell.lblBalls.text = "\(board?.maidensBowled ?? "0")"
                    cell.lblFours.text = "\(board?.runsConceded ?? 0)"
                    cell.lblSixes.text = "\(board?.wicketsTaken ?? 0)"
                    cell.lblSR.text = "\(board?.economyRatesRunsConceded ?? "0")"
                }

                return cell

            }
            
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LiveContestTVCell", for: indexPath) as! LiveContestTVCell
            cell.selectionStyle = .none
            

            let contest = self.arrJoinedContests?[indexPath.section]
            
            if let teams = contest?.teams{
                let breakUp = teams[indexPath.row]
                print("Team ---\(breakUp)")
                cell.lblTeamName.text = "\(breakUp.username ?? "")"
                cell.lblPoints.text = "\(breakUp.points ?? 0)"
                cell.lblRank.text = "#\(Int(breakUp.rank ?? 0))"
                cell.lblTeamNumber.text = "T\(Int(breakUp.team_count ?? 0))"
                
                if let status = GDP.selectedMatch?.match_status?.uppercased(){
                    if status == "FINISHED" || status == "COMPLETED"{
                        if (breakUp.win_amount ?? 0) > 0{
                            cell.winningBottom.constant = 13
                            //cell.winningHeight.constant = 15
                            let strWin_amount = CommonFunctions.suffixNumberIndian(currency: (breakUp.win_amount ?? 0))
                            cell.lblPrizeWon.text = "WON AMOUNT: \(GDP.globalCurrency)\(strWin_amount)"
                        }else{
                            cell.lblPrizeWon.text = breakUp.reward
                            cell.winningBottom.constant = 13
                            //cell.winningHeight.constant = 15
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
                
                if indexPath.row == teams.count - 1{
                    DispatchQueue.main.async {
                        cell.viewContainer.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10.0)
                    }
                }else{
                    DispatchQueue.main.async {
                        cell.viewContainer.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 0)
                    }
                }
                
            }
            
            return cell
        }
        
     
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if btnSelfContents.isSelected == true{
            let contest = self.arrJoinedContests?[indexPath.section]
            tipView.tipView.dismiss()
            if let teams = contest?.teams{
                let breakUp = teams[indexPath.row]
                self.getTeamPreviewAPI(team_id: breakUp.id ?? "", userId: Constants.kAppDelegate.user?.id ?? "", team: breakUp)
            }
        
        }
        else if btnStats.isSelected == true {
            let player = self.arrSeriesPlayers?[indexPath.row]
            if player?.playerBreckup != nil {
                let vc = PlayerPointsBreakupVC(nibName:"PlayerPointsBreakupVC", bundle:nil)
                vc.playerId = self.arrSeriesPlayers?[indexPath.row].player_id ?? 0
                vc.modalPresentationStyle = .custom
                self.present(vc, animated: true)
            }else{
                AppManager.showToast(ConstantMessages.PLAYER_STATS_NOT_AVL, view: self.view)
            }
        }
        else if btnMyTeams.isSelected == true{
            self.showTeamPreview(index: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if btnMyTeams.isSelected{
//            if let team = self.arrTeamList?[indexPath.row]{
//                if team.lineUpPlayerNotAnnounced > 0{
//                    return 195 + ((team.boosterDetails?.isEmpty == true) ? 0 : 30)
//                }
//            }
//            return 175 + ((self.arrTeamList?[indexPath.row].boosterDetails?.isEmpty == true) ? 0 : 30)
//        }
        if btnStats.isSelected{
            return 70
        }
        if btnScoreCard.isSelected{
            return UITableView.automaticDimension
        }
        return UITableView.automaticDimension
    }
    
}
extension LiveContestViewController{
    func getContestListByMatch (){
        let params:[String:String] = ["user_id":Constants.kAppDelegate.user?.id ?? "",
                                      "match_id":String(GDP.selectedMatch?.match_id ?? 0),
                                      "series_id":String(GDP.selectedMatch?.series_id ?? 0)
        ]
        
        let url = URLMethods.BaseURL + URLMethods().getContestListByMatch

        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                if result != nil {
                    let data = result?.object(forKey: "results") as? [[String:Any]]
                        if data != nil{
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                                  let tblData = try? JSONDecoder().decode([Contest].self, from: jsonData)else {return }
                            self.arrContests = tblData
                            self.tblContests.reloadData()
                            
                        }
                }
                
                if let teamCount = result?.object(forKey: "my_teams") as? Int{
                    GlobalDataPersistance.shared.myTeamCount = teamCount
                    if teamCount > 0{
                        self.btnMyTeams.setTitle("MY TEAMS (\(teamCount))", for: .normal)
                    }else{
                        self.btnMyTeams.setTitle("MY TEAM", for: .normal)
                    }
                }
                
                if let contestCount = result?.object(forKey: "my_contests") as? Int{
                    GlobalDataPersistance.shared.myContestCount = contestCount

                    if contestCount > 0{
                        self.btnSelfContents.setTitle("MY CONTESTS (\(contestCount))", for: .normal)
                    }else{
                        self.btnSelfContents.setTitle("MY CONTESTS", for: .normal)
                    }
                }
            }
            
            else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
            AppManager.stopActivityIndicator(self.view)
            self.refreshControl.endRefreshing()
        }
        AppManager.startActivityIndicator(sender: self.view)
    }
    
    func getJoinedContests (){
        let params:[String:String] = ["user_id":Constants.kAppDelegate.user?.id ?? "",
                                      "match_id":String(GDP.selectedMatch?.match_id ?? 0),
                                      "series_id":String(GDP.selectedMatch?.series_id ?? 0)
        ]
        
        let url = URLMethods.BaseURL + URLMethods().getJoinedContests

        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                if result != nil {
                    let data = result?.object(forKey: "results") as? [[String:Any]]
                        if data != nil{
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                                  let tblData = try? JSONDecoder().decode([JoinedContest].self, from: jsonData)else {return }
                            self.arrJoinedContests = tblData
                            
                            for i in 0..<(self.arrJoinedContests?.count ?? 0){
                                var contest = self.arrJoinedContests?[i]
                                var contestData = contest?.contestData
                                contestData?.is_joined = contest?.is_joined
                                contest?.contestData = contestData
                                var arrTeams = contest?.teams
                                arrTeams = arrTeams?.sorted(by: { ($0.rank ?? 0) < ($1.rank ?? 0) })
                                contest?.teams = arrTeams
                                self.arrJoinedContests?[i] = contest!
                            }
                            
                            if (self.arrJoinedContests?.count ?? 0) > 0{
                                self.btnSelfContents.setTitle("My Contests (\(self.arrJoinedContests?.count ?? 0))", for: .normal)
                            }
                            
                            if GDP.selectedMatch?.match_status?.uppercased() == "FINISHED" || GDP.selectedMatch?.match_status?.uppercased() == "COMPLETED"{
                                if GDP.selectedMatch?.win_amount ?? 0 > 0{
                                    self.populatePrizeView()
                                }
                            }
                           
                            
                            self.tblContests.reloadData()
                            
                        }
                    
                    if let teamCount = result?.object(forKey: "my_team_count") as? Int{
                        GlobalDataPersistance.shared.myTeamCount = teamCount
                        if teamCount > 0{
                            self.btnMyTeams.setTitle("My Teams (\(teamCount))", for: .normal)
                        }else{
                            self.btnMyTeams.setTitle("My Team", for: .normal)
                        }
                    }
                }
            }
            
            else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
            AppManager.stopActivityIndicator(self.view)
            self.refreshControl.endRefreshing()
        }
        AppManager.startActivityIndicator(sender: self.view)
    }
    
    func getTeamName(teamId:Int) -> String{
        if (GDP.selectedMatch?.localteam_id ?? 0) == teamId{
            return GDP.selectedMatch?.localteam ?? ""
        }else{
            return GDP.selectedMatch?.visitorteam ?? ""
        }
    }
    
    func getTeamLists (){
        
        WebCommunication.shared.getTeams(hostController: self, match_id: (GDP.selectedMatch?.match_id ?? 0), series_id: (GDP.selectedMatch?.series_id ?? 0), showLoader: true) { team in
            if let tblData = team{
                self.arrTeamList = tblData
                for i in 0..<(self.arrTeamList?.count ?? 0){
                    var team = self.arrTeamList?[i]
                    let notAnnouncedPlayers = team?.seriesPlayer?.filter({($0.is_playing ?? false) == false})
                    team?.lineUpPlayerNotAnnounced = notAnnouncedPlayers?.count ?? 0
                    self.arrTeamList?[i] = team!
                }
                self.tblContests.reloadData()
            }
            self.refreshControl.endRefreshing()
        }
    }
    
    func getSeriesPlayerList (){
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
                    let teams = result?.object(forKey: "my_teams") as? [[String:Any]]

                        if data != nil{
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                                  let tblData = try? JSONDecoder().decode([Player].self, from: jsonData)else {return }
                            
                            if let teams = teams{
                                guard let teamsJsonData = try? JSONSerialization.data(withJSONObject: teams, options: .prettyPrinted),
                                      let teamsTblData = try? JSONDecoder().decode([JoinedTeam].self, from: teamsJsonData)else {return }
                                
                                self.arrMyTeams = teamsTblData
                                
                                self.arrAllSeriesPlayers = tblData
                                self.arrSeriesPlayers = tblData
                                self.arrSeriesPlayers = self.arrSeriesPlayers?.sorted(by: {($0.points ?? 0) > ($1.points ?? 0)})
                                
                                self.arrMyTeams = self.arrMyTeams?.sorted(by: {($0.team_count ?? 0) < ($1.team_count ?? 0)})

                                if teamsTblData.count > 1{
                                    self.populateHighLightedPlayersForTeam(team: self.arrMyTeams!.first!)
                                }

                            }
                            
                            self.tblContests.reloadData()
                            
                        }
                    
                    if let teamCount = result?.object(forKey: "my_team_count") as? Int{
                        GlobalDataPersistance.shared.myTeamCount = teamCount
                        if teamCount > 0{
                            self.btnMyTeams.setTitle("My Teams (\(teamCount))", for: .normal)
                        }else{
                            self.btnMyTeams.setTitle("My Team", for: .normal)
                        }
                    }
                }
            }
            
            else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
            AppManager.stopActivityIndicator(self.view)
            self.refreshControl.endRefreshing()
        }
        AppManager.startActivityIndicator(sender: self.view)
    }
    
    func dreamTeam (){
        let params:[String:Any] = ["series_id":GDP.selectedMatch?.series_id ?? 0,
                                   "match_id":GDP.selectedMatch?.match_id ?? 0,
        ]
        
        let url = URLMethods.BaseURL + URLMethods().dreamTeam

        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                if result != nil {
                    let rData = result?.object(forKey: "results") as? [String:Any]
                    let data = rData?["player_details"] as? [[String:Any]]
                        if data != nil{
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                                  let tblData = try? JSONDecoder().decode([Player].self, from: jsonData)else {return }
                            let arrPlayers = tblData
                            var selectedPlayers = SelectedPlayerTypes()
                            var arrPlayerData = [PlayerDetails]()
                            
                            if arrPlayers.count > 0
                            {
                                for index  in 0..<arrPlayers.count {
                                    let player = arrPlayers[index]
                                    var playerData = PlayerDetails()
                                    playerData.name = "\(player.player_name ?? "")"
                                    playerData.credits = "\(self.getDouble(for: player.player_credit as Any))"
                                    playerData.role = "\(player.playing_role ?? "")"
                                    playerData.points = "\(self.getDouble(for: player.points as Any))"
                                    playerData.image = "\(player.image ?? "")"
                                    playerData.player_id = "\(player.player_id ?? 0)"
                                    playerData.inDreamTeam = true
                                    playerData.is_local_team = "\(player.team_id ?? 0)".caseInsensitiveCompare("\(GDP.selectedMatch?.localteam_id ?? 0)") == .orderedSame
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
                            let arrWicketKeeper = arrPlayerData.filter({$0.role.contains(GDP.wc)})
                            
                            selectedPlayers.batsman = arrBatsman.count
                            selectedPlayers.allrounder = arrAllRoud.count
                            selectedPlayers.bowler =  arrBowlers.count
                            selectedPlayers.wicketkeeper = arrWicketKeeper.count
                            
                            let captain = arrPlayerData.filter({$0.player_id == "\((rData?["captain_player_id"] as? Int) ?? 0)"})
                            let viceCaptain = arrPlayerData.filter({$0.player_id == "\((rData?["vice_captain_player_id"] as? Int) ?? 0)"})
                            
                            let vc = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "TeamPreviewVC") as! TeamPreviewVC

                            vc.teamNumber = "DreamTeam"
                            vc.strFromVC = "CompletedLeaderboard"
                            vc.playerDetails = arrPlayerData
                            vc.selectedPlayers = selectedPlayers
                            vc.teamName = "Dream Team"
                            vc.strCaptainId = captain.count > 0 ? captain[0].player_id : ""
                            vc.strViceCaptainId = viceCaptain.count > 0 ? viceCaptain[0].player_id : ""
                            vc.strPointsSuffix = "Pts"
                            vc.modalPresentationStyle = .custom
                            vc.userTeamName = "Dream Team"
                            vc.isShowTopPlayer = true
                            vc.isDreamTeam = true
                            UIApplication.getTopMostViewController()?.present(vc, animated: true, completion: nil)
                            
                            self.tblContests.reloadData()
                            
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
    
    
    func getTeamPreviewAPI (team_id: String, userId: String, team: JoinedTeam){
        
        WebCommunication.shared.dailyContestTeamPreview(hostController: self, seriesId: "\(GDP.selectedMatch?.series_id ?? 0)", matchId: (GDP.selectedMatch?.match_id ?? 0), teamId: team_id, userId: userId, showLoader: true) { teamData in
         
            guard let dictTeam = teamData else { return }
            
            var arrPlayerData = [PlayerDetails]()
            var selectedPlayers = SelectedPlayerTypes()
            
            let arrPlayers = dictTeam.seriesPlayer
            
            if arrPlayers?.count ?? 0 > 0
            {
                for index  in 0..<arrPlayers!.count {
                    let player = arrPlayers![index]
                    var playerData = PlayerDetails()
                    playerData.name = "\(player.name ?? "")"
                    playerData.credits = "\(self.getDouble(for: player.credits as Any))"
                    playerData.role = "\(player.role ?? "")"
                    playerData.points = "\(self.getDouble(for: player.points as Any))"
                    playerData.image = "\(player.image ?? "")"
                    playerData.player_id = "\(player.player_id ?? 0)"
                    playerData.is_local_team = "\(player.team_id ?? 0)".caseInsensitiveCompare("\(GDP.selectedMatch?.localteam_id ?? 0)") == .orderedSame
                    playerData.is_playing = player.is_playing ?? false
                    playerData.isBoosted = player.isBoosted ?? false
                    playerData.isDebuffed = player.isDebuffed ?? false
                    playerData.boosterDetails = player.boosterDetails ?? []
                    playerData.debuffedDetails = player.debuffDetails ?? []

                    arrPlayerData.append(playerData)
                }
                
            }
            
            for index  in 0..<arrPlayerData.count {
                let player = arrPlayerData[index]
                if player.role.contains(GDP.wc) {
                    arrPlayerData[index].role = GDP.wc
                }
            }
            
            selectedPlayers.batsman = Int("\(dictTeam.total_batsman ?? 0)") ?? 0
            selectedPlayers.allrounder = Int("\(dictTeam.total_allrounder ?? 0)") ?? 0
            selectedPlayers.bowler =  Int("\(dictTeam.total_bowler ?? 0)") ?? 0
            selectedPlayers.wicketkeeper = Int("\(dictTeam.total_wicketkeeper ?? 0)") ?? 0
            
            let captain = arrPlayerData.filter({$0.player_id == "\(dictTeam.captain_player_id ?? "0")"})
            let viceCaptain = arrPlayerData.filter({$0.player_id == "\(dictTeam.vice_captain_player_id ?? "0")"})
            
            let vc = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "TeamPreviewVC") as! TeamPreviewVC

            vc.teamNumber = "\(dictTeam.team_number ?? 0)"
            vc.strFromVC = "CompletedLeaderboard"
            
            vc.otherUserId = userId
            vc.playerDetails = arrPlayerData
            vc.selectedPlayers = selectedPlayers
            vc.teamName = "\(team.username ?? "") Team \(team.team_count ?? 0)"
            vc.strCaptainId = captain.count > 0 ? captain[0].player_id : ""
            vc.strViceCaptainId = viceCaptain.count > 0 ? viceCaptain[0].player_id : ""
            vc.strPointsSuffix = "Pts"
            vc.modalPresentationStyle = .custom
            vc.userTeamRank = "\((team.rank ?? 0).forTrailingZero())"
            vc.userTeamName = "\(team.username ?? "")-\(team.team_count ?? 0)"
            vc.TeamData = dictTeam
            vc.validTeamID = dictTeam.id ?? ""
            vc.delegate = self
            UIApplication.getTopMostViewController()?.present(vc, animated: true, completion: nil)
            
        }
    }
    
    
    func getTeamScoreFromData(scores:ScoreDetails) -> String{
           
           var str = ""
           for index  in 0..<(scores.records?.count ?? 0){
               let boardDetails = scores.records?[index]
               if boardDetails?.totalInningScore != nil{
                   str = boardDetails?.totalInningScore ?? ""
                   break
               }
           }
           return str
       }
    
    func NewBoard(name:String, value:String, type:String) -> Record{
        var newBoard = Record(name: name)
        newBoard.name = name
        newBoard.runScored = value
        newBoard.playerType = type

        return newBoard
    }
//
    func getNewSection(name:String, field1:String, field2:String, field3:String, field4:String, field5:String) -> Record{
        var newBoard = Record(name: name)
        newBoard.name = name
        newBoard.name = name
        newBoard.runScored = field1
        newBoard.ballFaced = field2
        newBoard.s4 = field3
        newBoard.s6 = field4
        newBoard.battingStrikeRate = field5

        return newBoard
    }

    func addScoreParams(){
        for index  in 0..<(self.arrScoreBoard?.count ?? 0){
            if var scoreBoard1 = self.arrScoreBoard?[index]{
                scoreBoard1.totalInningScore = self.getTeamScoreFromData(scores: scoreBoard1)
                scoreBoard1.inningNumber = scoreBoard1.id?.inningNumber ?? 0
                scoreBoard1.players = [Record]()
                
                scoreBoard1.players?.append(contentsOf: self.getFinalPlayersFrom(records: scoreBoard1.batsman ?? [Record](), key: "Batter"))
                scoreBoard1.players?.append(NewBoard(name: "EXTRAS \n(nb \(scoreBoard1.noBalls ?? 0),wd \(scoreBoard1.wideBalls ?? 0),b \(scoreBoard1.bye ?? 0),lb \(scoreBoard1.legBye ?? 0))", value: "\((scoreBoard1.totalExtraRuns?.value as? String) ?? "")", type: "extra"))
                scoreBoard1.players?.append(NewBoard(name: "TOTAL", value: "\(scoreBoard1.totalInningScore ?? "")", type: "extra"))
                if let yetToBat = scoreBoard1.records?.filter({$0.notBat == true}){
                    
                    let name = yetToBat.map { $0.name }
                    scoreBoard1.players?.append(NewBoard(name: "YET TO BAT", value: "\(name.joined(separator: ","))", type: "extra"))

                }
                
                let bowlerSection = getNewSection(name: "BOWLER", field1: "O", field2: "M", field3: "R", field4: "W", field5: "Eco")
                scoreBoard1.players?.append(bowlerSection)
               
                
                scoreBoard1.players?.append(contentsOf: self.getFinalPlayersFrom(records: scoreBoard1.bowlers ?? [Record](), key: "Bowler"))

                self.arrScoreBoard?[index] = scoreBoard1
            }
        }
    }
    
    
    func getFinalPlayersFrom(records:[Record], key:String) -> [Record]{
        
        var arrRecords = records
        for index  in 0..<(arrRecords.count){
            var model = arrRecords[index]
            model.playerType = key
            
            arrRecords[index] = model
        }
        
        return arrRecords
    }
    
    func getScoreBoard (){
        let params:[String:Any] = ["series_id":GDP.selectedMatch?.series_id ?? 0,
                                   "match_id":GDP.selectedMatch?.match_id ?? 0,
        ]
        
        let url = URLMethods.BaseURL + URLMethods().getScoreboard

        ApiClient.init().postRequest(params, request: url, view: self.view) { [self] (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                if result != nil {
                    let data = result?.object(forKey: "results") as? [[String:Any]]
                        if data != nil{
                            
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted)
                            else {return }
                                                    
                            do {
                                let tblData = try JSONDecoder().decode([ScoreDetails].self, from: jsonData)
                                self.arrScoreBoard = tblData
                                self.addScoreParams()
                                self.arrScoreBoard?.sort { (first, second) -> Bool in
                                    return first.inningNumber < second.inningNumber
                                }
                                self.loadFirstTeamScoreBoard()

                                self.tblContests.reloadData()
                                if self.viewLiveScore != nil{
                                    if GDP.selectedMatch?.match_status?.uppercased() ?? "" == "LIVE" || GDP.selectedMatch?.match_status?.uppercased() ?? "" == "IN PROGRESS" || GDP.selectedMatch?.match_status?.uppercased() ?? "" == "RUNNING"{
                                        self.viewLiveScore.updateView(selectedMatch: GDP.selectedMatch)
                                    }
                                }
                                
                            }catch {
                                print("error: ", error)
                            }
                        
                        }
                    
                    self.tblContests.reloadData()

                }
            }
            
            else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
            AppManager.stopActivityIndicator(self.view)
            self.refreshControl.endRefreshing()
        }
        AppManager.startActivityIndicator(sender: self.view)
    }
    
    func loadFirstTeamScoreBoard(){
        if (self.arrScoreBoard?.count ?? 0) > 0{
            var  board = arrScoreBoard?[self.selectedBoard]
            board?.isSelected = true
            self.arrScoreBoard?[self.selectedBoard] = board!
        }

    }
    
//    func showRugbyTeamPreview(team: Team, teamRank: String = "") {
//    
//        let vc = Constants.KRugbyStoryboard.instantiateViewController(withIdentifier: "RugbyPreviewTeamVC") as! RugbyPreviewTeamVC
//        vc.strFromVC = "LiveLeaderboard"
//        vc.arrPlayerTypes = [PlayerType(type: "Active Team", players: team.seriesPlayer ?? []),
//                             PlayerType(type: "Bench Team", players: team.benchPlayer ?? [])]
//        vc.strCaptainId = team.captain_player_id ?? ""
//        vc.strViceCaptainId = team.vice_captain_player_id ?? ""
//        vc.teamName = "\(Constants.kAppDelegate.user?.username ?? "") Team \(team.team_number ?? 1)"
//        vc.teamData = team
//        vc.teamRank = teamRank
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
    
    func showTeamPreview(index: Int) {
        
        let previewTeam = self.arrTeamList?[index]
        
        WebCommunication.shared.dailyContestTeamPreview(hostController: self, seriesId: "\(GDP.selectedMatch?.series_id ?? 0)", matchId: (GDP.selectedMatch?.match_id ?? 0), teamId: previewTeam?.id ?? "", userId: "", showLoader: true) { team in
         
            guard let dataDict = team else { return }
            
            let vc = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "TeamPreviewVC") as! TeamPreviewVC

            vc.teamNumber = "\(dataDict.team_number ?? 1)"
            vc.TeamData = dataDict
            vc.strFromVC = "LiveLeaderboard"
            vc.isLiveMatch = true
            
            let arrPlayers = dataDict.seriesPlayer
            var arrPlayerData = [PlayerDetails]()
            var selectedPlayers = SelectedPlayerTypes()
            
            if arrPlayers?.count ?? 0 > 0
            {
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
                    playerData.isBoosted = player.isBoosted ?? false
                    playerData.isDebuffed = player.isDebuffed ?? false
                    playerData.boosterDetails = player.boosterDetails ?? []
                    playerData.debuffedDetails = player.debuffDetails ?? []

                    arrPlayerData.append(playerData)
                }
            }
            
            selectedPlayers.batsman = Int("\(dataDict.total_batsman ?? 0)") ?? 0
            selectedPlayers.allrounder = Int("\(dataDict.total_allrounder ?? 0)") ?? 0
            selectedPlayers.bowler =  Int("\(dataDict.total_bowler ?? 0)") ?? 0
            selectedPlayers.wicketkeeper = Int("\(dataDict.total_wicketkeeper ?? 0)") ?? 0
            
            let captain = arrPlayerData.filter({$0.player_id == "\(dataDict.captain_player_id ?? "0")"})
            let viceCaptain = arrPlayerData.filter({$0.player_id == "\(dataDict.vice_captain_player_id ?? "0")"})

            
            vc.otherUserId = Constants.kAppDelegate.user?.id ?? ""

            vc.playerDetails = arrPlayerData
            vc.selectedPlayers = selectedPlayers
            vc.teamName = "\(Constants.kAppDelegate.user?.username ?? "") Team \(index + 1)"
            vc.strCaptainId = captain.count > 0 ? captain[0].player_id : ""
            vc.strViceCaptainId = viceCaptain.count > 0 ? viceCaptain[0].player_id : ""
            vc.strPointsSuffix = "Cr"
            vc.modalPresentationStyle = .custom
            vc.isEditTeam = true
            vc.teamEditIndex = index
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }
}

extension LiveContestViewController{

    func getShortNameFromString(fullName:String) -> String{
        if GDP.selectedMatch?.localteam == fullName{
            return GDP.selectedMatch?.localteam_short_name ?? ""
        }
        if GDP.selectedMatch?.visitorteam == fullName{
            return GDP.selectedMatch?.visitorteam_short_name ?? ""
        }
        
        return ""
    }
    
    
    func resetAllPlayers(){
        for i in 0..<(self.arrSeriesPlayers?.count ?? 0) {
            var player = self.arrSeriesPlayers?[i]
            player?.isHighLight = false
            if let player = player{
                self.arrSeriesPlayers?[i] = player
            }
        }
    }
    
    func populateHighLightedPlayersForTeam(team:JoinedTeam){
        self.currentHighLightedTeam = team
        resetAllPlayers()
        
        for i in 0..<(self.arrSeriesPlayers?.count ?? 0) {
            var player = self.arrSeriesPlayers?[i]
            player?.isHighLight = false
            if let playerTeams = player?.team_number{
                if playerTeams.contains(team.team_count ?? 0){
                    player?.isHighLight = true
                }
            }
            
            if let player = player{
                self.arrSeriesPlayers?[i] = player
            }
        }
        
        
        self.arrSeriesPlayers?.sort(by: {($0.isHighLight == true) && ($1.isHighLight == false)})
        self.tblContests.reloadData()
    }
}

extension LiveContestViewController : EditTeamDelegate
{
    func editMyTeam(index: Int) {
        
        let dataDict = self.arrTeamList?[index]
        let navData = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "CreateTeamViewController") as! CreateTeamViewController
        //navData.setSelectTeamDelegate = true
        navData.isFromEdit = "Edit"
        navData.TeamData = dataDict
        navData.strCaptainID = "\(dataDict?.captain_player_id ?? "0")"
        navData.strViceCaptainID = "\(dataDict?.vice_captain_player_id ?? "0")"
        navData.teamID = "\(dataDict?.team_id ?? "0")"
        navData.strTeamNumber = "\(dataDict?.team_number ?? 1)"
        self.navigationController?.pushViewController(navData, animated: true)
        
    }
}
extension LiveContestViewController:SocketHandlerDelegate {
    
    func handleDraftSocketRoom(data: [Any], ack: SocketAckEmitter) {
        //print("------------------------------------Join  Draft Room------------------------------------")
    }
    
    func handleActiveDraftSocketListners(data: [Any], ack: SocketAckEmitter) {
       // print(data);
        if self.selectedTab == btnScoreCard{
            self.btnTabActionPressed(selectedTab)
        }else{
            getTeamScore()
        }
    }
    
    func getTeamScore() {
        
        WebCommunication.shared.getTeamScore(hostController: self, series_id: GDP.selectedMatch?.series_id ?? 0, match_id: GDP.selectedMatch?.match_id ?? 0, showLoader: false) { score in
            self.matchTotalScore = score
            self.lblLocalTeamScore.text = score?.local_team_score ?? ""
            self.lblVisitorTeamScore.text = score?.visitor_team_score ?? ""
            
            if GDP.selectedMatch?.match_status?.uppercased() ?? "" == "LIVE" || GDP.selectedMatch?.match_status?.uppercased() ?? "" == "RUNNING" || GDP.selectedMatch?.match_status?.uppercased() ?? "" == "IN PROGRESS"{
                self.lblMatchStatus.text = "Live"
                self.viewLiveIndicator.isHidden = false
                self.lblCommentScore.text = score?.comment ?? ""
                self.highLightBattingBowlingTeams(score: score)
                
            }else{
                
                self.viewLiveIndicator.isHidden = true
                self.lblMatchStatus.text = GDP.selectedMatch?.match_status?.capitalized ?? ""
                self.lblCommentScore.text = score?.finalComment ?? ""
            }
            self.lblLocalTeamScore.text = score?.local_team_score ?? ""
            self.lblVisitorTeamScore.text = score?.visitor_team_score ?? ""
            
            self.getScoreBoard()
        }
    }
}

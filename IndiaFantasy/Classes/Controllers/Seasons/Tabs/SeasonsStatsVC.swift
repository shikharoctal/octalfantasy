//
//  SeasonsStatsVC.swift
//  India’s fantasy
//
//  Created by admin on 24/04/23.
//

import UIKit
import DropDown

class SeasonsStatsVC: UIViewController {
    
    @IBOutlet weak var navigationView: SeasonNavigation!
    @IBOutlet weak var tblStats: UITableView!
    
    @IBOutlet weak var viewTabs: UIView!
    @IBOutlet weak var viewGeneral: UIView!
    @IBOutlet weak var btnGeneral: UIButton!
    
    @IBOutlet weak var viewPoints: UIView!
    @IBOutlet weak var btnPoints: UIButton!
    
    @IBOutlet weak var viewTransfers: UIView!
    @IBOutlet weak var btnTransfers: UIButton!
    
    @IBOutlet weak var viewBoosters: UIView!
    @IBOutlet weak var btnBoosters: UIButton!
    
    @IBOutlet weak var viewTopHeader: UIView!
    @IBOutlet weak var imgHeader: UIImageView!
    @IBOutlet weak var lblPointsHeader: UILabel!
    @IBOutlet weak var lblSubtitleHeader: UILabel!
    @IBOutlet weak var lblBottomHeader: UILabel!
    @IBOutlet weak var btnTeam: UIButton!
    
    private let cellId = "SeasonsStatsTVCell"
    private let historyCellId = "StatsHistoryTVCell"
    private let boosterCellId = "BoostersHistoryTVCell"
    
    private var topPlayers: [TopPlayers] = [] {
        didSet {
            if topPlayers.count == 0 {
                tblStats.setEmptyMessage(ConstantMessages.NotFound)
            }else {
                tblStats.restoreEmptyMessage()
            }
            tblStats.reloadData()
        }
    }
    private var arrMatch: [LeagueStatsMatch] = [] {
        didSet {
            if arrMatch.count == 0 {
                if GDP.leagueType == "fun" {
                    tblStats.setEmptyMessage(btnPoints.isSelected ? ConstantMessages.NoPointsFound : ConstantMessages.UnlimitedTransfers)
                }else {
                    tblStats.setEmptyMessage(btnPoints.isSelected ? ConstantMessages.NoPointsFound : ConstantMessages.NoTransfersFound)
                }
                
            }else {
                tblStats.restoreEmptyMessage()
            }
            tblStats.reloadData()
        }
    }
    
    private var arrBoosters: [BoostersHistory] = [] {
        didSet {
            if arrBoosters.count == 0 {
                tblStats.setEmptyMessage(ConstantMessages.NoBoosterHistoryFound)
            }else {
                tblStats.restoreEmptyMessage()
            }
            tblStats.reloadData()
        }
    }
    
    var arrLeagueMyteam = [LeagueMyTeam]() {
        didSet {
            btnTeam.isHidden = arrLeagueMyteam.isEmpty ? true : false
        }
    }
    
    var fromCreateTeam = false
    
    var teamNumber: Int = 0
    
    var isFromNotification = false
    var selectionTab = UIButton()
    
    private var refreshControl = UIRefreshControl()
    private var currentPage = 1
    private var totalBoostersCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationView()
        setupTableView()
        setupRefreshControl()
        addNotificationObservers()
        
        viewTabs.isHidden = fromCreateTeam ? true : false
        
        self.selectionTab = fromCreateTeam ? btnTransfers : btnGeneral
        //btnTabActionPressed(fromCreateTeam ? btnTransfers : btnGeneral)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.isFromNotification == true{
            self.isFromNotification = false
        }else{
            btnTabActionPressed(self.selectionTab)
        }
    }
    
    func setupNavigationView() {
        
        navigationView.setupUI(title: GDP.leagueName, hideBackBtn: fromCreateTeam ? false : true)
    }
    
    func setupTableView() {
        
        let nib = UINib(nibName: cellId, bundle: nil)
        tblStats.register(nib, forCellReuseIdentifier: cellId)
        
        let nib1 = UINib(nibName: historyCellId, bundle: nil)
        tblStats.register(nib1, forCellReuseIdentifier: historyCellId)
        
        let nib2 = UINib(nibName: boosterCellId, bundle: nil)
        tblStats.register(nib2, forCellReuseIdentifier: boosterCellId)
        
        tblStats.contentInset = .init(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    //MARK: - Setup Refresh Control
    private func setupRefreshControl() {
        
        refreshControl = UIRefreshControl()
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: attributes)
        refreshControl.addTarget(self, action: #selector(getDataFromServer), for: .valueChanged)
        refreshControl.tintColor = .white
        tblStats.refreshControl = refreshControl
    }
    
    @objc func getDataFromServer() {
        
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
        
        btnTabActionPressed(self.selectionTab)
    }
    
    
    @IBAction func btnTabActionPressed(_ sender: UIButton) {
        
        btnGeneral.isSelected = false
        btnPoints.isSelected = false
        btnTransfers.isSelected = false
        btnBoosters.isSelected = false
        
        tblStats.reloadData()
        
        viewGeneral.backgroundColor = UIColor.clear
        viewPoints.backgroundColor = UIColor.clear
        viewTransfers.backgroundColor = UIColor.clear
        viewBoosters.backgroundColor = UIColor.clear
        
        sender.isSelected = true
        self.selectionTab = sender
        tblStats.backgroundColor = .clear
        
        if sender == btnGeneral {
            viewGeneral.backgroundColor = UIColor.appRedColor
            viewTopHeader.isHidden = true
            getLeagueTopPlayers()
        }
        else if sender == btnPoints {
            viewPoints.backgroundColor = UIColor.appRedColor
            viewTopHeader.isHidden = false
            imgHeader.image = UIImage(named: "Points_ic")
            lblSubtitleHeader.text = "Points Scored"
            lblBottomHeader.text = "Points History"
            getLeagueDetail()
        }
        else if sender == btnTransfers {
            viewTransfers.backgroundColor = UIColor.appRedColor
            viewTopHeader.isHidden = false
            imgHeader.image = UIImage(named: "Transfers_ic")
            lblSubtitleHeader.text = "Transfers Left"
            lblBottomHeader.text = "Transfers History"
            getLeagueDetail()
        }
        else {
            viewBoosters.backgroundColor = UIColor.appRedColor
            viewTopHeader.isHidden = true
            currentPage = 1
            tblStats.backgroundColor = .Color.footerBackground.value
            getBoostersHistory()
        }
        
        tblStats.reloadData()
    }
    
    @IBAction func btnSelectTeamPressed(_ sender: UIButton) {
        
        let dropDown = DropDown()
        
        // The view to which the drop down will appear on
        dropDown.anchorView = sender // UIView or UIBarButtonItem
        dropDown.textFont = UIFont(name: "Gilroy-Regular", size: 12.0)!
        
        var arrTeam = [String]()
        for team in arrLeagueMyteam {
            arrTeam.append("Team \(team.teamCount ?? 0)")
        }
        dropDown.dataSource = arrTeam
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            
            self.btnTeam.setTitle("\(item) ", for: .normal)
            self.teamNumber = arrLeagueMyteam[index].teamCount ?? 0
            self.getMatchPointsTransfers()
            
            dropDown.hide()
        }
        dropDown.show()
    }
    
    func showTeamPreview(team: Team, localTeam: String, visitorTeam: String) {
        
        let dataDict = team
        let vc = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonTeamPreviewVC") as! SeasonTeamPreviewVC

        vc.teamNumber = "\(dataDict.team_number ?? 1)"
        vc.strFromVC = "Points"
        
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
        vc.teamName = "\(Constants.kAppDelegate.user?.username ?? "") (Team\(dataDict.team_number ?? 1))"
        vc.strCaptainId = captain.count > 0 ? captain[0].player_id : ""
        vc.strViceCaptainId = viceCaptain.count > 0 ? viceCaptain[0].player_id : ""
        vc.strPointsSuffix = "Cr"
        vc.totalPoints = dataDict.total_point ?? 0
        vc.userTeamRank = ""
        vc.localTeamShort = localTeam
        vc.visitorTeamShort = visitorTeam
        vc.actualPoints = dataDict.actualPoints ?? 0
        //
        vc.modalPresentationStyle = .custom
        self.present(vc, animated: true, completion: nil)
    }
    
}

//MARK: - Table Delegate and DataSource Method
extension SeasonsStatsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if btnGeneral.isSelected == true {
            return topPlayers.count
            
        } else if btnBoosters.isSelected == true {
            return arrBoosters.count
        }

        return arrMatch.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if btnGeneral.isSelected == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SeasonsStatsTVCell
            
            let topPlayer = topPlayers[indexPath.row]
            cell.lblTitle.text = topPlayer.title
            cell.lblSubtitle.text = topPlayer.subTitle
            cell.playersList = topPlayer.list ?? []
            
            cell.collectionViewPlayers.reloadData()
            
            return cell
            
        }else if btnBoosters.isSelected == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: boosterCellId, for: indexPath) as! BoostersHistoryTVCell
            cell.setData = arrBoosters[indexPath.row]
            return cell
            
        }else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: historyCellId, for: indexPath) as! StatsHistoryTVCell
            
            let match = arrMatch[indexPath.row]
            cell.isTypePoints = btnPoints.isSelected
            cell.setData = match
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if btnPoints.isSelected {
            let match = arrMatch[indexPath.row]
            getTeamPreviewData(matchId: match.matchID ?? 0, localTeam: match.localteamShortName ?? "", visitorTeam: match.visitorteamShortName ?? "")
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if btnGeneral.isSelected == true {
            if topPlayers[indexPath.row].list?.isEmpty == true {
                return 0
            }
        }
        
        return UITableView.automaticDimension
    }
    
    //MARK: Check TableView Scrolling To End
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == tblStats, selectionTab == btnBoosters  else {
            return
        }
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
            
            if totalBoostersCount > arrBoosters.count {
                currentPage += 1
                self.getBoostersHistory()
            }
        }
    }
}

//MARK: API Call
extension SeasonsStatsVC {
    
    func getLeagueTopPlayers() {
        
        //guard let match = GDP.selectedMatch else { return }
        
        WebCommunication.shared.getLeagueTopPlayersList(hostController: self, series_id: GDP.leagueSeriesId, showLoader: true) { topPlayers in
            
            //self.topPlayers = topPlayers ?? []
            self.topPlayers = topPlayers?.filter({$0.list?.isEmpty == false}) ?? []
            
            self.tblStats.reloadData()
        }
    }
    
    func getMatchPointsTransfers() {
        
        WebCommunication.shared.getMatchPointsTransfers(hostController: self, seriesId: GDP.leagueSeriesId, teamName: "\(teamNumber)", showLoader: true) { match in
            
            if self.btnPoints.isSelected {
                self.lblPointsHeader.text = match?.totalPoints?.formattedNumber() ?? "-"
                
            }else {
                
                if GDP.leagueType == "fun" {
                    self.lblPointsHeader.text = "Unlimited"
                }else {
                    let transferLeft =  match?.transferLeft?.formattedNumber() ?? "-"
                    let totalTransfers =  match?.totalTransfers?.formattedNumber() ?? "-"
                    let attStr = CommonFunctions.getCombinedAttributedString(first: "\(transferLeft)/", second: totalTransfers)
                    self.lblPointsHeader.attributedText = attStr
                }
            }
            
            self.arrMatch = match?.leagueStatsMatches ?? []
        }
    }
    
    func getBoostersHistory() {
        
        WebCommunication.shared.getBoosterHistory(hostController: self, seriesId: Int(GDP.leagueSeriesId) ?? 0, page: currentPage, showLoader: true) { history in
            
            if let history = history {
                if self.currentPage == 1 {
                    self.arrBoosters = history.docs ?? []
                }else {
                    self.arrBoosters += history.docs ?? []
                }
                
                self.totalBoostersCount = history.totalDocs ?? 0
            }
        }
    }
    
    func getLeagueDetail(showLoader: Bool = true) {
        
        //        guard let seriesId = GDP.selectedMatch?.series_id else { return }
        
        WebCommunication.shared.getLeagueDetail(hostController: self, seriesId: GDP.leagueSeriesId, showLoader: showLoader) { leagueDetails in
            
            guard let leagueDetails = leagueDetails else { return }
            self.arrLeagueMyteam = leagueDetails.userTeams ?? []
            self.arrLeagueMyteam = self.arrLeagueMyteam.sorted(by: {($0.teamCount ?? 0) < ($1.teamCount ?? 0)})
            
            GDP.leagueMyTeams = self.arrLeagueMyteam
            
            if !self.arrLeagueMyteam.isEmpty {
                if self.teamNumber == 0 {
                    self.teamNumber = self.arrLeagueMyteam.first?.teamCount ?? 0
                }
                
                self.btnTeam.setTitle("Team \(self.teamNumber) ", for: .normal)
                self.getMatchPointsTransfers()
            }else {
                self.arrMatch = []
            }
            
        }
    }
    
    func getTeamPreviewData(matchId: Int, localTeam: String, visitorTeam: String) {
        
        WebCommunication.shared.leagueTeamPreview(hostController: self, seriesId: GDP.leagueSeriesId, matchId: matchId, teamName: "\(teamNumber)", userId: "", showLoader: true) { team in
         
            guard let team = team, let firstTeam = team.first else {
                return
            }
            self.showTeamPreview(team: firstTeam, localTeam: localTeam, visitorTeam: visitorTeam)
        }
    }
}

//MARK: - Notification Observer
extension SeasonsStatsVC {
    
    func addNotificationObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.getNavigationNotification(notification:)), name: .MoveToLeagueStats, object: nil)
    }
    
    
    @objc func getNavigationNotification(notification: NSNotification) {
        
        isFromNotification = true
        
        if let receiveObject = notification.userInfo, let tab = receiveObject["tab"] as? Int {
            
            if let teamNumber = receiveObject["teamNumber"] as? Int {
                self.teamNumber = teamNumber
                self.btnTeam.setTitle("Team \(teamNumber) ", for: .normal)
            }
            if tab == 1{
                self.selectionTab = btnPoints
                self.btnTabActionPressed(self.selectionTab)
            }else {
                self.selectionTab = btnTransfers
                self.btnTabActionPressed(self.selectionTab)
            }
            
        }else {
            self.selectionTab = btnPoints
            self.btnTabActionPressed(self.selectionTab)
        }
    }
    
    func removeNotificationObservers() {
        print("Removed NotificationCenter Observer")
        NotificationCenter.default.removeObserver(self, name: .MoveToLeagueStats, object: nil)
    }
}

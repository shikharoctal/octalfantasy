//
//  SeasonsHomeVC.swift
//  India’s fantasy
//
//  Created by admin on 24/04/23.
//

import UIKit

class SeasonsHomeVC: UIViewController {

    @IBOutlet weak var navigationView: SeasonNavigation!
    @IBOutlet weak var tblMatches: UITableView!
    @IBOutlet weak var btnContests: UIButton!
    @IBOutlet weak var btnMakeTransfer: UIButton!
    @IBOutlet weak var btnCreateTeam: UIButton!
    
    private let cellId = "SeasonMatchCell"
    
    private var refreshControl = UIRefreshControl()
    private var leagueMatchDetails: [Match] = []
    private var availableTransfer: String = "-"
    private var teamNumber: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationView()
        setupTableView()
        addNotificationObservers()
        setupRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getDataFromServer()
    }
    
    deinit {
        removeNotificationObservers()
    }
    
    func setupNavigationView() {
        
        navigationView.setupUI(title: GDP.leagueName)
    }
    
    func setupTableView() {
        
        let nib = UINib(nibName: cellId, bundle: nil)
        tblMatches.register(nib, forCellReuseIdentifier: cellId)
    }
    
    //MARK: - Setup Refresh Control
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: attributes)
        refreshControl.addTarget(self, action: #selector(getDataFromServer), for: .valueChanged)
        refreshControl.tintColor = .white
        tblMatches.refreshControl = refreshControl
    }
    
    @objc func getDataFromServer() {
        
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
        
        getLeagueDetail()
        getLeagueMatches()
    }

    @IBAction func btnContestPressed(_ sender: UIButton) {
    
        self.tabBarController?.selectedIndex = 1
        postNotification(.MoveToMyContest, userInfo: [:])
    }    
    @IBAction func btnMakeTransferPressed(_ sender: UIButton) {
        
        self.tabBarController?.selectedIndex = 1
        postNotification(.MoveToMyTeam, userInfo: [:])
    }
    
    @IBAction func btnCreateTeamPressed(_ sender: UIButton) {
        
        let vc = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonCreateTeamVC") as! SeasonCreateTeamVC
        self.navigationController?.pushViewController(vc, animated: false)
    }
}

//MARK: - Table Delegate and DataSource Method
extension SeasonsHomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leagueMatchDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SeasonMatchCell
        
        cell.setData = leagueMatchDetails[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

//MARK: API Call
extension SeasonsHomeVC {
    
    func getLeagueDetail() {
        
        WebCommunication.shared.getLeagueDetail(hostController: self, seriesId: GDP.leagueSeriesId, showLoader: true) { leagueDetails in
            
            if let leagueDetails = leagueDetails {
                self.setupLeagueData(data: leagueDetails)
                GDP.leagueMyTeams = leagueDetails.userTeams ?? []
                self.tblMatches.reloadData()
            }
        }
    }
    
    func getLeagueMatches() {
        
        WebCommunication.shared.getLeagueMatches(hostController: self, seriesId: GDP.leagueSeriesId, showLoader: true) { match in
            self.leagueMatchDetails = match?.allMatches ?? []
            GDP.selectedMatch = match
            
            if GDP.leagueName == "" {
                GDP.leagueName = match?.series_name ?? ""
                self.setupNavigationView()
            }
            
            self.tblMatches.reloadData()
        }
    }
    
    func setupLeagueData(data: LeagueDetails) {

        if data.isMatchPlayed == false {
            self.availableTransfer = "Unlimited"
        }else {
            if GDP.leagueType == "fun" {
                self.availableTransfer = "Unlimited"
            }else {
                self.availableTransfer = (data.availableTransfer ?? 0).clean
            }
        }
        
        teamNumber = data.teamNumber ?? 1
        
        let header = SeasonHomeHeaderView.instanceFromNib() as! SeasonHomeHeaderView
        header.setupUI()
        header.setData = data

//        header.btnPoints.tag = 1
//        header.btnPoints.addTarget(self, action: #selector(btnHeaderAction(_:)), for: .touchUpInside)
//        header.btnTransfers.tag = 2
//        header.btnTransfers.addTarget(self, action: #selector(btnHeaderAction(_:)), for: .touchUpInside)
//        header.btnBoosters.tag = 3
//        header.btnBoosters.addTarget(self, action: #selector(btnHeaderAction(_:)), for: .touchUpInside)

        tblMatches.tableHeaderView = header

        if data.isTeamCreated == true {
            btnCreateTeam.isHidden = true
            btnContests.isHidden = false
            btnMakeTransfer.isHidden = false
        }else {
            btnCreateTeam.isHidden = false
            btnContests.isHidden = true
            btnMakeTransfer.isHidden = true
        }
    }
//
//    @objc func btnHeaderAction(_ sender: UIButton) {
//
//        switch sender.tag {
//        case 1:
//            self.tabBarController?.selectedIndex = 2
//            postNotification(.MoveToLeagueStats, userInfo: ["tab":1, "teamNumber": teamNumber])
//            break
//        case 2:
//            self.tabBarController?.selectedIndex = 2
//            postNotification(.MoveToLeagueStats, userInfo: ["tab":2, "teamNumber": teamNumber])
//            break
//        case 3:
//            let boostersVC = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "BoostersVC") as! BoostersVC
//            boostersVC.teamName = teamNumber
//            self.navigationController?.pushViewController(boostersVC, animated: false)
//            break
//        default:
//            break
//        }
//    }
}

//MARK: - Notification Observer
extension SeasonsHomeVC {
    
    func addNotificationObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTeamList(notification:)), name: .LeagueTeamCreation, object: nil)
    }
    
    @objc func refreshTeamList(notification: NSNotification) {
        getDataFromServer()
    }
    
    func removeNotificationObservers() {
        print("Removed NotificationCenter Observer")
        NotificationCenter.default.removeObserver(self, name: .LeagueTeamCreation, object: nil)
    }
}

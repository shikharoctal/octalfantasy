//
//  ContestViewController.swift
//  CrypTech
//
//  Created by New on 29/03/22.
//

import UIKit
import SDWebImage
import SocketIO

class ContestViewController: BaseClassWithoutTabNavigation {
    
    @IBOutlet weak var viewNoData: UIView!
    @IBOutlet weak var navigationView: CustomNavigation!
    @IBOutlet weak var lblNoData: UILabel!
    @IBOutlet weak var btnJoinContest: UIButton!
    @IBOutlet weak var tblMatches: UITableView!
    
    
    @IBOutlet weak var viewUpcoming: UIView!
    @IBOutlet weak var btnUpcoming: UIButton!
    
    @IBOutlet weak var viewLive: UIView!
    @IBOutlet weak var btnLive: UIButton!
    
    @IBOutlet weak var viewCompleted: UIView!
    @IBOutlet weak var btnCompleted: UIButton!
    
    var selectedButton:UIButton? = nil
    
    var arrJoinedMatches:[Match]? = nil
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //    self.setupUI()
        SocketIOManager.sharedInstance.delegateToHandleSocketConnection = self
        GDP.selectedMatch = nil
        let title = GDP.getFantasyTitle()
        navigationView.configureNavigationBarWithController(controller: self, title: title, hideNotification: false, hideAddMoney: true, hideBackBtn: false, titleSelectable: true)
//        navigationView.sideMenuBtnView.isHidden = false
//        navigationView.avatar.isHidden = true
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: attributes)
        refreshControl.tintColor = .white
        self.refreshControl.addTarget(self, action: #selector(self.refreshTableData(_:)), for: .valueChanged)
        tblMatches.addSubview(refreshControl)
    }
    
    func setupUI() {
        //navigationView.controller = self
        navigationView.btnBack.isHidden = true
        navigationView.sideMenuBtnView.isHidden = false
    }
    
    @objc func refreshTableData(_ sender: AnyObject) {
        self.getMatchesFromServer(withLoader: true)
    }
    
    @objc func refreshMatchStatus(notification : NSNotification)
    {
        self.getMatchesFromServer(withLoader: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        let title = GDP.getFantasyTitle()
        navigationView.btnFantasyType.setTitle(title, for: .normal)
        navigationView.completionHandler = { type in
            
            switch type {
            case "Cricket":
                GDP.switchToCricket()
            default:
                break
            }
            
            self.getMyMatchesFromServer()
        }
        
        self.getMyMatchesFromServer()
        
    }
    
    @objc func btnReminderPressed(sender:UIButton){
        //        if let match = self.arrJoinedMatches?[sender.tag]{
        //            self.saveMatch(match: match, index: sender.tag)
        //        }
        
        let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "SetRemindersVC") as! SetRemindersVC
        VC.isModalInPresentation = true
        VC.selectedMatch = self.arrJoinedMatches?[sender.tag]
        VC.completionHandler = {(match, isReminder) in
            self.arrJoinedMatches?[sender.tag] = match
            self.tblMatches.reloadData()
        }
        self.present(VC, animated: false)
    }
    
    
    @IBAction func btnTabActionPressed(_ sender: UIButton) {
        
        self.selectedButton = sender
        btnUpcoming.isSelected = false
        btnLive.isSelected = false
        btnCompleted.isSelected = false
        
        self.arrJoinedMatches?.removeAll()
        tblMatches.reloadData()
        
        viewUpcoming.backgroundColor = UIColor.clear//cellSepratorColor
        viewLive.backgroundColor = UIColor.clear//cellSepratorColor
        viewCompleted.backgroundColor = UIColor.clear//cellSepratorColor
        
        sender.isSelected = true
        
        if sender == btnUpcoming {
            GlobalDataPersistance.shared.gameType = "upcoming"
            viewUpcoming.backgroundColor = UIColor.appRedColor
        }
        else if sender == btnLive {
            GlobalDataPersistance.shared.gameType = "running"
            viewLive.backgroundColor = UIColor.appRedColor
        }
        else {
            GlobalDataPersistance.shared.gameType = "completed"
            viewCompleted.backgroundColor = UIColor.appRedColor
        }
        
        self.arrJoinedMatches?.removeAll()
        self.updateNoData()
        self.getMatchesFromServer(withLoader: true)
    }
    
    @IBAction func btnNotificationAction(_ sender: UIButton) {
        let VC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "NotificationsViewController") as! NotificationsViewController
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func btnJoinContestPressed(_ sender: Any) {
        if let tabbarController = Constants.kAppDelegate.tabbarController{
            if tabbarController.selectedIndex != 1{
                tabbarController.selectedIndex = 1
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.kNavigateToMatchList), object: nil, userInfo: nil)
            }
        }
    }
}

extension ContestViewController {
    
    func updateNoData(){
        if GlobalDataPersistance.shared.gameType == "upcoming" {
            lblNoData.text = ConstantMessages.NoUpcomingMatches
            btnJoinContest.isHidden = false
        }
        else if GlobalDataPersistance.shared.gameType == "running" {
            lblNoData.text = ConstantMessages.NoLiveMatches
            btnJoinContest.isHidden = false
        }
        else if GlobalDataPersistance.shared.gameType == "completed" {
            lblNoData.text = ConstantMessages.NoCompletedMatches
            btnJoinContest.isHidden = true
        }
    }
    
    func getMatchesFromServer(withLoader:Bool) {
        if LocationManager.sharedInstance.isPLayingInLegalState() == false {
            self.viewNoData.isHidden = true
            return
        }
        let params:[String:String] = ["status":GlobalDataPersistance.shared.gameType]
        let url = URLMethods.BaseURL + URLMethods().getJoinedMatchList
        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                if result != nil {
                    let data = result?.object(forKey: "results") as? [[String:Any]]
                    if data != nil{
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                              let tblData = try? JSONDecoder().decode([Match].self, from: jsonData)else {return }
                        self.arrJoinedMatches = tblData
                        self.tblMatches.reloadData()
                    }
                }
            }
            
            else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
            
            if (self.arrJoinedMatches?.count ?? 0) > 0{
                self.viewNoData.isHidden = true
            }else{
                self.viewNoData.isHidden = false
            }
            
            if withLoader == true{
                AppManager.stopActivityIndicator(self.view)
            }
            self.refreshControl.endRefreshing()
        }
        if withLoader == true{
            AppManager.startActivityIndicator(sender: self.view)
        }
    }
    
    func saveMatch(match:Match, index:Int) {
        
        let params = ["match_id":match.match_id ?? 0,
                      "series_id":match.series_id ?? 0
        ]
        
        ApiClient.init().postRequest(params, request: URLMethods.BaseURL + URLMethods().saveMatchReminder, view: self.view) { (msg,result) in
            if result != nil {
                if (result?.object(forKey: "success") as? Bool ?? false) == true {
                    if let matchModal = self.arrJoinedMatches?[index]{
                        var model = matchModal
                        model.is_match_reminder = true
                        self.arrJoinedMatches?[index] = model
                        self.tblMatches.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    }
                }
                else {
                    if let matchModal = self.arrJoinedMatches?[index]{
                        var model = matchModal
                        model.is_match_reminder = false
                        self.arrJoinedMatches?[index] = model
                        self.tblMatches.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    }
                }
            }else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
        }
    }
    
    func getMyMatchesFromServer (){
        let params: [String:String] = [String:String
        ]()
        
        let url = URLMethods.BaseURL + URLMethods().getMyMatchList
        
        ApiClient.init().getRequest(method: url, parameters: params, view: (self.view)!) { result in
            if result != nil {
                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "message") as? String ?? ""
                if status == true{
                    //                    let upcoming = result?.object(forKey: "upcoming") as? [[String:Any]]
                    let live = result?.object(forKey: "live") as? [[String:Any]]
                    //                    let completed = result?.object(forKey: "completed") as? [[String:Any]]
                    if let liveMatches = live{
                        
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: liveMatches, options: .prettyPrinted),
                              let tblData = try? JSONDecoder().decode([Match].self, from: jsonData)else {return }
                        
                        if tblData.count > 0{
                            self.btnTabActionPressed(self.btnLive)
                        }else{
                            self.btnTabActionPressed(self.selectedButton ?? self.btnUpcoming)
                        }
                    }else{
                        self.btnTabActionPressed(self.selectedButton ?? self.btnUpcoming)
                    }
                    
                }else{
                    AppManager.showToast(msg, view: (self.view)!)
                }
                
            }else{
                AppManager.showToast("", view: (self.view)!)
            }
            DispatchQueue.main.async {
                AppManager.stopActivityIndicator(self.view)
            }
        }
        AppManager.startActivityIndicator(sender: self.view)
    }
}

extension ContestViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrJoinedMatches?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardTVCell", for: indexPath) as! DashboardTVCell
        
        cell.selectionStyle = .none
        
        let match = self.arrJoinedMatches?[indexPath.row]
        cell.selectedMatch = match
        
        cell.lblHomeTeam.text = match?.localteam ?? ""
        cell.lblAwayTeam.text = match?.visitorteam ?? ""
        
        cell.lblHomeTeamShortName.text = match?.localteam_short_name ?? ""
        cell.lblAwayTeamShortName.text = match?.visitorteam_short_name ?? ""
        
        cell.lblMatchType.text = (match?.type?.uppercased() ?? "")
        
        if (match?.my_total_contest ?? 0) > 1{
            cell.lblTeamContests.text = String(match?.my_total_teams ?? 0) + " " + "Team" + " " + String(match?.my_total_contest ?? 0) + " " + "Contests"
        }else{
            cell.lblTeamContests.text = String(match?.my_total_teams ?? 0) + " " + "Team" + " " + String(match?.my_total_contest ?? 0) + " " + "Contest"
        }
        
        cell.lblSeriesName.superview?.roundCorners(corners: [.topLeft, .topRight], radius: 10)
        cell.lblTeamContests.superview?.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10)
        
        let matchtype = (match?.type?.uppercased() ?? "")
        cell.lblSeriesName.text = "\(match?.series_name ?? "") \(matchtype)"
        
        cell.lblRemainingTime.isHidden = true
        cell.btnLive.isHidden = true
        cell.vsIcon.isHidden = true
        cell.btnReminder.isHidden = true
        cell.lblCompletedMatchComment.isHidden = true
        cell.lblRemainingTime.text = ""
        cell.lblRemainingTime.numberOfLines = 2
        cell.lblRemainingTime.textColor = .white
        cell.lblRemainingTime.backgroundColor = .clear
        
        if GlobalDataPersistance.shared.gameType == "running" {
            cell.btnLive.isHidden = false
            cell.lblRemainingTime.text = match?.match_status ?? "Live"
        }else if GlobalDataPersistance.shared.gameType == "completed" {
            cell.vsIcon.isHidden = false
            cell.lblCompletedMatchComment.isHidden = false
            
            if (match?.match_status ?? "").caseInsensitiveCompare("finished") == .orderedSame || (match?.match_status ?? "").caseInsensitiveCompare("completed") == .orderedSame{
                cell.lblRemainingTime.text = "Completed"
                
                cell.lblCompletedMatchComment.textColor = UIColor.appThemeColor
                
                if match?.win_amount ?? 0 == 0 {
                    
                    cell.lblCompletedMatchComment.text = match?.reward
                }else {
                    cell.lblCompletedMatchComment.text = "You won \(GDP.globalCurrency)\(match?.win_amount?.rounded(toPlaces: 2) ?? 0)"
                }
                
            }else{
                cell.lblCompletedMatchComment.textColor = UIColor.appThemeColor
                cell.lblCompletedMatchComment.text = match?.match_status ?? "Completed"
                cell.lblRemainingTime.text = match?.match_status ?? "Completed"
            }
            
        }else{
            cell.btnReminder.isHidden = false
            cell.lblRemainingTime.isHidden = false
            cell.lblRemainingTime.backgroundColor = .Color.timeGreen.value
            DispatchQueue.main.async {
                
                //let strtDate = "\(match?.start_date ?? "")".components(separatedBy: "T")
                //let dataValue = "\(strtDate[0])T\(match?.start_time ?? "")"
                
                //let matchDate = CommonFunctions.getNewRemainingTimeWith(strDate : dataValue, serverDate : match?.server_time ?? "")
                if let matchDate = CommonFunctions.getDateFromString(date: match?.match_date ?? "", format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") {
                    cell.releaseDate = matchDate as NSDate
                    let elapseTimeInSeconds =  cell.releaseDate!.timeIntervalSince(Date())
                    cell.expiryTimeInterval = elapseTimeInSeconds
                    if(elapseTimeInSeconds <= 0){
                        //   cell.isUserInteractionEnabled = false
                    }
                }
            }
        }
        
        if GlobalDataPersistance.shared.gameType == "upcoming"{
            if (match?.lineup ?? false) == true
            {
                cell.lblLineUp.isHidden = false
            }
            else
            {
                cell.lblLineUp.isHidden = true
            }
        }else{
            cell.lblLineUp.isHidden = true
        }
        
        cell.btnReminder.tag = indexPath.row
        cell.btnReminder.addTarget(self, action: #selector(btnReminderPressed(sender:)), for: .touchUpInside)
        
        if (match?.is_match_reminder ?? false) == true || (match?.is_series_reminder ?? false) == true{
            cell.btnReminder.isSelected = true
        }else{
            cell.btnReminder.isSelected = false
        }
        
        cell.lblMatchType.text = ""
        
        cell.imgViewHomeTeam.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.imgViewHomeTeam.sd_setImage(with: URL(string: match?.localteam_flag ?? ""), placeholderImage: Constants.kNoImageUser)
        
        cell.imgViewAwayTeam.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.imgViewAwayTeam.sd_setImage(with: URL(string: match?.visitorteam_flag ?? ""), placeholderImage: Constants.kNoImageUser)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if GlobalDataPersistance.shared.gameType == "upcoming" {
            let match = self.arrJoinedMatches?[indexPath.row]
            let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "MatchContestViewController") as! MatchContestViewController
            VC.isMyGames = true
            GDP.selectedMatch = match
            self.navigationController?.pushViewController(VC, animated: true)
        }
        else{
            let match = self.arrJoinedMatches?[indexPath.row]
            if (match?.match_status?.uppercased() ?? "") == "CANCELLED"{
                return
            }
            let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "LiveContestViewController") as! LiveContestViewController
            GDP.selectedMatch = match
            self.navigationController?.pushViewController(VC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
        
    }
}
extension ContestViewController:SocketHandlerDelegate {
    
    func handleDraftSocketRoom(data: [Any], ack: SocketAckEmitter) {
        //print("------------------------------------Join  Draft Room------------------------------------")
    }
    
    func handleActiveDraftSocketListners(data: [Any], ack: SocketAckEmitter) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "matchStatusChanged"), object: nil, userInfo: nil)
    }
}

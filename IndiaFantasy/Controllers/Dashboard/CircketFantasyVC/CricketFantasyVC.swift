//
//  CricketFantasyVC.swift
//  IndiaFantasy
//
//  Created by Harendra Singh Rathore on 31/05/24.
//

import UIKit
import SideMenu
import SwiftyAttributes

class CricketFantasyVC: BaseClassVC {
    
    @IBOutlet weak var navigationView: CustomNavigation!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var tblMatches: UITableView!
    @IBOutlet weak var viewEmpty: UIView!
    
    var arrMyMatches:[Match]? = nil
    var arrBanners:[Banner]? = nil
    var bannerPath:String = ""
    var arrMatches:[Match]? = nil {
        didSet {
            self.tblMatches.reloadData()
        }
    }
    
    let refreshControl = UIRefreshControl()
    var seriesCricketFilterId: Int? = nil
    
    private var isShimmerEnable = true {
        didSet {
            self.tblMatches.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Constants.kAppDelegate.startSocketConnection()
        setupNavigationView()
        setupRefreshControl()
        setupTableView()
        getCommonDetails()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshLineUpAnnounced(notification:)), name: NSNotification.Name(rawValue: Constants.kRefreshLineUp), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadInitialData()
    }
    
    //MARK: - Setup Navigation View
    private func setupNavigationView() {
        navigationView.configureNavigationBarWithController(controller: self, title: "Fantasy", hideNotification: false, hideAddMoney: true, hideBackBtn: true)
        navigationView.sideMenuBtnView.isHidden = false
        navigationView.avatar.isHidden = true
        //CommonFunctions.setupSideMenu(controller: self)
    }
    
    //MARK: - Setup TableView
    private func setupTableView() {
        
        if #available(iOS 15.0, *) {
            tblMatches.sectionHeaderTopPadding = 0
        } else { 
            // Fallback on earlier versions
        }
        
        tblMatches.contentInset = .init(top: 0, left: 0, bottom: 55, right: 0)
        
        let nib = UINib(nibName: "DashboardShimmerTVCell", bundle: nil)
        tblMatches.register(nib, forCellReuseIdentifier: "DashboardShimmerTVCell")
    }
    
    //MARK: - Setup Refresh Control
    private func setupRefreshControl() {
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: attributes)
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(self.refreshTableData(_:)), for: .valueChanged)
        tblMatches.addSubview(refreshControl)
    }
    
    @objc func refreshLineUpAnnounced(notification : NSNotification) {
        self.loadInitialData()
    }
    
    @objc func refreshTableData(_ sender: AnyObject) {
        self.loadInitialData()
    }
    
    func loadInitialData(){
        if arrMatches?.isEmpty == true {
            isShimmerEnable = true
        }
    
        self.getMatchesFromServer()
    }
    
    
}

extension CricketFantasyVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
        return isShimmerEnable ? 5 : arrMatches?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard section == 0 else {
            
            let headerView = UpcomingMatchHeaderView.instanceFromNib() as! UpcomingMatchHeaderView
            headerView.filterBtn.addTarget(self, action: #selector(btnUpcomingFilterPressed(_:)), for: .touchUpInside)
            return headerView
        }
        
        let headerView = BannerHeaderView.instanceFromNib() as! BannerHeaderView
        
        headerView.arrMyMatches = self.arrMyMatches
        headerView.bannerPath = self.bannerPath
        headerView.arrBanners = self.arrBanners
        headerView.controller = self
        headerView.updateView()

        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard isShimmerEnable == false else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardShimmerTVCell", for: indexPath) as! DashboardShimmerTVCell
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardTVCell", for: indexPath) as! DashboardTVCell

        cell.selectionStyle = .none
        cell.lblRemainingTime.backgroundColor = UIColor.init(named: "03881A_gray")
        cell.lblRemainingTime.textColor = UIColor.white
        
        let match = self.arrMatches?[indexPath.row]
        cell.selectedMatch = match
        //cell.controller = self
        cell.indexPath = indexPath
        
        cell.lblHomeTeam.text = match?.localteam ?? ""
        cell.lblAwayTeam.text = match?.visitorteam ?? ""
        
        cell.lblHomeTeamShortName.text = match?.localteam_short_name ?? ""
        cell.lblAwayTeamShortName.text = match?.visitorteam_short_name ?? ""
        
        cell.lblMatchType.text = ""
        
        cell.lblSeriesName.superview?.roundCorners(corners: [.topLeft,.topRight], radius: 10)
        cell.lblTeamContests.superview?.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 10)
        
        let mega = "Mega Prize ".withAttributes([
            .textColor(UIColor.white),
            .font(UIFont(name: Constants.kRegularFont, size: cell.lblTeamContests.font.pointSize)!)
            ])
        
        if (match?.mega ?? 0) != 0 && (match?.mega != nil) {
            
            let strPrize = CommonFunctions.suffixNumberIndian(currency: (match?.mega ?? 0))
            let prize = "\(GDP.globalCurrency)\(strPrize)".withAttributes([
                .textColor(UIColor.appHighlightedTextColor),
                .font(UIFont(name: Constants.kBoldFont, size: cell.lblTeamContests.font.pointSize)!)
                ])
            
            cell.lblTeamContests.isHidden = false
            cell.lblTeamContests.attributedText = mega + prize
            
        }else if (match?.reward ?? "") != ""{
            
            let prize = (match?.reward ?? "").withAttributes([
                .textColor(UIColor.appHighlightedTextColor),
                .font(UIFont(name: Constants.kBoldFont, size: cell.lblTeamContests.font.pointSize)!)
                ])
            cell.lblTeamContests.isHidden = false
            cell.lblTeamContests.attributedText = mega + prize
            
        }else {
            cell.lblTeamContests.isHidden = true
        }
        
        let matchtype = (match?.type?.uppercased() ?? "")
        cell.lblSeriesName.text = "\(match?.series_name ?? "") \(matchtype)"
        
        cell.lblRemainingTime.text = match?.timerText ?? ""
        DispatchQueue.main.async {
            if match?.start_time != nil{
               
                if let matchDate = CommonFunctions.getDateFromString(date: match?.match_date ?? "", format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") {
                    cell.releaseDate = matchDate as NSDate
                    let elapseTimeInSeconds =  cell.releaseDate!.timeIntervalSince(Date())
                    cell.expiryTimeInterval = elapseTimeInSeconds
                    if(elapseTimeInSeconds <= 0){
                        cell.isUserInteractionEnabled = false
                    }else{
                        cell.isUserInteractionEnabled = true
                    }
                }
            }else{
                cell.lblRemainingTime.text = ""
            }
        }
        
        if (match?.lineup ?? false) == true {
            cell.lblLineUp.isHidden = false
        }else {
            cell.lblLineUp.isHidden = true
        }

        cell.imgViewHomeTeam.loadImage(urlS: match?.localteam_flag, placeHolder: Constants.kNoImageUser)
        cell.imgViewAwayTeam.loadImage(urlS: match?.visitorteam_flag, placeHolder: Constants.kNoImageUser)
        
        cell.btnReminder.tag = indexPath.row
        cell.btnReminder.addTarget(self, action: #selector(btnReminderPressed(sender:)), for: .touchUpInside)
        
        if (match?.is_match_reminder ?? false) == true || (match?.is_series_reminder ?? false) == true{
            cell.btnReminder.isSelected = true
        }else{
            cell.btnReminder.isSelected = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard isShimmerEnable == false else { return }
        
        let match = self.arrMatches?[indexPath.row]
        let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "MatchContestViewController") as! MatchContestViewController
        GDP.selectedMatch = match
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.tblMatches.reloadData()
    }
    
    @objc func btnUpcomingFilterPressed(_ sender: UIButton) {
        
        let vc = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "UpcomingMatchesFilterVC") as! UpcomingMatchesFilterVC
        
        vc.selectedSeriesId = seriesCricketFilterId
        vc.completion = { seriesId in
            self.seriesCricketFilterId = seriesId
            self.getMatchesFromServer(fromFilter: true)
        }
        self.present(vc, animated: true) {
            vc.getSeriesListing()
        }
    }
    
    @objc func btnReminderPressed(sender:UIButton){
        
        let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "SetRemindersVC") as! SetRemindersVC
        VC.selectedMatch = self.arrMatches?[sender.tag]
        VC.completionHandler = {(match, isReminder) in
            self.getMatchesFromServer()
        }
        VC.isModalInPresentation = true
        self.present(VC, animated: false)
    }
    
}

extension CricketFantasyVC {
    
    func getMatchesFromServer(fromFilter: Bool = false) {
        
        var params: [String:Any] = [:]

        let url = URLMethods.BaseURL + URLMethods().getActiveMatchList
        
        if let seriesFilterId = seriesCricketFilterId {
            params["series_id"] = "\(seriesFilterId)"
        }
        
        //self.arrMatches?.removeAll()
        
        ApiClient.init().getRequest(method: url, parameters: params, view: (self.view)!) { result in
            
            self.isShimmerEnable = false
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            
            guard let result = result else {
                return
            }
            
            let status = result.object(forKey: "success") as? Bool ?? false
            let msg = result.object(forKey: "msg") as? String ?? ""
            
            guard status == true,  let data = result.object(forKey: "results") as? [String:Any] else {
                self.arrMatches?.removeAll()
                AppManager.showToast(msg, view: (self.view)!)
                return
            }
            
            if let results = data["rows"] as? [[String:Any]]{
                guard let jsonData = try? JSONSerialization.data(withJSONObject: results, options: .prettyPrinted),
                      let tblData = try? JSONDecoder().decode([Match].self, from: jsonData)else {
                    return
                }
                self.arrMatches = tblData
                self.tblMatches.reloadData()
            }else {
                self.arrMatches?.removeAll()
                AppManager.showToast(msg, view: (self.view)!)
            }
        }
        
        if !fromFilter {
            self.getMyMatchesFromServer()
            self.fetchBanners()
        }
    }
    
    func getMyMatchesFromServer() {
        
        let url = URLMethods.BaseURL + URLMethods().getMyMatchList
        
        ApiClient.init().getRequest(method: url, parameters: [:], view: (self.view)!) { result in
            
            guard let result = result else { return }
            let status = result.object(forKey: "success") as? Bool ?? false
            let msg = result.object(forKey: "message") as? String ?? ""
            
            guard status == true else {
                AppManager.showToast(msg, view: (self.view)!)
                return
            }
            
            let upcoming = result.object(forKey: "upcoming") as? [[String:Any]]
            let live = result.object(forKey: "live") as? [[String:Any]]
            let completed = result.object(forKey: "completed") as? [[String:Any]]
            
            var arrAllMatches = [Match]()
            
            if let liveMatches = live {
                guard let jsonData = try? JSONSerialization.data(withJSONObject: liveMatches, options: .prettyPrinted),
                      let tblData = try? JSONDecoder().decode([Match].self, from: jsonData)else {
                          AppManager.stopActivityIndicator(self.view)
                          return
                      }
                
                arrAllMatches.append(contentsOf: tblData)
            }
            
            if let upcomingMatches = upcoming {
                guard let jsonData = try? JSONSerialization.data(withJSONObject: upcomingMatches, options: .prettyPrinted),
                      let tblData = try? JSONDecoder().decode([Match].self, from: jsonData)else {
                          AppManager.stopActivityIndicator(self.view)
                          return
                      }
                if arrAllMatches.count == 0{
                    arrAllMatches.append(contentsOf: tblData)
                }
            }
            
            if let completedMatches = completed {
                guard let jsonData = try? JSONSerialization.data(withJSONObject: completedMatches, options: .prettyPrinted),
                      let tblData = try? JSONDecoder().decode([Match].self, from: jsonData)else {
                          AppManager.stopActivityIndicator(self.view)
                          return
                      }
                if arrAllMatches.count == 0{
                    arrAllMatches.append(contentsOf: tblData)
                }
            }
            self.arrMyMatches = arrAllMatches
            self.tblMatches.reloadData()
        }
    }
    
    
    func saveMatch(match:Match, index:Int) {
        
        let params = ["match_id":match.match_id ?? 0,
                      "series_id":match.series_id ?? 0
        ]
        
        ApiClient.init().postRequest(params, request: URLMethods.BaseURL + URLMethods().saveMatchReminder, view: self.view) { (msg,result) in
            if result != nil {
                WebCommunication.shared.getMatchDetail(hostController: self, match_id: match.match_id ?? 0, showLoader: false) { match in
                    self.arrMatches?[index] = match ?? self.arrMatches![index]
                    self.tblMatches.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)

                }
            }else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
        }
    }
    
    func getCommonDetails() {
        WebCommunication.shared.getCommonDetails(hostController: self, showLoader: false) { _ in }
    }
    
    func fetchBanners() {
        
        let params: [String:String] = ["page":"1",
                                       "itemsPerPage":"100"
        ]
        
        let url = URLMethods.BaseURL + URLMethods.homebanner
        
        ApiClient.init().getRequest(method: url, parameters: params, view: (self.view)) { result in
            
            guard let result = result else { return }
            let status = result.object(forKey: "success") as? Bool ?? false
            let msg = result.object(forKey: "message") as? String ?? ""
            
            guard status == true, let data = result.object(forKey: "results") as? [String:Any] else {
                //AppManager.showToast(msg, view: (self.view)!)
                return
            }
            
            
            self.bannerPath = (result.object(forKey: "banner_path") as? String ) ?? ""
            if let results = data["docs"] as? [[String:Any]]{
                guard let jsonData = try? JSONSerialization.data(withJSONObject: results, options: .prettyPrinted),
                      let tblData = try? JSONDecoder().decode([Banner].self, from: jsonData)else {return }
                self.arrBanners = tblData
            }
        }
    }
}

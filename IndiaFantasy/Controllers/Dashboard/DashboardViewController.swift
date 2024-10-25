//
//  DashboardViewController.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 02/03/22.
//

import UIKit
import SideMenu
import SDWebImage
import SafariServices
import SwiftyAttributes

class DashboardViewController: BaseClassVC {

    @IBOutlet weak var btnCricket: UIButton!
    @IBOutlet weak var topConstTable: NSLayoutConstraint!
    @IBOutlet weak var contstHt: NSLayoutConstraint!
    @IBOutlet weak var navigationView: CustomNavigation!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tblMatches: UITableView!
    @IBOutlet weak var viewBanner: UIView!
    @IBOutlet weak var viewEmpty: UIView!
    
    var arrMyMatches:[Match]? = nil
    var arrMatches:[Match]? = nil {
        didSet {
//            if arrMatches?.count == 0 {
//                tblMatches.setEmptyMessage(ConstantMessages.NoUpcomingMatchesFound)
//            }else {
//                tblMatches.restoreEmptyMessage()
//            }
            tblMatches.reloadData()
        }
    }
    let refreshControl = UIRefreshControl()
    var seriesCricketFilterId: Int? = nil
//    var seriesFootballFilterId: Int? = nil
//    var seriesRugbyFilterId: Int? = nil
    
    private var isShimmerEnable = true {
        didSet {
            tblMatches.reloadData()
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
    
    override func viewWillLayoutSubviews() {
//        viewContainer.roundCorners(corners: [.topLeft,.topRight], radius: 20)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        GDP.selectedMatch = nil
        self.btnGameTypePressed(btnCricket)
        navigationView.btnFantasyType.setTitle(GDP.getFantasyTitle(), for: .normal)
        self.loadInitialData()
    }
    
    //MARK: - Setup NavigationView
    private func setupNavigationView() {
        navigationView.configureNavigationBarWithController(controller: self, title: "Cricket", hideNotification: false, hideAddMoney: true, hideBackBtn: true)
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
    
    @objc func refreshLineUpAnnounced(notification : NSNotification)
    {
        self.loadInitialData()
    }
    
    @objc func refreshTableData(_ sender: AnyObject) {
        self.loadInitialData()
    }
    
    func loadInitialData(){
        isShimmerEnable = true
        self.getMatchesFromServer()
    }
    
    func loadBannerComponent(){
//        let banner = DashboardBannerView.instanceFromNib() as! DashboardBannerView
//        banner.controller = self
//        banner.updateView(type: 2)
        
        for view in viewBanner.subviews{
            view.removeFromSuperview()
        }
        if let headerView = self.tblMatches.tableHeaderView as? MyMatchesContainer{
            //headerView.viewBanner.addSubview(banner)
           
            // banner.frame = viewBanner.bounds
            self.tblMatches.tableHeaderView = headerView
        }else{
            let header = MyMatchesContainer.instanceFromNib() as! MyMatchesContainer
            header.viewMyContest.isHidden = true
            header.viewMatch.isHidden = true
            header.frame.size.height = 145
            //header.viewBanner.addSubview(banner)
            self.tblMatches.tableHeaderView = header
        }
    }
    
    @IBAction func btnNotification(_ sender: UIButton!) {
        let VC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "NotificationsViewController") as! NotificationsViewController
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func btnWalletPressed(_ sender: Any) {
        let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "MyAccountDetailsVC") as! MyAccountDetailsVC
        self.navigationController?.pushViewController(pushVC, animated: true)
    }
    
    @IBAction func menuBtnPressed(_ sender: UIButton!) {
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    
    @objc func btnReminderPressed(sender:UIButton){
//        if let match = self.arrMatches?[sender.tag]{
//           // if match.is_reminder == false{
//                self.saveMatch(match: match, index: sender.tag)
//            //}
//        }
        
        let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "SetRemindersVC") as! SetRemindersVC
        VC.selectedMatch = self.arrMatches?[sender.tag]
        VC.completionHandler = {(match, isReminder) in
            //self.arrMatches?[sender.tag] = match
            self.getMatchesFromServer()
//            self.getMyMatchesFromServer()

        }
        VC.isModalInPresentation = true
        self.present(VC, animated: false)
    }
    
    @objc func btnViewAllPrssed(sender:UIButton){
//        let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "ContestViewController") as! ContestViewController
//        self.navigationController?.pushViewController(VC, animated: true)
        
        if let tabbarController = Constants.kAppDelegate.tabbarController{
            if tabbarController.selectedIndex != 2{
                tabbarController.selectedIndex = 2
            }
        }
    }
    
    @IBAction func btnGameTypePressed(_ sender: UIButton) {
        btnCricket.isSelected = false
        viewEmpty.isHidden = true
        tblMatches.isHidden = false
        
        sender.isSelected = true
        
        self.arrMatches = [Match]()
        self.arrMyMatches = [Match]()
        self.tblMatches.tableHeaderView = nil
        
        self.tblMatches.reloadData()
        switch sender{
        case btnCricket:
            GDP.switchToCricket()
            navigationView.btnFantasyType.setTitle("Cricket", for: .normal)
            self.getMatchesFromServer()
            break
        default:
            break
        }
    }
    
    
    func navigateToMatchDetails(index:Int){
        let match = self.arrMyMatches?[index]
        if (match?.match_status?.uppercased() ?? "") == "NOT STARTED" || (match?.match_status?.uppercased() ?? "") == "FIXTURE" {
            let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "MatchContestViewController") as! MatchContestViewController
            GDP.selectedMatch = match
            self.navigationController?.pushViewController(VC, animated: true)
        }
        else{
            if (match?.match_status?.uppercased() ?? "") == "CANCELLED"{
                return
            }
            let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "LiveContestViewController") as! LiveContestViewController
            GDP.selectedMatch = match
            self.navigationController?.pushViewController(VC, animated: true)
        }
        
    }
}
extension DashboardViewController{
    func getMatchesFromServer (fromFilter: Bool = false){
        var params: [String:Any] = [:]
        
        let url = URLMethods.BaseURL + URLMethods().getActiveMatchList
        
        if let seriesFilterId = seriesCricketFilterId {
            params["series_id"] = "\(seriesFilterId)"
        }
        
        //self.arrMatches?.removeAll()
        
        ApiClient.init().getRequest(method: url, parameters: params, view: (self.view)!) { result in
            
            self.isShimmerEnable = false
            if result != nil {
                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "msg") as? String ?? ""
                if status == true{
                    let data = result?.object(forKey: "results") as? [String:Any]
                   
                    if let results = data?["rows"] as? [[String:Any]]{
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: results, options: .prettyPrinted),
                              let tblData = try? JSONDecoder().decode([Match].self, from: jsonData)else {
                                  //AppManager.stopActivityIndicator(self.view)
                                  return
                              }
                        self.arrMatches = tblData
                        self.tblMatches.reloadData()
                    }else{
                        AppManager.showToast(msg, view: (self.view)!)
                    }
                }else{
                    AppManager.showToast(msg, view: (self.view)!)
                }
               
            }else{
                //AppManager.showToast("", view: (self.view)!)
            }
            //self.progressIndicator.stopAnimating()
            if !fromFilter {
                self.loadBannerComponent()
            }else {
                //AppManager.stopActivityIndicator(self.view)
            }
            self.refreshControl.endRefreshing()
        }
        //self.progressIndicator.startAnimating()
        //AppManager.startActivityIndicator(sender: self.view)
        
        if !fromFilter {
            self.getMyMatchesFromServer()
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
                    let upcoming = result?.object(forKey: "upcoming") as? [[String:Any]]
                    let live = result?.object(forKey: "live") as? [[String:Any]]
                    let completed = result?.object(forKey: "completed") as? [[String:Any]]

                   var arrAllMatches = [Match]()
                   
                    if let liveMatches = live{
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: liveMatches, options: .prettyPrinted),
                              let tblData = try? JSONDecoder().decode([Match].self, from: jsonData)else {
                                  AppManager.stopActivityIndicator(self.view)
                                  return
                              }
                        
                        arrAllMatches.append(contentsOf: tblData)
                    }
                    
                    if let upcomingMatches = upcoming{
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: upcomingMatches, options: .prettyPrinted),
                              let tblData = try? JSONDecoder().decode([Match].self, from: jsonData)else {
                                  AppManager.stopActivityIndicator(self.view)
                                  return
                              }
                        if arrAllMatches.count == 0{
                            arrAllMatches.append(contentsOf: tblData)
                        }
                    }
                    
                   
                    
                    if let completedMatches = completed{
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: completedMatches, options: .prettyPrinted),
                              let tblData = try? JSONDecoder().decode([Match].self, from: jsonData)else {
                                  AppManager.stopActivityIndicator(self.view)
                                  return
                              }
                        if arrAllMatches.count == 0{
                            arrAllMatches.append(contentsOf: tblData)
                        }
                    }
                    
                    let header = MyMatchesContainer.instanceFromNib() as! MyMatchesContainer
                    if arrAllMatches.count > 0 {
                        self.arrMyMatches = arrAllMatches
                        header.controller = self
                        header.arrMyMatches = arrAllMatches
                        header.updateView()
                        self.tblMatches.tableHeaderView = header
                        DispatchQueue.main.async {
                            self.tblMatches.reloadData()
                        }
                    }
                    else{
                        header.viewMyContest.isHidden = true
                        header.viewMatch.isHidden = true
                        header.frame.size.height = 145
                        header.controller = self
                        header.updateView()
                        self.tblMatches.tableHeaderView = header
//                        self.loadBannerComponent()
                        //self.tblMatches.tableHeaderView = nil
                    }
                    
                }else{
                    AppManager.showToast(msg, view: (self.view)!)
                }
               
            }else{
                let header = MyMatchesContainer.instanceFromNib() as! MyMatchesContainer
                header.viewMatch.isHidden = true
                header.frame.size.height = 145
                self.tblMatches.tableHeaderView = header
                //AppManager.showToast("", view: (self.view)!)
            }
            //self.progressIndicator.stopAnimating()
            AppManager.stopActivityIndicator(self.view)
            self.refreshControl.endRefreshing()
        }
        //self.progressIndicator.startAnimating()
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
}
extension DashboardViewController:UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isShimmerEnable ? 5 : arrMatches?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UpcomingMatchHeaderView.instanceFromNib() as! UpcomingMatchHeaderView
        headerView.filterBtn.addTarget(self, action: #selector(btnUpcomingFilterPressed(_:)), for: .touchUpInside)

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
        cell.controller = self
        cell.indexPath = indexPath
        
        cell.lblHomeTeam.text = match?.localteam ?? ""
        cell.lblAwayTeam.text = match?.visitorteam ?? ""
        
        cell.lblHomeTeamShortName.text = match?.localteam_short_name ?? ""
        cell.lblAwayTeamShortName.text = match?.visitorteam_short_name ?? ""
        
        //cell.lblMatchType.text = (match?.type?.uppercased() ?? "")
        cell.lblMatchType.text = ""
        
        cell.lblSeriesName.superview?.roundCorners(corners: [.topLeft,.topRight], radius: 10)
        cell.lblTeamContests.superview?.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 10)
//        cell.viewBackground.dropShadow12(color: .black, opacity: 0.8, offSet: CGSize(width: 0, height: 0), radius: 1, scale: true,Cradius: 20)
        
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
            
//            let prize = "XP".withAttributes([
//                .textColor(UIColor.white.withAlphaComponent(0.7)),
//                .font(UIFont(name: Constants.kBoldFont, size: cell.lblTeamContests.font.pointSize)!)
//                ])
            cell.lblTeamContests.isHidden = true
            //cell.lblTeamContests.attributedText = ""
        }
        
        let matchtype = (match?.type?.uppercased() ?? "")
        cell.lblSeriesName.text = "\(match?.series_name ?? "") \(matchtype)"
        
        cell.lblRemainingTime.text = match?.timerText ?? ""
        DispatchQueue.main.async {

            //let strtDate = "\(match?.start_date ?? "")".components(separatedBy: "T")
            if match?.start_time != nil{
                //let dataValue = "\(strtDate[0])T\(match?.start_time ?? "")"

                //let matchDate = CommonFunctions.getNewRemainingTimeWith(strDate : dataValue, serverDate : match?.server_time ?? "")
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
        
        if (match?.lineup ?? false) == true
        {
            cell.lblLineUp.isHidden = false
        }
        else
        {
            cell.lblLineUp.isHidden = true
        }

        cell.imgViewHomeTeam.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.imgViewHomeTeam.sd_setImage(with: URL(string: match?.localteam_flag ?? ""), placeholderImage: Constants.kNoImageUser)

        cell.imgViewAwayTeam.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.imgViewAwayTeam.sd_setImage(with: URL(string: match?.visitorteam_flag ?? ""), placeholderImage: Constants.kNoImageUser)
        
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
     
    }

    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.tblMatches.reloadData()
    }
    //pushing up
    func tableView(_ tableView: UITableView,
                   didEndDisplayingHeaderView view: UIView,
                   forSection section: Int) {
     
        //lets ensure there are visible rows.  Safety first!
        guard let pathsForVisibleRows = tableView.indexPathsForVisibleRows,
            let lastPath = pathsForVisibleRows.last else { return }

        //compare the section for the header that just disappeared to the section
        //for the bottom-most cell in the table view
        if lastPath.section >= section {
          
            print("the next header is stuck to the top")
        }

    }

    //pulling down
    func tableView(_ tableView: UITableView,
                   willDisplayHeaderView view: UIView,
                   forSection section: Int) {

        //lets ensure there are visible rows.  Safety first!
        guard let pathsForVisibleRows = tableView.indexPathsForVisibleRows,
            let firstPath = pathsForVisibleRows.first else { return }

        //compare the section for the header that just appeared to the section
        //for the top-most cell in the table view
        if firstPath.section == section {
         //   self.viewContainer.backgroundColor = .clear
        }
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
    
}

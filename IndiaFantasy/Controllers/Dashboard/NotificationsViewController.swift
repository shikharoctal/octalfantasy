//
//  NotificationsViewController.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 10/03/22.
//

import UIKit
import SwiftUI

class NotificationsViewController: BaseClassWithoutTabNavigation {

    @IBOutlet weak var navigationView: CustomNavigation!
    @IBOutlet weak var lblNoData: UILabel!
    @IBOutlet weak var tblNotifications: UITableView!
    
    var page = 1
    var itemPerPage = 100
    var arrNotifications:[NotificationInfo]? = nil
    var isFromBack = false
    
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationView.configureNavigationBarWithController(controller: self, title: "Notifications", hideNotification: true, hideAddMoney: true, hideBackBtn: false)
        self.tblNotifications.rowHeight = UITableView.automaticDimension;
        self.tblNotifications.estimatedRowHeight = 44.0; //
        
        setupRefreshControl()
    }

    override func viewDidAppear(_ animated: Bool) {
        self.getNotificationsFromServer()
    }
    
    //MARK: - Setup Refresh Control
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(getDataFromServer), for: .valueChanged)
        refreshControl.tintColor = .black
        tblNotifications.refreshControl = refreshControl
    }
    
    @objc func getDataFromServer() {
        
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
        
        self.getNotificationsFromServer()
    }
    
    @IBAction func btnClearAllPressed(_ sender: Any)
    {
        if self.arrNotifications?.count == 0
        {
            AppManager.showToast(ConstantMessages.NOTIFICATION_NOT_FOUND, view: self.view)
            return
        }
        
        let alert = UIAlertController(title: Constants.kAppDisplayName, message: ConstantMessages.ALERT_CLEAR_ALL_NOTIFICATION, preferredStyle:.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.clearNotifications(id: "0", type: Constants.kClearNotification, notification: NotificationInfo())
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension NotificationsViewController {
    
    func getNotificationsFromServer () {
       // let body = "page=\(String(page))&itemsPerPage=\(String(itemPerPage))"
        
        let params = ["page":"1",
                      "itemsPerPage":"100"]
        
        let url = URLMethods.BaseURL + URLMethods.getNotifications
        
        ApiClient.init().getRequest(method: url, parameters: params, view: (self.view)!) { result in
            if result != nil {
                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "message") as? String ?? ""
                if status == true{
                    let data = result?.object(forKey: "results") as? [String:Any]
                   
                    if let results = data?["docs"] as? [[String:Any]]{
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: results, options: .prettyPrinted),
                              let tblData = try? JSONDecoder().decode([NotificationInfo].self, from: jsonData)else {return }
                        
                        self.arrNotifications = tblData
                        self.tblNotifications.reloadData()
                        
                        self.clearNotifications(id: "0", type: Constants.kReadNotification, notification: NotificationInfo())
                       
                    }else{
                        AppManager.showToast(msg, view: (self.view)!)
                    }
                }else{
                    AppManager.showToast(msg, view: (self.view)!)
                }
               
            }else{
                AppManager.showToast("", view: (self.view)!)
            }
            
            if (self.arrNotifications?.count ?? 0) == 0{
                self.lblNoData.isHidden = false
               // self.btnClearAll.isHidden = true
            }else{
                self.lblNoData.isHidden = true
//                self.btnClearAll.isHidden = false
            }
            AppManager.stopActivityIndicator((self.view)!)
            
            if self.isFromBack == true{
                self.isFromBack = false
            }
        }
        if self.isFromBack == false{
            AppManager.startActivityIndicator(sender: (self.view)!)

        }
    }
    
    func clearNotifications (id:String, type:String, notification: NotificationInfo) {
        var params:[String:Any] = ["id":id]
        
        var url = ""
        
        if type == Constants.kClearNotification{
            url = URLMethods.BaseURL + URLMethods.clearNotifications
        }else{
            url = URLMethods.BaseURL + URLMethods.readNotifications
            params = ["id":id, "read":true]
        }

        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                
                if let index = self.arrNotifications?.firstIndex(where: {$0.id == id}),( self.arrNotifications?.count ?? 0) > index {
                    self.arrNotifications?[index].read = true
                    let indexPath = IndexPath(row: index, section: 0)
                    self.tblNotifications.reloadRows(at: [indexPath], with: .none)
                }
                
                if id == "0"{
                    if type == Constants.kClearNotification{
                        self.arrNotifications?.removeAll()
                        self.tblNotifications.reloadData()
                        self.lblNoData.isHidden = false
                    }
                }
            }
            
            else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
            
            AppManager.stopActivityIndicator(self.view)
            self.notificationTapped(type: type, notification: notification)
            
        }
        
//        if id == "0"{
            AppManager.startActivityIndicator(sender: self.view)
//        }
    }
    
    func notificationTapped(type: String, notification: NotificationInfo) {
        
        
        if type == Constants.kClearNotification{
            print("Cleared a row")

        }else if type == Constants.kReadNotification{
            self.navigationView.getBalance()
            print("Read All Notifications")
        }
        else{
            if type == "cricket_contest" || type == "entry_fees" || type == "lineup_out" || type == "debuff" {
                
                self.contestRedirection(notification: notification)
                
            }
            else if type == "contest_cancel"{
                let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "RecentTransactionsVC") as! RecentTransactionsVC
                self.navigationController?.pushViewController(pushVC, animated: true)
            }
            else if type == "wallet_deposit" || type == "sign_in_bonus" || type == "withdrawals" || type == "bonus" || type == "winning" || type == "free_cash"{
                if let tabbarController = Constants.kAppDelegate.tabbarController{
                    self.navigationController?.popToRootViewController(animated: false)
                    tabbarController.selectedIndex = 4
                }
               
            }
//            else if type == "refer"{
//                let pushVC = Constants.KHelpStoryboard.instantiateViewController(withIdentifier: "YourReferralsVC") as! YourReferralsVC
//                self.navigationController?.pushViewController(pushVC, animated: true)
//            }
            else if type == "identity_status"{
                WebCommunication.shared.getCommonDetails(hostController: self, showLoader: false) { user in
                    let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "VerificationOptionsVC") as! VerificationOptionsVC
                    self.navigationController?.pushViewController(pushVC, animated: true)
                }
            }else if type == "purchase" {
//                    if let tabbarController = Constants.kAppDelegate.tabbarController{
//                        self.navigationController?.popToRootViewController(animated: false)
//                        tabbarController.selectedIndex = 3
//                    }
            }else if type == "daily" || type == "gift" || type == "referral_commission" {
                AppManager.stopActivityIndicator(self.view)
                return
            }
            else if type == "chatMessage" {
                if let tabbarController = Constants.kAppDelegate.tabbarController{
                    self.navigationController?.popToRootViewController(animated: false)
                    tabbarController.selectedIndex = 1
                }
            }
        }
    }
    
    func contestRedirection(notification: NotificationInfo) {
        
        guard notification.contestType != nil else { return }
        
        let matchType = notification.matchType ?? ""
        switch matchType.lowercased() {
        case "cricket":
            GDP.switchToCricket()
            break
        default:
            break
        }
        
        if notification.contestType == "daily" {
            
            WebCommunication.shared.getMatchDetail(hostController: self, match_id: (notification.matchId ?? 0), showLoader: true) { match in
                
                guard let match = match else { return }
                
                if match.match_status?.uppercased() == "NOT STARTED" || match.match_status?.uppercased() == "UPCOMING" || (match.match_status?.uppercased() ?? "") == "FIXTURE"{
                    
                    let vc = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "MatchContestViewController") as! MatchContestViewController
                    vc.isMyGames = true
                    GDP.selectedMatch = match
                
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }else{

                    if (match.match_status?.uppercased() ?? "") == "CANCELLED"{
                        return
                    }
                    let vc = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "LiveContestViewController") as! LiveContestViewController
                    GDP.selectedMatch = match

                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        }else {
            let vc = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonsTabBarVC") as! SeasonsTabBarVC
            GDP.leagueType = notification.leagueType ?? ""
            GDP.leagueSeriesId = "\(notification.seriesId ?? 0)"
            GDP.leagueName = notification.leagueName ?? ""
        
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }
}
extension NotificationsViewController:UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrNotifications?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTVCell", for: indexPath) as! NotificationTVCell
        
        cell.selectionStyle = .none
        let item = arrNotifications?[indexPath.row]
        cell.lblTitle.text = item?.title ?? ""
        cell.lblDescription.text = item?.message ?? ""
//        cell.viewRead.isHidden = item?.read ?? false
        if item?.read ?? false == true{
            cell.lblTitle.textColor = UIColor.lightGray
        }else{
            cell.lblTitle.textColor = UIColor.black
        }
        let finalDate = "\(item?.createdAt ?? "")".UTCToLocal(incomingFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outGoingFormat: "MMM d, yyyy h:mm a")
        cell.lblDateTime.text = finalDate

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notif = self.arrNotifications?[indexPath.row]
        self.isFromBack = true
        if let notif = notif {
            if notif.read == true {
                //AppManager.startActivityIndicator(sender: self.view)
                self.notificationTapped(type: (notif.type ?? ""), notification: notif)
            }else {
                self.clearNotifications(id: (notif.id ?? "0"), type: (notif.type ?? ""), notification: notif)
            }
            
        }
      
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle:   UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let item = arrNotifications?[indexPath.row]

        if (editingStyle == .delete) {
            let alert = UIAlertController(title: Constants.kAppDisplayName, message: ConstantMessages.kDeleteNotification, preferredStyle:.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                if let item = item{
                    self.clearNotifications(id: item.id ?? "", type: Constants.kClearNotification, notification: item)
                }
                self.arrNotifications?.remove(at: indexPath.row)
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .middle)
                tableView.endUpdates()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }

}

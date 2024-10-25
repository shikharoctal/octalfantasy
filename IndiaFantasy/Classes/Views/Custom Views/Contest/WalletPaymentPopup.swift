//
//  WalletPaymentPopup.swift
//  GloFans
//
//  Created by octal on 02/03/20.
//  Copyright © 2020 octal. All rights reserved.
//

import UIKit
import AMPopTip

class WalletPaymentPopup: UIView {
    @IBOutlet weak var lblTotalBalance: UILabel!
    @IBOutlet weak var lblEntryFee: UILabel!
    @IBOutlet weak var lblBonus: UILabel!
    @IBOutlet weak var lblNetPay: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var btnInfo: UIButton!
    
    var teamId = String()
    var teamNumber = Int()
    var matchData:Match?
    var contestData:ContestData? = nil
    
    let popTip = PopTip()
    var newContest:NewContestData? = nil
    var isNewContest = false
    var useableBonousPercent = String()
    
    var completionHandler: ((String)->Void)?
    
    var gameType = String()
    
    var contestBalance: ContestFeeBalances? {
        didSet{
            if let balance = self.contestBalance{
                
                self.lblEntryFee.text = "\(GDP.globalCurrency)" +  String(balance.entryFee.rounded(toPlaces: 2).cleanValue)
                 
                let entryFee = balance.entryFee.rounded(toPlaces: 2)
                let usableBonus = balance.usableBalance.rounded(toPlaces: 2)
                
                self.lblNetPay.text = "\(GDP.globalCurrency)" +  (entryFee - usableBonus).rounded(toPlaces: 2).cleanValue
                
                if balance.usableBalance > 0{
                    self.lblBonus.text = "- \(GDP.globalCurrency)" + String(balance.usableBalance.rounded(toPlaces: 2).cleanValue)

                }else{
                    self.lblBonus.text = "\(GDP.globalCurrency)" + String(balance.usableBalance.rounded(toPlaces: 2).cleanValue)
                }
                
                
                lblTotalBalance.text = "Unutilized Balance + Winnings = \(GDP.globalCurrency)" + String((balance.cashBalance.rounded(toPlaces: 2) + balance.winningBalance.rounded(toPlaces: 2)).rounded(toPlaces: 2).cleanValue)
                
                if balance.useableBonousPercent == "" || balance.useableBonousPercent.count == 0
                {
                    //self.btnInfoPopup.isHidden = true
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.updateDidLoad()
    }
    
    //Mark: - Functions
    
    func updateDidLoad()
    {
        print("MyGameType--->",self.gameType)
    }
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    @IBAction func InfoBtnPressed(_ sender: UIButton)
    {
        
        popTip.bubbleColor = UIColor.init(named: "SecondaryColor") ?? UIColor.appPrimaryColor
        popTip.shouldDismissOnTapOutside = true
        popTip.shouldDismissOnTap = true
        popTip.show(text: "Max 10% of total entry fee* per match\n* valid for Selected contests only\n*not valid for private contests", direction: .down, maxWidth: 250, in: self.containerView, from: sender.frame)
    }
    
    @IBAction func onSubmitClick(_ sender: UIButton)
    {
        sender.isUserInteractionEnabled = false
        
        if (self.contestData?.isLeagueContest ?? false) == true {
            self.CallLeagueJoinContestApi()
            return
        }else if self.isNewContest
        {
            self.CallJoinNewContestApi()
        }
        else
        {
            self.CallJoinContestApi()
        }
    }
    
    @IBAction func onCloseClick(_ sender: Any)
    {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.0
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.bounds.maxY)
        }) { _ in
            self.removeFromSuperview()
        }
    }
}

//MARK: - Api Calling
extension WalletPaymentPopup
{
    func CallJoinContestApi(){
        let params:[String:String] = ["user_id": Constants.kAppDelegate.user?.id ?? "",
                                      "match_id":String(matchData?.match_id ?? 0),
                                       "series_id":String(matchData?.series_id ?? 0),
                                      "contest_id":contestData?.id ?? "0",
                                      "team_id":teamId
        ]
        
        let url = URLMethods.BaseURL + URLMethods().joinContest

        ApiClient.init().postRequest(params, request: url, view: self) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                UIView.animate(withDuration: 0.3, animations: {
                    self.alpha = 0.0
                    self.containerView.transform = CGAffineTransform(translationX: 0, y: self.bounds.maxY)
                }) { _ in
                    self.completionHandler?("\(msg ?? "Server Error")")
                    self.removeFromSuperview()
                }
                
                AppManager.showToast(msg ?? "", view: self)
            }
            
            else{
                UIView.animate(withDuration: 0.3, animations: {
                    self.alpha = 0.0
                    self.containerView.transform = CGAffineTransform(translationX: 0, y: self.bounds.maxY)
                }) { _ in
                    AppManager.showToast(msg ?? "", view: self)
                    self.removeFromSuperview()
                }
            }
            
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.kUpdateTopNavigation), object: nil, userInfo: nil)

            AppManager.stopActivityIndicator(self)
        }
        AppManager.startActivityIndicator(sender: self)

    }
    
    
    func CallJoinNewContestApi()
    {
        let topController = UIApplication.shared.topMostViewController

        let params:[String:String] = 
//        ["match_id":String(matchData?.match_id ?? 0),
//                                      "series_id":String(matchData?.series_id ?? 0),
//                                      "contest_id":contestData?.id ?? "0",
//                                      "team_id":teamId,
//                                      "contest_size":self.newContest?.contestSize ?? "",
//                                      "max_team_join_count": self.newContest?.maxTeamEntery ?? "",
//                                      "contest_name":self.newContest?.title ?? "",
//                                      "looserPunishment": self.newContest?.loserPunishmentText ?? ""
//        ]
        
        ["match_id":String(matchData?.match_id ?? 0),
                                      "series_id":String(matchData?.series_id ?? 0),
                                      "contest_id":contestData?.id ?? "0",
                                      "team_id":teamId,
                                      "contest_size":self.newContest?.contestSize ?? "",
                                      "winners_count":self.newContest?.totalWinners ?? "",
                                      "entry_fee":self.newContest?.entryFees ?? "",
                                      "contest_name":self.newContest?.title ?? "",
                                      "winning_amount":self.newContest?.prizeAmount ?? "0",
                                      "join_multiple": (self.newContest?.multiple_winner ?? false) ? "yes" : "no"
                                      
        ]

        let url = URLMethods.BaseURL + URLMethods().createContest

        ApiClient.init().postRequest(params, request: url, view: self) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                
                let data = result?.object(forKey: "results") as? [String:Any]
                let inviteCode = (data?["invite_code"] as? String) ?? ""
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.alpha = 0.0
                    self.containerView.transform = CGAffineTransform(translationX: 0, y: self.bounds.maxY)
                }) { _ in
                    
                    let vc = Constants.KMoreStoryboard.instantiateViewController(withIdentifier: "InviteYourFriendsVC") as! InviteYourFriendsVC
                    vc.isCreateContest = true
                    vc.inviteCode = inviteCode
                    self.removeFromSuperview()
                    topController?.navigationController?.pushViewController(vc, animated: false)
                }
            }
            
            else{
                UIView.animate(withDuration: 0.3, animations: {
                    self.alpha = 0.0
                    self.containerView.transform = CGAffineTransform(translationX: 0, y: self.bounds.maxY)
                }) { _ in
                    AppManager.showToast(msg ?? "", view: self)
                    self.removeFromSuperview()
                }
            }
            AppManager.stopActivityIndicator(self)
        }
        AppManager.startActivityIndicator(sender: self)
    }
    
    func CallLeagueJoinContestApi(){
        let params:[String:String] = ["contest_id":contestData?.id ?? "0",
                                      "team_id":teamId,
                                      "series_id":String(matchData?.series_id ?? 0),
                                      "match_id":String(matchData?.match_id ?? 0),
                                      "teamName": String(teamNumber),
                                      "timestamp_start": String(matchData?.timestamp_start ?? 0)
        ]
        
        let url = URLMethods.BaseURL + URLMethods().leaguejoinContest

        ApiClient.init().postRequest(params, request: url, view: self) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                UIView.animate(withDuration: 0.3, animations: {
                    self.alpha = 0.0
                    self.containerView.transform = CGAffineTransform(translationX: 0, y: self.bounds.maxY)
                }) { _ in
                    self.completionHandler?("\(msg ?? "Server Error")")
                    self.removeFromSuperview()
                }
                
                AppManager.showToast(msg ?? "", view: self)
            }
            
            else{
                UIView.animate(withDuration: 0.3, animations: {
                    self.alpha = 0.0
                    self.containerView.transform = CGAffineTransform(translationX: 0, y: self.bounds.maxY)
                }) { _ in
                    AppManager.showToast(msg ?? "", view: self)
                    self.removeFromSuperview()
                }
            }
            
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.kUpdateTopNavigation), object: nil, userInfo: nil)

            AppManager.stopActivityIndicator(self)
        }
        AppManager.startActivityIndicator(sender: self)

    }
}

extension UIViewController {
    
    func showWalletPopupView(_ booking: ContestFeeBalances? = nil, matchData: Match? = nil, team:Team, gameTypeValue:String, contestData:ContestData, completionHandler: ((String)->Void)? = nil){
        if let window = Constants.kAppDelegate.window {
            if let ratingView = Bundle.main.loadNibNamed("WalletPaymentPopup", owner: nil, options: nil)?.first as? WalletPaymentPopup {
                ratingView.teamId = team.team_id ?? ""
                ratingView.teamNumber = team.team_number ?? 0
                ratingView.gameType = gameTypeValue
                ratingView.contestBalance = booking!
                ratingView.completionHandler = completionHandler
                ratingView.matchData = matchData
                ratingView.contestData = contestData
                ratingView.frame = window.bounds
                ratingView.alpha = 0
                ratingView.containerView.transform = CGAffineTransform(translationX: 0, y: window.bounds.midY)
                window.addSubviewConstraint(to: ratingView)
                
                
                UIView.animate(withDuration: 0.75, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                    ratingView.alpha = 1.0
                    ratingView.containerView.transform = .identity
                }) { _ in
                }
            }
        }
    }
    
    func showNewContestWalletPopupView(_ booking: ContestFeeBalances? = nil,matchData:Match? = nil,teamId:String,isNewContest:Bool,contestData:NewContestData,gameType:String, completionHandler: ((String)->Void)? = nil){
        if let window = Constants.kAppDelegate.window {
            if let ratingView = Bundle.main.loadNibNamed("WalletPaymentPopup", owner: nil, options: nil)?.first as? WalletPaymentPopup {
                ratingView.contestBalance = booking!
                ratingView.completionHandler = completionHandler
                ratingView.matchData = matchData!
                ratingView.teamId = teamId
                ratingView.isNewContest = isNewContest
                ratingView.newContest = contestData
                ratingView.gameType = gameType
                ratingView.frame = window.bounds
                ratingView.alpha = 0
                ratingView.containerView.transform = CGAffineTransform(translationX: 0, y: window.bounds.midY)
                window.addSubviewConstraint(to: ratingView)
                
                
                UIView.animate(withDuration: 0.75, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                    ratingView.alpha = 1.0
                    ratingView.containerView.transform = .identity
                }) { _ in
                }
            }
        }
    }
}

struct ContestFeeBalances {
    var cashBalance = Double()
    var winningBalance = Double()
    var usableBalance = Double()
    var entryFee = Double()
    var useableBonousPercent = String()
    var gameType = String()
}

extension UIView {
    
    func addSubviewConstraint(to subView: UIView){
        
        subView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subView)
        let views: [String: Any] = ["alertView": subView]
        let horizontalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|[alertView]|", metrics: nil, views: views)
        let verticalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|[alertView]|", metrics: nil, views: views)
        NSLayoutConstraint.activate(horizontalConstraint+verticalConstraint)
        
    }
}

extension UIViewController {
    var topMostViewController : UIViewController {
        
        if let presented = self.presentedViewController {
            return presented.topMostViewController
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController ?? navigation
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController ?? tab
        }
        
        return self
    }
}
extension UIApplication {
    var topMostViewController : UIViewController? {
        //return self.keyWindow?.rootViewController?.topMostViewController
        return UIWindow.key!.rootViewController?.topMostViewController
    }
    
    var topViewController : UIViewController? {
        return UIWindow.key!.rootViewController?.topViewController()
    }
    
//    class func getTopViewController(base: UIViewController? = UIKit.UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController) -> UIViewController? {
//
//        if let nav = base as? UINavigationController {
//            return getTopViewController(base: nav.visibleViewController)
//
//        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
//            return getTopViewController(base: selected)
//
//        } else if let presented = base?.presentedViewController {
//            return getTopViewController(base: presented)
//        }
////        else if let current = base as? SSASideMenu, let selected = current.contentViewController {
////            return getTopViewController(base: selected)
////        }
//        return base
//    }
}

extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}

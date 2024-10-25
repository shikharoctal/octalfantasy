//
//  CustomNavigation.swift
//  KnockOut11
//
//  Created by Octal Mac 217 on 02/09/22.
//

import UIKit
import SideMenu
import SDWebImage
import DropDown

class CustomNavigation: UIView {
    
    @IBOutlet weak var img_BG: UIImageView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var notificationWidth: NSLayoutConstraint!
    @IBOutlet weak var lblNotification: UILabel!
    @IBOutlet var contentView: UIView!
    //var controller:UIViewController? =  UIViewController()
    @IBOutlet weak var btnBack: UIButton!
    //@IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnNotification: UIButton!
    @IBOutlet weak var sideMenuBtnView: UIView!
    @IBOutlet weak var viewAddMoney: UIView!
    @IBOutlet weak var btnAddMoney: UIButton!
    @IBOutlet weak var btnFantasyType: UIButton!
    @IBOutlet weak var lblWalletAmount: UILabel!
    
    var showUserName = false
    
    var controllerTitle = ""
    var isCreateContest = false
    var isCongratulationScreen = false
    var isFromInviteContest = false
    private var isNotificationHide = false
    
    var completionHandler : ((String)-> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInilized()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupInilized()
    }
    
    func configureNavigationBarWithController(controller:UIViewController, title:String, hideNotification:Bool, hideAddMoney:Bool, hideBackBtn:Bool, titleSelectable: Bool = false){
        SideMenuManager.default.leftMenuNavigationController?.presentationStyle = .menuSlideIn
        //        self.controller = controller
        //        self.controllerTitle = title
        if title == ""{
            showUserName = true
        }else{
            self.btnFantasyType.setTitle(title, for: .normal)
        }
        isNotificationHide = hideNotification
        btnFantasyType.isUserInteractionEnabled = false
//        self.btnFantasyType.titleLabel?.adjustsFontSizeToFitWidth = true
//        self.btnFantasyType.isUserInteractionEnabled = titleSelectable
//        self.btnFantasyType.setImage(titleSelectable ? UIImage(named: "arrow-white-down") : .none, for: .normal)
//        self.btnFantasyType.titleLabel?.adjustsFontSizeToFitWidth = true
//        self.btnFantasyType.tintColor = .white
        
        self.btnBack.isHidden = hideBackBtn
        
        if (self.btnFantasyType.currentTitle ?? "") != "Terms & Conditions"{
            NotificationCenter.default.addObserver(self, selector: #selector(self.updateTopNavigation(notification:)), name: NSNotification.Name(rawValue: Constants.kUpdateTopNavigation), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTopNavigation(notification:)), name: NSNotification.Name(rawValue: Constants.kRefreshTopNavigation), object: nil)

            
            self.viewAddMoney.isHidden = hideAddMoney
            if hideNotification == true{
                notificationWidth.constant = 0
            }else{
                notificationWidth.constant = 48
            }
            self.btnNotification.isHidden = hideNotification
            self.lblNotification.isHidden = hideNotification
        }
        else{
            self.viewAddMoney.isHidden = true
            notificationWidth.constant = 0
            self.btnNotification.isHidden = true
            self.lblNotification.isHidden = true
        }
        
        
    }
    
    @objc func updateTopNavigation(notification : NSNotification){
        self.setupUI(user: Constants.kAppDelegate.user)
    }
    
    @objc func refreshTopNavigation(notification : NSNotification){
        self.getBalance()
    }
    
    deinit {
        print("Removed NotificationCenter Observer")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kUpdateTopNavigation), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kRefreshTopNavigation), object: nil)

    }
    
    func setupInilized() {
        Bundle.main.loadNibNamed("CustomNavigation", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func getBalance(){
        
        guard let parent = self.parentViewController else { return }
        WebCommunication.shared.getUserProfile(hostController: parent, showLoader: false) { user in
            self.setupUI(user: user)
        }
    }
    
    func setupUI(user:UserDataModel?){
        if GlobalDataPersistance.shared.unreadNotificationCount == 0{
            self.lblNotification.isHidden = true
        }else{
            
            if isNotificationHide == false {
                self.lblNotification.isHidden = false
                self.lblNotification.text = "\(GlobalDataPersistance.shared.unreadNotificationCount)"
            }
        }
//        self.btnAddMoney.titleLabel?.numberOfLines = 1
//        self.btnAddMoney.titleLabel?.lineBreakMode = .byTruncatingTail
//        self.btnAddMoney.titleLabel?.adjustsFontSizeToFitWidth = true
        
        let walletAmount = "\(GDP.globalCurrency)\((Constants.kAppDelegate.user?.total_balance?.rounded(toPlaces: 2) ?? 0).formattedNumber())"
        self.lblWalletAmount.text = walletAmount
        //self.btnAddMoney.setTitle(, for: .normal)
        if showUserName == true{
            self.btnFantasyType.setTitle(user?.full_name ?? "", for: .normal)
        }
        
        var avatarImage = Constants.kFemaleAvatar
        if (user?.gender?.uppercased() ?? "") == "FEMALE"{
            avatarImage = Constants.kFemaleAvatar
        }else{
            avatarImage = Constants.kMaleAvatar
        }
        
        self.avatar.sd_setImage(with: URL(string: Constants.kAppDelegate.user?.image ?? ""), placeholderImage: avatarImage)
    }
    
    @IBAction func btnAddPressed(_ sender: Any) {
        //        let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "AddCashViewController") as! AddCashViewController
        //        self.controller?.navigationController?.pushViewController(pushVC, animated: true)
        
        if let tabbarController = Constants.kAppDelegate.tabbarController {
            if let parent = self.parentViewController {
                if let nav = parent.navigationController {
                    nav.popToRootViewController(animated: false)
                }else {
                    Constants.kAppDelegate.window?.rootViewController?.dismiss(animated: false)
                }
            }
            tabbarController.selectedIndex = 4
            if let nav = tabbarController.viewControllers?.last {
                if let navControllers = nav as? UINavigationController{
                    print(navControllers.viewControllers)
                    if let accountDetailVC = navControllers.viewControllers.first as? MyAccountDetailsVC {
                        accountDetailVC.addNotificationObserver()
                    }
                }
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.kMoveToAddCash), object: nil, userInfo: nil)
        }
    }
    
    @IBAction func btnFantasyTypePressed(_ sender: UIButton) {
//        
//        let arrtypes = ["Football", "Cricket", "Rugby"]
//        
//        let dropDown = DropDown()
//        dropDown.anchorView = sender // UIView or UIBarButtonItem
//        dropDown.textFont = UIFont(name: "Gilroy-Regular", size: 12.0)!
//        dropDown.dataSource = arrtypes
//        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
//            print("Selected item: \(item) at index: \(index)")
//            self.btnFantasyType.setTitle(item, for: .normal)
//            if let completionHandler = completionHandler {
//                completionHandler(item)
//            }
//            
//            dropDown.hide()
//        }
//        dropDown.show()
        
    }
    
    @IBAction func btnBackPressed(_ sender: Any) {
        var isIn = false
        if self.isCreateContest == true{
            let currentStack = ((self.parentViewController?.navigationController!.viewControllers)! as Array).reversed()
            for element in currentStack {
                if "\(type(of: element)).Type" == "\(type(of: MatchContestViewController.self))"
                {
                    isIn = false
                    self.parentViewController!.navigationController?.popToViewController(element, animated: true)
                    break
                }else{
                    isIn = true
                }
            }
            if isIn == true{
                self.parentViewController!.navigationController?.popToRootViewController(animated: true)
            }
        }
        else if self.isCongratulationScreen == true{
            let currentStack = (self.parentViewController!.navigationController!.viewControllers as Array).reversed()
            for element in currentStack {
                if "\(type(of: element)).Type" == "\(type(of: VerificationOptionsVC.self))"
                {
                    isIn = false
                    self.parentViewController!.navigationController?.popToViewController(element, animated: true)
                    break
                }else{
                    isIn = true
                }
            }
            if isIn == true{
                self.parentViewController!.navigationController?.popToRootViewController(animated: true)
            }
        }
        else if self.btnFantasyType.currentTitle == "Player Info"{
            self.parentViewController!.dismiss(animated: true)
            
        } else if isFromInviteContest == true {
            guard let nav = self.parentViewController?.navigationController else { return }
            nav.popToRootViewController(animated: true)
            
        }else{
            if let parent = self.parentViewController, ((parent as? CreateTeamViewController) != nil) {
                parent.alertBoxWithAction(message: ConstantMessages.DiscardTeamAlert, btn1Title: ConstantMessages.CancelBtn, btn2Title: ConstantMessages.OkBtn) {
                    parent.navigationController?.popViewController(animated: true)
                }
            }else {
                guard let nav =  self.parentViewController!.navigationController else {
                    self.parentViewController?.dismiss(animated: true)
                    return
                }
                nav.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func btnNotificationPressed(_ sender: Any) {
        
        guard let parent = self.parentViewController else { return }
        
        var isIn = false
        if let nv = parent.navigationController{
            let currentStack = (nv.viewControllers as Array).reversed()
            for element in currentStack {
                if "\(type(of: element)).Type" == "\(type(of: NotificationsViewController.self))"
                {
                    isIn = true
                    parent.navigationController?.popToViewController(element, animated: true)
                    break
                }
            }
        }
        if isIn == false{
            if "\(type(of: parent)).Type" == "\(type(of: PlayerPointsBreakupVC.self))" || "\(type(of: parent)).Type" == "\(type(of: PlayerInfoVC.self))"{
                
                Constants.kAppDelegate.window?.rootViewController?.dismiss(animated: false, completion: {
                    if let vc  = UIApplication.topViewController {
                        let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "NotificationsViewController") as! NotificationsViewController
                        vc.navigationController?.pushViewController(pushVC, animated: true)
                    }
                })
                
                //                self.parentViewController?.dismiss(animated: false, completion:{
                //                    print("Dismissed!")
                //                    //print(UIApplication.topViewController)
                //                    if let topVC  = UIApplication.topViewController {
                //                        if topVC.isModal {
                //                            topVC.dismiss(animated: false) {
                //
                //                                if let vc  = UIApplication.topViewController {
                //                                    let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "NotificationsViewController") as! NotificationsViewController
                //                                    vc.navigationController?.pushViewController(pushVC, animated: true)
                //                                }
                //                            }
                //                        }else {
                //                            let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "NotificationsViewController") as! NotificationsViewController
                //                            topVC.navigationController?.pushViewController(pushVC, animated: true)
                //                        }
                //
                //                    }
                //                })
            }else{
                let VC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "NotificationsViewController") as! NotificationsViewController
                parent.navigationController?.pushViewController(VC, animated: true)
            }
            
        }
    }
    
    @IBAction func btnSideMenuPressed(_ sender: UIButton) {
        self.parentViewController?.present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
}

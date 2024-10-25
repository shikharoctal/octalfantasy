//
//  MenusViewController.swift
//  GymPod
//
//  Created by Octal Mac 217 on 22/11/21.
//

import UIKit
import SideMenu
import SDWebImage

class MenusViewController: UIViewController {

    @IBOutlet weak var rightArrow: UIImageView!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgViewProfile: UIImageView!
    @IBOutlet weak var lblHoursBalance: UILabel!
    @IBOutlet weak var btnKYCStatus: UIButton!
    
    @IBOutlet weak var tblSideMenu: UITableView! {
        didSet {
        //    tblSideMenu.roundCorners(corners: [.topLeft], radius: 30.0)
        }
    }
    
    @IBOutlet weak var headerView: SideMenuHeaderView!
    private var moreItem : [String] = []
    private var isTapMore = false
    
    var arrMenuItems:[[String:Any]]? = nil
    var footerView:SideMenuFooterView? = nil
    var profileData: UserDataModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnKYCStatus.titleLabel?.adjustsFontSizeToFitWidth = true
        
        SideMenuManager.default.leftMenuNavigationController?.presentationStyle = .menuSlideIn

    
        moreItem.append("Terms & Conditions")
        moreItem.append("Privacy Policy")
        moreItem.append("Legality")
        //moreItem.append("Contest Invite code")
        moreItem.append("Fantasy Point System")
        moreItem.append("FAQs")
        moreItem.append("About Us")
        moreItem.append("Contact Us")
        moreItem.append("Refund Policy")
        //moreItem.append("Help")
        moreItem.append("Logout")

        arrMenuItems = CommonFunctions.getItemFromInternalResourcesforKey(key: "SideMenu")

        self.setupUI(user: Constants.kAppDelegate.user)
        // Do any additional setup after loading the view.
        if #available(iOS 15.0, *) {
            tblSideMenu.sectionHeaderTopPadding = 0.0
        }
//        self.tblSideMenu.separatorStyle = UITableViewCell.SeparatorStyle.none

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }
    
    func setupUI(user:UserDataModel?){
        
        let userName = (user?.full_name != "") ? (user?.full_name?.capitalized ?? "") : (user?.username?.capitalized ?? "")
        self.lblTitle.text = userName
        self.imgViewProfile.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.imgViewProfile.sd_setImage(with: URL(string: Constants.kAppDelegate.user?.image ?? ""), placeholderImage: Constants.kNoImageUser)
        
        self.headerView.controller = self
        self.headerView.updateView()
        self.headerView.roundCorners(corners: [.topLeft], radius: 30.0)
       
        footerView = SideMenuFooterView.instanceFromNib() as? SideMenuFooterView
        footerView?.controller = self
        footerView?.updateView()
        tblSideMenu?.tableFooterView = footerView
        
        tblSideMenu.reloadData()
    }
//
    override func viewDidAppear(_ animated: Bool) {
        if footerView != nil{
            footerView?.updateView()
        }
        
        updateView()
    }
    
    @IBAction func btnHeaderPressed(_ sender: Any) {
        
        let pushVC = Constants.KHelpStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(pushVC, animated: true)
    }
    
    
    @IBAction func btnKYCStatusPressed(_ sender: Any) {
        if (Constants.kAppDelegate.user?.email ?? "") == ""{
            
            let alert = UIAlertController(title: Constants.kAppDisplayName, message: ConstantMessages.UPDATE_PROFILE_KYC, preferredStyle:.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                let pushVC = Constants.KHelpStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                self.navigationController?.pushViewController(pushVC, animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }else{
            let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "VerificationOptionsVC") as! VerificationOptionsVC
            self.navigationController?.pushViewController(pushVC, animated: true)
        }
    }
}

//MARK: Header
extension MenusViewController {
    
    func updateView(){
        WebCommunication.shared.getUserProfile(hostController: self, showLoader: false) { user in
            self.profileData = user
            self.setupUI(user: user)
        }
        self.populateKYCResult()

    }
    
    func populateKYCResult(){
        WebCommunication.shared.getUserProfile(hostController: self, showLoader: false) { user in
            if (user?.kyc_verified ?? false) == true{
                self.rightArrow.isHidden = true
                self.btnKYCStatus.setTitle("KYC Verified", for: .normal)
                self.btnKYCStatus.setImage(UIImage(named: "kyc-verified"), for: .normal)
                self.btnKYCStatus.setTitleColor(UIColor.appKYCVerifiedColor, for: .normal)
            }
            else {
                self.rightArrow.isHidden = false
                self.btnKYCStatus.setTitle("Verify KYC", for: .normal)
                self.btnKYCStatus.setImage(nil, for: .normal)
                self.btnKYCStatus.setTitleColor(UIColor.hexStringToUIColor(hex: "#FB6D31"), for: .normal)
            }
        }
    }
}

extension MenusViewController:UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrMenuItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let title = arrMenuItems?[section]["title"] as? String ?? ""
        
        if title == "More" {
            if isTapMore{
                if let footerView = self.footerView{
                    footerView.viewSeprator.isHidden = false
                }
                return moreItem.count
            }else{
                if let footerView = self.footerView{
                    footerView.viewSeprator.isHidden = true
                }
                return 0
            }
        }
        return 0

    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTVCell", for: indexPath) as! SideMenuTVCell

        let item = moreItem[indexPath.row]
//        cell.imgViewIcon.image = UIImage(named: item["image"] as! String)
        cell.lblTitle.text = item
        cell.selectionStyle = .none
        //cell.lblTitle.textColor = UIColor.appTitleColor
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view:HeaderViewSideMenu = Bundle.main.loadNibNamed("HeaderViewSideMenu", owner: self, options: nil)?.first as! HeaderViewSideMenu
        let title = arrMenuItems?[section]["title"] as? String ?? ""
        view.lblTitle.text = title
        view.imgIcon.image = UIImage(named: arrMenuItems?[section]["image"] as? String ?? "")
//        if section == 0 {
//            view.imgIcon.borderColor = .white
//            view.imgIcon.borderWidth = 1
//            view.imgIcon.image = imgViewProfile.image
//            view.imgIcon.cornerRadius = view.imgIcon.frame.height/2
//        }else {
//            view.imgIcon.image = UIImage(named: arrMenuItems?[section]["image"] as? String ?? "")
//            view.imgIcon.cornerRadius = 0
//            view.imgIcon.borderWidth = 0
//            view.imgIcon.borderColor = .clear
//        }
        
        view.imgArrow.isHidden = true

        if title == "More" {
            view.imgArrow.isHidden = false
            if isTapMore {
                view.viewLine.isHidden = true
                view.imgArrow.image = Constants.kArrowUp
            }else{
                view.viewLine.isHidden = false
                view.imgArrow.image = Constants.kArrowDown
            }
        }
        view.onButtonTapped = { [self] in
            if title == "More" {
                if isTapMore {
                    isTapMore = false
                }else{
                    isTapMore = true
                }
                DispatchQueue.main.async {
                    self.tblSideMenu.reloadData()
//                    self.tblSideMenu.beginUpdates()
//                    self.tblSideMenu.endUpdates()
                }
                
            }else{
                goTapToScreen(section: section)
            }
        }
        return view
    }
        
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = moreItem[indexPath.row]
        print(item)
        
        switch indexPath.row {
            
        case 0: // Terms and Conditions
            let vc = Constants.KSideMenuStoryboard.instantiateViewController(withIdentifier: "WebPageViewController") as! WebPageViewController
            vc.url = URL(string: (URLMethods.BaseURL + URLMethods.termsConditions))
            vc.headerText = moreItem[indexPath.row]
            WebCommunication.shared.getCommonContent(hostController: self, slug: (URLMethods.BaseURL + URLMethods.termsConditions), showLoader: true) { data in
                vc.htmlData = data
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            break
            
        case 1: //Privacy Policy
            let vc = Constants.KSideMenuStoryboard.instantiateViewController(withIdentifier: "WebPageViewController") as! WebPageViewController
            vc.url = URL(string: (URLMethods.BaseURL + URLMethods.privacyPolicy))
            vc.headerText = moreItem[indexPath.row]
            WebCommunication.shared.getCommonContent(hostController: self, slug: (URLMethods.BaseURL + URLMethods.privacyPolicy), showLoader: true) { data in
                vc.htmlData = data
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case 2: // Legality
            let vc = Constants.KSideMenuStoryboard.instantiateViewController(withIdentifier: "WebPageViewController") as! WebPageViewController
            vc.url = URL(string: (URLMethods.BaseURL + URLMethods.legality))
            vc.headerText = moreItem[indexPath.row]
            WebCommunication.shared.getCommonContent(hostController: self, slug: (URLMethods.BaseURL + URLMethods.legality), showLoader: true) { data in
                vc.htmlData = data
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case 3: // Fantasy Point System
            let vc = Constants.KSideMenuStoryboard.instantiateViewController(withIdentifier: "WebPageViewController") as! WebPageViewController
            vc.url = URL(string: URLMethods.FantasyPointSystem_URL)
            vc.headerText = moreItem[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 4: // FAQ
            let vc = Constants.KMoreStoryboard.instantiateViewController(withIdentifier: "FAQViewController") as! FAQViewController
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 5: // About Us
            let vc = Constants.KSideMenuStoryboard.instantiateViewController(withIdentifier: "WebPageViewController") as! WebPageViewController
            vc.headerText = moreItem[indexPath.row]
            WebCommunication.shared.getCommonContent(hostController: self, slug: (URLMethods.BaseURL + URLMethods.aboutUs), showLoader: true) { data in
                vc.htmlData = data
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case 6: // Contact Us
            let vc = Constants.KSideMenuStoryboard.instantiateViewController(withIdentifier: "WebPageViewController") as! WebPageViewController
            vc.headerText = moreItem[indexPath.row]
            WebCommunication.shared.getCommonContent(hostController: self, slug: (URLMethods.BaseURL + URLMethods.ContactUsWebView_URL), showLoader: true) { data in
                vc.htmlData = data
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case 7: // Refund Policy
            let vc = Constants.KSideMenuStoryboard.instantiateViewController(withIdentifier: "WebPageViewController") as! WebPageViewController
            vc.headerText = moreItem[indexPath.row]
            WebCommunication.shared.getCommonContent(hostController: self, slug: (URLMethods.BaseURL + URLMethods.refundPolicy), showLoader: true) { data in
                vc.htmlData = data
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case 8: // Logout
            
            let alert = UIAlertController(title: Constants.kAppDisplayName, message: ConstantMessages.LogoutApp, preferredStyle:.alert)
            
            let logout = UIAlertAction(title: "Logout", style: .default) { _ in
                Constants.kAppDelegate.logOutApp()
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in }

            alert.addAction(logout)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
            
            break
                
        default:
            break
        }
    }
    
    func goTapToScreen (section : Int){
        switch section {
            
        case 0: // My Account Details
            
            let pushVC = Constants.KHelpStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            self.navigationController?.pushViewController(pushVC, animated: true)
            break
            
        case 1: // Wallet
            
            if let tabbarController = Constants.kAppDelegate.tabbarController{
                SideMenuManager.defaultManager.leftMenuNavigationController?.dismiss(animated: true, completion: {
                    if tabbarController.selectedIndex != 4{
                        tabbarController.selectedIndex = 4
                    }
                })
            }
            break
            
        case 2:// How to Play
            let vc = Constants.KSideMenuStoryboard.instantiateViewController(withIdentifier: "WebPageViewController") as! WebPageViewController
            vc.headerText = "How to Play"
            let slug = URLMethods.howToPlay
            WebCommunication.shared.getCommonContent(hostController: self, slug: (URLMethods.BaseURL + slug), showLoader: true) { data in
                vc.htmlData = data
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
        case 3: // Season History
            let vc = Constants.KSideMenuStoryboard.instantiateViewController(withIdentifier: "SeasonHistoryVC") as! SeasonHistoryVC
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func addDashedBorder(dashColor:UIColor, dash:NSNumber, gap:NSNumber, width:CGFloat, cornerRadius:CGFloat) {
        let color = dashColor.cgColor

        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)

        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = width
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [dash,gap]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: cornerRadius).cgPath

        self.layer.addSublayer(shapeLayer)
    }
}

extension UITableViewCell {
    func removeSectionSeparators() {
        for subview in subviews {
            if subview != contentView && subview.frame.width == frame.width {
                subview.removeFromSuperview()
            }
        }
    }
}

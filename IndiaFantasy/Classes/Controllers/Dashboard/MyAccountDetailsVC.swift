//
//  MyAccountDetailsVC.swift
//  CrypTech
//
//  Created by New on 14/03/22.
//

import UIKit

class MyAccountDetailsVC: BaseClassVC {
    
    @IBOutlet weak var navigationView: CustomNavigation!
    @IBOutlet weak var lblTotalBalance: UILabel!
    @IBOutlet weak var lblCashBonus: UILabel!
    //@IBOutlet weak var lblWinnings: UILabel!
    @IBOutlet weak var lblAmountAdded: UILabel!
    //@IBOutlet weak var btnBalance: UIButton!
//    @IBOutlet weak var txtCouponCode: UITextField!
    @IBOutlet weak var lblReferralAmount: UILabel!
    @IBOutlet weak var viewKYCVerify: UIView!
    @IBOutlet weak var viewReferral: UIView!
    @IBOutlet weak var lblReferralLink: UILabel!
    @IBOutlet weak var viewApplyReferral: UIView!
    
    var tipView = EasyTipHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationView.configureNavigationBarWithController(controller: self, title: Constants.kAppDelegate.user?.username ?? "", hideNotification: false, hideAddMoney: true, hideBackBtn: true)
        navigationView.avatar.isHidden = true
        navigationView.sideMenuBtnView.isHidden = false
        navigationView.img_BG.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshAccount(notification:)), name: NSNotification.Name(rawValue: Constants.kRefreshAccountDetails), object: nil)

    }
    
    
    @objc func refreshAccount(notification : NSNotification)
    {
        self.setupUI()
    }
    
    func addNotificationObserver(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.kMoveToAddCash), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.navigateToAddCash(notification:)), name: NSNotification.Name(rawValue: Constants.kMoveToAddCash), object: nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
//        self.tabBarController?.tabBar.isHidden = false
        self.populateKYCResult()
    }
    
    
    @objc func navigateToAddCash(notification : NSNotification)
    {
        let VC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "AddCashViewController") as! AddCashViewController
        VC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(VC, animated: false)
    }
    
    
    func populateKYCResult(){
        WebCommunication.shared.getCommonDetails(hostController: self, showLoader: false) { user in
//            if GlobalDataPersistance.shared.pan_verified == 3 && GlobalDataPersistance.shared.bank_verified == 3{
//                self.viewKYCVerify.isHidden = true
//            }
//            else {
//                self.viewKYCVerify.isHidden = false
//            }
            self.setupUI()
        }
    }
    
    func setupUI(){
        WebCommunication.shared.getUserProfile(hostController: self, showLoader: false) { user in
            
            self.lblTotalBalance.text = (Constants.kAppDelegate.user?.total_balance?.rounded(toPlaces: 2) ?? 0).formattedNumber()
            //.self.btnBalance.setTitle("\(GDP.globalCurrency)\((Constants.kAppDelegate.user?.total_balance?.rounded(toPlaces: 2) ?? 0).formattedNumber())", for: .normal)
            self.lblAmountAdded.text = "\((Constants.kAppDelegate.user?.deposit_amount?.rounded(toPlaces: 2) ?? 0).formattedNumber())"
            //self.lblWinnings.text = "\(GDP.globalCurrency)\((Constants.kAppDelegate.user?.unUsedBoosterCount?.rounded(toPlaces: 2) ?? 0).formattedNumber())"
            self.lblCashBonus.text = "\((Constants.kAppDelegate.user?.bonus?.rounded(toPlaces: 2) ?? 0).formattedNumber())"
            self.lblReferralAmount.text = "\((Constants.kAppDelegate.user?.winngs_amount?.rounded(toPlaces: 2) ?? 0).formattedNumber())"
            self.lblReferralLink.text = Constants.kAppDelegate.user?.referral_code ?? ""
          //  self.viewApplyReferral.isHidden = (Constants.kAppDelegate.user?.isUsedReferral ?? false)

        }
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAddMoneyPressed(_ sender: Any) {
        
        let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "AddCashViewController") as! AddCashViewController
        pushVC.completion = { _ in
            let alert = UIAlertController(title: Constants.kAppDisplayName, message: ConstantMessages.PaymentSuccessful, preferredStyle:.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            }))
            self.present(alert, animated: true, completion: nil)
        }
        self.navigationController?.pushViewController(pushVC, animated: true)
//
    }
    
    @IBAction func actionRecentTransactions(_ sender: Any) {
        
        let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "RecentTransactionsVC") as! RecentTransactionsVC
        
        self.navigationController?.pushViewController(pushVC, animated: true)
    }
    
    
    @IBAction func btnVerifyPressed(_ sender: UIButton) {
        let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "VerificationOptionsVC") as! VerificationOptionsVC
        self.navigationController?.pushViewController(pushVC, animated: true)
    }
    
    @IBAction func btnCopyReferralLinkPressed(_ sender: UIButton) {
        
        AppManager.showToast(ConstantMessages.COPY_SUCCESS.localized(), view: self.view)
        UIPasteboard.general.string = lblReferralLink.text ?? ""
    }
    
    @IBAction func btnTopInfluencersPressed(_ sender: UIButton) {
        
        let vc = Constants.KSideMenuStoryboard.instantiateViewController(withIdentifier: "InfluencersVC") as! InfluencersVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnShareReferralLinkPressed(_ sender: UIButton) {
        
        guard let referralCode = Constants.kAppDelegate.user?.referral_code else { return }
//        guard let link = URL(string: "\(URLMethods.referralWebAppLink)\(referralCode)") else { return }
//
//        let textToShare = [ link.absoluteString ]
//        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
//        activityViewController.popoverPresentationController?.sourceView = self.view
//        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
//        self.present(activityViewController, animated: true, completion: nil)
        
        guard let link = URL(string: "\(URLMethods.DeepLinkURL)/?referralCode=\(referralCode)") else { return }
        
        CommonFunctions().getDynamicLink(link: link) { dynamicLink in
            
            //let text = "Start playing on India’s fantasy. Think, you can beat me? Use my invite code: \(referralCode.uppercased()) or\nclick on this link \(dynamicLink) to register and let the games begin!"
            let textToShare = [ dynamicLink ]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnApplyReferralPressed(_ sender: UIButton) {
        
        guard let vc = Constants.KLoginSignupStoryboard.instantiateViewController(withIdentifier: "ReferralCodeViewController") as? ReferralCodeViewController else {return}
        
        vc.completionHandler = { status in
           // self.viewApplyReferral.isHidden = status
        }
        
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnToolTipPressed(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        tipView.showEasyTip(sender: sender, onView: self.view, withText: "Please note: This Referral Amount will be paid to users quarterly.")
    }
    
    @IBAction func btnWithdrawAmountPressed(_ sender: UIButton) {
        if Constants.kAppDelegate.user?.email ?? "" == ""{
            let alert = UIAlertController(title: Constants.kAppDisplayName, message: ConstantMessages.UPDATE_PROFILE_KYC_Withdraw, preferredStyle:.alert)
            alert.addAction(UIAlertAction(title: "Update Profile", style: .default, handler: { action in
                let pushVC = Constants.KHelpStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                self.navigationController?.pushViewController(pushVC, animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }else{
            if (Constants.kAppDelegate.user?.kyc_verified ?? false) == true{
                let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "WithdrawAmountVC") as! WithdrawAmountVC
                self.navigationController?.pushViewController(pushVC, animated: true)
            }else {
                let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "VerificationOptionsVC") as! VerificationOptionsVC
                self.navigationController?.pushViewController(pushVC, animated: true)
            }
        }
       
    }
    
    
}
extension MyAccountDetailsVC{
    
//    func submitValidData(){
//        if self.txtCouponCode.text?.count == 0
//        {
//            AppManager.showToast(ConstantMessages.PromoCode_Empty, view: (self.view)!)
//            return
//        }
//
//        self.applyCoupan(coupanCode: self.txtCouponCode.text ?? "")
//    }
//
//    func applyCoupan(coupanCode:String){
//
//        let params:[String:String] = ["coupon_code":coupanCode]
//
//        let url = URLMethods.BaseURL + URLMethods.applyCouppon
//
//        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
//
//            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
//
//            if isSuccess == true{
//
//                if let data = result?.object(forKey: "results") as? [String:Any]{
//                    guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
//                          let tblData = try? JSONDecoder().decode(CouponDetails.self, from: jsonData)else {return }
//                    let coupanDetails = tblData
//
//                    let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "AddCashViewController") as! AddCashViewController
//                    pushVC.isFromCoupanCode = true
//                    pushVC.coupanDetails = coupanDetails
//                    pushVC.completionHandler = { (balance) in
//                        print(balance)
//                    }
//                    self.navigationController?.pushViewController(pushVC, animated: true)
//                }
//            }
//
//            else{
//                AppManager.showToast(msg ?? "", view: self.view)
//            }
//            AppManager.stopActivityIndicator(self.view)
//        }
//        AppManager.startActivityIndicator(sender: self.view)
//    }
}
extension MyAccountDetailsVC:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            return false
        }
        
//        if textField == txtCouponCode{
//
//            let currentString: NSString = (textField.text ?? "") as NSString
//            let newString: NSString =
//                currentString.replacingCharacters(in: range, with: string) as NSString
//            return newString.length <= Constants.kCoupenLength
//        }
       
        return true
    }
}

//
//  ReferEarnViewController.swift
//
//  Created by Octal-Mac on 01/11/22.
//

import UIKit
import FirebaseDynamicLinks

class ReferEarnViewController: BaseClassVC {
  
    @IBOutlet weak var navigationView: CustomNavigation!
    
    @IBOutlet weak var viewReferralCode: UIView!
    @IBOutlet weak var txtCodeInvite: UITextField! {
        didSet {
            
        }
    }
    @IBOutlet weak var scrollConHeight: NSLayoutConstraint!
    var faqsList: [Doc] = []
    private var selectFaqIndex : Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationView.configureNavigationBarWithController(controller: self, title: "Refer & Earn", hideNotification: false, hideAddMoney: true, hideBackBtn: true)
        navigationView.avatar.isHidden = true
        navigationView.sideMenuBtnView.isHidden = false
        self.txtCodeInvite.text = Constants.kAppDelegate.user?.referral_code?.uppercased() ?? ""

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewReferralCode.addDashedBorder(dashColor: UIColor.white, dash: 10, gap: 5, width: 1, cornerRadius: 10.0)

    }
    
    @IBAction func actionCopy(_ sender: Any) {
        
        AppManager.showToast(ConstantMessages.COPY_SUCCESS.localized(), view: self.view)
        UIPasteboard.general.string = txtCodeInvite.text
    }
    
    @IBAction func btnSharePressed(_ sender: UIButton) {
//        guard let link = URL(string: "\(URLMethods.DeepLinkURL)/?referralCode=\(self.txtCodeInvite.text ?? "")") else { return }
//        let dynamicLinksDomainURIPrefix = "\(URLMethods.DeepLinkURL)"
//        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix)
//        linkBuilder!.iOSParameters = DynamicLinkIOSParameters(bundleID: Constants.kBundleID ?? "")
//        linkBuilder!.androidParameters = DynamicLinkAndroidParameters(packageName: Constants.kAndroiPackageName)
//
//        guard let longDynamicLink = linkBuilder?.url?.absoluteString else { return }
//        print("The long URL is: \(longDynamicLink)")
//        
//        
//        let text = "I have gifted you \(GDP.globalCurrency) 150 to start playing on India’s fantasy. Think, you can beat me? Use my invite code: \(self.txtCodeInvite.text?.uppercased() ?? "") or \n\n click on this link \(longDynamicLink) to register and let the games begin!"
//        let textToShare = [ text ]
//        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
//        activityViewController.popoverPresentationController?.sourceView = self.view
//        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
//        self.present(activityViewController, animated: true, completion: nil)
    }
    
}



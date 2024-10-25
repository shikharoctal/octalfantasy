//
//  InviteYourFriendsVC.swift
//  CrypTech
//
//  Created by New on 08/03/22.
//

import UIKit

class InviteYourFriendsVC: BaseClassWithoutTabNavigation {

    @IBOutlet weak var txtCodeInvite: UITextField! {
        didSet {
            
        }
    }
    @IBOutlet weak var navigationView: CustomNavigation!
    @IBOutlet weak var lblMessage: UILabel!
    
    @IBOutlet weak var lblTitle: UILabel!
    var isCreateContest = false
    var inviteCode = String()
    
    @IBOutlet weak var lblSubMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationView.configureNavigationBarWithController(controller: self, title: "Invite your friends", hideNotification: false, hideAddMoney: true, hideBackBtn: false)
        navigationView.isCreateContest = self.isCreateContest
        self.lblMessage.text = ""

        if self.isCreateContest == true{
            self.lblTitle.text = "Congratulations!!"
            self.lblMessage.text = "Your contest has been created"
            self.lblSubMessage.text = "Share the contest code"
 
            self.txtCodeInvite.text = self.inviteCode.uppercased()
        }else{
            WebCommunication.shared.getUserProfile(hostController: self, showLoader: false) { user in
//                self.lblMessage.text = "For every friend that joins, you both get ₹\(Constants.kAppDelegate.user?.referred_amount ?? 0.0) for free in wallet"
                self.txtCodeInvite.text = Constants.kAppDelegate.user?.referral_code?.uppercased() ?? ""

            }
        }
       
    }
    
    @IBAction func actionBack(_ sender: Any) {
        if self.isCreateContest == true{
            let currentStack = (self.navigationController!.viewControllers as Array).reversed()
            var isIn = false
            for element in currentStack {
              if "\(type(of: element)).Type" == "\(type(of: MatchContestViewController.self))"
              {
                isIn = false
                self.navigationController?.popToViewController(element, animated: true)
                break
              }else{
                  isIn = true
              }
            }
            
            if isIn == true{
                self.navigationController?.popToRootViewController(animated: true)
            }
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func actionShare(_ sender: Any) {
        
        if isCreateContest == true{
            
//            guard let link = URL(string: "\(URLMethods.contestInviteWebAppLink)\(inviteCode)") else { return }
//
//            let textToShare = [ link.absoluteString ]
//            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
//            activityViewController.popoverPresentationController?.sourceView = self.view
//            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
//            self.present(activityViewController, animated: true, completion: nil)
            
            guard let link = URL(string: "\(URLMethods.DeepLinkURL)/?inviteCode=\(inviteCode)") else { return }
            
            CommonFunctions().getDynamicLink(link: link) { dynamicLink in
                
                //let text = "You've been challenged! \n\nThink you can beat me? Join the contest on India’s fantasy for the \(GDP.selectedMatch?.series_name ?? "") match and prove it! \n\nClick on this link \(dynamicLink) or use my invite code \(self.inviteCode.uppercased()) to accept this challenge!"
                let textToShare = [ dynamicLink ]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
                self.present(activityViewController, animated: true, completion: nil)
            }
            
        }else{
            
//            guard let referralCode = self.txtCodeInvite.text, let link = URL(string: "\(URLMethods.referralWebAppLink)\(referralCode)") else { return }
//
//            let textToShare = [ link.absoluteString ]
//            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
//            activityViewController.popoverPresentationController?.sourceView = self.view
//            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
//            self.present(activityViewController, animated: true, completion: nil)
            
            guard let link = URL(string: "\(URLMethods.DeepLinkURL)/?referralCode=\(self.txtCodeInvite.text ?? "")") else { return }
            
            CommonFunctions().getDynamicLink(link: link) { dynamicLink in
                
                //let text = "I have gifted you \(GDP.globalCurrency)150 to start playing on India’s fantasy. Think, you can beat me? Use my invite code: \(self.txtCodeInvite.text?.uppercased() ?? "") or \n\n click on this link \(dynamicLink) to register and let the games begin!"
                let textToShare = [ dynamicLink ]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func actionCopy(_ sender: Any) {
        
        AppManager.showToast(ConstantMessages.COPY_SUCCESS.localized(), view: self.view)
        UIPasteboard.general.string = txtCodeInvite.text
    }
}

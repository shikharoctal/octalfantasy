//
//  SideMenuHeaderView.swift
//  GymPod
//
//  Created by Octal Mac 217 on 23/11/21.
//

import UIKit
import SDWebImage
import SideMenu

class SideMenuHeaderView: UIView {
       
    @IBOutlet weak var lblBalance: UILabel!
    @IBOutlet var contentView: UIView!

    var controller:MenusViewController? = nil
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "SideMenuHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
      }
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            setupInilized()
         
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setupInilized()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
           // self.setUpUserInterface()
        }

     func setupInilized() {
            Bundle.main.loadNibNamed("SideMenuHeaderView", owner: self, options: nil)
            self.addSubview(contentView)
            contentView.frame = self.bounds
            contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        }


    
    func updateView(){
        
        lblBalance.text = "\((Constants.kAppDelegate.user?.total_balance?.rounded(toPlaces: 2) ?? 0).formattedNumber())" //\(GDP.globalCurrency)
    }
    
    @objc func sendPostNavigationRequest(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.kMoveToAddCash), object: nil, userInfo: nil)
    }
    
    @IBAction func btnBalancePressed(_ sender: Any) {
        
        SideMenuManager.defaultManager.leftMenuNavigationController?.dismiss(animated: true, completion: {
            if let tabbarController = Constants.kAppDelegate.tabbarController {
                tabbarController.selectedIndex = 4
                if let nav = tabbarController.viewControllers?.last {
                    if let navControllers = nav as? UINavigationController{
                        print(navControllers.viewControllers)
                        if let accountDetailVC = navControllers.viewControllers.first as? MyAccountDetailsVC {
                            accountDetailVC.addNotificationObserver()
                        }
                    }

                }
                self.sendPostNavigationRequest()
            }
        })
    }
}

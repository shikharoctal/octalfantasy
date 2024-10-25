//
//  TabBarVC.swift
//  Lifferent
//
//  Created by sumit sharma on 29/01/21.
//

import UIKit

class TabBarVC: UITabBarController {
    /// Image view to temporarily cover feed and content so it doesn't appear to flash when showing login screen
    var backgroundImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.tabBar.backgroundColor = UIColor.blue
        self.addBackgroundImageView()
        self.setUpTabBarItems()
        //        self.setGradientBackground(colorOne: UIColor.colorFromHex("#237BBF"), colorTwo: .white, colorThree: UIColor.colorFromHex("00134A"))
        
        //  self.addBackgroundImageView()
    }
    
    func setGradientBackground(colorOne: UIColor, colorTwo: UIColor, colorThree:UIColor)  {
        let gradientlayer = CAGradientLayer()
        gradientlayer.frame = tabBar.bounds
        gradientlayer.colors = [
            colorOne.cgColor,colorThree.cgColor]
        gradientlayer.locations = [ 0.0, 0.5]
        gradientlayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientlayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        self.tabBar.layer.insertSublayer(gradientlayer, at: 0)
    }
    
    // MARK: - this is fun for create tabbar item
    func setUpTabBarItems(){
        
        let bgView: UIImageView = UIImageView(image: UIImage(named: "tab_back"))
        
        bgView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 100)
        self.tabBar.addSubview(bgView)
        
        let contestItem = (self.tabBar.items?[0])! as UITabBarItem
        contestItem.image = UIImage(named: "home-unselected")?.withRenderingMode(.alwaysOriginal)
        contestItem.image?.withTintColor(.white)
        contestItem.selectedImage = UIImage(named: "home-selected")?.withRenderingMode(.alwaysOriginal)
        contestItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        contestItem.title = "Money Pool"//"Chat"
        
        let homeItem = (self.tabBar.items?[1])! as UITabBarItem
        homeItem.image = UIImage(named: "ic_prizepool_white")?.withRenderingMode(.alwaysOriginal)
        homeItem.selectedImage = UIImage(named: "ic_prizepool_active")?.withRenderingMode(.alwaysOriginal)
        homeItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        homeItem.title = "Fantasy"
        
        let gameItem = (self.tabBar.items?[2])! as UITabBarItem
        gameItem.image = UIImage(named: "ic_logo")?.withRenderingMode(.alwaysOriginal)
        gameItem.selectedImage = UIImage(named: "ic_logo")?.withRenderingMode(.alwaysOriginal)
        gameItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        gameItem.title = "My Fantasy"
        
        
        let supportItem = (self.tabBar.items?[3])! as UITabBarItem
        supportItem.image = UIImage(named: "chat_unselected")?.withRenderingMode(.alwaysOriginal)
        supportItem.selectedImage = UIImage(named: "chat_selected")?.withRenderingMode(.alwaysOriginal)
        supportItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        supportItem.title = "Offers"//"Shop"
        
        let moreItem = (self.tabBar.items?[4])! as UITabBarItem
        moreItem.image = UIImage(named: "more-unselected")?.withRenderingMode(.alwaysOriginal)
        moreItem.selectedImage = UIImage(named: "more-selected")?.withRenderingMode(.alwaysOriginal)
        moreItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        moreItem.title = "Wallet"
        
        let selectedColor   = UIColor.appYellowColor
        let unselectedColor = UIColor.white
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: unselectedColor, NSAttributedString.Key.font: UIFont(name: "Kanit-Medium", size: 12.0)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedColor, NSAttributedString.Key.font: UIFont(name: "Kanit-Medium", size: 12.0)!], for: .selected)
        
//        if let items = self.tabBar.items {
//            // Set selected and unselected colours
////            let selectedColor = UIColor.red // Change this to your desired color
////            let unselectedColor = UIColor.gray // Change this to your desired color
//
//            let selectedColor   = UIColor.appYellowColor
//            let unselectedColor = UIColor.white
//            
//            for item in items {
//                // Set text attributes for selected state
//                UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedColor, NSAttributedString.Key.font: UIFont(name: "Kanit-Medium", size: 12.0)!], for: .selected)
//
//                // Set text attributes for unselected state
//                UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: unselectedColor, NSAttributedString.Key.font: UIFont(name: "Kanit-Medium", size: 12.0)!], for: .normal)
//
//                // Optionally, you can also set the image tint color for selected and unselected states
//                item.selectedImage = item.selectedImage?.withRenderingMode(.alwaysTemplate)
//                item.image = item.image?.withRenderingMode(.alwaysTemplate)
//                
//                // Set the tint color for selected and unselected states
//                item.image?.withTintColor(unselectedColor, renderingMode: .alwaysTemplate)
//                item.selectedImage?.withTintColor(selectedColor, renderingMode: .alwaysTemplate)
//            }
//        }
        
        
        self.addBackgroundImageView()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //        let indexOfTab = tabBar.items?.index(of: item)
        //        print("pressed tabBar: \(String(describing: indexOfTab))")
        //        if item.tag == 3{
        //            //do our animations
        //            UIApplication.shared.applicationIconBadgeNumber = 0
        //        }
        
    }
    
    let simpleCompleationHandler:()->Void =  {
        print("From The Compleation handler!")
    }
    
    
    func addBackgroundImageView() {
        self.backgroundImageView = UIImageView(frame:self.tabBar.frame)
        
        self.backgroundImageView.image = UIImage(named: "top_banner")
        self.tabBar.addSubview(self.backgroundImageView)
    }
}


func completionhandler()-> Void{
    
}

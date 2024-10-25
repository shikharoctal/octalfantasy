//
//  SeasonsTabBarVC.swift
//  India’s fantasy
//
//  Created by admin on 24/04/23.
//

import UIKit

class SeasonsTabBarVC: UITabBarController {

    var backgroundImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addBackgroundImageView()
        self.setUpTabBarItems()
    }

    func setUpTabBarItems(){
        
        let bgView: UIImageView = UIImageView(image: UIImage(named: "tab_back"))
        
        bgView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 100)
        self.tabBar.addSubview(bgView)
        
        let homeItem = (self.tabBar.items?[0])! as UITabBarItem
        homeItem.image = UIImage(named: "SeasonsHome_ic")?.withRenderingMode(.alwaysOriginal)
        homeItem.selectedImage = UIImage(named: "SeasonsHome_ic")?.withRenderingMode(.alwaysOriginal)
        homeItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        homeItem.title = "Main"
        
        let contestItem = (self.tabBar.items?[1])! as UITabBarItem
        contestItem.image = UIImage(named: "SeasonsContest_ic")?.withRenderingMode(.alwaysOriginal)
        contestItem.selectedImage = UIImage(named: "SeasonsContest_ic")?.withRenderingMode(.alwaysOriginal)
        contestItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        contestItem.title = "Contest"
        
        
        let gameItem = (self.tabBar.items?[2])! as UITabBarItem
        gameItem.image = UIImage(named: "SeasonsStats_ic")?.withRenderingMode(.alwaysOriginal)
        gameItem.selectedImage = UIImage(named: "SeasonsStats_ic")?.withRenderingMode(.alwaysOriginal)
        gameItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        gameItem.title = "Stats"
        
        let winningItem = (self.tabBar.items?[3])! as UITabBarItem
        winningItem.image = UIImage(named: "shop-unselected")?.withRenderingMode(.alwaysOriginal)
        winningItem.selectedImage = UIImage(named: "shop-unselected")?.withRenderingMode(.alwaysOriginal)
        winningItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        winningItem.title = "Winning"
        
        
        let selectedColor   = UIColor.appThemeColor
        let unselectedColor = UIColor.white
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: unselectedColor, NSAttributedString.Key.font: UIFont(name: "Gilroy-Medium", size: 12.0)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedColor, NSAttributedString.Key.font: UIFont(name: "Gilroy-Medium", size: 12.0)!], for: .selected)
        
        //self.addBackgroundImageView()
    }
    

    func addBackgroundImageView() {
        self.backgroundImageView = UIImageView(frame:self.tabBar.frame)
        
        self.backgroundImageView.image = UIImage(named: "top_banner")
        self.tabBar.addSubview(self.backgroundImageView)
    }
}

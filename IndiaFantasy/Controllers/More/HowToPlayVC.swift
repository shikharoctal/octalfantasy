//
//  HowToPlayVC.swift
//  CrypTech
//
//  Created by New on 09/03/22.
//

import UIKit

class HowToPlayVC: BaseClassWithoutTabNavigation {
    
    @IBOutlet weak var navigationView: CustomNavigation!
    var arrItems = CommonFunctions.getItemFromInternalResourcesforKey(key: "HowToPlay")
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUIData()
    }
    
    func setUIData(){
        
        navigationView.configureNavigationBarWithController(controller: self, title: "How to Play", hideNotification: false, hideAddMoney: true, hideBackBtn: false)
        tableView.dataSource = self
        tableView.delegate   = self
    }
   
}


//MARK: UITableView (DataSource & Delegate) Methods
extension HowToPlayVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HowToPlayTVCell", for: indexPath) as! HowToPlayTVCell
        cell.lblTitle.font = UIFont(name: "Gilroy-Semibold", size: 14.0)!
        let item = arrItems[indexPath.row]
        cell.lblTitle.text = item["title"] as? String ?? ""
        cell.imgIcon.image = UIImage(named: item["image"] as? String ?? "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = Constants.KSideMenuStoryboard.instantiateViewController(withIdentifier: "WebPageViewController") as! WebPageViewController
        vc.headerText = arrItems[indexPath.row]["title"] as? String ?? ""
        var slug = ""
        if indexPath.row == 0{
            slug = URLMethods.howToPlay
        }else{
            slug = URLMethods.cricket
        }
        WebCommunication.shared.getCommonContent(hostController: self, slug: (URLMethods.BaseURL + slug), showLoader: true) { data in
            vc.htmlData = data
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}

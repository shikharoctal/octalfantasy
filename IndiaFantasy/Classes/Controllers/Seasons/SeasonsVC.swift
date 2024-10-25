//
//  SeasonsVC.swift
//  India’s fantasy
//
//  Created by admin on 17/04/23.
//

import UIKit

class SeasonsVC: BaseClassVC {
    
    @IBOutlet weak var navigationView: CustomNavigation!
    @IBOutlet weak var tblSeasons: UITableView!
    
    private let cellId = "SeasonsTVCell"
    private var arrSeasonsItems = [[String: Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = false
        let title = GDP.getFantasyTitle()
        navigationView.btnFantasyType.setTitle(title, for: .normal)
        navigationView.completionHandler = { type in
            
            switch type {
            case "Cricket":
                GDP.switchToCricket()
                break
            default:
                break
            }
        }
    }
    
    private func setupUI() {
        
        setupNavigationView()
        tblSeasons.contentInset = .init(top: 10, left: 0, bottom: 20, right: 0)
        arrSeasonsItems = CommonFunctions.getItemFromInternalResourcesforKey(key: "Seasons")
        addNotificationObserver()
    }
    
    private func setupNavigationView() {
        
        let title = GDP.getFantasyTitle()
        navigationView.configureNavigationBarWithController(controller: self, title: title, hideNotification: false, hideAddMoney: true, hideBackBtn: true, titleSelectable: true)
        navigationView.sideMenuBtnView.isHidden = false
        navigationView.avatar.isHidden = true
    }
    
    private func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.pushToContest(notification:)), name: NSNotification.Name(rawValue: Constants.kMoveToContest), object: nil)
    }
    
    @objc func pushToContest(notification : NSNotification){
        
        if let contestVC = self.navigationController?.getViewController(of: ContestViewController.self) {
            self.navigationController?.popToViewController(contestVC, animated: false)
        }else {
            let contestVC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "ContestViewController") as! ContestViewController
            self.navigationController?.pushViewController(contestVC, animated: false)
            
        }
    }
    
}

//MARK: - Table Delegate and DataSource Method
extension SeasonsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSeasonsItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? SeasonsTVCell else { return .init() }
        
        let item = arrSeasonsItems[indexPath.row]
        cell.setData = item
        
        cell.lblJoin.text = "Join"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            let vc = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "ContestViewController") as! ContestViewController
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 1:
            presentLeagueList(type: "pro")
            break
        case 2:
            //presentLeagueList(type: "fun")
            break
        default:
            debugPrint("Unkown Index")
        }
    }
    
    func presentLeagueList(type: String) {
        
        let leagueVC = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonLeagueVC") as! SeasonLeagueVC
        leagueVC.modalPresentationStyle = .custom
        leagueVC.completion = { seriesId, leagueName in
            let vc = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonsTabBarVC") as! SeasonsTabBarVC
            GDP.leagueType = type
            GDP.leagueSeriesId = "\(seriesId)"
//            GDP.leagueSeriesId = "128432"
            GDP.leagueName = leagueName
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        self.present(leagueVC, animated: true, completion: nil)
    }
}

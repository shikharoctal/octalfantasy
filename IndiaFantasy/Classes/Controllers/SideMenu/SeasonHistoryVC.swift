//
//  SeasonHistoryVC.swift
//  India’s fantasy
//
//  Created by admin on 03/08/23.
//

import UIKit

class SeasonHistoryVC: UIViewController {
    
    @IBOutlet weak var navigationView: SeasonNavigation!
    @IBOutlet weak var tblHistory: UITableView!
    private var selectionTab = UIButton()
    private let cellId = "SeasonHistoryTVCell"
    
    private var currentPage = 1
    private var totalItemCount = 0
    private var refreshControl = UIRefreshControl()
    
    private var arrHistory: [LeagueHistory] = [] {
        didSet {
            if arrHistory.count == 0 {
                tblHistory.setEmptyMessage(ConstantMessages.NoHistoryFound)
            }else {
                tblHistory.restoreEmptyMessage()
            }
            tblHistory.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationView()
        setupTableView()
        setupRefreshControl()
        
        getHistory()
    }
    
    func setupNavigationView() {
        
        navigationView.setupUI(title: "Season History")
    }
    
    func setupTableView() {
        
        let nib = UINib(nibName: cellId, bundle: nil)
        tblHistory.register(nib, forCellReuseIdentifier: cellId)
        tblHistory.contentInset = .init(top: 15, left: 0, bottom: 0, right: 0)
    }
    
    //MARK: - Setup Refresh Control
    private func setupRefreshControl() {
        
        refreshControl = UIRefreshControl()
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: attributes)
        refreshControl.addTarget(self, action: #selector(getDataFromServer), for: .valueChanged)
        refreshControl.tintColor = .white
        tblHistory.refreshControl = refreshControl
    }
    
    @objc func getDataFromServer() {
        
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
    
        self.getHistory()
    }

}

//MARK: - Table Delegate and DataSource Method
extension SeasonHistoryVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SeasonHistoryTVCell
        cell.setData = arrHistory[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    //MARK: Check TableView Scrolling To End
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == tblHistory else {
            return
        }
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
            
            if totalItemCount > arrHistory.count {
                currentPage += 1
                self.getHistory()
            }
        }
    }
}

//MARK: API Call
extension SeasonHistoryVC {
    
    func getHistory() {
        
        let type = "cricket"
        
        WebCommunication.shared.getSeasonLeagueHistory(page: currentPage, type: type, hostController: self, showLoader: true) { result in
            
            if let result = result {
                if self.currentPage == 1 {
                    self.arrHistory = result.docs ?? []
                }else {
                    self.arrHistory += result.docs ?? []
                }
                self.totalItemCount = result.totalDocs ?? 0
            }
        }
    }
}



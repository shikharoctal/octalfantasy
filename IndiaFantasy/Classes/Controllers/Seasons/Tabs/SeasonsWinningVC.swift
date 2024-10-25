//
//  SeasonsWinningVC.swift
//  IndiaFantasy
//
//  Created by Harendra Singh Rathore on 18/04/24.
//

import UIKit

class SeasonsWinningVC: UIViewController {

    @IBOutlet weak var navigationView: SeasonNavigation!
    @IBOutlet weak var tableView: UITableView!
    
    private let cellId = "SeasonWinningTVCell"
    private var refreshControl = UIRefreshControl()
    private var arrWinning: [SeasonWinning] = [] {
        didSet {
            if arrWinning.count == 0 {
                tableView.setEmptyMessage(ConstantMessages.NotFound)
            }else {
                tableView.restoreEmptyMessage()
            }
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationView()
        setupTableView()
        setupRefreshControl()
        getWinningDetail()
    }
    
    func setupNavigationView() {
        navigationView.setupUI(title: GDP.leagueName, hideBackBtn: true)
    }

    //MARK: - Setup TableView
    private func setupTableView() {
        
        let nib = UINib(nibName: cellId, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
    
    //MARK: - Setup Refresh Control
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: attributes)
        refreshControl.addTarget(self, action: #selector(getDataFromServer), for: .valueChanged)
        refreshControl.tintColor = .white
        tableView.refreshControl = refreshControl
    }
    
    @objc func getDataFromServer() {
        
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
        getWinningDetail()
    }
}

//MARK: - Table DataSource Method
extension SeasonsWinningVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrWinning.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? SeasonWinningTVCell else { return .init()}
        
        cell.setData = arrWinning[indexPath.row]
        return cell
    }
    
}

//MARK: API Call
extension SeasonsWinningVC {
    
    func getWinningDetail() {
        
        WebCommunication.shared.getSeasonWinningList(showLoader: true) { list in
            self.arrWinning = list ?? []
        }
    }
}

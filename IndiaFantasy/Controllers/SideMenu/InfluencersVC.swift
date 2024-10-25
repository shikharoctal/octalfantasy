//
//  InfluencersVC.swift
//  IndiaFantasy
//
//  Created by Harendra Singh Rathore on 11/06/24.
//

import UIKit

class InfluencersVC: UIViewController {
    
    @IBOutlet weak var navigationView: SeasonNavigation!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewHeader: UIView!
    
    private let cellId = "InfluencersTVCell"
    private var refreshControl = UIRefreshControl()
    
    private var arrInfluencers: [InfluencersInfo] = [] {
        didSet {
            if arrInfluencers.count == 0 {
                tableView.setEmptyMessage(ConstantMessages.NotFound)
                viewHeader.isHidden = true
            }else {
                tableView.restoreEmptyMessage()
                viewHeader.isHidden = false
            }
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationView()
        setupTableView()
        setupRefreshControl()
        
        getInfluencersList(showLoader: true)
    }
    
    //MARK: - Setup Navigation
    private func setupNavigationView() {
        navigationView.setupUI(title: "Top Influencers")
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
        self.getInfluencersList(showLoader: false)
    }

}

//MARK: - Table DataSource Method
extension InfluencersVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrInfluencers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! InfluencersTVCell
        cell.setData = arrInfluencers[indexPath.row]
        
        cell.lblRank.text = "\(indexPath.row + 1)"
        
        cell.btnCode.tag = indexPath.row
        cell.btnCode.addTarget(self, action: #selector(copyCodePressed(_:)), for: .touchUpInside)
        return cell
    }
    

    @objc func copyCodePressed(_ sender: UIButton) {
        UIPasteboard.general.string = arrInfluencers[sender.tag].code ?? ""
        AppManager.showToast("Copied to clipboard", view: (self.view)!)
    }
    
}

//MARK: API Call
extension InfluencersVC {
    
    func getInfluencersList(showLoader: Bool) {
        
        WebCommunication.shared.getInfluencersList(showLoader: showLoader) { list in
         
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            let list = (list ?? []).sorted(by: {($0.useCount ?? 0) > ($1.useCount ?? 0)})
            self.arrInfluencers = list
        }
    }
}


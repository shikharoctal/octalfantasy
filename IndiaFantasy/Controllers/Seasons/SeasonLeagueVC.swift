//
//  SeasonLeagueVC.swift
//  India’s fantasy
//
//  Created by admin on 16/05/23.
//

import UIKit

class SeasonLeagueVC: UIViewController {
    
    @IBOutlet weak var navigationView: SeasonNavigation!
    @IBOutlet weak var tblLeagues: UITableView!
    
    private let cellId = "SeasonLeagueTVCell"
    private var arrLeagues = [LeagueList]() {
        didSet {
            if arrLeagues.count == 0 {
                tblLeagues.setEmptyMessage(ConstantMessages.NoLeaguesAvailable)
            }else {
                tblLeagues.restoreEmptyMessage()
            }
            tblLeagues.reloadData()
        }
    }
    
    var completion: ((_ seriesId: Int, _ leagueName: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        getLeagues()
    }
    
    private func setupUI() {
        setupNavigationView()
        setupTableView()
    }
    
    private func setupNavigationView() {
        navigationView.setupUI(title: "Season League")
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: cellId, bundle: nil)
        tblLeagues.register(nib, forCellReuseIdentifier: cellId)
    }
    
}

//MARK: - Table DataSource Method
extension SeasonLeagueVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrLeagues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? SeasonLeagueTVCell else { return .init() }
        
        cell.setData = arrLeagues[indexPath.row]
        
        cell.btnEnter.tag = indexPath.row
        cell.btnEnter.addTarget(self, action: #selector(btnEnterPressed(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func btnEnterPressed(_ sender: UIButton) {
        
        let league = arrLeagues[sender.tag]
        self.dismiss(animated: true) {
            if let completion = self.completion {
                completion(league.idAPI ?? 0, league.name ?? "")
            }
        }
    }
}

//MARK: API Call
extension SeasonLeagueVC {
    
    func getLeagues() {
        
        WebCommunication.shared.getSeasonLeagues(hostController: self, showLoader: true) { leagueList in
            
            self.arrLeagues = leagueList ?? []
        }
    }
}

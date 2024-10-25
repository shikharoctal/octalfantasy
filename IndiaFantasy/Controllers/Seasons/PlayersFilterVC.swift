//
//  PlayersFilterVC.swift
//  India’s fantasy
//
//  Created by admin on 26/06/23.
//

import UIKit

class PlayersFilterVC: UIViewController {
    
    @IBOutlet weak var tblFilter: UITableView!
    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var btnApply: UIButton!
    
    private let cellId = "PlayersFilterTVCell"
    var arrTeams: [PlayerFilters] = []
    
    var completion: ((_ selectedTeams: [PlayerFilters]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateButtonsUI()
        setupTableView()
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: cellId, bundle: nil)
        tblFilter.register(nib, forCellReuseIdentifier: cellId)
        //tblFilter.contentInset = .init(top: 0, left: 0, bottom: 70, right: 0)
        tblFilter.reloadData()
    }
    
    private func updateButtonsUI() {
        btnReset.isHidden = arrTeams.filter({$0.isSelected == true}).isEmpty ? true : false
        btnApply.isEnabled = arrTeams.filter({$0.isSelected == true}).isEmpty ? false : true
        btnApply.alpha = arrTeams.filter({$0.isSelected == true}).isEmpty ? 0.5 : 1
    }
    
    @IBAction func btnBackPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnResetPressed(_ sender: UIButton) {
     
        self.arrTeams.indices.forEach {
            self.arrTeams[$0].isSelected = false
        }
        
        debugPrint("Reset Filters/n", arrTeams)
            
        self.dismiss(animated: true) {
            if let completion = self.completion {
                completion(self.arrTeams)
            }
        }
    }
    
    @IBAction func btnApplyPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true) {
            if let completion = self.completion {
                completion(self.arrTeams)
            }
        }
    }
    
}

//MARK: - Table DataSource and Delegate Method
extension PlayersFilterVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTeams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? PlayersFilterTVCell else { return .init() }
        
        let team = arrTeams[indexPath.row]
        cell.lblTitle.text = team.name
        cell.btnCheckBox.isSelected = team.isSelected
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        arrTeams[indexPath.row].isSelected = !arrTeams[indexPath.row].isSelected
        updateButtonsUI()
        debugPrint("Selected Filters", arrTeams)
        
        tableView.reloadData()
    }

}


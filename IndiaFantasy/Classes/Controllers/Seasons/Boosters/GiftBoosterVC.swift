//
//  GiftBoosterVC.swift
//  India’s fantasy
//
//  Created by admin on 17/07/23.
//

import UIKit

class GiftBoosterVC: UIViewController {
    
    @IBOutlet weak var navigationView: SeasonNavigation!
    @IBOutlet weak var tblBoosters: UITableView!
    @IBOutlet weak var viewBtnSend: UIView!
    
    var teamId = "" //Daily Contest Team Id
    var teamName: Int = 0
    var boosterId = ""
    var arrBooster = [Booster]()
    var completion: (() -> Void)?
    var isFromDailyContest: Bool = false
    
    private let cellId = "BoosterTVCell"
    private var selectedBooster: Booster? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationView()
        setupTableView()
    }
    
    func setupNavigationView() {
        
        navigationView.setupUI(title: "Gift Booster")
    }
    
    func setupTableView() {
        
        let nib = UINib(nibName: cellId, bundle: nil)
        tblBoosters.register(nib, forCellReuseIdentifier: cellId)
    
        if #available(iOS 15.0, *) {
            self.tblBoosters.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func btnSendPressed(_ sender: UIButton) {
        
        guard let selectedBooster = selectedBooster else { return }
        guard let vc = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "ApplyDebuffVC") as? ApplyDebuffVC else { return }
        vc.isFromDailyContest = isFromDailyContest
        vc.teamId = teamId
        vc.booster = selectedBooster
        vc.teamName = self.teamName
        vc.isfromGiftVC = true
        vc.boosterId = self.boosterId
        vc.completion = {
            if let completion = self.completion {
                completion()
            }
            self.navigationController?.popViewController(animated: false)
        }
        self.present(vc, animated: true, completion: nil)
    }
}

//MARK: - Table Delegate and DataSource Method
extension GiftBoosterVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrBooster.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! BoosterTVCell
        let booster = arrBooster[indexPath.row]
        cell.setData = booster
        
        if selectedBooster?.boosterUniqueID == booster.boosterUniqueID {
            cell.imgCheck.isHidden = booster.isApplied ?? true
        }else {
            cell.imgCheck.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let booster = arrBooster[indexPath.row]
        selectedBooster = booster
        viewBtnSend.isHidden = false
        tblBoosters.reloadData()
    }
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//
//        let footer = CustomButtonView.instanceFromNib() as! CustomButtonView
//        footer.btnApply.setTitle("Send", for: .normal)
//        footer.btnClear.isHidden = true
//
//        footer.btnApply.addTarget(self, action: #selector(btnSendPressed(_:)), for: .touchUpInside)
//        return footer
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//
//        return selectedBooster == nil ? 0 : 83
//    }
    
}


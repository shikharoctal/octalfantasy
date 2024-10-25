//
//  BoostersVC.swift
//  India’s fantasy
//
//  Created by admin on 25/04/23.
//

import UIKit

class BoostersVC: UIViewController {

    @IBOutlet weak var navigationView: SeasonNavigation!
    @IBOutlet weak var tblBoosters: UITableView!
    
    @IBOutlet weak var viewBoosters: UIView!
    @IBOutlet weak var btnBoosters: UIButton!
    
    @IBOutlet weak var viewDebuff: UIView!
    @IBOutlet weak var btnDebuff: UIButton!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var btnApply: UIButton!
    
    private let cellId = "BoosterTVCell"
    private let historyCellId = "BoosterHistoryTVCell"
    
    var isFromCreateTeam: Bool = false
    
    var teamId = ""
    var teamName: Int = 0
    var selectedBooster: [Booster] = []
    var completion: ((_ appliedBooster: [Booster]) -> Void)?
    
    private var arrBooster = [Booster]()
    private var arrDebuff = [Booster]()
    private var arrBoosterHistory = [BoosterHistoryData]()
    
    var totalBoosters: Int = 0
    var availableBoosters: Int = 0
    
    var selectionTab = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationView()
        setupTableView()
        
        selectionTab = btnBoosters
        btnTabAction(selectionTab)
        //addNotificationObservers()
        getBoosters()
    }
    
    deinit {
        removeNotificationObservers()
    }
    
    func setupNavigationView() {
        
        navigationView.setupUI(title: GDP.leagueName)
    }
    
    func setupTableView() {
        
        let nib = UINib(nibName: cellId, bundle: nil)
        tblBoosters.register(nib, forCellReuseIdentifier: cellId)
        
        let nib1 = UINib(nibName: historyCellId, bundle: nil)
        tblBoosters.register(nib1, forCellReuseIdentifier: historyCellId)
        
        
        if #available(iOS 15.0, *) {
            self.tblBoosters.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
    }

    func updateApplyBtnUI() {
        
//        btnApply.alpha = selectedBooster.isEmpty ? 0.5 : 1
//        btnApply.isUserInteractionEnabled = selectedBooster.isEmpty ? false : true
        
        btnClear.alpha = selectedBooster.isEmpty ? 0.5 : 1
        btnClear.isUserInteractionEnabled = selectedBooster.isEmpty ? false : true
    }
    
    @IBAction func btnTabAction(_ sender: UIButton) {
        
        btnBoosters.isSelected = false
        btnDebuff.isSelected = false
        
        viewBoosters.backgroundColor = UIColor.clear
        viewDebuff.backgroundColor = UIColor.clear
        
        sender.isSelected = true
        self.selectionTab = sender
        
        if sender == btnBoosters {
            viewBoosters.backgroundColor = UIColor.appRedColor
        }else {
            viewDebuff.backgroundColor = UIColor.appRedColor
        }
        
        self.checkEmptyList()
        self.tblBoosters.reloadData()
    }
    
    @IBAction func btnShopAction(_ sender: UIButton) {
        self.selectedBooster.removeAll()
        self.updateApplyBtnUI()
        self.tblBoosters.reloadData()
    }
    
    @IBAction func btnApplyAction(_ sender: UIButton) {
        
        self.validateBoosters()
    }
    
}

//MARK: - Table Delegate and DataSource Method
extension BoostersVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return selectionTab == btnBoosters ? arrBooster.count : arrDebuff.count
        }
        return arrBoosterHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! BoosterTVCell
            let booster = selectionTab == btnBoosters ? arrBooster[indexPath.row] : arrDebuff[indexPath.row]
            cell.setData = booster
            
            if selectedBooster.contains(where: {$0.boosterCode == booster.boosterCode}) {
                cell.imgCheck.isHidden = booster.isApplied ?? true
            }else {
                cell.imgCheck.isHidden = true
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: historyCellId, for: indexPath) as! BoosterHistoryTVCell
        cell.setData = arrBoosterHistory[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard isFromCreateTeam else { return }
        
        let booster = arrBooster[indexPath.row]
        
        if let row = selectedBooster.firstIndex(where: {$0.boosterCode == booster.boosterCode}) {
            self.selectedBooster.remove(at: row)
        }else {
            if (booster.isApplied ?? false) == false {
                self.selectedBooster.removeAll()
                selectedBooster.append(arrBooster[indexPath.row])
            }
        }
        
        self.updateApplyBtnUI()
        tblBoosters.reloadData()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            
            if isFromCreateTeam {
                let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))
                
                headerView.backgroundColor = .Color.headerBlue.value
                
                let lblHeader:UILabel = UILabel(frame: CGRect(x: 20, y: 0, width: 200, height: 40))
                lblHeader.text = selectionTab == btnBoosters ? "Select a Booster" : "Select a Debuff"
                lblHeader.textColor = .Color.headerYellow.value
                lblHeader.font = UIFont(name: customFontSemiBold, size: 17)
                headerView.addSubview(lblHeader)
                return headerView
                
            }else {
                let headerView = BoosterHeaderView.instanceFromNib() as! BoosterHeaderView
                
                let attStr = CommonFunctions.getCombinedAttributedString(first: "\(availableBoosters)/", second: "\(totalBoosters)")
                headerView.lblBoosterLeft.attributedText = attStr
                
                if !isFromCreateTeam {
                    if GDP.leagueMyTeams.isEmpty {
                        headerView.btnTeam.isHidden = true
                    }
                    headerView.btnTeam.setTitle("Team \(teamName) ", for: .normal)
                    
                    headerView.completion = { teamName in
                        self.teamName = teamName
                        self.getBoosters()
                    }
                }else {
                    headerView.btnTeam.isHidden = true
                }
                
                return headerView
            }
        }else {
            
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            
            headerView.backgroundColor = .clear
            
            let lblHeader:UILabel = UILabel(frame: CGRect(x: 20, y: 0, width: 200, height: 40))
            lblHeader.text = "Boosters History"
            lblHeader.textColor = .Color.headerYellow.value
            lblHeader.font = UIFont(name: customFontSemiBold, size: 17)
            headerView.addSubview(lblHeader)

            return headerView
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            if isFromCreateTeam {
                return 40
            }
            return 83
        }else {
            if isFromCreateTeam {
                return 0
            }else {
                if arrBoosterHistory.isEmpty {
                    return 0
                }
            }
            return 50
        }
    }
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        if section == 0 {
//            if selectionTab == btnBoosters {
//                let footer = CustomButtonView.instanceFromNib() as! CustomButtonView
//                footer.btnApply.addTarget(self, action: #selector(btnApplyPressed(_:)), for: .touchUpInside)
//                footer.btnClear.addTarget(self, action: #selector(btnClearPressed(_:)), for: .touchUpInside)
//                footer.btnClear.isHidden = selectedBooster.isEmpty ? true : false
//                return footer
//            }
//        }
//        
//        return nil
//    }
//    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        
//        if section == 0 {
//            if selectionTab == btnBoosters {
//                return selectedBooster.isEmpty ? 0 : 83
//            }
//        }
//        return 0
//    }
//    
//    @objc func btnApplyPressed(_ sender: UIButton) {
//        self.validateBoosters()
//    }
//    
//    @objc func btnClearPressed(_ sender: UIButton) {
//        selectedBooster = []
//        if let completion = completion {
//            completion(selectedBooster)
//        }
//        tblBoosters.reloadData()
//        //self.navigationController?.popViewController(animated: true)
//    }
}

//MARK: API Call
extension BoostersVC {
    
    func getBoosters() {
        
        WebCommunication.shared.getBoosterList(hostController: self, seriesId: GDP.leagueSeriesId, matchId: "\(GDP.selectedMatch?.match_id ?? 0)", teamName: "\(teamName)", teamId: teamId, showLoader: true) { boosterData, totalBoosters, availableBoosters in
         
            self.totalBoosters = totalBoosters
            self.availableBoosters = availableBoosters
            self.arrBooster = boosterData?.updatedBoostersList ?? []
            self.arrDebuff = boosterData?.debuffBooster ?? []
            
            if !self.isFromCreateTeam {
                self.arrBoosterHistory = boosterData?.boosterHistoryList ?? []
            }
            
            self.checkEmptyList()
            self.updateApplyBtnUI()
            
            self.tblBoosters.reloadData()
        }
    }
    
    func validateBoosters() {

//        guard !selectedBooster.isEmpty else {
//            self.alertBoxWithAction(message: ConstantMessages.SelectBoosterAppliedError, btnTitle: ConstantMessages.OkBtn) {}
//            return
//        }
        
        if let completion = self.completion {
            completion(self.selectedBooster)
        }
        self.navigationController?.popViewController(animated: true)
        
//        var appliedBooster = [[String: Any]]()
//        selectedBooster.forEach({ booster in
//            appliedBooster.append(["code": booster.boosterCode ?? 0, "id": booster.boosterUniqueID ?? ""])
//        })
//        
//        let request = BoosterValidateRequest(seriesId: GDP.leagueSeriesId, matchId: GDP.selectedMatch?.id ?? "", teamName: "\(teamName)", boosterCode: appliedBooster, boostedPlayerId: "")
//        
//        WebCommunication.shared.validateBoosters(hostController: self, request: request, showLoader: true) { status, msg in
//            
//            guard status == true else {
//                
//                self.alertBoxWithAction(message: msg, btnTitle: ConstantMessages.OkBtn) {}
//                return
//            }
//            
//            if let completion = self.completion {
//                completion(self.selectedBooster)
//            }
//            self.navigationController?.popViewController(animated: true)
//        }
    }
    
    func checkEmptyList() {
        if self.selectionTab == self.btnBoosters {
            if self.arrBooster.count == 0 {
                self.tblBoosters.setEmptyMessage(ConstantMessages.NoBoostersFound)
            }else {
                self.tblBoosters.restoreEmptyMessage()
            }
        }else {
            if self.arrDebuff.count == 0 {
                self.tblBoosters.setEmptyMessage(ConstantMessages.NoDebuffFound)
            }else {
                self.tblBoosters.restoreEmptyMessage()
            }
        }
    }
}

//MARK: - Notification Observer
extension BoostersVC {
    
    func addNotificationObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshBoosterList(notification:)), name: .RefreshBoosterList, object: nil)
    }
    
    @objc func refreshBoosterList(notification: NSNotification) {
        getBoosters()
    }
    
    func removeNotificationObservers() {
        print("Removed BOOSTER NotificationCenter Observer")
        NotificationCenter.default.removeObserver(self, name: .RefreshBoosterList, object: nil)
    }
}

//
//  DailyContestBoosterVC.swift
//  India’s fantasy
//
//  Created by admin on 31/07/23.
//

import UIKit

class DailyContestBoosterVC: UIViewController {
    
    @IBOutlet weak var navigationView: SeasonNavigation!
    @IBOutlet weak var tblBoosters: UITableView!
    
    @IBOutlet weak var viewBoosters: UIView!
    @IBOutlet weak var btnBoosters: UIButton!
    
    @IBOutlet weak var viewDebuff: UIView!
    @IBOutlet weak var btnDebuff: UIButton!
    @IBOutlet weak var btnApply: UIButton!
    
    private let cellId = "BoosterTVCell"
    private let historyCellId = "BoosterHistoryTVCell"
    
    var teamId = ""
    var teamName: Int = 0
    var selectedBooster: [Booster] = []
    var completion: ((_ appliedBooster: [Booster]) -> Void)?
    
    private var arrBooster = [Booster]()
    private var arrDebuff = [Booster]()
    
    var selectionTab = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationView()
        setupTableView()
        
        selectionTab = btnBoosters
        btnTabAction(selectionTab)
        addNotificationObservers()
        getBoosters()
    }
    
    deinit {
        removeNotificationObservers()
    }
    
    func setupNavigationView() {
        
        navigationView.setupUI(title: "Boosters")
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
        
        btnApply.alpha = selectedBooster.isEmpty ? 0.5 : 1
        btnApply.isUserInteractionEnabled = selectedBooster.isEmpty ? false : true
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
        
//        guard let vc = Constants.KShopStoryboard.instantiateViewController(withIdentifier: "ShopVC") as? ShopVC else { return }
//        vc.isFromBooster = true
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnApplyAction(_ sender: UIButton) {
        
        self.validateBoosters()
    }
}

//MARK: - Table Delegate and DataSource Method
extension DailyContestBoosterVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return selectionTab == btnBoosters ? arrBooster.count : arrDebuff.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! BoosterTVCell
        let booster = selectionTab == btnBoosters ? arrBooster[indexPath.row] : arrDebuff[indexPath.row]
        cell.setData = booster
        
        if selectedBooster.contains(where: {$0.boosterUniqueID == booster.boosterUniqueID}) {
            cell.imgCheck.isHidden = booster.isApplied ?? true
        }else {
            cell.imgCheck.isHidden = true
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if selectionTab == btnDebuff {
            
            let debuff = arrDebuff[indexPath.row]
            guard (debuff.isApplied ?? false) == false, let vc = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "ApplyDebuffVC") as? ApplyDebuffVC else { return }
            //vc.modalPresentationStyle = .custom
            vc.isFromDailyContest = true
            vc.teamId = teamId
            vc.booster = debuff
            vc.teamName = self.teamName
            vc.completion = {
                self.getBoosters()
            }
            self.present(vc, animated: true, completion: nil)
            return
        }
        
        let booster = arrBooster[indexPath.row]
        
        if let row = selectedBooster.firstIndex(where: {$0.boosterUniqueID == booster.boosterUniqueID}) {
            self.selectedBooster.remove(at: row)
        }else {
            if (booster.isApplied ?? false) == false {
                
                guard booster.boosterCode != 9 else { //if On the house booster
                    
                    guard let vc = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "GiftBoosterVC") as? GiftBoosterVC else { return }
                    
                    let allBooster = self.arrBooster + self.arrDebuff
                    vc.isFromDailyContest = true
                    vc.arrBooster = (allBooster.filter({$0.isApplied == false})).filter({$0.boosterCode != 9}).filter({$0.isCurrentlyUsed ?? false == false})
                    vc.teamName = self.teamName
                    vc.teamId = teamId
                    vc.boosterId = booster.boosterUniqueID ?? ""
                    vc.completion = {
                        self.getBoosters()
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                    return
                }
                
                if let row = selectedBooster.firstIndex(where: {$0.id == booster.id}) {
                    self.selectedBooster.remove(at: row)
                }
                guard selectedBooster.count < 2 else {
                    AppManager.showToast(ConstantMessages.BoosterAppliedError, view: self.view)
                    return
                }
                selectedBooster.append(arrBooster[indexPath.row])
            }
        }
        
        //self.updateApplyBtnUI()
        tblBoosters.reloadData()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))
        
        headerView.backgroundColor = .Color.headerBlue.value
        
        let lblHeader:UILabel = UILabel(frame: CGRect(x: 20, y: 0, width: 200, height: 40))
        lblHeader.text = selectionTab == btnBoosters ? "Select a Booster" : "Select a Debuff"
        lblHeader.textColor = .Color.headerYellow.value
        lblHeader.font = UIFont(name: customFontSemiBold, size: 17)
        headerView.addSubview(lblHeader)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 40
    }
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//
//        if selectionTab == btnBoosters {
//            let footer = CustomButtonView.instanceFromNib() as! CustomButtonView
//            footer.btnApply.addTarget(self, action: #selector(btnApplyPressed(_:)), for: .touchUpInside)
//            footer.btnClear.addTarget(self, action: #selector(btnClearPressed(_:)), for: .touchUpInside)
//            footer.btnClear.isHidden = selectedBooster.isEmpty ? true : false
//            return footer
//        }
//        return nil
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//
//        if selectionTab == btnBoosters {
//            return selectedBooster.isEmpty ? 0 : 83
//        }
//        return 0
//    }
    
//    @objc func btnApplyPressed(_ sender: UIButton) {
//        self.validateBoosters()
//    }
    
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
extension DailyContestBoosterVC {
    
    func getBoosters() {
        
        WebCommunication.shared.getBoosterList(fromDailyBooster: true, hostController: self, seriesId: "\(GDP.selectedMatch?.series_id ?? 0)", matchId: "\(GDP.selectedMatch?.match_id ?? 0)", teamName: "", teamId: teamId, showLoader: true) { boosterData, totalBoosters, availableBoosters in
         
            self.arrBooster = boosterData?.updatedBoostersList ?? []
            self.arrDebuff = boosterData?.debuffBooster ?? []
            
            self.checkEmptyList()
            //self.updateApplyBtnUI()
            
            self.tblBoosters.reloadData()
        }
    }
    
    func validateBoosters() {
        
        guard !selectedBooster.isEmpty else {
            if let completion = self.completion {
                completion(self.selectedBooster)
            }
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        var appliedBooster = [[String: Any]]()
        selectedBooster.forEach({ booster in
            appliedBooster.append(["code": booster.boosterCode ?? 0, "id": booster.boosterUniqueID ?? ""])
        })
        
        let request = BoosterValidateRequest(seriesId: "\(GDP.selectedMatch?.series_id ?? 0)", matchId: "\(GDP.selectedMatch?.match_id ?? 0)", teamName: "\(teamName)", boosterCode: appliedBooster, fromDailyContest: true)
        
        WebCommunication.shared.validateBoosters(hostController: self, request: request, showLoader: true) { status, msg in
            
            guard status == true else {
                
                self.alertBoxWithAction(message: msg, btnTitle: ConstantMessages.OkBtn) {}
                return
            }
            
            if let completion = self.completion {
                completion(self.selectedBooster)
            }
            self.navigationController?.popViewController(animated: true)
        }
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
extension DailyContestBoosterVC {
    
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

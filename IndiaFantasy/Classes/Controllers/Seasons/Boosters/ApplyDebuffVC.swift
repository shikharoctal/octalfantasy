//
//  ApplyDebuffVC.swift
//  India’s fantasy
//
//  Created by admin on 13/07/23.
//

import UIKit

class ApplyDebuffVC: UIViewController {
    
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var lblHeaderTitle: UILabel!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewApplyBtn: UIView!
    @IBOutlet weak var btnApply: UIButton!
    
    var boosterId: String? = "" //On the house booster Id
    var isfromGiftVC: Bool = false
    var isFromDailyContest: Bool = false
    var teamId = "" //Daily Contest Team Id
    
    var booster: Booster? = nil
    var teamName: Int = 0
    var completion: (() -> Void)?
    
    private let cellId = "SeasonLeagueTVCell"
    private let teamCellId = "ContestUserTVCell"

    private var isShowTeams = false
    private var selectedTeam: ContestUser? = nil
    private var selectedContest: ContestData? = nil
    private var currentPage = 1
    private var totalTeamsCount = 0
    
    private var arrAllContest = [ContestData]()
    private var arrContest = [ContestData]() {
        didSet {
            if arrContest.count == 0 {
                tableView.setEmptyMessage(ConstantMessages.NoContestAvailable, .black)
            }else {
                tableView.restoreEmptyMessage()
            }
            tableView.reloadData()
        }
    }
    
    private var arrTeams = [ContestUser]() {
        didSet {
            if arrTeams.count == 0 {
                tableView.setEmptyMessage(ConstantMessages.NotFound, .black)
            }else {
                tableView.restoreEmptyMessage()
            }
            tableView.reloadData()
        }
    }
    
    private let runner = DelayedRunner.initWithDuration(seconds: 0.5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblHeaderTitle.text = isfromGiftVC ? "Gift Booster".localized() : "Apply Debuff".localized()
        setupTableView()
        txtSearch.addTarget(self, action: #selector(textSearchChanged(_:)), for: .editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.getContestLeagues()
    }
    
    override func viewDidLayoutSubviews() {
        viewMain.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 33)
    }

    private func setupTableView() {
        let nib = UINib(nibName: cellId, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        let nib1 = UINib(nibName: teamCellId, bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: teamCellId)
    }
    
    //MARK: - Search Field Text Changed
    @objc func textSearchChanged(_ sender: UITextField) {
        
        if isShowTeams {
            runner.run {
                self.currentPage = 1
                self.getContestTeams()
            }
        }else {
            if sender.text == "" {
                self.arrContest = self.arrAllContest
            }else {
                self.arrContest = self.arrAllContest.filter({$0.name?.lowercased().contains((sender.text ?? "").lowercased()) ?? false})
            }
        }
    }
    
    @IBAction func btnClosePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnApplyDebuffPressed(_ sender: UIButton) {
        
        let teamName = isFromDailyContest ? ((selectedTeam?.username ?? "") + " Team\(selectedTeam?.teamCount ?? 1)") : (selectedTeam?.teamName ?? "")
        
        if isfromGiftVC {
            let message = ConstantMessages.SendBoosterGiftAlert + " \(booster?.title ?? "") to \(teamName)?"
            self.alertBoxWithAction(message: message, btn1Title: ConstantMessages.CancelBtn, btn2Title: ConstantMessages.OkBtn) {
                self.sendBoosterGift()
            }
        }else {
            let message = ConstantMessages.ApplyDebuffMessage + " \(booster?.title ?? "") to \(teamName)?"
            self.alertBoxWithAction(message: message, btn1Title: ConstantMessages.CancelBtn, btn2Title: ConstantMessages.OkBtn) {
                self.applyDebuffRequest()
            }
        }
        
    }
}

//MARK: - Table DataSource Method
extension ApplyDebuffVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isShowTeams ? arrTeams.count : arrContest.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if isShowTeams {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: teamCellId, for: indexPath) as? ContestUserTVCell else { return .init() }
            let team = arrTeams[indexPath.row]
            cell.setData = team
            
            if let selectedTeam = selectedTeam, team.id == selectedTeam.id {
                cell.selectUser(status: true)
            }else {
                cell.selectUser(status: false)
            }
            
            return cell
            
        }else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? SeasonLeagueTVCell else { return .init() }
            cell.setContestData = arrContest[indexPath.row]
            
            cell.btnEnter.tag = indexPath.row
            cell.btnEnter.addTarget(self, action: #selector(btnEnterPressed(_:)), for: .touchUpInside)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard isShowTeams else { return }
        self.selectedTeam = arrTeams[indexPath.row]
        self.btnApply.alpha = 1
        self.btnApply.isUserInteractionEnabled = true
        tableView.reloadData()
    }
    
    @objc func btnEnterPressed(_ sender: UIButton) {
        self.selectedContest = arrContest[sender.tag]
        currentPage = 1
        getContestTeams()
    }
    
    //MARK: Check TableView Scrolling To End
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == tableView && isShowTeams else {
            return
        }
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
            
            if totalTeamsCount > arrTeams.count {
                currentPage += 1
                self.getContestTeams()
            }
        }
    }
}

//MARK: API Calls
extension ApplyDebuffVC {
    
    func getContestLeagues() {
        
        let teamName = isFromDailyContest ? teamId : "\(teamName)"
        
        WebCommunication.shared.getDebuffContestList(forDailyContest: isFromDailyContest, hostController: self, seriesId: "\(GDP.selectedMatch?.series_id ?? 0)", teamName: teamName, showLoader: true) { contestList in
            
            self.arrAllContest =  contestList ?? []
            self.arrContest = contestList ?? []
        }
    }
    
    func getContestTeams() {
        
        guard let contestId = selectedContest?.id else { return }
        
        WebCommunication.shared.getContestUsers(forDailyContest: isFromDailyContest, hostController: self, seriesId: "\(GDP.selectedMatch?.series_id ?? 0)", contestId: contestId, matchId: "\(GDP.selectedMatch?.match_id ?? 0)", keyword: txtSearch.text ?? "", page: currentPage, showLoader: true) { contestTeams, totalTeamsCount in
            
            self.isShowTeams = true
            self.viewApplyBtn.isHidden = false
            
            self.totalTeamsCount = totalTeamsCount
            
            if self.currentPage == 1 {
                self.arrTeams = contestTeams ?? []
            }else {
                self.arrTeams += contestTeams ?? []
            }
        }
    }
    
    func applyDebuffRequest() {
        
        let teamId = isFromDailyContest ? teamId : (selectedTeam?.id ?? "")
        let otherUserTeamName = isFromDailyContest ? (selectedTeam?.id ?? "") : (selectedTeam?.teamName ?? "")
    
        let request = DebuffApplyRequest(seriesId: "\(GDP.selectedMatch?.series_id ?? 0)", matchId:  GDP.selectedMatch?.match_id ?? 0, teamName: teamName, otherUserTeamName: otherUserTeamName, teamId: teamId, boosterCode: booster?.boosterCode ?? 0, userId: selectedTeam?.userID ?? "", boosterUniqueId: booster?.boosterUniqueID ?? "", fromDailyContest: isFromDailyContest)
        
        WebCommunication.shared.applyDebuff(hostController: self, request: request, showLoader: true) { status, msg in
            if status == true {
                self.alertBoxWithAction(message: msg, btnTitle: ConstantMessages.OkBtn) {
                    self.dismiss(animated: true) {
                        if let completion = self.completion {
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    func sendBoosterGift() {
    
        let request = BoosterGiftRequest(seriesId: "\(GDP.selectedMatch?.series_id ?? 0)", matchId: GDP.selectedMatch?.match_id ?? 0, teamName: teamName, teamId: teamId, userId: selectedTeam?.userID ?? "", boosterUniqueId: boosterId ?? "", sharedBoosterUniqueId: booster?.boosterUniqueID ?? "", fromDailyContest: isFromDailyContest)
    
        WebCommunication.shared.sendBoosterGift(hostController: self, request: request, showLoader: true) { status, msg in
            if status == true {
                self.alertBoxWithAction(message: msg, btnTitle: ConstantMessages.OkBtn) {
                    self.dismiss(animated: true) {
                        if let completion = self.completion {
                            completion()
                        }
                    }
                }
            }
        }
    }
}

//MARK: - Search TextField Delegate
extension ApplyDebuffVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
     
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText: NSString = (textField.text ?? "") as NSString
        
        guard range.location == 0 else {
            return true
        }
        
        let newString = currentText.replacingCharacters(in: range, with: string) as NSString
        if newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0 {
            return true
        }else {
            return false
        }
    }
}

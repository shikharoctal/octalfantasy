//
//  SeasonTransferReviewVC.swift
//  India’s fantasy
//
//  Created by admin on 12/05/23.
//

import UIKit

class SeasonTransferPreviewVC: UIViewController {

    @IBOutlet weak var navigationView: SeasonNavigation!
    
    @IBOutlet weak var lblMatchName: UILabel!
    @IBOutlet weak var lblVisitorTeam: UILabel!
    @IBOutlet weak var lblHomeTeam: UILabel!
    @IBOutlet weak var imgVisitorTeam: UIImageView!
    @IBOutlet weak var imgLocalTeam: UIImageView!
    @IBOutlet weak var lblLastMatch: UILabel!
    @IBOutlet weak var lblNextMatch: UILabel!
    
    @IBOutlet weak var lblTransferInUse: UILabel!
    @IBOutlet weak var btnHistory: UIButton!
    @IBOutlet weak var btnPoints: UIButton!
    @IBOutlet weak var btnHelp: UIButton!
    
    @IBOutlet weak var imgBoosterFirst: UIImageView!
    @IBOutlet weak var imgBoosterSecond: UIImageView!
    
    @IBOutlet weak var lblMatchNumber: UILabel!
    @IBOutlet weak var lblTransfersCount: UILabel!
    
    @IBOutlet weak var tblTransfer: UITableView!
    
    private let cellId = "TransferTeamTVCell"
    
    var requestParams: [String: Any] = [:]
    var teamName: String = "0"
    var selectedBooster: Booster?

    private var arrTransfersPlayers = [TransferdPlayer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        getTransferPlayers()
    }

    private func setupUI() {
        
        setupNavigationView()
        setupTableView()
        
        imgBoosterFirst.isHidden = true
        imgBoosterSecond.isHidden = true
        
        if let selectedBooster = selectedBooster, selectedBooster.boosterCode != nil {
            imgBoosterFirst.loadImage(urlS: selectedBooster.boosterImage, placeHolder: Constants.kNoImage)
            imgBoosterFirst.isHidden = false
        }
        
        if let match = GDP.selectedMatch {
            
            lblMatchName.text = "Match \(match.matchNumber ?? 0)"
            imgLocalTeam.loadImage(urlS: match.localteam_flag, placeHolder: Constants.kNoImageUser)
            lblHomeTeam.text = match.localteam_short_name
            imgVisitorTeam.loadImage(urlS: match.visitorteam_flag, placeHolder: Constants.kNoImageUser)
            lblVisitorTeam.text = match.visitorteam_short_name
            
//            CommonFunctions().timerStart(date: navigationView.lblSubTitle, strTime: match.start_time ?? "", strDate: match.start_date, viewcontroller: self)
            CommonFunctions().timerStart(lblTime: navigationView.lblSubTitle, strDate: match.match_date ?? "", viewcontroller: self, fromSeasonMyTeams: false)
        }
    }
    
    private func setupNavigationView() {
        
        navigationView.setupUI(title: GDP.leagueName, hideBG: true)
    }
    
    private func setupTableView() {
        
        let nib = UINib(nibName: cellId, bundle: nil)
        tblTransfer.register(nib, forCellReuseIdentifier: cellId)
        
        tblTransfer.contentInset = .init(top: 0, left: 0, bottom: 100, right: 0)
    }
    
    
    @IBAction func btnSaveTeamPressed(_ sender: UIButton) {
        addEditTeam(params: requestParams)
    }
    
    @IBAction func btnHistoryPressed(_ sender: UIButton) {
        let vc = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonsStatsVC") as! SeasonsStatsVC
        vc.fromCreateTeam = true
        vc.teamNumber = Int(teamName) ?? 0
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnPointPressed(_ sender: UIButton) {
        let vc = Constants.KSideMenuStoryboard.instantiateViewController(withIdentifier: "WebPageViewController") as! WebPageViewController
        vc.url = URL(string: URLMethods.FantasyPointSystem_URL)
        vc.isFromLeague = true
        vc.headerText = "Fantasy Points System"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnHelpPressed(_ sender: UIButton) {
        let vc = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonHelpVC") as! SeasonHelpVC
        vc.modalPresentationStyle = .custom
        self.present(vc, animated: true, completion: nil)
    }
}

//MARK: - Table Delegate and DataSource Method
extension SeasonTransferPreviewVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrTransfersPlayers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TransferTeamTVCell
        cell.setData = arrTransfersPlayers[indexPath.row]
        return cell
        
    }
    
}

//MARK: API Call
extension SeasonTransferPreviewVC {
    
    func getTransferPlayers() {

        requestParams["teamName"] = teamName
    
        WebCommunication.shared.transferPreviewTeam(hostController: self, params: requestParams, showLoader: true) { transferPreviewData in
            
            if let transfer = transferPreviewData {
                self.arrTransfersPlayers = transfer.transferdPlayer ?? []
                self.lblMatchNumber.text = "Match \(transfer.matchNumber ?? 0)"
                self.lblTransfersCount.text = "\(transfer.totalPlayerTransfered ?? 0) Transfers"
                self.lblTransferInUse.text = "\(transfer.totalPlayerTransfered ?? 0)/\(transfer.availableTransfer ?? 0) transfer in use"
                self.tblTransfer.reloadData()
            }else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func addEditTeam(params: [String: Any]) {
        
        WebCommunication.shared.createEditLeagueTeam(hostController: self, params: params, showLoader: true) { status, msg in
            
            if status == true {
                let alert = UIAlertController(title: Constants.kAppDisplayName, message: msg, preferredStyle:.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in

                    if let tabVC = self.navigationController?.getViewController(of: SeasonsTabBarVC.self) {
                        
                        //postNotification(.LeagueTeamCreation, userInfo: [:])
                        self.navigationController?.popToViewController(tabVC, animated: true)
                        return
                    }
                }))
                
                self.present(alert, animated: true, completion: nil)

            }else {
                AppManager.showToast(msg, view: self.view)
            }
        }
    }
}

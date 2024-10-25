//
//  ChooseWinningBreakupVC.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 21/03/22.
//

import UIKit
import SDWebImage

class ChooseWinningBreakupVC: BaseClassWithoutTabNavigation {

    @IBOutlet weak var navigationView: CustomNavigation!
    @IBOutlet weak var lblVisitorTeam: UILabel!
    @IBOutlet weak var lblHomeTeam: UILabel!
    @IBOutlet weak var imgVisitorTeam: UIImageView!
    @IBOutlet weak var imgLocalTeam: UIImageView!
    @IBOutlet weak var lblHeader: UILabel!
  
    @IBOutlet weak var tblWinnerBreakup: UITableView!
    @IBOutlet weak var lblWinners: UILabel!
    @IBOutlet weak var lblEntryFee: UILabel!
    @IBOutlet weak var lblPrizePool: UILabel!
    @IBOutlet weak var lblContestSize: UILabel!
    
    var arrWinList = [CAWinningBreakupDatum]()
    var arrWinnerList  = [WinningBreakUp]()


    var contestData = NewContestData()
    var gameType = ""

    var teamCount = "0"
    
    var isContestJoinFlow = false

    
    var selectedIndexList : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        navigationView.configureNavigationBarWithController(controller: self, title: "Create Contest", hideNotification: false, hideAddMoney: true, hideBackBtn: false)
        navigationView.img_BG.isHidden = true

        NotificationCenter.default.addObserver(self, selector: #selector(self.updateSelectedList(notification:)), name: NSNotification.Name(rawValue: "updateList"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.createdTeamSuccess(notification:)), name: NSNotification.Name(rawValue: "TeamCreationSuccessEvent"), object: nil)

        self.setupUI()
    }
    
    func setupUI(){
        lblHomeTeam.text = GDP.selectedMatch?.localteam_short_name ?? ""
        lblVisitorTeam.text = GDP.selectedMatch?.visitorteam_short_name ?? ""
        
        imgLocalTeam.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgLocalTeam.sd_setImage(with: URL(string: GDP.selectedMatch?.localteam_flag ?? ""), placeholderImage: Constants.kNoImageUser)

        imgVisitorTeam.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgVisitorTeam.sd_setImage(with: URL(string: GDP.selectedMatch?.visitorteam_flag ?? ""), placeholderImage: Constants.kNoImageUser)
        
        
        self.lblPrizePool.text = contestData.prizeAmount//dictData?["prize"]
        self.lblContestSize.text = contestData.contestSize//dictData?["size"]
        self.lblWinners.text = String(format : "\(self.contestData.totalWinners) Winners (Recommended)")
        self.lblEntryFee.text = String(format : "\(GDP.globalCurrency)\(self.contestData.entryFees)")

        self.contestData.teamCounts = "\(GlobalDataPersistance.shared.myTeamCount)"
        

        self.startTimer()
    }
    
    
    func startTimer()
    {
        //CommonFunctions().timerStart(date: self.lblHeader, strTime: GDP.selectedMatch?.start_time ?? "", strDate: GDP.selectedMatch?.start_date, viewcontroller: self)
        CommonFunctions().timerStart(lblTime: self.lblHeader, strDate: GDP.selectedMatch?.match_date ?? "", viewcontroller: self, fromSeasonMyTeams: false, isFromHome: true)
    }
    @IBAction func btnSelectWinnerPressed(_ sender: UIButton) {
        
        let vc = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "ChooseTotalWinners")as! ChooseTotalWinners
        vc.arrWinList = arrWinList
        vc.contestData = self.contestData
        vc.selectedIndexList = self.selectedIndexList
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true) {
            vc.tblWinnersChoice.reloadData()
        }
    }
    
    @IBAction func btnBackPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCreateContestPressed(_ sender: UIButton) {
        if (Int(self.contestData.teamCounts) ?? 0) > 0 {
            if self.contestData.teamId.count <= 0 || Int(self.contestData.teamCounts) ?? 0 > 0  {
                self.selectTeamToJoin()
            }else {
                self.WalletAmountCheck(teamcount: "1")
            }
        }else {
            self.ShowCreateTeamView()
        }

    }
    
    
    func ShowCreateTeamView() {
        
        let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "CreateTeamViewController") as! CreateTeamViewController
        VC.strVCFrom = "CreateContest"
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    
    @objc func selectTeamToJoin() {
        let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "SelectTeamViewController") as! SelectTeamViewController
          VC.completionHandler = { (team, teamCount) in
              print("teamId--->",team.team_id ?? "0")
              if LocationManager.sharedInstance.isPLayingInLegalState() == true{
                  self.initJoinFlow(team: team, teamCount: teamCount)
              }
          }
        VC.createTeamcompletionHandler = { (success) in
            self.ShowCreateTeamView()
        }
        VC.editTeamcompletionHandler = { (dataDict) in
            let navData = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "CreateTeamViewController") as! CreateTeamViewController
            //navData.setSelectTeamDelegate = true
            navData.isFromEdit = "Edit"
            navData.TeamData = dataDict
            navData.strCaptainID = "\(dataDict.captain_player_id ?? "0")"
            navData.strViceCaptainID = "\(dataDict.vice_captain_player_id ?? "0")"
            navData.teamID = "\(dataDict.team_id ?? "0")"
            navData.strTeamNumber = "\(dataDict.team_number ?? 1)"
            self.navigationController?.pushViewController(navData, animated: true)
            
        }
        self.present(VC, animated: false, completion: nil)

    }
    
    func initJoinFlow(team:Team, teamCount:Int){
        self.contestData.teamId = team.team_id ?? ""
        if teamCount == 0
        {
            self.contestData.teamCounts = "1"
            self.WalletAmountCheck(teamcount: "1")
        }
        else
        {
            self.contestData.teamCounts = String(teamCount)
            self.WalletAmountCheck(teamcount: String(teamCount))
        }
        
        self.teamCount = self.contestData.teamCounts
    }
    
    @objc func createdTeamSuccess(notification : NSNotification)
    {
        self.isContestJoinFlow = true
        self.perform(#selector(getTeamLists), with: self, afterDelay: 1.0)
    }
    
    @objc func updateSelectedList(notification : NSNotification)
    {
        self.selectedIndexList =  Int("\(notification.userInfo?["index"] ?? "")") ?? 0
        if self.selectedIndexList < self.arrWinList.count{
            self.contestData.totalWinners = "\((self.arrWinList[self.selectedIndexList]).id ?? 2)"
            self.arrWinnerList = (self.arrWinList[self.selectedIndexList]).info!
            self.lblWinners.text = "\(self.contestData.totalWinners) Winners (Recommended)"
        }
        
        self.tblWinnerBreakup.reloadData()
    }
}

extension ChooseWinningBreakupVC{
    func WalletAmountCheck (teamcount:String){
                
        let params:[String:String] = ["contest_id": "",
                                      "match_id":String(GDP.selectedMatch?.match_id ?? 0),
                                      "series_id":String(GDP.selectedMatch?.series_id ?? 0),
                                      "entry_fees":"\(self.getDouble(for: self.contestData.entryFees).rounded(toPlaces: 2))"
        ]
        
        let url = URLMethods.BaseURL + URLMethods().joinContestCheckWallet

        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
                if result != nil {
                    let data = result?.object(forKey: "results") as? [String:Any]
                        if data != nil{
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                                  let tblData = try? JSONDecoder().decode(WalletAmountResults.self, from: jsonData)else {return }
                           
                            var contestBalance = ContestFeeBalances()
                            contestBalance.cashBalance = Double("\(tblData.cashBalance ?? 0.0)") ?? 0.0
                            contestBalance.winningBalance = Double("\(tblData.winningBalance ?? 0.0)") ?? 0.0
                            contestBalance.usableBalance = Double("\(tblData.usableBonus ?? 0.0)") ?? 0.0
                            contestBalance.entryFee = Double("\(tblData.entryFee ?? 0.0)") ?? 0.0
                            contestBalance.useableBonousPercent = "\(tblData.useableBonousPercent ?? 0)"
                            
                            if contestBalance.entryFee - (contestBalance.usableBalance + contestBalance.cashBalance + contestBalance.winningBalance) <= 0 {
                                
                                self.showNewContestWalletPopupView(contestBalance, matchData: GDP.selectedMatch,teamId:self.contestData.teamId,isNewContest:true,contestData:self.contestData,gameType:self.gameType, completionHandler: {receiveData in
                                    print(receiveData)
                                    
                                })
                            }
                            else
                            {
                                let remainingBalance = contestBalance.entryFee - (contestBalance.usableBalance + contestBalance.cashBalance + contestBalance.winningBalance)
                                
                                
                                let alert = UIAlertController(title: Constants.kAppDisplayName, message: "Low balance!. Please add \(GDP.globalCurrency)\(String.init(format: "%.2f", arguments: [ceil(remainingBalance*100)/100])) to join contest.", preferredStyle:.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                    let vc = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "AddCashViewController") as! AddCashViewController
                                    vc.requiredCash = ceil(remainingBalance*100)/100
                                    vc.completionHandler = { (balance) in
                                                    print(balance)
                                        if Int(self.teamCount) == 0
                                        {
                                            self.WalletAmountCheck(teamcount: "1")
                                        }
                                        else
                                        {
                                            self.WalletAmountCheck(teamcount: self.teamCount)
                                        }
                                    }
                                    self.navigationController?.pushViewController(vc, animated: false)
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                                
                        }
                    }
                }
                        
            AppManager.stopActivityIndicator(self.view)
        }
        AppManager.startActivityIndicator(sender: self.view)
    }
    
    @objc func getTeamLists (){
        
        WebCommunication.shared.getTeams(hostController: self, match_id: (GDP.selectedMatch?.match_id ?? 0), series_id: (GDP.selectedMatch?.series_id ?? 0), showLoader:true) { team in
            if let tblData = team{
                GlobalDataPersistance.shared.myTeamCount = tblData.count
                GlobalDataPersistance.shared.myTeams = tblData
                self.contestData.teamCounts = String(tblData.count )
                
                if self.isContestJoinFlow == true{
                    self.isContestJoinFlow = false
                    if GlobalDataPersistance.shared.myTeamCount > 0{
                        if let team = tblData.last{
                            if LocationManager.sharedInstance.isPLayingInLegalState() == true{
                                self.initJoinFlow(team: team, teamCount: GlobalDataPersistance.shared.myTeamCount)
                            }
                        }
                    }
                }else{
                    self.selectTeamToJoin()
                }
            }
        }
    }
}

extension ChooseWinningBreakupVC:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrWinnerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseWinnerTVCell", for: indexPath) as! ChooseWinnerTVCell

         cell.selectionStyle = .none
        let dict = self.arrWinnerList[indexPath.row]
        cell.lblWinners.text = "\(dict.rankSize ?? "")"
        cell.lblPercantage.text = String(format : "%@%%",("\(dict.percent!.value)"))
        
        let percent =        Float("\(dict.percent!.value)")
        let totalPrize = Float(contestData.prizeAmount) ?? 0
        let finalPrize = ( percent! * totalPrize) / 100.0
        cell.lblAmount.text = "\(GDP.globalCurrency)" + String(format : "%.1f",finalPrize)
            
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
}

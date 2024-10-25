//
//  CreateContestViewController.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 16/03/22.
//

import UIKit
import SDWebImage
import MaterialComponents


class CreateContestViewController: BaseClassWithoutTabNavigation {
    
    @IBOutlet weak var navigationView: CustomNavigation!
    @IBOutlet weak var lblVisitorTeam: UILabel!
    @IBOutlet weak var lblHomeTeam: UILabel!
    @IBOutlet weak var imgVisitorTeam: UIImageView!
    @IBOutlet weak var imgLocalTeam: UIImageView!
    @IBOutlet weak var lblHeader: UILabel!
    
    @IBOutlet weak var txtFContestName: MDCOutlinedTextField!
    @IBOutlet weak var txtFContestSize: MDCOutlinedTextField!
    
   @IBOutlet weak var txtFEntryPrice: MDCOutlinedTextField!
    
    @IBOutlet weak var btnCreateContest: UIButton!
    @IBOutlet weak var btnAllowMultipleUser: UIButton!
    
    @IBOutlet weak var lblPrizePool: UILabel!

    
    var contestData = NewContestData()
    var entryFee = 0.0
    var teamCount = "0"
    var gameType = ""
    var isContestJoinFlow = false
    
    var countDownTimer: CountDown?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationView.configureNavigationBarWithController(controller: self, title: "Create Contest", hideNotification: false, hideAddMoney: true, hideBackBtn: false)
        navigationView.img_BG.isHidden = true
        
        setTextField()
       
       
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.createdTeamSuccess(notification:)), name: NSNotification.Name(rawValue: "TeamCreationSuccessEvent"), object: nil)
        
        self.setupUI()
        // Do any additional setup after loading the view.
    }
    
    
    func setTextField(){
        self.txtFContestName.label.text = "Enter Contest Name"
        self.txtFContestSize.label.text = "Enter Contest Size"
        self.txtFEntryPrice.label.text = "Max Prize Pool"
        self.txtFContestName.label.textColor = .white
        self.txtFContestSize.label.textColor = .white
        self.txtFEntryPrice.label.textColor = .white
        
         self.txtFContestName.textColor = .white
        self.txtFContestSize.textColor = .white
        self.txtFEntryPrice.textColor = .white
        
//        self.txtFContestName.font = UIFont(name: customFontRegular, size: 14)
//        self.txtFContestSize.font = UIFont(name: customFontRegular, size: 14)
//        self.txtFEntryPrice.font = UIFont(name: customFontRegular, size: 14)

        
        
        self.txtFContestName.setNormalLabelColor(.darkGray, for: .normal)
        self.txtFContestSize.setNormalLabelColor(.darkGray, for: .normal)
        self.txtFEntryPrice.setNormalLabelColor(.darkGray, for: .normal)
    
        
        [self.txtFContestName, self.txtFContestSize, self.txtFEntryPrice].forEach( {$0.setFloatingLabelColor(.white, for: .normal)} )
        [self.txtFContestName, self.txtFContestSize, self.txtFEntryPrice].forEach( {$0.setTextColor(.white, for: .normal)} )
        [self.txtFContestName, self.txtFContestSize, self.txtFEntryPrice].forEach( {$0.setNormalLabelColor(.gray, for: .normal)} )
        [self.txtFContestName, self.txtFContestSize, self.txtFEntryPrice].forEach( {$0.setFloatingLabelColor(.white, for: .editing)} )
        [self.txtFContestName, self.txtFContestSize, self.txtFEntryPrice].forEach( {$0.setTextColor(.white, for: .editing)} )
        [self.txtFContestName, self.txtFContestSize, self.txtFEntryPrice].forEach( {$0.setNormalLabelColor(.gray, for: .editing)} )
        [self.txtFContestName, self.txtFContestSize, self.txtFEntryPrice].forEach({$0?.setOutlineColor(UIColor.appTextFieldBorder, for: .normal)})
        [self.txtFContestName, self.txtFContestSize, self.txtFEntryPrice].forEach({$0?.setOutlineColor(UIColor.appTextFieldBorder, for: .editing)})
        
//        self.txtFEntryPrice.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
//        self.txtCustomeAmount.addTarget(self, action: #selector(textFieldAmountDidBegain), for: UIControl.Event.editingDidBegin)
        
        self.txtFEntryPrice.keyboardType = .numberPad
        self.txtFContestSize.keyboardType = .numberPad
        
        self.txtFContestName.delegate = self
        self.txtFContestSize.delegate = self
        self.txtFEntryPrice.delegate = self
    }
    deinit {
        debugPrint("Create Contest Deinit Call")
        countDownTimer?.stop()
        countDownTimer = nil
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "TeamCreationSuccessEvent"), object: nil)
    }
    
    func setupUI(){
        lblHomeTeam.text = GDP.selectedMatch?.localteam_short_name ?? ""
        lblVisitorTeam.text = GDP.selectedMatch?.visitorteam_short_name ?? ""
        
        imgLocalTeam.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgLocalTeam.sd_setImage(with: URL(string: GDP.selectedMatch?.localteam_flag ?? ""), placeholderImage: Constants.kNoImageUser)
        
        imgVisitorTeam.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgVisitorTeam.sd_setImage(with: URL(string: GDP.selectedMatch?.visitorteam_flag ?? ""), placeholderImage: Constants.kNoImageUser)
        
        
        self.contestData.teamCounts = "\(GlobalDataPersistance.shared.myTeamCount )"
        
        self.startTimer()
    }
    
    func startTimer()
    {
        //CommonFunctions().timerStart(date: self.lblHeader, strTime: GDP.selectedMatch?.start_time ?? "", strDate: GDP.selectedMatch?.start_date, viewcontroller: self)
        //CommonFunctions().timerStart(lblTime: self.lblHeader, strDate: GDP.selectedMatch?.match_date ?? "", viewcontroller: self, fromSeasonMyTeams: false, isFromHome: true)
        
        if let matchDate = CommonFunctions.getDateFromString(date: GDP.selectedMatch?.match_date ?? "", format: "yyyy-MM-dd'T'HH:mm:ss") {
            countDownTimer = CountDownTimer(endsOn: matchDate, repeatingTask: countDownTimerRepeatingTask, completion: countDownTimerCompletion)
            countDownTimer?.start()
        }
    }
    
    private var countDownTimerRepeatingTask: CompletionHandler? {
         let handler: CompletionHandler = { [weak self] in
             guard let `self` = self,
                 let countDownTimer = self.countDownTimer
                 else {return}
             
             self.lblHeader.text = countDownTimer.timeLeft

         }
         return handler
     }

     private var countDownTimerCompletion: CompletionHandler? {
         let handler: CompletionHandler = { [weak self] in
             guard let `self` = self else {return}

             self.lblHeader.text = GDP.selectedMatch?.match_status?.capitalized ?? "Match Started"
             self.alertBoxWithAction(message: ConstantMessages.kMatchNotStarted, btnTitle: ConstantMessages.OkBtn) {
                 self.navigationController?.popToRootViewController(animated: true)
             }
         }
         return handler
     }

    @objc func createdTeamSuccess(notification : NSNotification)
    {
        self.isContestJoinFlow = true
        self.perform(#selector(getTeamLists), with: self, afterDelay: 1.0)
    }
    
    
    @IBAction func btnChoosePrizeBreakupPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if isValidate() {
            self.contestData.prizeAmount = self.txtFEntryPrice.text!
            self.contestData.contestSize = self.txtFContestSize.text!
            self.contestData.title = self.txtFContestName.text!
            self.contestData.multiple_winner = self.btnAllowMultipleUser.isSelected
            
            if (Int(self.contestData.contestSize) ?? 2) == 2 || (Int(self.contestData.prizeAmount) ?? 0) <= 0 {
                
                if (Int(self.contestData.prizeAmount) ?? 0) <= 0 {
                    self.contestData.totalWinners = "1"
                    self.contestData.entryFees = "0"
                }else if (Int(self.contestData.contestSize) ?? 2) == 2 {
                    self.contestData.totalWinners = "1"
                }
                
                if (Int(self.contestData.teamCounts) ?? 0) > 0 {
                    if self.contestData.teamId.count <= 0 || Int(self.contestData.teamCounts) ?? 0 > 0 {
                        self.selectTeamToJoin()
                    }else {
                        self.WalletAmountCheck(teamcount: "1")
                    }
                }else {
                    self.getContestPrizeBreakup()
                }
            }else {
                self.getContestPrizeBreakup()
            }
        }
        
        
//        if isValidate() {
//            
//            // self.contestData.prizeAmount = self.txtFEntryPrice.text!
//            self.contestData.contestSize = self.txtFContestSize.text!
//            self.contestData.title = self.txtFContestName.text!
//            
//            if Int(self.contestData.teamCounts) ?? 0 == 0 {
//                showCreateTeamView()
//            }else {
//                selectTeamToJoin()
//            }
//            
////            if self.contestData.teamId.count <= 0 || Int(self.contestData.teamCounts) ?? 0 > 0 {
////                self.selectTeamToJoin()
////            }else {
////                self.WalletAmountCheck(teamcount: "1")
////            }
//            
////            if (Int(self.contestData.contestSize) ?? 2) == 2 {
////
////                if (Int(self.contestData.prizeAmount) ?? 0) <= 0 {
////                    self.contestData.totalWinners = "1"
////                    self.contestData.entryFees = "0"
////                }else if (Int(self.contestData.contestSize) ?? 2) == 2 {
////                    self.contestData.totalWinners = "1"
////                }
////
////                if (Int(self.contestData.teamCounts) ?? 0) > 0 {
////                    if self.contestData.teamId.count <= 0 || Int(self.contestData.teamCounts) ?? 0 > 0 {
////                        self.selectTeamToJoin()
////                    }else {
////                        self.WalletAmountCheck(teamcount: "1")
////                    }
////                }else {
////                    self.getContestPrizeBreakup()
////                }
////            }else {
////                self.getContestPrizeBreakup()
////            }
//        }
    }
    
    
    @IBAction func btnAllowMultiTeamPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    //MARK: - Create Contest Conditions
    
    func showCreateTeamView() {
        
        let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "CreateTeamViewController") as! CreateTeamViewController
        VC.strVCFrom = "CreateContest"
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    
    func selectTeamToJoin()
    {
        let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "SelectTeamViewController") as! SelectTeamViewController
        VC.completionHandler = { (team, teamCount) in
            print(team, teamCount)
            self.teamCount = String(teamCount )
            self.setTeamId(teamId: (team.team_id ?? "0"), teamCount: String(teamCount ))
            
        }
        VC.createTeamcompletionHandler = { (success) in
            self.showCreateTeamView()
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
    
    func setTeamId(teamId: String, teamCount:String) {
        print("teamId--->",teamId)
        self.contestData.teamCounts = "1"
        self.contestData.teamId = teamId
        self.WalletAmountCheck(teamcount: teamCount)
    }
    
    //MARK: - Validation
//    func isValidate() -> Bool{
//        var msg = ""
//        
//        if (txtFContestName.text?.trimmingCharacters(in: .whitespaces).count ?? 0) == 0{
//            msg = ConstantMessages.ENT_CONTEST_NAME
//            AppManager.showToast(msg, view: self.view)
//            return false
//        }
//        
//        if (txtFContestSize.text?.trimmingCharacters(in: .whitespaces).count ?? 0) == 0{
//            msg = ConstantMessages.ENT_CONTEST_SIZE
//            AppManager.showToast(msg, view: self.view)
//            return false
//        }
//        
//        var contentS = 0
//        txtFContestSize.text?.count != 0 ? (contentS = Int(txtFContestSize.text!)!) : (contentS = 0)
//        if contentS < 2  ||  contentS > 10000
//        {
//            msg = ConstantMessages.INCORRECT_CONTEST_SIZE_ENT
//            AppManager.showToast(msg, view: self.view)
//            return false
//        }
//        
////        if (txtFMaxTeam.text?.trimmingCharacters(in: .whitespaces).count ?? 0) == 0{
////            msg = ConstantMessages.ENT_MAX_TEAM
////            AppManager.showToast(msg, view: self.view)
////            return false
////        }
////        
////        if contentS < Int(txtFMaxTeam.text ?? "0") ?? 0 {
////            msg = ConstantMessages.ENT_VALID_MAX_TEAM
////            AppManager.showToast(msg, view: self.view)
////            return false
////        }
////
////        if (txtFLoserPunishment.text?.trimmingCharacters(in: .whitespaces).count ?? 0) == 0{
////            msg = ConstantMessages.ENT_LOSER_PUNISHMENT
////            AppManager.showToast(msg, view: self.view)
////            return false
////        }
//        
//        return true
//        
//    }
    
    
    //MARK: - Validation
    func isValidate() -> Bool{
        var msg = ""
        
        if (txtFContestName.text?.trimmingCharacters(in: .whitespaces).count ?? 0) == 0{
            msg = ConstantMessages.ENT_CONTEST_NAME
            AppManager.showToast(msg, view: self.view)
            return false
        }
        
        if (txtFContestSize.text?.trimmingCharacters(in: .whitespaces).count ?? 0) == 0{
            msg = ConstantMessages.ENT_CONTEST_SIZE
            AppManager.showToast(msg, view: self.view)
            return false
        }

        if txtFEntryPrice.text == ""
        {
            msg = ConstantMessages.ENT_PRIZE_AMOUNT
            AppManager.showToast(msg, view: self.view)
            return false
            
        }
                    
        var prize = 0
        txtFEntryPrice.text?.count != 0 ? (prize = Int(txtFEntryPrice.text ?? "0") ?? 0) : (prize = 0)
        if prize < 0 ||  prize > 10000
        {
            msg = ConstantMessages.INCORRECT_WINNING_AMOUNT
            AppManager.showToast(msg, view: self.view)
            return false
        }
        
        var contentS = 0
        txtFContestSize.text?.count != 0 ? (contentS = Int(txtFContestSize.text ?? "0") ?? 0) : (contentS = 0)
        if contentS < 2  ||  contentS > 100
        {
            msg = ConstantMessages.INCORRECT_CONTEST_SIZE_ENT
            AppManager.showToast(msg, view: self.view)
            return false
        }
        
        if self.entryFee < 5.0 && prize > 0
        {
            msg = ConstantMessages.ENT_FEE_LESS_THAN_5
            AppManager.showToast(msg, view: self.view)
            return false
            
        }
        
        return true
        
    }
}



extension CreateContestViewController {
    
    func getEntryFee(){
        let params:[String:String] = ["contest_size": txtFContestSize.text ?? "0",
                                      "winning_amount":txtFEntryPrice.text ?? "0"
                                       
        ]
        let url = URLMethods.BaseURL + URLMethods().getEntryFees
        
        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                if result != nil {
                    let data = result?.object(forKey: "results") as? [String:Any]
                    if data != nil{
                        let fee = (data?["entry_fee"] as? Double) ?? 0
                        self.entryFee = fee.rounded(toPlaces: 2)
                        self.contestData.entryFees = "\(fee.rounded(toPlaces: 2))"
                        self.lblPrizePool.text = "\(CommonFunctions.suffixNumberIndian(currency: fee.rounded(toPlaces: 2)))"
                        if fee < 5 && (Int(self.txtFEntryPrice.text ?? "0") ?? 0) > 0 {
                            AppManager.showToast(ConstantMessages.ENT_FEE_LESS_THAN_5, view: self.view)
                        }
                    }
                }
            }
            
            else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
            AppManager.stopActivityIndicator(self.view)
        }
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
    
    func WalletAmountCheck (teamcount:String){
        
        let params:[String:String] = ["contest_id": "",
                                      "match_id":String(GDP.selectedMatch?.match_id ?? 0),
                                      "series_id":String(GDP.selectedMatch?.series_id ?? 0),
                                      "entry_fees":"\(self.getDouble(for: self.contestData.entryFees).rounded(toPlaces: 2))"
        ]
        
        let url = URLMethods.BaseURL + URLMethods().joinContestCheckWallet
        
        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
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
            }
            
            else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
            AppManager.stopActivityIndicator(self.view)
        }
        AppManager.startActivityIndicator(sender: self.view)
    }
    
    //    func getEntryFee(){
    //        let params:[String:String] = ["contest_size": txtFContestSize.text ?? "0",
    //                                      "winning_amount":txtFEntryPrice.text ?? "0"
    //
    //        ]
    //
    //        let url = URLMethods.BaseURL + URLMethods().getEntryFees
    //
    //        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
    //
    //            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
    //
    //            if isSuccess == true{
    //                if result != nil {
    //                    let data = result?.object(forKey: "results") as? [String:Any]
    //                        if data != nil{
    //                                let fee = (data?["entry_fee"] as? Double) ?? 0
    //                            self.entryFee = fee.rounded(toPlaces: 2)
    //                            self.contestData.entryFees = "\(fee.rounded(toPlaces: 2))"
    //                            self.lblPrizePool.text = "\(GDP.globalCurrency) \(CommonFunctions.suffixNumberIndian(currency: fee.rounded(toPlaces: 2)))"
    //                            if fee < 5 && (Int(self.txtFEntryPrice.text ?? "0") ?? 0) > 0 {
    //                                AppManager.showToast(ConstantMessages.ENT_FEE_LESS_THAN_5, view: self.view)
    //                                return
    //                            }
    //
    //                        }
    //                }
    //            }
    //
    //            else{
    //                AppManager.showToast(msg ?? "", view: self.view)
    //            }
    //            AppManager.stopActivityIndicator(self.view)
    //        }
    //    }
    
    func getContestPrizeBreakup(){
        let params:[String:Any] = ["contest_size": Int(txtFContestSize.text ?? "0") ?? 0
        ]
        
        let url = URLMethods.BaseURL + URLMethods().contestPriceBreakup
        
        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                if result != nil {
                    let data = result?.object(forKey: "results") as? [[String:Any]]
                    if data != nil{
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                              let tblData = try? JSONDecoder().decode([CAWinningBreakupDatum].self, from: jsonData)else {return }
                        
                        let vc = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "ChooseWinningBreakupVC")as! ChooseWinningBreakupVC
                        vc.contestData = self.contestData
                        vc.arrWinList = tblData
                        vc.gameType = self.gameType
                        if tblData.count > 0 {
                            vc.contestData.totalWinners = "\((tblData[0]).id ?? 2)"
                            vc.arrWinnerList = (tblData[0]).info!
                        }
                        self.navigationController?.pushViewController(vc, animated: false)
                    }
                }
            }
            
            else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
            AppManager.stopActivityIndicator(self.view)
        }
    }
}
extension CreateContestViewController : UITextFieldDelegate {
    
    func  textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

}

extension CreateContestViewController {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //        self.calculationEntry()
        if (self.txtFEntryPrice.text?.count ?? 0) > 0 && (self.txtFContestSize.text?.count ?? 0) > 0 && textField != self.txtFContestName {
            if (Int(self.txtFEntryPrice.text ?? "0") ?? 0) > 0 {
                self.getEntryFee()
            }else {
                let fee = 0
                self.contestData.entryFees = "\(fee)"
                self.lblPrizePool.text = "\(fee)"
            }
            //arpita
           /* if (Int(txtFContestSize?.text ?? "0") ?? 0) <= 2 {
                self.btnCreateContest.setTitle("Create Contest", for: .normal)
            }else if (Int(txtFContestSize?.text ?? "0") ?? 0) > 2 {
                self.btnCreateContest.setTitle("Choose Winning Breakup", for: .normal)
            }*/
        }
    }
  
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
//        guard range.location == 0 else {
//                return true
//            }
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
        
        if newString == "0"
        {
            textField.text = ""
            return false
        }
        
        if textField == self.txtFContestName {
            if range.location >= 25 && string != "" {
                return false
            }
        }else if textField == self.txtFEntryPrice {
            self.entryFee = 0.0
            self.lblPrizePool.text = "\(0)"
            if range.location >= 5 && string != "" {
                return false
            }
            
            let allowedCharacters = CharacterSet(charactersIn: "0123456789")
            let characterSet = CharacterSet(charactersIn: string)
            if allowedCharacters.isSuperset(of: characterSet) {
                return true
            } else {
                return false
            }
            
        }else if textField == self.txtFContestSize {
            self.entryFee = 0.0
            self.lblPrizePool.text = "\(0)"
            if range.location >= 3 && string != "" {
                return false
            }
            
            let allowedCharacters = CharacterSet(charactersIn: "0123456789")
            let characterSet = CharacterSet(charactersIn: string)
            if allowedCharacters.isSuperset(of: characterSet) {
                return true
            } else {
                return false
            }
        }
        
        if string.rangeOfCharacter(from: CharacterSet.alphanumerics) != nil || string.rangeOfCharacter(from: CharacterSet.whitespaces) != nil || string == "" {
            return true
        }else {
            return false
        }
    }
}

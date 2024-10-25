//
//  ContestDetailViewController.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 09/03/22.
//

import UIKit
import SDWebImage
import MessageUI

class ContestDetailViewController: BaseClassWithoutTabNavigation {

    @IBOutlet weak var navigationView: CustomNavigation!

    @IBOutlet weak var lblVisitorTeam: UILabel!
    @IBOutlet weak var lblHomeTeam: UILabel!
    @IBOutlet weak var imgVisitorTeam: UIImageView!
    @IBOutlet weak var imgLocalTeam: UIImageView!
    @IBOutlet weak var lblVS: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var btnJoin: UIButton!
    @IBOutlet weak var lblTotalSpots: UILabel!
    @IBOutlet weak var lblLeftSpots: UILabel!
    @IBOutlet weak var viewPrize: UIView!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var btnPrize: UIButton!
    @IBOutlet weak var lblContestNamr: UILabel!
    @IBOutlet weak var tblContestDetails: UITableView!
    @IBOutlet weak var viewLeaderboard: UIView!
    @IBOutlet weak var viewWinnings: UIView!
    @IBOutlet weak var btnLeaderboard: UIButton!
    @IBOutlet weak var btnWinnings: UIButton!
    @IBOutlet weak var btnRewardAmount: UIButton!
    @IBOutlet weak var btnTrophyPercantage: UIButton!
    @IBOutlet weak var btnMaxTeam: UIButton!
    @IBOutlet weak var btnShareFriends: UIButton!
    @IBOutlet weak var btnGuaranteeStatus: UIButton!
    
    
    var contestData:ContestData? = nil
    var isFromInviteContest = false
    
    var arrTeam = [Team]()
    
    @IBOutlet weak var EntryModuleWidth: NSLayoutConstraint!
    var isLiveContest:Bool = false
    
    var tipView = EasyTipHelper()
    var strFromVC = ""
    var selectedUserRank = ""
    var selectedTeamName = ""
    
    var teamCount = "0"
    var selectedTeam:Team? = nil
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GlobalDataPersistance.shared.isFromContestList = false
        self.setupUI()
        self.btnWinningLeaderboardPressed(btnWinnings)
        if #available(iOS 15.0, *) {
            self.tblContestDetails.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        
        navigationView.configureNavigationBarWithController(controller: self, title: "Leaderboard", hideNotification: false, hideAddMoney: true, hideBackBtn: false)
        navigationView.img_BG.isHidden = true
        navigationView.isFromInviteContest = isFromInviteContest
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTeamList(notification:)), name: NSNotification.Name(rawValue: Constants.kTeamCreation), object: nil)
        
//        if GlobalDataPersistance.shared.gameType == "running" || GlobalDataPersistance.shared.gameType == "completed"{
//            if GDP.selectedMatch?.match_status?.uppercased() == "FINISHED" || GDP.selectedMatch?.match_status?.uppercased() == "COMPLETED"{
//                self.lblVS.text = "COMPLETED"
//            }else{
//                self.lblVS.text = GDP.selectedMatch?.match_status ?? ""
//            }
//        }else{
//            self.startTimer()
//        }
        
        if GDP.selectedMatch?.match_status?.uppercased() == "FINISHED" || GDP.selectedMatch?.match_status?.uppercased() == "COMPLETED"{
            self.lblVS.text = "COMPLETED"
        }else{
            self.startTimer()
        }
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: attributes)
        refreshControl.tintColor = .white
        self.refreshControl.addTarget(self, action: #selector(self.refreshTableData(_:)), for: .valueChanged)
        tblContestDetails.addSubview(refreshControl)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getTeamLists()

    }
    
    @objc func refreshTableData(_ sender: AnyObject) {
        self.getTeamLists()
    }
    
    
    @objc func refreshTeamList(notification : NSNotification)
    {
        if GlobalDataPersistance.shared.isFromContestList == true{
            GlobalDataPersistance.shared.isFromContestList = false
            GlobalDataPersistance.shared.isContestJoinFlow = true
            self.perform(#selector(getTeamLists), with: self, afterDelay: 1.0)
        }
    }
    
    func startTimer()
    {
//        CommonFunctions().timerStart(date: self.lblVS, strTime: GDP.selectedMatch?.start_time ?? "", strDate: GDP.selectedMatch?.start_date, viewcontroller: self)
        
        CommonFunctions().timerStart(lblTime: self.lblVS, strDate: GDP.selectedMatch?.match_date ?? "", viewcontroller: self, fromSeasonMyTeams: false, isFromHome: true)
    }
    
    func setupUI(){
        lblHomeTeam.text = GDP.selectedMatch?.localteam_short_name ?? ""
        lblVisitorTeam.text = GDP.selectedMatch?.visitorteam_short_name ?? ""
        
        imgLocalTeam.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgLocalTeam.sd_setImage(with: URL(string: GDP.selectedMatch?.localteam_flag ?? ""), placeholderImage: Constants.kNoImageUser)

        imgVisitorTeam.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgVisitorTeam.sd_setImage(with: URL(string: GDP.selectedMatch?.visitorteam_flag ?? ""), placeholderImage: Constants.kNoImageUser)
        
//        lblContestNamr.text = contestData?.name ?? "Prize"
        lblContestNamr.text = "Prize"

        if self.isLiveContest == true{
            lblVS.text = "LIVE"
           // EntryModuleWidth.constant = 0
            btnJoin.isHidden = true
        }
        
        if GDP.selectedMatch?.match_status == "Not Started" || GDP.selectedMatch?.match_status == "FIXTURE" {
            
            if self.contestData?.created_by ?? "" == "admin"{
                btnShareFriends.isHidden = true
            }else{
                btnShareFriends.isHidden = false
            }
        }else{
            btnShareFriends.isHidden = true
        }
        
        if contestData?.confirm_winning == true{
            btnGuaranteeStatus.isHidden = false
        }else{
            btnGuaranteeStatus.isHidden = true
        }
        
        self.populateData()
    }

    func populateData(){
        
        if self.contestData?.winning_amount ?? 0 == 0 {
            if let firstPrize = self.contestData?.price_breakup?.first(where: {$0.start_rank == 1}) {
                lblAmount.text = firstPrize.reward
            }else {
                if contestData?.created_by == "user" {
                    lblAmount.text = " Punishment "
                    viewPrize.backgroundColor = .appHighlightedTextColor
                    lblAmount.textColor = .black
                    lblAmount.font = .init(name: Constants.kSemiBoldFont, size: 14)
                    viewPrize.layer.cornerRadius = 5
                }
            }
        }else {
            lblAmount.text = "\(GDP.globalCurrency)\(CommonFunctions.suffixNumberIndian(currency: self.contestData?.winning_amount ?? 0))"
        }
        
       // btnJoin.setTitle("Join", for: .normal)
        btnJoin.backgroundColor = .appHighlightedTextColor
        btnJoin.setTitleColor(.black, for: .normal)
        btnJoin.isUserInteractionEnabled = true
//        btnJoin.setTitle("\(GDP.globalCurrency)\(self.contestData?.entry_fee ?? 0)", for: .normal)
        
        if contestData?.entry_fee ?? 0 <= 0 {
            self.btnJoin.setTitle("Free", for: .normal)
        }else {
            let strAmount = CommonFunctions.suffixNumberIndian(currency: (self.contestData?.entry_fee ?? 0))
            self.btnJoin.setTitle("\(GDP.globalCurrency)\(strAmount)", for: .normal)
        }
        
//        lblAmount.textColor = UIColor.appTitleColor
//        lblEntryFee.text = "₹ \(self.contestData?.entry_fee ?? 0)"
        //"\(self.contestData?.entry_fee ?? 0)"
//        btnJoin.setTitleColor(.white, for: .normal)
       // lblEntryFee.textColor = UIColor.appTitleColor
        let spotLeft = Int(self.contestData?.users_limit ?? 0) - (self.contestData?.joined_teams_count ?? 0)
        
        progressBar.progress = Float(self.contestData?.joined_teams_count ?? 0)/Float(self.contestData?.users_limit ?? 0)
        
        if spotLeft < 2
        {
            if spotLeft == 0{
                lblLeftSpots.text = "Contest Full"
                btnJoin.backgroundColor = .clear
                btnJoin.setTitleColor(.appHighlightedTextColor, for: .normal)
                btnJoin.isUserInteractionEnabled = false
                
                if contestData?.entry_fee ?? 0 <= 0 {
                    self.btnJoin.setTitle("Free", for: .normal)
                }else {
                    let strAmount = CommonFunctions.suffixNumberIndian(currency: (self.contestData?.entry_fee ?? 0))
                    self.btnJoin.setTitle("\(GDP.globalCurrency)\(strAmount)", for: .normal)
                }
                
            }else{
                lblLeftSpots.text = "\(spotLeft.formattedNumber()) spot left"
            }
        }
        else
        {
            lblLeftSpots.text = "Only \(spotLeft.formattedNumber()) spots left"
        }
        
        if (contestData?.my_teams_ids?.count ?? 0) >= (contestData?.max_team_join_count ?? 0) {
            
            btnJoin.backgroundColor = .clear
            btnJoin.setTitleColor(.appHighlightedTextColor, for: .normal)
            btnJoin.isUserInteractionEnabled = false
            
            if contestData?.entry_fee ?? 0 <= 0 {
                self.btnJoin.setTitle("Free", for: .normal)
            }else {
                let strAmount = CommonFunctions.suffixNumberIndian(currency: (self.contestData?.entry_fee ?? 0))
                self.btnJoin.setTitle("\(GDP.globalCurrency)\(strAmount)", for: .normal)
            }
        }
        
        lblTotalSpots.text = "\((self.contestData?.users_limit ?? 0).formattedNumber()) Spots"
        
        let firstWinnerPrize = Double(self.contestData?.total_winners ?? 0)/Double(self.contestData?.users_limit ?? 0)
        
        if (contestData?.entry_fee ?? 0) > 0{
            self.btnTrophyPercantage.isHidden = false
            if Double(firstWinnerPrize * 100).rounded(toPlaces: 2).isInteger{
                btnTrophyPercantage.setTitle("\(Int(firstWinnerPrize * 100))%", for: .normal)
            }else{
                btnTrophyPercantage.setTitle("\(Double(firstWinnerPrize * 100).rounded(toPlaces: 2))%", for: .normal)
            }
            
            
            if self.contestData?.price_breakup?.count ?? 0 > 0{
                btnRewardAmount.setTitle("\(GDP.globalCurrency)\(CommonFunctions.suffixNumberIndian(currency: self.contestData?.price_breakup?[0].each_price ?? 0))", for: .normal)
            }
            
        }else{
            self.btnTrophyPercantage.isHidden = true
            let prize = lblAmount.text ?? ""
            btnRewardAmount.setTitle(prize == " Punishment " ? "" : prize == "" ? "" : prize, for: .normal)
        }
    
        
        if (self.contestData?.max_team_join_count ?? 0) == 1{
            self.btnMaxTeam.setTitle("Max 1 Team", for: .normal)
        }else{
            self.btnMaxTeam.setTitle("Max \(self.contestData?.max_team_join_count ?? 0) Teams", for: .normal)
        }

        tblContestDetails.reloadData()
    }
    
    func isMatchTimeOver() -> Bool  {
        
        if let matchDate = CommonFunctions.getDateFromString(date: GDP.selectedMatch?.match_date ?? "", format: "yyyy-MM-dd'T'HH:mm:ss"), Date() >= matchDate {
            self.alertBoxWithAction(message: ConstantMessages.kMatchNotStarted, btnTitle: ConstantMessages.OkBtn) { }
            return true
        }
        return false
    }
    
    @IBAction func btnRewardPressed(_ sender: UIButton) {
        
        if self.contestData?.created_by == "user", let punishment = contestData?.loserPunishment {
            sender.isSelected = !sender.isSelected
            tipView.showEasyTip(sender: sender, onView: self.view, withText: punishment)
        }
    }
    
    @IBAction func btnDownloadPressed(_ sender: Any) {
        if GDP.selectedMatch?.match_status == "Not Started" || GDP.selectedMatch?.match_status == "FIXTURE"{
            AppManager.showToast("Match is not started yet.", view: self.view)
            return
        }
        downloadTeam()
        
    }

    @IBAction func btnBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnJoinTeamPressed(_ sender: UIButton) {
        
        guard !isMatchTimeOver() else {return}
        let spotLeft = Int(self.contestData?.users_limit ?? 0) - (self.contestData?.joined_teams_count ?? 0)

        if spotLeft == 0{
            return
        }
        
//        self.proceedToJoin()
        WebCommunication.shared.getUserProfile(hostController: self, showLoader: true) { user in
                if let user = user{
                    if (user.state ?? "") == "" || (user.dob ?? "") == ""{
                        let VC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "DOBStateViewController") as! DOBStateViewController
                        VC.completionHandler = { (success) in
                            if success == true{
                                self.proceedToJoin()
                            }
                        }
                        UIApplication.getTopMostViewController()?.present(VC, animated: true, completion: nil)
                    }
                    else{
                        self.proceedToJoin()
                    }
                }
            }
    }
    
    
    func proceedToJoin(){
        if self.contestData?.join_multiple_team ?? false == false && self.contestData?.is_joined ?? false == true
        {
            Constants.kAppDelegate.showAlert(msg: ConstantMessages.CANNOT_JOINED_MORETHANSINGLETEAM, isLogout: false, isLocationAlert: false)
            return
        }
        
        else if (self.contestData?.my_teams_ids?.count ?? 0) == (self.contestData?.max_team_join_count ?? 0)
        {
            Constants.kAppDelegate.showAlert(msg: ConstantMessages.CAN_NOT_JOIN_MORE_TEAMS, isLogout: false, isLocationAlert: false)
            return
        }
        
        GlobalDataPersistance.shared.isFromContestList = true
        if GlobalDataPersistance.shared.myTeamCount == 0{
            
            let pushVC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "CreateTeamViewController") as! CreateTeamViewController
            self.navigationController?.pushViewController(pushVC, animated: true)
        }
        else{
            self.initJoinContestFlow()

        }
    }
    
    //MARK: download file
    func downloadTeam(){
        let VC = VCDownloadTeam(nibName: "VCDownloadTeam", bundle: nil)
        VC.downloadTeamClouser =  {(value) in
            self.getDownloadTeamFile(winningTeam: value)
        }
        self.present(VC, animated: true)
    }
    
    func openDownloadFile(url:String){
       
        let url = URL(string: url)
        AppManager.startActivityIndicator("", sender: view)
        FileDownloader.loadFileAsync(url: url!) { (path, error) in
            print("PDF File downloaded to : \(path!)")
            DispatchQueue.main.async {
                AppManager.stopActivityIndicator(self.view)
                if path != ""{
                    let vc = VCShowTeams(nibName: "VCShowTeams", bundle: nil)
                    vc.webUrl = path ?? ""
                    self.navigationController?.pushViewController(vc, animated: true)
                }
              
            }
        
        }
    }
    
    func initJoinContestFlow(){
        if GlobalDataPersistance.shared.myTeamCount > (contestData?.my_teams_ids?.count ?? 0){
            let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "SelectTeamViewController") as! SelectTeamViewController
            VC.contestData = self.contestData
            VC.completionHandler = { (team, teamCount) in
                print(team, teamCount)
                
                var isAlreadyJoined = false
                for i in 0..<(self.contestData?.joined_teams?.count ?? 0) {
                    let jTeam = self.contestData?.joined_teams?[i]
                    if (jTeam?.id ?? "") == team.team_id{
                        isAlreadyJoined = true
                        break
                    }
                }
                
                if isAlreadyJoined == true{
                    Constants.kAppDelegate.showAlert(msg: "You already have joined with this team. Please select another team or create a new one.", isLogout: false, isLocationAlert: false)
                }else{
                    if (self.contestData?.entry_fee ?? 0) == 0{
                        self.setTeamId(team: team, teamCount: String(teamCount))
                    }
                    else if LocationManager.sharedInstance.isPLayingInLegalState() == true{
                        self.setTeamId(team: team, teamCount: String(teamCount))
                    }
                }
            }
            VC.createTeamcompletionHandler = { (success) in
                let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "CreateTeamViewController") as! CreateTeamViewController
                self.navigationController?.pushViewController(VC, animated: true)
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
        else{
            let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "CreateTeamViewController") as! CreateTeamViewController
            self.navigationController?.pushViewController(VC, animated: true)
        }

    }
    
    @IBAction func btnWinningLeaderboardPressed(_ sender: UIButton) {
        btnWinnings.isSelected = false
        btnLeaderboard.isSelected = false
        viewWinnings.backgroundColor = UIColor.clear
        viewLeaderboard.backgroundColor = UIColor.clear
        
        switch sender{
        case btnWinnings:
            btnWinnings.isSelected = true
            viewWinnings.backgroundColor =  UIColor.appRedColor
            tblContestDetails.reloadData()
            break
        case btnLeaderboard:
            btnLeaderboard.isSelected = true
            viewLeaderboard.backgroundColor =  UIColor.appRedColor
            tblContestDetails.reloadData()
            break
        default:            
            break
            
            
            
        }
    }
    
    @IBAction func btnInviteFriendsPressed(_ sender: UIButton) {
        
        guard !isMatchTimeOver() else {return}
        let inviteCode = self.contestData?.invite_code ?? ""

        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let btnCopy = UIAlertAction(title: "Copy Code", style: .default) { action in
            AppManager.showToast(ConstantMessages.COPY_SUCCESS.localized(), view: self.view)
            UIPasteboard.general.string = inviteCode.uppercased()
        }
        
        let btnShare = UIAlertAction(title: "Invite Friends", style: .default) { action in
            self.inviteFriends(inviteCode: inviteCode)
        }
        
        let btnCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(btnCopy)
        actionSheet.addAction(btnShare)
        actionSheet.addAction(btnCancel)
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func inviteFriends(inviteCode: String) {
        
//        guard let link = URL(string: "\(URLMethods.contestInviteWebAppLink)\(inviteCode)") else { return }
//
//        let textToShare = [ link.absoluteString ]
//        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
//        activityViewController.popoverPresentationController?.sourceView = self.view
//        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
//        self.present(activityViewController, animated: true, completion: nil)
        
        guard let link = URL(string: "\(URLMethods.DeepLinkURL)/?inviteCode=\(inviteCode)") else { return }
        
        CommonFunctions().getDynamicLink(link: link) { dynamicLink in
            
            //let text = "You've been challenged! \n\nThink you can beat me? Join the contest on India’s fantasy for the \(GDP.selectedMatch?.series_name ?? "") match and prove it! \n\nClick on this link \(dynamicLink) or use my invite code \(inviteCode.uppercased()) to accept this challenge!"
            
            let textToShare = [ dynamicLink ]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnReportPressed(_ sender: UIButton) {
        
        sendEmail()
    }
    
    @IBAction func btnWalletPressed(_ sender: Any) {
        let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "MyAccountDetailsVC") as! MyAccountDetailsVC
        self.navigationController?.pushViewController(pushVC, animated: true)
    }
    
    func setTeamId(team: Team, teamCount:String)
    {
        print("teamId--->",team.team_id ?? "")
        self.selectedTeam = team
        if GDP.selectedMatch != nil
        {
            var findCurrentCount = GDP.selectedMatch?.my_total_teams ?? 0
            findCurrentCount += 1
            GDP.selectedMatch?.my_total_teams = findCurrentCount
        }
        self.teamCount = String(GlobalDataPersistance.shared.myTeamCount)
        self.checkWalletValidation(team: team, teamcount: GlobalDataPersistance.shared.myTeamCount)
    }
    
    @IBAction func btnToolTipPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        var str = "My easy Tip"
        if sender.titleLabel?.text == ConstantMessages.kGloryMessageShort{
            return
        }
        if sender.tag == 1{
            btnMaxTeam.isSelected = false
            btnTrophyPercantage.isSelected = false
            btnGuaranteeStatus.isSelected = false
            if self.contestData?.price_breakup?.count ?? 0 > 0
            {
                let strAmount = CommonFunctions.suffixNumberIndian(currency: (self.contestData?.price_breakup?[0].each_price ?? 0))
                if (self.contestData?.entry_fee ?? 0) > 0{
                    str = "First Prize = \(GDP.globalCurrency)\(strAmount)"
                }else{
                    guard let reward = contestData?.price_breakup?[0].reward else {
                        tipView.tipView.dismiss()
                        return
                    }
                    str = reward
                }
            }
           // return
        }else if sender.tag == 2{
            btnMaxTeam.isSelected = false
            btnRewardAmount.isSelected = false
            btnGuaranteeStatus.isSelected = false
            str = "\(self.contestData?.total_winners ?? 0) teams win in this contest"
        }else if sender.tag == 3{
            btnRewardAmount.isSelected = false
            btnTrophyPercantage.isSelected = false
            btnGuaranteeStatus.isSelected = false
            str = "Max \(self.contestData?.max_team_join_count ?? 0) entries allowed in this contest"
        }else if sender.tag == 4{
            btnMaxTeam.isSelected = false
            btnTrophyPercantage.isSelected = false
            btnRewardAmount.isSelected = false
            str = ConstantMessages.kGuaranteeMessage

        }
        
        tipView.showEasyTip(sender: sender, onView: self.navigationController?.view ?? UIView(), withText: str)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tipView.tipView.dismiss()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tipView.tipView.dismiss()
    }
}
extension ContestDetailViewController{
    
    //MARK: Api getDownloadTeamFile
    func getDownloadTeamFile(winningTeam:Bool){
        let params:[String:Any] = ["contest_id": contestData?.id ?? "0",
                                   "match_id":String(GDP.selectedMatch?.match_id ?? 0),
                                   "series_id":String(GDP.selectedMatch?.series_id ?? 0),
                                   "winning_team": winningTeam
        ]
       // let params: [String:String] = [String:String]()

        let url = URLMethods.BaseURL + URLMethods().getContestTeam
        //+ "?series_id=\(String(selectedMatch?.series_id ?? 0))" + "&match_id=\(String(selectedMatch?.match_id ?? 0))" + "&contest_id=\(contestData?.id ?? "0")" + "&winning_team=\(true)"
        
        ApiClient.init().getRequest(method: url, parameters: params, view: (self.view)!) { result in
                if result != nil {
                    let status = result?.object(forKey: "success") as? Bool ?? false
                    let msg = result?.object(forKey: "message") as? String ?? ""
                    if status == true{
                        let pdfUrl = result?.object(forKey: "result") as? String
                        if pdfUrl != ""{
                            self.openDownloadFile(url: pdfUrl ?? "")
                        }
                       
                    }else{
                        AppManager.showToast(msg, view: (self.view)!)
                    }
                   
                }else{
                    AppManager.showToast("", view: (self.view)!)
                }
            }
        }
    
    
    @objc func getTeamLists (){
        WebCommunication.shared.getTeams(hostController: self, match_id: (GDP.selectedMatch?.match_id ?? 0), series_id: (GDP.selectedMatch?.series_id ?? 0), showLoader: true) { team in
            if let tblData = team{
                GlobalDataPersistance.shared.myTeamCount = tblData.count
                GlobalDataPersistance.shared.myTeams = tblData
                
                if GlobalDataPersistance.shared.isContestJoinFlow == true{
                    GlobalDataPersistance.shared.isContestJoinFlow = false
                    if GlobalDataPersistance.shared.myTeamCount > 0{
                        if let team = tblData.last{
                            if (self.contestData?.entry_fee ?? 0) == 0{
                                self.setTeamId(team: team, teamCount: String(GlobalDataPersistance.shared.myTeamCount))
                            }
                            else if LocationManager.sharedInstance.isPLayingInLegalState() == true{
                                self.setTeamId(team: team, teamCount: String(GlobalDataPersistance.shared.myTeamCount))
                            }
                        }
                    }
                }
                self.getContestDetails()
            }
        }
    }
   
    
    func getContestDetails (){
        let params:[String:String] = ["user_id": Constants.kAppDelegate.user?.id ?? "",
                                      "match_id":String(GDP.selectedMatch?.match_id ?? 0),
                                      "series_id":String(GDP.selectedMatch?.series_id ?? 0),
                                      "contest_id":contestData?.id ?? "0"
        ]
        
        let url = URLMethods.BaseURL + URLMethods().getContestDetail

        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                if result != nil {
                    let data = result?.object(forKey: "results") as? [String:Any]
                        if data != nil{
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                                  let tblData = try? JSONDecoder().decode(ContestData.self, from: jsonData)else {return }
                            self.contestData = tblData
                            
                            if let arrTeams = self.contestData?.joined_teams{
                                var myTeamsList = arrTeams.filter { m in GlobalDataPersistance.shared.myTeams.contains(where: { $0.team_id == m.id }) }

                                for i in 0..<myTeamsList.count {
                                    var temp = myTeamsList[i]
                                    temp.inMyTeam = true
                                    myTeamsList[i] = temp
                                }
                                
                                myTeamsList = myTeamsList.sorted(by: { ($0.rank ?? 0) < ($1.rank ?? 0) })


                                var otherTeamsList = arrTeams.filter { m in !GlobalDataPersistance.shared.myTeams.contains(where: { $0.team_id == m.id }) }
                                

                                otherTeamsList = otherTeamsList.sorted(by: { ($0.rank ?? 0) < ($1.rank ?? 0) })
                                
                                self.contestData?.joined_teams = [JoinedTeam]()
                                self.contestData?.my_teams = [JoinedTeam]()
                                self.contestData?.my_teams?.append(contentsOf: myTeamsList)
                                self.contestData?.joined_teams?.append(contentsOf: otherTeamsList)
                            }
                            
                          

                          //  self.contestData?.joined_teams = arrTeams
                            

                            self.populateData()
                            
                            self.refreshControl.endRefreshing()
                            
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
    
    func checkWalletValidation (team:Team, teamcount:Int){
        
        if (self.contestData?.users_limit ?? 0) == (contestData?.joined_teams_count ?? 0) && self.contestData?.is_joined ?? false == true
        {
            if (self.contestData?.users_limit ?? 0) == (contestData?.joined_teams_count ?? 0){
                Constants.kAppDelegate.showAlert(msg:"You cannot join this contest more than \((self.contestData?.users_limit ?? 0)) teams", isLogout: false, isLocationAlert: false)

            }else{
                Constants.kAppDelegate.showAlert(msg: ConstantMessages.ALREADY_JOINED_THIS_CONTEST, isLogout: false, isLocationAlert: false)
            }
            return
        }
        
        if self.contestData?.join_multiple_team ?? false == false && self.contestData?.is_joined ?? false == true
        {
            Constants.kAppDelegate.showAlert(msg: ConstantMessages.CANNOT_JOINED_MORETHANSINGLETEAM, isLogout: false, isLocationAlert: false)
            return
        }
        
        if (self.contestData?.my_teams_ids?.count ?? 0) > (self.contestData?.max_team_join_count ?? 0)
        {
            Constants.kAppDelegate.showAlert(msg: ConstantMessages.CAN_NOT_JOIN_MORE_TEAMS, isLogout: false, isLocationAlert: false)
            return
        }
        
        let params:[String:String] = ["contest_id": contestData?.id ?? "",
                                      "match_id":String(GDP.selectedMatch?.match_id ?? 0),
                                      "series_id":String(GDP.selectedMatch?.series_id ?? 0),
                                      "league_type": ""
        ]
        
        let url = URLMethods.BaseURL + URLMethods().joinContestCheckWallet

        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                if result != nil {
                    let data = result?.object(forKey: "results") as? [String:Any]
                    if data != nil{
                        self.parseWalletData(data: data!, team: team, teamcount: teamcount)
                    }
                }
            }
            else{
                if result != nil {
                    let data = result?.object(forKey: "results") as? [String:Any]
                    if data != nil{
                        self.parseWalletData(data: data!, team: team, teamcount: teamcount)
                    }
                    else{
                        AppManager.showToast(msg ?? "", view: self.view)
                    }
                }else{
                    AppManager.showToast(msg ?? "", view: self.view)
                }
            }
            AppManager.stopActivityIndicator(self.view)
        }
        AppManager.startActivityIndicator(sender: self.view)
    }
    
    func parseWalletData(data:[String:Any], team:Team, teamcount:Int){
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
              let tblData = try? JSONDecoder().decode(WalletAmountResults.self, from: jsonData)else {return }
       
        var contestBalance = ContestFeeBalances()
        contestBalance.cashBalance = Double("\(tblData.cashBalance ?? 0.0)") ?? 0.0
        contestBalance.winningBalance = Double("\(tblData.winningBalance ?? 0.0)") ?? 0.0
        contestBalance.usableBalance = Double("\(tblData.usableBonus ?? 0.0)") ?? 0.0
        contestBalance.entryFee = Double("\(tblData.entryFee ?? 0.0)") ?? 0.0
        contestBalance.useableBonousPercent = "\(tblData.useableBonousPercent ?? 0)"
        
        if contestBalance.entryFee - (contestBalance.usableBalance + contestBalance.cashBalance + contestBalance.winningBalance) <= 0
        {

            self.showWalletPopupView(contestBalance, matchData: GDP.selectedMatch,team: team, gameTypeValue: "", contestData:self.contestData!, completionHandler: { receiveData in
                print(receiveData)
                
                self.getContestDetails()

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
                        self.checkWalletValidation(team: self.selectedTeam!, teamcount: 1)
                    }
                    else
                    {
                        self.checkWalletValidation(team: self.selectedTeam!, teamcount: Int(self.teamCount) ?? 0)
                    }
                }
                self.navigationController?.pushViewController(vc, animated: false)
            }))
            
            self.present(alert, animated: true, completion: nil)

        }
        
    }
    
    func loadTeamPreview(team:Team, userId:String) {
        
        var arrPlayerData = [PlayerDetails]()
        var selectedPlayers = SelectedPlayerTypes()
        let dictTeam = team
        self.arrTeam = [dictTeam]
      
        let arrPlayers = dictTeam.seriesPlayer
        
        if arrPlayers?.count ?? 0 > 0
        {
            for index  in 0..<arrPlayers!.count {
                let player = arrPlayers![index]
                var playerData = PlayerDetails()
                playerData.name = "\(player.name ?? "")"
                playerData.credits = "\(self.getDouble(for: player.credits as Any))"
                playerData.role = "\(player.role ?? "")"
                playerData.points = "\(self.getDouble(for: player.points as Any))"
                playerData.image = "\(player.image ?? "")"
                playerData.player_id = "\(player.player_id ?? 0)"
                playerData.is_local_team = "\(player.team_id ?? 0)".caseInsensitiveCompare("\(GDP.selectedMatch?.localteam_id ?? 0)") == .orderedSame
                playerData.is_playing = player.is_playing ?? false
                playerData.isBoosted = player.isBoosted ?? false
                playerData.isDebuffed = player.isDebuffed ?? false
                playerData.boosterDetails = player.boosterDetails ?? []
                playerData.debuffedDetails = player.debuffDetails ?? []
                
                arrPlayerData.append(playerData)
            }
            
        }
        
        for index  in 0..<arrPlayerData.count {
            let player = arrPlayerData[index]
            if player.role.contains(GDP.wc) {
                arrPlayerData[index].role = GDP.wc
            }
        }
        
        selectedPlayers.batsman = Int("\(dictTeam.total_batsman ?? 0)") ?? 0
        selectedPlayers.allrounder = Int("\(dictTeam.total_allrounder ?? 0)") ?? 0
        selectedPlayers.bowler =  Int("\(dictTeam.total_bowler ?? 0)") ?? 0
        selectedPlayers.wicketkeeper = Int("\(dictTeam.total_wicketkeeper ?? 0)") ?? 0
        
        let captain = arrPlayerData.filter({$0.player_id == "\(dictTeam.captain_player_id ?? "0")"})
        let viceCaptain = arrPlayerData.filter({$0.player_id == "\(dictTeam.vice_captain_player_id ?? "0")"})
        
        let vc = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "TeamPreviewVC") as! TeamPreviewVC

        vc.teamNumber = "\(dictTeam.team_number ?? 0)"
        vc.strFromVC = "\(self.strFromVC)Leaderboard"
        
        vc.otherUserId = userId
        vc.playerDetails = arrPlayerData
        vc.selectedPlayers = selectedPlayers
        vc.teamName = self.selectedTeamName
        vc.strCaptainId = captain.count > 0 ? captain[0].player_id : ""
        vc.strViceCaptainId = viceCaptain.count > 0 ? viceCaptain[0].player_id : ""
        vc.strPointsSuffix = "Cr"
        vc.modalPresentationStyle = .custom
        vc.userTeamRank = self.selectedUserRank
        vc.userTeamName = self.selectedTeamName
        vc.TeamData = dictTeam
        vc.validTeamID = dictTeam.id ?? ""
        vc.delegate = self
        UIApplication.getTopMostViewController()?.present(vc, animated: true, completion: nil)
        
    }
    
//    func getTeamAPI (team_id:String, userId:String){
//        let params:[String:String] = ["team_id": team_id,
//                                      "match_id":String(GDP.selectedMatch?.match_id ?? 0),
//                                      "series_id":String(GDP.selectedMatch?.series_id ?? 0)
//        ]
//
//        let url = URLMethods.BaseURL + URLMethods().getTeamList
//
//        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
//
//            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
//
//            if isSuccess == true{
//                if result != nil {
//                    let data = result?.object(forKey: "results") as? [[String:Any]]
//                        if data != nil{
//                            guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
//                                  let tblData = try? JSONDecoder().decode([Team].self, from: jsonData)else {return }
//
//                            var arrPlayerData = [PlayerDetails]()
//                            var selectedPlayers = SelectedPlayerTypes()
//                            self.arrTeam = tblData
//                            var dictTeam:Team?
//                            if self.arrTeam.count > 0 {
//                                dictTeam = self.arrTeam[0]
//                            }else {
//                                return
//                            }
//
//                            let arrPlayers = dictTeam!.seriesPlayer
//
//                            if arrPlayers?.count ?? 0 > 0
//                            {
//                                for index  in 0..<arrPlayers!.count {
//                                    let player = arrPlayers![index]
//                                    var playerData = PlayerDetails()
//                                    playerData.name = "\(player.name ?? "")"
//                                    playerData.credits = "\(self.getDouble(for: player.credits as Any))"
//                                    playerData.role = "\(player.role ?? "")"
//                                    playerData.points = "\(self.getDouble(for: player.points as Any))"
//                                    playerData.image = "\(player.image ?? "")"
//                                    playerData.player_id = "\(player.player_id ?? 0)"
//                                    playerData.is_local_team = "\(player.team_id ?? 0)".caseInsensitiveCompare("\(GDP.selectedMatch?.localteam_id ?? 0)") == .orderedSame
//                                    playerData.is_playing = player.is_playing ?? false
//                                    arrPlayerData.append(playerData)
//                                }
//
//                            }
//
//                            for index  in 0..<arrPlayerData.count {
//                                let player = arrPlayerData[index]
//                                if player.role.contains(GDP.wc) {
//                                    arrPlayerData[index].role = GDP.wc
//                                }
//                            }
//
//                            selectedPlayers.batsman = Int("\(dictTeam?.total_batsman ?? 0)") ?? 0
//                            selectedPlayers.allrounder = Int("\(dictTeam?.total_allrounder ?? 0)") ?? 0
//                            selectedPlayers.bowler =  Int("\(dictTeam?.total_bowler ?? 0)") ?? 0
//                            selectedPlayers.wicketkeeper = Int("\(dictTeam?.total_wicketkeeper ?? 0)") ?? 0
//
//                            let captain = arrPlayerData.filter({$0.player_id == "\(dictTeam?.captain_player_id ?? "0")"})
//                            let viceCaptain = arrPlayerData.filter({$0.player_id == "\(dictTeam?.vice_captain_player_id ?? "0")"})
//
//                            let vc = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "TeamPreviewVC") as! TeamPreviewVC
//
//                            vc.teamNumber = "\(dictTeam?.team_number ?? 0)"
//                            vc.strFromVC = "\(self.strFromVC)Leaderboard"
//
//                            vc.otherUserId = userId
//                            vc.playerDetails = arrPlayerData
//                            vc.selectedPlayers = selectedPlayers
//                            vc.teamName = self.selectedTeamName
//                            vc.strCaptainId = captain.count > 0 ? captain[0].player_id : ""
//                            vc.strViceCaptainId = viceCaptain.count > 0 ? viceCaptain[0].player_id : ""
//                            vc.strPointsSuffix = "Cr"
//                            vc.modalPresentationStyle = .custom
//                            vc.userTeamRank = self.selectedUserRank
//                            vc.userTeamName = self.selectedTeamName
//                            vc.TeamData = tblData[0]
//                            vc.validTeamID = tblData[0].id ?? ""
//                            vc.delegate = self
//                            UIApplication.getTopMostViewController()?.present(vc, animated: true, completion: nil)
//
//                        }
//                }
//            }
//
//            else{
//                AppManager.showToast(msg ?? "", view: self.view)
//            }
//            AppManager.stopActivityIndicator(self.view)
//
//        }
//        AppManager.startActivityIndicator(sender: self.view)
//    }
}

extension ContestDetailViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if btnWinnings.isSelected == true {
            return contestData?.price_breakup?.count ?? 0
        }else{
            if section == 0{
                return contestData?.my_teams?.count ?? 0
            }else{
                return contestData?.joined_teams?.count ?? 0
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if btnLeaderboard.isSelected == true{
            return 2
        }else{
            return 1;
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if btnWinnings.isSelected == true{
//            return 0
//        }
        return 40;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))

        if btnWinnings.isSelected == true{
            let winningHeader:WinningsHeaderView = WinningsHeaderView.instanceFromNib() as! WinningsHeaderView
            winningHeader.controller = self
            winningHeader.contestData = self.contestData
            winningHeader.viewPrizePool.isHidden = true
            winningHeader.updateView()
            
            if contestData?.created_by == "user" {
                winningHeader.lblRank.text = ""
                winningHeader.lblWinnings.text = ""
            }
            
            headerView.addSubview(winningHeader)
            winningHeader.frame = headerView.bounds
        }
        else{
            let leaderHeader:LeaderBoardHeaderView = LeaderBoardHeaderView.instanceFromNib() as! LeaderBoardHeaderView
            leaderHeader.controller = self
            if section == 0{
                leaderHeader.lblTitle.text = "My Teams (\(contestData?.my_teams?.count ?? 0))"
            }else{
                leaderHeader.lblTitle.text = "All Teams (\(contestData?.joined_teams?.count ?? 0))"
            }
            leaderHeader.updateView()
            headerView.addSubview(leaderHeader)
            leaderHeader.frame = headerView.bounds
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if btnWinnings.isSelected == true{
            let cell = tableView.dequeueReusableCell(withIdentifier: "WinningsTVCell", for: indexPath) as! WinningsTVCell

            cell.selectionStyle = .none
            let breakUp = contestData?.price_breakup?[indexPath.row]
            
            
            if (Int(breakUp?.start_rank ?? 0)) == (Int(breakUp?.end_rank ?? 0)){
                let rank = "# " + "\(Int(breakUp?.start_rank ?? 0))"
                cell.btnRank.setTitle(rank, for: .normal)
            }else{
                let rank = "# " + "\(Int(breakUp?.start_rank ?? 0))" + " - " + "\(Int(breakUp?.end_rank ?? 0))"
                cell.btnRank.setTitle(rank, for: .normal)
            }
            
            
            
            if self.contestData?.winning_amount ?? 0 == 0 {
                cell.lblWinnings.text = breakUp?.reward
            }else {
                cell.lblWinnings.text = "\(GDP.globalCurrency)\(CommonFunctions.suffixNumberIndian(currency: (breakUp?.each_price ?? 0)))"
            }
            
            if indexPath.row < 3{
                cell.btnRank.setImage(Constants.kWinningImage, for: .normal)
            }else{
                cell.btnRank.setImage(nil, for: .normal)
            }
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderBoardTVCell", for: indexPath) as! LeaderBoardTVCell

            cell.selectionStyle = .none
          
            var breakUp:JoinedTeam? = nil
            
            if indexPath.section == 0{
//                cell.contentView.backgroundColor = UIColor.cellStatsSelectedColor
                cell.contentView.backgroundColor = UIColor.hexStringToUIColor(hex: "040F19")
                cell.lblTeamCount.textColor = UIColor.appRedColor
                cell.viewBackground.backgroundColor = UIColor.bgDarkSepratorColor
                cell.viewImgProfile.borderColor = UIColor.appHighlightedTextColor
                breakUp = contestData?.my_teams?[indexPath.row]
            }else{
                cell.contentView.backgroundColor = UIColor.hexStringToUIColor(hex: "040F19")
//                cell.contentView.backgroundColor = UIColor.bgDarkSepratorColor
                cell.lblTeamCount.textColor = UIColor.appRedColor
                cell.viewBackground.backgroundColor = UIColor.cellStatsSelectedColor
                cell.viewImgProfile.borderColor = UIColor.red
                breakUp = contestData?.joined_teams?[indexPath.row]
            }
            
            cell.imgViewProfile.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imgViewProfile.sd_setImage(with: URL(string: breakUp?.user_image ?? ""), placeholderImage: Constants.kNoImageUser)
            
            cell.lblTitle.text = "\(breakUp?.username ?? "")"
            cell.lblTeamCount.text = "T\(Int(breakUp?.team_count ?? 0))"
            cell.lblPoints.text = "\(breakUp?.points ?? 0)"
            cell.lblRank.text = "#\(Int(breakUp?.rank ?? 0))"
            
            cell.winningAmountBottom.constant = 13

            if GDP.selectedMatch?.match_status == "Finished" || GDP.selectedMatch?.match_status == "Completed"{
                if (breakUp?.win_amount ?? 0) > 0{
                    cell.lblReward.text = "WON AMOUNT: \(GDP.globalCurrency)\(breakUp?.win_amount ?? 0)"
                    cell.WinningAmountHeight.constant = 15
                }else{
                    cell.lblReward.text = ""
                    cell.WinningAmountHeight.constant = 0
                }
                
            }else{
                cell.lblReward.text = ""
                cell.WinningAmountHeight.constant = 0
            }

            
          
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if btnWinnings.isSelected == false{
            var dataDict:JoinedTeam? = nil
            
            if indexPath.section == 0{
                dataDict = self.contestData?.my_teams?[indexPath.row]
            }else{
                dataDict = self.contestData?.joined_teams?[indexPath.row]
            }
            
            self.selectedUserRank = "\((dataDict?.rank ?? 0).forTrailingZero())"
            self.selectedTeamName = "\(dataDict?.username ?? "") (Team \(Int(dataDict?.team_count ?? 0)))"
            
            if self.strFromVC == "Live" || self.strFromVC == "Completed"
            {
                WebCommunication.shared.dailyContestTeamPreview(hostController: self, seriesId: "\(GDP.selectedMatch?.series_id ?? 0)", matchId: (GDP.selectedMatch?.match_id ?? 0), teamId: dataDict?.id ?? "", userId: (dataDict?.user_id ?? ""), showLoader: true) { team in
                    if let team = team {
                        self.loadTeamPreview(team: team, userId: (dataDict?.user_id ?? ""))
                    }
                }               
            }
            else
            {
                if (Constants.kAppDelegate.user?.id ?? "") == (dataDict?.user_id ?? "")
                {
                    GlobalDataPersistance.shared.isFromContestList = false
                    WebCommunication.shared.dailyContestTeamPreview(hostController: self, seriesId: "\(GDP.selectedMatch?.series_id ?? 0)", matchId: (GDP.selectedMatch?.match_id ?? 0), teamId: dataDict?.id ?? "", userId: (dataDict?.user_id ?? ""), showLoader: true) { team in
                        if let team = team {
                            self.loadTeamPreview(team: team, userId: (dataDict?.user_id ?? ""))
                        }
                    }
                }
                else
                {
                    AppManager.showToast(ConstantMessages.VIEW_OTHER_TEAMS_AFTER_MATCH_STARTED, view: self.view)
                }
            }
        }
    }
}
extension ContestDetailViewController : EditTeamDelegate
{
    func editMyTeam(index: Int) {
        
        let dataDict = self.arrTeam[0]
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
}
//extension ContestDetailViewController:UIDocumentInteractionControllerDelegate {
//
////MARK: UIDocumentInteractionController delegates
//func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
//    return self//or use return self.navigationController for fetching app navigation bar colour
//}
//}

extension ContestDetailViewController: MFMailComposeViewControllerDelegate{
 
    func sendEmail() {
        
        let leagueName = GDP.selectedMatch?.series_name ?? ""
        let localteam = GDP.selectedMatch?.localteam ?? ""
        let visitorTeam = GDP.selectedMatch?.visitorteam ?? ""
        
        let emailTitle = "Report: \(leagueName) (\(localteam) vs \(visitorTeam))"
        let messageBody = "Reason: "
        let toRecipents = "support@indiafantasy.com"
        
        if MFMailComposeViewController.canSendMail() {
            
            let mail: MFMailComposeViewController = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject(emailTitle)
            mail.setMessageBody(messageBody, isHTML: false)
            mail.setToRecipients([toRecipents])
            
            self.present(mail, animated: true, completion: nil)
            
        }else if let emailUrl = CommonFunctions.createEmailUrl(to: toRecipents, subject: emailTitle, body: messageBody) {
            UIApplication.shared.open(emailUrl)
        } else {
            // show failure alert
            self.alertBoxWithAction(message: ConstantMessages.NoEmailAppFound, btnTitle: ConstantMessages.OkBtn) {
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

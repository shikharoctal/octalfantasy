//
//  MatchContestViewController.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 07/03/22.
//

import UIKit
import SDWebImage
import DropDown
import EasyTipView

//iOSDropDown
class MatchContestViewController: BaseClassWithoutTabNavigation {

    var selectedMatch:Match? = nil
    var fantasyType = GDP.fantasyType
    @IBOutlet weak var navigationView: CustomNavigation!
    @IBOutlet weak var viewMyTeams: UIView!
    @IBOutlet weak var btnMyTeams: UIButton!
    @IBOutlet weak var btnSelfContents: UIButton!
    @IBOutlet weak var btnContests: UIButton!
    @IBOutlet weak var tblContests: UITableView!
    @IBOutlet weak var viewSelfContest: UIView!
    @IBOutlet weak var viewContestOpitions: UIView!
    
    @IBOutlet weak var btnCreateContestsBottom: UIButton!
    @IBOutlet weak var btnCreateTeam: UIButton!
    @IBOutlet var btnsSort: [UIButton]!
    
    @IBOutlet weak var createContestViewOptionHeight: NSLayoutConstraint!
    var selectedTab:UIButton!
    
    let tipView = EasyTipHelper()
    
    @IBOutlet weak var viewContest: UIView!
    @IBOutlet weak var lblNoData: UILabel!
    @IBOutlet weak var lblVisitorTeam: UILabel!
    @IBOutlet weak var lblHomeTeam: UILabel!
    @IBOutlet weak var imgVisitorTeam: UIImageView!
    @IBOutlet weak var imgLocalTeam: UIImageView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblVS: UILabel!
            
    var arrContests:[Contest]? = nil
    var arrTeamList:[Team]? = nil
    
    var arrJoinedContests:[JoinedContest]? = nil
    

    
    var filterData:[String:Any]? = nil
    var filterArray = NSMutableArray()
    
    
    var isDidLoad = true
    var isMyGames = false
    
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GlobalDataPersistance.shared.isContestJoinFlow = false
        GlobalDataPersistance.shared.selectedContest = nil
        self.selectedMatch = GDP.selectedMatch
        self.tabBarController?.tabBar.isHidden = true
        if #available(iOS 15.0, *) {
            self.tblContests.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        self.navigationView.configureNavigationBarWithController(controller: self, title: "My Contests", hideNotification: false, hideAddMoney: true, hideBackBtn: false)
        self.navigationView.img_BG.isHidden = true
        
        self.resetAllSortBtns(sender: UIButton())

        if self.isMyGames == true{
            selectedTab = btnSelfContents
        }else{
            selectedTab = btnContests
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTeamList(notification:)), name: NSNotification.Name(rawValue: "updateTeamList"), object: nil)
        
        if #available(iOS 15.0, *) {
            tblContests.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        self.setupUI()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.setFantasyEnviornment()
        if self.isDidLoad == true{
            self.isDidLoad = false
            self.btnTabActionPressed(selectedTab)
        }else{
            self.loadSelectedTab(sender: self.selectedTab, hideLoader: true)
        }
    }
    
    func setFantasyEnviornment(){
        
        switch GDP.fantasyType {
        case Constants.kCricketFantasy:
            GDP.switchToCricket()
            break
        default:
            break
        }
        
        GDP.selectedMatch = self.selectedMatch
    }
    
    deinit {
        print("Removed NotificationCenter Observer")
    }
    
    //MARK: - Setup Refresh Control
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: attributes)
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(getDataFromServer), for: .valueChanged)
        tblContests.refreshControl = refreshControl
    }
    
    @objc func getDataFromServer() {
        
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
        
        self.loadSelectedTab(sender: self.selectedTab, hideLoader: true)
    }
    
    
    @objc func updateTeamList(notification : NSNotification)
    {
        if GlobalDataPersistance.shared.isFromContestList == true{
            GlobalDataPersistance.shared.isFromContestList = false
            GlobalDataPersistance.shared.isContestJoinFlow = true
            AppManager.startActivityIndicator(sender: self.view)
            self.perform(#selector(getTeamLists), with: self, afterDelay: 1.0)
        }
       
    }
    
    func setupUI(){
        lblHomeTeam.text = GDP.selectedMatch?.localteam_short_name ?? ""
        lblVisitorTeam.text = GDP.selectedMatch?.visitorteam_short_name ?? ""
        
        imgLocalTeam.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgLocalTeam.sd_setImage(with: URL(string: GDP.selectedMatch?.localteam_flag ?? ""), placeholderImage: Constants.kNoImageUser)

        imgVisitorTeam.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgVisitorTeam.sd_setImage(with: URL(string: GDP.selectedMatch?.visitorteam_flag ?? ""), placeholderImage: Constants.kNoImageUser)
        
        self.setupRefreshControl()
        self.startTimer()
    }
    
    func startTimer()
    {

        //CommonFunctions().timerStart(date: self.lblVS, strTime: GDP.selectedMatch?.start_time ?? "", strDate: GDP.selectedMatch?.start_date, viewcontroller: self)
        CommonFunctions().timerStart(lblTime: self.lblVS, strDate: GDP.selectedMatch?.match_date ?? "", viewcontroller: self, fromSeasonMyTeams: false, isFromHome: true)
    }
    
    func isMatchTimeOver() -> Bool  {
        
        if let matchDate = CommonFunctions.getDateFromString(date: GDP.selectedMatch?.match_date ?? "", format: "yyyy-MM-dd'T'HH:mm:ss"), Date() >= matchDate {
            self.alertBoxWithAction(message: ConstantMessages.kMatchNotStarted, btnTitle: ConstantMessages.OkBtn) { }
            return true
        }
        return false
    }

    @IBAction func btnBackPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tipView.tipView.dismiss()
    }
    
    @IBAction func btnTabActionPressed(_ sender: UIButton) {
        
        GlobalDataPersistance.shared.isFromContestList = false
        self.tipView.tipView.dismiss()
        
        self.resetAllButtons()
        sender.isSelected = true
        selectedTab = sender
        self.lblHeader.text = selectedTab.title(for: .normal)
        self.loadSelectedTab(sender: sender, hideLoader: false)
    }
    
    func resetAllButtons(){
        btnContests.isSelected = false
        btnSelfContents.isSelected = false
        btnMyTeams.isSelected = false
        viewContest.backgroundColor = #colorLiteral(red: 0.04299286008, green: 0.08705208451, blue: 0.1310158372, alpha: 1)//UIColor.cellSepratorColor
        viewSelfContest.backgroundColor = #colorLiteral(red: 0.04299286008, green: 0.08705208451, blue: 0.1310158372, alpha: 1)//UIColor.cellSepratorColor
        viewMyTeams.backgroundColor = #colorLiteral(red: 0.04299286008, green: 0.08705208451, blue: 0.1310158372, alpha: 1)//UIColor.cellSepratorColor
        btnCreateTeam.isHidden = true
        btnCreateContestsBottom.isHidden = true
    }
    
    func loadSelectedTab(sender:UIButton, hideLoader:Bool){
        if sender == btnContests{
            
            navigationView.btnFantasyType.setTitle("Contests", for: .normal)
            viewContest.backgroundColor = #colorLiteral(red: 0.9670545459, green: 0.7020347118, blue: 0.1649923623, alpha: 1)//UIColor.appThemeColor
            createContestViewOptionHeight.constant = 40
            btnCreateTeam.isHidden = false
            btnCreateTeam.setTitle("Create Team", for: .normal)
            btnCreateContestsBottom.isHidden = false
            self.resetAllSortBtns(sender: UIButton())
            self.getContestListByMatch(hideLoader: hideLoader)
        }
        else if sender == btnSelfContents{
            navigationView.btnFantasyType.setTitle("My Contests", for: .normal)
            btnCreateTeam.setTitle("Create New Team", for: .normal)
            viewSelfContest.backgroundColor = #colorLiteral(red: 0.9670545459, green: 0.7020347118, blue: 0.1649923623, alpha: 1)//UIColor.appThemeColor
            createContestViewOptionHeight.constant = 0
            btnCreateTeam.isHidden = false

            self.getJoinedContests(hideLoader: hideLoader)
        }
        else{
            navigationView.btnFantasyType.setTitle("My Teams", for: .normal)
            btnCreateTeam.setTitle("Create New Team", for: .normal)
            viewMyTeams.backgroundColor = #colorLiteral(red: 0.9670545459, green: 0.7020347118, blue: 0.1649923623, alpha: 1)//UIColor.appThemeColor
            createContestViewOptionHeight.constant = 0
            btnCreateTeam.isHidden = false

            self.getTeamLists()
        }
    }
    
    @IBAction func btnContestsTapped(_ sender: UIButton) {
        
        guard !isMatchTimeOver() else {return}
        GlobalDataPersistance.shared.isFromContestList = false
        self.tipView.tipView.dismiss()
        
        WebCommunication.shared.getUserProfile(hostController: self, showLoader: false) { user in
                if let user = user{
                    if (user.state ?? "") == "" || (user.dob ?? "") == ""{
                        let VC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "DOBStateViewController") as! DOBStateViewController
                        VC.completionHandler = { (success) in
                            if success == true{
                                self.openCreateContestPopup()
                            }
                        }
                        UIApplication.getTopMostViewController()?.present(VC, animated: true, completion: nil)
                    }
                    else{
                        self.openCreateContestPopup()
                    }
                }
            }
    }
    
    func openCreateContestPopup(){
        let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "JoinContestPopUp") as! JoinContestPopUp
        VC.completionHandler = {(contest, isJoinContest) in

            if isJoinContest == true{
                let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "ContestDetailViewController") as! ContestDetailViewController
                VC.contestData = contest
                VC.isFromInviteContest = true
                self.navigationController?.pushViewController(VC, animated: true)
            }else{
                let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "CreateContestViewController") as! CreateContestViewController
                self.navigationController?.pushViewController(VC, animated: true)
            }
           

        }
        self.present(VC, animated: false)
    }
    
    @IBAction func btnCreateTeamPressed(_ sender: UIButton) {
        guard !isMatchTimeOver() else {return}
        self.tipView.tipView.dismiss()
        GlobalDataPersistance.shared.isFromContestList = false
        
        let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "CreateTeamViewController") as! CreateTeamViewController
        self.navigationController?.pushViewController(VC, animated: true)
        
    }
    
    @IBAction func btnEditTeamPressed(_ sender: UIButton) {
        
        guard !isMatchTimeOver() else {return}
        let dataDict = self.arrTeamList?[sender.tag]
        let navData = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "CreateTeamViewController") as! CreateTeamViewController
//        navData.setSelectTeamDelegate = true
        navData.isFromEdit = "Edit"
        navData.TeamData = dataDict
        navData.strCaptainID = "\(dataDict?.captain_player_id ?? "0")"
        navData.strViceCaptainID = "\(dataDict?.vice_captain_player_id ?? "0")"
        navData.teamID = "\(dataDict?.team_id ?? "0")"
        navData.strTeamNumber = "\(dataDict?.team_number ?? 1)"
        self.navigationController?.pushViewController(navData, animated: true)
    }
    
    @IBAction func btnCloneTeamPressed(_ sender: UIButton) {
        
        guard !isMatchTimeOver() else {return}
        guard let team = self.arrTeamList?[sender.tag] else { return }
        
        let navData = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "CreateTeamViewController") as! CreateTeamViewController
        navData.isFromEdit = "Clone"
//        navData.setSelectTeamDelegate = true
        navData.TeamData = team
        navData.strCaptainID = "\(team.captain_player_id ?? "0")"
        navData.strViceCaptainID = "\(team.vice_captain_player_id ?? "0")"
        navData.isFromMainContest = true
        navData.strTeamNumber = "\((team.team_number ?? 1) + 1)"
        self.navigationController?.pushViewController(navData, animated: true)
    }
    
    @IBAction func actionSort(_ sender: UIButton) {
        self.resetAllSortBtns(sender: sender)
        sender.isSelected = true
        sender.backgroundColor =  UIColor.hexStringToUIColor(hex: "263642")
        
        self.performSortingOperationOnSender(sender: sender)
    }
    
    func performSortingOperationOnSender(sender:UIButton){
        let spacing:CGFloat = -5; // the amount of spacing to appear between image and title

        if sender.image(for: .selected)!.isEqualToImage(Constants.kSortUp!){
            sender.imageEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: 0)
            sender.setImage(Constants.kSortDown!, for: .selected)
            self.sortInDescendingOrder(sender: sender)

        }else{
            sender.imageEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: 0)
            sender.setImage(Constants.kSortUp!, for: .selected)
            self.sortInAscendingOrder(sender: sender)

        }
    }
    
    func sortInDescendingOrder(sender:UIButton){
        for index in 0..<(self.arrContests?.count ?? 0){
            var contest = self.arrContests?[index]
            if sender.tag == 101{
                let contestData = contest?.contestData?.sorted(by: { ($0.entry_fee ?? 0) > ($1.entry_fee ?? 0) })
                contest?.contestData = contestData

            }else if sender.tag == 102{
                let contestData = contest?.contestData?.sorted(by: { ($0.users_limit ?? 0) > ($1.users_limit ?? 0) })
                contest?.contestData = contestData

            }else if sender.tag == 103{
                let contestData = contest?.contestData?.sorted(by: { ($0.winning_amount ?? 0) > ($1.winning_amount ?? 0) })
                contest?.contestData = contestData

            }else if sender.tag == 104{
                let contestData = contest?.contestData?.sorted(by: { ($0.winners_percentage ?? 0) > ($1.winners_percentage ?? 0) })
                contest?.contestData = contestData
            }
            
            self.arrContests?[index] = contest ?? Contest()
        }
        
        tblContests.reloadData()
    }
    
    func sortInAscendingOrder(sender:UIButton){
        for index in 0..<(self.arrContests?.count ?? 0){
            var contest = self.arrContests?[index]
            if sender.tag == 101{
                let contestData = contest?.contestData?.sorted(by: { ($0.entry_fee ?? 0) < ($1.entry_fee ?? 0) })
                contest?.contestData = contestData

            }else if sender.tag == 102{
                let contestData = contest?.contestData?.sorted(by: { ($0.users_limit ?? 0) < ($1.users_limit ?? 0) })
                contest?.contestData = contestData

            }else if sender.tag == 103{
                let contestData = contest?.contestData?.sorted(by: { ($0.winning_amount ?? 0) < ($1.winning_amount ?? 0) })
                contest?.contestData = contestData

            }else if sender.tag == 104{
                let contestData = contest?.contestData?.sorted(by: { ($0.winners_percentage ?? 0) < ($1.winners_percentage ?? 0) })
                contest?.contestData = contestData
            }
            
            self.arrContests?[index] = contest ?? Contest()
        }
        
        tblContests.reloadData()
    }
    
    func resetAllSortBtns(sender: UIButton){
        self.tipView.tipView.dismiss()
        self.btnsSort.forEach { btn in
            btn.titleLabel?.adjustsFontSizeToFitWidth = true
            if btn != sender{
                btn.backgroundColor = .white
                btn.isSelected = false
            }
        }
    }
    
    @IBAction func btnPreviewPressed(_ sender: UIButton) {
        let previewTeam = self.arrTeamList?[sender.tag]
        
        WebCommunication.shared.dailyContestTeamPreview(hostController: self, seriesId: "\(GDP.selectedMatch?.series_id ?? 0)", matchId: (GDP.selectedMatch?.match_id ?? 0), teamId: previewTeam?.id ?? "", userId: "", showLoader: true) { team in
         
            guard let dataDict = team else { return }
            
            let vc = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "TeamPreviewVC") as! TeamPreviewVC

            vc.teamNumber = "\(dataDict.team_number ?? 1)"
            vc.strFromVC = "MyTeams"
            vc.TeamData = dataDict
            
            let arrPlayers = dataDict.seriesPlayer
            var arrPlayerData = [PlayerDetails]()
            var selectedPlayers = SelectedPlayerTypes()
            
            if arrPlayers?.count ?? 0 > 0
            {
                for index  in 0..<arrPlayers!.count {
                    let player = arrPlayers![index]
                    var playerData = PlayerDetails()
                    playerData.name = "\(player.name ?? "")"
                    playerData.credits = "\(player.credits!)"
                    playerData.role = "\(player.role ?? "")"
                    playerData.points = "\(player.points ?? 0)"
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
            
            selectedPlayers.batsman = Int("\(dataDict.total_batsman ?? 0)") ?? 0
            selectedPlayers.allrounder = Int("\(dataDict.total_allrounder ?? 0)") ?? 0
            selectedPlayers.bowler =  Int("\(dataDict.total_bowler ?? 0)") ?? 0
            selectedPlayers.wicketkeeper = Int("\(dataDict.total_wicketkeeper ?? 0)") ?? 0
            
            let captain = arrPlayerData.filter({$0.player_id == "\(dataDict.captain_player_id ?? "0")"})
            let viceCaptain = arrPlayerData.filter({$0.player_id == "\(dataDict.vice_captain_player_id ?? "0")"})

            
            vc.otherUserId = Constants.kAppDelegate.user?.id ?? ""

            vc.playerDetails = arrPlayerData
            vc.selectedPlayers = selectedPlayers
            vc.teamName = "\(Constants.kAppDelegate.user?.username ?? "") Team \(sender.tag + 1)"
            vc.strCaptainId = captain.count > 0 ? captain[0].player_id : ""
            vc.strViceCaptainId = viceCaptain.count > 0 ? viceCaptain[0].player_id : ""
            vc.strPointsSuffix = "Cr"
            vc.modalPresentationStyle = .custom
            vc.isEditTeam = true
            vc.teamEditIndex = sender.tag
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func btnJoinContestPressed(_ sender: UIButton) {
        guard !isMatchTimeOver() else {return}
        
//        let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "JoinContestViewController") as! JoinContestViewController
//        self.navigationController?.pushViewController(VC, animated: true)
        WebCommunication.shared.getUserProfile(hostController: self, showLoader: true) { user in
            if let user = user{
                if (user.state ?? "") == "" || (user.dob ?? "") == ""{
                    let VC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "DOBStateViewController") as! DOBStateViewController
                    VC.completionHandler = { (success) in
                        if success == true{
                            let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "JoinContestViewController") as! JoinContestViewController
                            self.navigationController?.pushViewController(VC, animated: true)
                        }
                    }
                    UIApplication.getTopMostViewController()?.present(VC, animated: true, completion: nil)
                }
                else{
                    let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "JoinContestViewController") as! JoinContestViewController
                    self.navigationController?.pushViewController(VC, animated: true)
                }
            }
        }
    }
    
    
    @objc func entryFreePressed(sender:UIButton){
        guard !isMatchTimeOver() else {return}
        GlobalDataPersistance.shared.isFromContestList = false
        var contestDataValue:ContestData!
        if btnContests.isSelected{
            contestDataValue = self.arrContests?[sender.indexPath?.section ?? 0].contestData?[sender.indexPath?.row ?? 0]
        }
        else{
            contestDataValue = self.arrJoinedContests![sender.indexPath?.row ?? 0].contestData
        }
        GDP.selectedContest = contestDataValue
        WebCommunication.shared.getContestDetail(hostController: self, contestId: contestDataValue?.id ?? "", selectedMatch: GDP.selectedMatch!, showLoader: true) { contest in
            let spotLeft = Int(contest?.users_limit ?? 0) - (contest?.joined_teams_count ?? 0)
            GDP.selectedContest = contestDataValue

            if spotLeft == 0{
                AppManager.showToast(ConstantMessages.ContestFull, view: self.view)
                return
            }
            
//            self.proceedToJoin(contestData: contest)
            WebCommunication.shared.getUserProfile(hostController: self, showLoader: true) { user in
                if let user = user{
                    if (user.state ?? "") == "" || (user.dob ?? "") == ""{
                        let VC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "DOBStateViewController") as! DOBStateViewController
                        VC.completionHandler = { (success) in
                            if success == true{
                                self.proceedToJoin(contestData: contest)
                            }
                        }
                        UIApplication.getTopMostViewController()?.present(VC, animated: true, completion: nil)
                    }
                    else{
                        self.proceedToJoin(contestData: contest)
                    }
                }
            }
        }
    }
    
    func proceedToJoin(contestData:ContestData?){
        if contestData?.join_multiple_team ?? false == false && contestData?.is_joined ?? false == true
        {
            Constants.kAppDelegate.showAlert(msg: ConstantMessages.CANNOT_JOINED_MORETHANSINGLETEAM, isLogout: false, isLocationAlert: false)
            return
        }else if (contestData?.my_teams_ids?.count ?? 0) == (contestData?.max_team_join_count ?? 0)
        {
            Constants.kAppDelegate.showAlert(msg: ConstantMessages.CAN_NOT_JOIN_MORE_TEAMS, isLogout: false, isLocationAlert: false)
            return
        }
        
        GlobalDataPersistance.shared.isFromContestList = true
        if GlobalDataPersistance.shared.myTeamCount == 0{
            let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "CreateTeamViewController") as! CreateTeamViewController
            self.navigationController?.pushViewController(VC, animated: true)
        }
        else{
            self.initJoinContestFlow(contestData: contestData)

        }
    }
    
    func initJoinContestFlow(contestData:ContestData?){
        if GlobalDataPersistance.shared.myTeamCount > (contestData?.my_teams_ids?.count ?? 0){
            let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "SelectTeamViewController") as! SelectTeamViewController
            VC.contestData = contestData
            VC.completionHandler = { (team, teamCount) in
                print(team, teamCount)
                
                var isAlreadyJoined = false
                for i in 0..<(contestData?.joined_teams?.count ?? 0) {
                    let jTeam = contestData?.joined_teams?[i]
                    if (jTeam?.id ?? "") == team.team_id{
                        isAlreadyJoined = true
                        break
                    }
                }
                
                if isAlreadyJoined == true{
                    Constants.kAppDelegate.showAlert(msg: "You already have joined with this team. Please select another team or create a new one.", isLogout: false, isLocationAlert: false)
                }else{
                    if (contestData?.entry_fee ?? 0) == 0{
                        self.setTeamId(team: team, teamCount: String(teamCount), contestData: contestData)
                    }
                    else if LocationManager.sharedInstance.isPLayingInLegalState() == true{
                        self.setTeamId(team: team, teamCount: String(teamCount), contestData: contestData)
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
    
    func setTeamId(team: Team, teamCount:String, contestData:ContestData?)
    {
        print("teamId--->",team.team_id ?? "")
        if GDP.selectedMatch != nil
        {
            var findCurrentCount = GDP.selectedMatch?.my_total_teams ?? 0
            findCurrentCount += 1
            GDP.selectedMatch?.my_total_teams = findCurrentCount
        }
        self.checkWalletValidation(team: team, teamcount: GlobalDataPersistance.shared.myTeamCount, contestData: contestData)
    }
    
    func checkWalletValidation (team:Team, teamcount:Int, contestData:ContestData?){
        
        if (contestData?.users_limit ?? 0) == (contestData?.joined_teams_count ?? 0) && contestData?.is_joined ?? false == true
        {
            if (contestData?.users_limit ?? 0) == (contestData?.joined_teams_count ?? 0){
                Constants.kAppDelegate.showAlert(msg:"You cannot join this contest more than \((contestData?.users_limit ?? 0)) teams", isLogout: false, isLocationAlert: false)

            }else{
                Constants.kAppDelegate.showAlert(msg: ConstantMessages.ALREADY_JOINED_THIS_CONTEST, isLogout: false, isLocationAlert: false)
            }
            return
        }
        
        if contestData?.join_multiple_team ?? false == false && contestData?.is_joined ?? false == true
        {
            Constants.kAppDelegate.showAlert(msg: ConstantMessages.CANNOT_JOINED_MORETHANSINGLETEAM, isLogout: false, isLocationAlert: false)
            return
        }
        
        if (contestData?.my_teams_ids?.count ?? 0) > (contestData?.max_team_join_count ?? 0)
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
                        self.parseWalletData(data: data!, team: team, teamcount: teamcount, contestData: contestData)
                    }
                }
            }
            else{
                if result != nil {
                    let data = result?.object(forKey: "results") as? [String:Any]
                    if data != nil{
                        self.parseWalletData(data: data!, team: team, teamcount: teamcount, contestData: contestData)
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
    
    func parseWalletData(data:[String:Any], team:Team, teamcount:Int, contestData:ContestData?){
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
            if contestData != nil{
                self.showWalletPopupView(contestBalance, matchData: GDP.selectedMatch, team: team, gameTypeValue: "", contestData:contestData!, completionHandler: { receiveData in
                    print(receiveData)
                    
                    if self.btnContests.isSelected == true{
                        self.getContestListByMatch(hideLoader: true)
                    }else{
                        self.getJoinedContests(hideLoader: true)
                    }

                })
            }else{
                AppManager.showToast("Something went wrong", view: self.view)
            }

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
                    if teamcount == 0
                    {
                        self.checkWalletValidation(team: team, teamcount: 1, contestData: contestData)
                    }
                    else
                    {
                        self.checkWalletValidation(team: team, teamcount: teamcount, contestData: contestData)
                    }
                }
                self.navigationController?.pushViewController(vc, animated: false)
            }))
            
            self.present(alert, animated: true, completion: nil)

        }
        
    }
    
    @IBAction func btnWalletPressed(_ sender: Any) {
        let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "MyAccountDetailsVC") as! MyAccountDetailsVC
        self.navigationController?.pushViewController(pushVC, animated: true)
    }
    
    
    @IBAction func btnCreateContestPressed(_ sender: UIButton) {
        self.tipView.tipView.dismiss()

        let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "FilterVC") as! FilterVC
        VC.modalPresentationStyle = .overCurrentContext
        VC.btnStatusTrack = self.filterData ?? [:]
        if filterArray.count > 0 {
            VC.groups = filterArray
        }
        VC.filterClouser = { [weak self] (result, arrayGroup) in
            if let self = self {
//                let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
//                let dataString =  NSString(data: jsonData ?? Data(), encoding: String.Encoding.utf8.rawValue)! as String
//                print(dataString)
                self.filterData = result
                self.filterArray = arrayGroup
                self.resetAllSortBtns(sender: UIButton())
                self.getContestListByMatch (hideLoader: false)
            }
        }
        self.present(VC, animated: true, completion: nil)
    }
    
    @objc func shareFriendsBtnPressed(sender:UIButton){
        
        guard !isMatchTimeOver() else {return}
        var contestDataValue: ContestData!
        if btnContests.isSelected == true{
            contestDataValue = self.arrContests?[0].contestData?[sender.tag]
        }else{
            contestDataValue = self.arrJoinedContests![sender.tag].contestData
        }

        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let btnCopy = UIAlertAction(title: "Copy Code", style: .default) { action in
            AppManager.showToast(ConstantMessages.COPY_SUCCESS.localized(), view: self.view)
            UIPasteboard.general.string = contestDataValue.invite_code?.uppercased() ?? ""
        }
        
        let btnShare = UIAlertAction(title: "Invite Friends", style: .default) { action in
            self.inviteFriends(inviteCode: contestDataValue.invite_code ?? "")
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
            
            //let text = "You've been challenged! \n\nThink you can beat me? Join the contest on India’s fantasy for the \(self.selectedMatch?.series_name ?? "") match and prove it! \n\nClick on this link \(dynamicLink) or use my invite code \(inviteCode.uppercased()) to accept this challenge!"
            
            let textToShare = [ dynamicLink ]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
}
extension MatchContestViewController:UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if btnMyTeams.isSelected{
            return arrTeamList?.count ?? 0
        }
        else if btnSelfContents.isSelected{
            return arrJoinedContests?.count ?? 0
        }
        else{
            let model = arrContests?[section]
            return model?.contestData?.count ?? 0
        }
       
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if btnMyTeams.isSelected || btnSelfContents.isSelected{
            return 1;

        }else{
            return arrContests?.count ?? 1;

        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if btnMyTeams.isSelected || btnSelfContents.isSelected{
            return 0
        }
        return 0;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))

        headerView.backgroundColor = UIColor.white
        let lblHeader:UILabel = UILabel(frame: CGRect(x: 25, y: 0, width: 320, height: 40))
        let lblVS:UILabel = UILabel(frame: CGRect(x: 25, y: 5, width: 320, height: 40))
        _ = arrContests?[section]
//        lblHeader.text = model?.category_title ?? ""
//        lblVS.text = model?.category_title ?? ""

        lblHeader.text = ""
        lblVS.text = ""

        lblHeader.textColor = UIColor.white
        lblHeader.font = UIFont(name: "Gilroy-SemiBold", size: 18)
        lblHeader.adjustsFontSizeToFitWidth = true
        lblHeader.numberOfLines = 0
        lblVS.adjustsFontSizeToFitWidth = true
        lblVS.numberOfLines = 0
        lblVS.font = UIFont(name: "Gilroy-Medium", size: 14)
                            
        headerView.backgroundColor = UIColor.clear
        headerView.addSubview(lblHeader)

        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if btnMyTeams.isSelected{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TeamListTVCell", for: indexPath) as! TeamListTVCell

            cell.selectionStyle = .none

            let team = self.arrTeamList?[indexPath.row]
            cell.btnEdit.tag = indexPath.row
            cell.btnEdit.addTarget(self, action: #selector(btnEditTeamPressed(_:)), for: .touchUpInside)
            
            cell.btnClone.tag = indexPath.row
            cell.btnClone.addTarget(self, action: #selector(btnCloneTeamPressed(_:)), for: .touchUpInside)
            
            cell.btnPreview.tag = indexPath.row
            cell.btnPreview.addTarget(self, action: #selector(btnPreviewPressed(_:)), for: .touchUpInside)
            
            cell.btnApplyBoosters.tag = indexPath.row
            cell.btnApplyBoosters.addTarget(self, action: #selector(btnApplyBoosters(_:)), for: .touchUpInside)
            
            cell.updateView(team: team, indexPath: indexPath)
            
            //  MARK: - Hide Booster
            cell.stackViewRugbyBooster.isHidden = true
            cell.btnApplyBoosters.isHidden = true
            
            return cell
        }
        else{
            
            var contestDataValue:ContestData? = nil
            let cellMatch = tableView.dequeueReusableCell(withIdentifier: "MatchContestTVCell", for: indexPath) as! MatchContestTVCell
            cellMatch.selectionStyle = .none
            cellMatch.tipView = self.tipView
            cellMatch.controller = self
            cellMatch.btnShareFriends.tag = indexPath.row
            cellMatch.btnJoin.indexPath = indexPath
            cellMatch.btnJoin.addTarget(self, action: #selector(entryFreePressed(sender:)), for: .touchUpInside)
            cellMatch.btnShareFriends.addTarget(self, action:#selector(shareFriendsBtnPressed(sender:)), for: .touchUpInside)
            
            if btnContests.isSelected == true{
                contestDataValue = self.arrContests?[indexPath.section].contestData?[indexPath.row]
                cellMatch.updateCell(contestDataValue: contestDataValue)
                cellMatch.viewJoinedTeams.isHidden = true
                cellMatch.joinedTeamsHeight.constant = 10
                
                cellMatch.btnJoin.setTitle("Join", for: .normal)
                cellMatch.btnJoin.backgroundColor = .appHighlightedTextColor
                cellMatch.btnJoin.setTitleColor(.black, for: .normal)
                cellMatch.btnJoin.isUserInteractionEnabled = true
                
                if contestDataValue?.entry_fee ?? 0 == 0 {
                    cellMatch.btnJoin.setTitle("Free", for: .normal)
                } else {
                    cellMatch.btnJoin.setTitle("\(GDP.globalCurrency)\(contestDataValue?.entry_fee ?? 0)", for: .normal)
                }
                
                let spotLeft = Int(contestDataValue?.users_limit ?? 0) - (contestDataValue?.joined_teams_count ?? 0)
                
                if spotLeft == 0 {
                    cellMatch.btnJoin.setTitle("View", for: .normal)
                    cellMatch.btnJoin.isUserInteractionEnabled = false
                }
                
                if (contestDataValue?.my_team_ids?.count ?? 0) >= (contestDataValue?.max_team_join_count ?? 0) {
                    cellMatch.btnJoin.setTitle("View", for: .normal)
                    cellMatch.btnJoin.isUserInteractionEnabled = false
                }
                
                // MARK: -  Add entry fees
                
            }
            else{
                cellMatch.viewJoinedTeams.isHidden = false
                cellMatch.joinedTeamsHeight.constant = 32
                guard self.arrJoinedContests?.count ?? 0 > indexPath.row else { return cellMatch}
                let contest = self.arrJoinedContests?[indexPath.row]
                contestDataValue = self.arrJoinedContests?[indexPath.row].contestData
                var temp = contestDataValue
                temp?.joined_teams_count = contest?.joined_teams_count ?? 0
                
                contestDataValue = temp
                cellMatch.updateCell(contestDataValue: contestDataValue)
                cellMatch.updateJoinedTeams(teams: contest?.teams, controller: self)
            }
            
           
            return cellMatch
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.tipView.tipView.dismiss()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.tipView.tipView.dismiss()

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if btnMyTeams.isSelected == false{
            let cell = tableView.cellForRow(at: indexPath) as! MatchContestTVCell
            
            cell.tipView.tipView.dismiss()
            
            var contestDataValue:ContestData!
            if btnContests.isSelected{
                contestDataValue = self.arrContests?[indexPath.section].contestData?[indexPath.row]
            }
            else{
                contestDataValue = self.arrJoinedContests![indexPath.row].contestData
            }
            GDP.selectedContest = contestDataValue
            let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "ContestDetailViewController") as! ContestDetailViewController
            VC.contestData = contestDataValue
            self.navigationController?.pushViewController(VC, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if btnMyTeams.isSelected{
            return UITableView.automaticDimension
        }
        
        if btnContests.isSelected{
            return 150
        }
        return 170
    }
    
    @objc func btnApplyBoosters(_ sender: UIButton) {
        
        guard !isMatchTimeOver() else {return}
        guard let team = self.arrTeamList?[sender.tag] else { return }
        getPlayerList(team: team)

    }
    
    @objc func btnMakeTransferPressed(_ sender: UIButton) {
        
//        guard !isMatchTimeOver() else {return}
//        guard let team = self.arrTeamList?[sender.tag] else { return }
//        
//        let vc = Constants.KRugbyStoryboard.instantiateViewController(withIdentifier: "RugbyMakeTransferVC") as! RugbyMakeTransferVC
//        vc.team = team
//        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MatchContestViewController{
    func getContestListByMatch (hideLoader:Bool){
        var params:[String:Any] = ["user_id":Constants.kAppDelegate.user?.id ?? "",
                                   "match_id":String(GDP.selectedMatch?.match_id ?? 0),
                                   "series_id":String(GDP.selectedMatch?.series_id ?? 0),
        ]
        
        if filterData != nil{
            
            params = ["user_id":Constants.kAppDelegate.user?.id ?? "", "match_id":GDP.selectedMatch?.match_id ?? 0, "series_id":GDP.selectedMatch?.series_id ?? 0, "filter_data": filterData ?? [:]]
        }
        
        let url = URLMethods.BaseURL + URLMethods().getContestListByMatch
        if filterData == nil {
            ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
                
                let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
                
                if isSuccess == true{
                    if result != nil {
                        let data = result?.object(forKey: "results") as? [[String:Any]]
                        if data != nil{
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                                  let tblData = try? JSONDecoder().decode([ContestData].self, from: jsonData)else {return }
                            self.arrContests = [Contest]()
                            var contest = Contest()
//                            var contestData = [ContestData]()
//                            for index  in 0..<tblData.count{
//                                let contest = tblData[index]
//                                if (contest.contestData?.count ?? 0) > 0{
//                                    contestData.append(contentsOf: contest.contestData!)
//                                }
//                            }
                            contest.contestData = tblData
                            self.arrContests?.append(contest)
                            self.tblContests.reloadData()
                            
                        }
                    }
                    
                    self.showCounts(result: result)
                }
                
                else{
                    AppManager.showToast(msg ?? "", view: self.view)
                }
                
                self.lblNoData.text = "No Contests Available!"
                if (self.arrContests?.count ?? 0) > 0{
                    if let contest = self.arrContests?.first{
                        if (contest.contestData?.count ?? 0) > 0{
                            self.lblNoData.isHidden = true
                        }else{
                            self.lblNoData.isHidden = false
                        }
                    }else{
                        self.lblNoData.isHidden = false
                    }
                    
                }else{
                    self.lblNoData.isHidden = false
                }
                AppManager.stopActivityIndicator(self.view)
            }
            if hideLoader == false{
                AppManager.startActivityIndicator(sender: self.view)
            }
        }else {
            
            ApiClient.init().postRequestFilter(dict: params, request: url, view: self.view) { (msg,result) in
                
                let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
                if isSuccess == true{
                    if result != nil {
                        let data = result?.object(forKey: "results") as? [[String:Any]]
                        if data != nil{
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                                  let tblData = try? JSONDecoder().decode([ContestData].self, from: jsonData)else {return }
                            self.arrContests = [Contest]()
                            var contest = Contest()
//                            var contestData = [ContestData]()
//                            for index  in 0..<tblData.count{
//                                let contest = tblData[index]
//                                if (contest.contestData?.count ?? 0) > 0{
//                                    contestData.append(contentsOf: contest.contestData!)
//                                }
//                            }
                            contest.contestData = tblData
                            self.arrContests?.append(contest)
                            
                            DispatchQueue.main.async {
                                self.lblNoData.text = "No Contests Available!"
                                if (self.arrContests?.count ?? 0) > 0{
                                    if let contest = self.arrContests?.first{
                                        if (contest.contestData?.count ?? 0) > 0{
                                            self.lblNoData.isHidden = true
                                        }else{
                                            self.lblNoData.isHidden = false
                                        }
                                    }else{
                                        self.lblNoData.isHidden = false
                                    }
                                    
                                }else{
                                    self.lblNoData.isHidden = false
                                }
                                self.showCounts(result: result)
                                self.tblContests.reloadData()
                            }
                        }
                    }
                }
                
                else{
                    DispatchQueue.main.async {
                        AppManager.showToast(msg ?? "", view: self.view)
                    }
                }
                
                DispatchQueue.main.async {
                    AppManager.stopActivityIndicator(self.view)
                }
                
            }
            
            if hideLoader == false{
                AppManager.startActivityIndicator(sender: self.view)
            }
        }
    }
    
    func showCounts(result:NSDictionary?){
        if let teamCount = result?.object(forKey: "my_teams") as? Int{
            GlobalDataPersistance.shared.myTeamCount = teamCount
            if teamCount > 0{
                self.btnMyTeams.setTitle("My Teams (\(teamCount))", for: .normal)
            }else{
                self.btnMyTeams.setTitle("My Teams", for: .normal)
            }
        }
        
        if let fullContests = result?.object(forKey: "full_contest") as? Int{
            GlobalDataPersistance.shared.fullContestCount = fullContests
            if fullContests > 0{
                self.btnContests.setTitle("All Contests (\(fullContests))", for: .normal)
            }else{
                self.btnContests.setTitle("All Contests", for: .normal)
            }
        }
        
        if let contestCount = result?.object(forKey: "my_contests") as? Int{
            GlobalDataPersistance.shared.myContestCount = contestCount
            
            if contestCount > 0{
                self.btnSelfContents.setTitle("My Contests (\(contestCount))", for: .normal)
            }else{
                self.btnSelfContents.setTitle("My Contests", for: .normal)
            }
        }
    }
    
    func getJoinedContests (hideLoader:Bool){
        let params:[String:String] = ["user_id":Constants.kAppDelegate.user?.id ?? "",
                                      "match_id":String(GDP.selectedMatch?.match_id ?? 0),
                                      "series_id":String(GDP.selectedMatch?.series_id ?? 0)
        ]
        
        let url = URLMethods.BaseURL + URLMethods().getJoinedContests

        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            let teamCount = (result?.object(forKey: "my_team_count") as? Int) ?? GlobalDataPersistance.shared.myTeamCount
            GlobalDataPersistance.shared.myTeamCount = teamCount
            
            if self.filterData == nil {
                if let fullContests = result?.object(forKey: "full_contest") as? Int{
                    GlobalDataPersistance.shared.fullContestCount = fullContests
                    if fullContests > 0{
                        self.btnContests.setTitle("All Contests (\(fullContests))", for: .normal)
                    }else{
                        self.btnContests.setTitle("All Contests", for: .normal)
                    }
                }
            }
            
            if isSuccess == true{
                if result != nil {
                    let data = result?.object(forKey: "results") as? [[String:Any]]
                        if data != nil{
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                                  let tblData = try? JSONDecoder().decode([JoinedContest].self, from: jsonData)else {return }
                            self.arrJoinedContests = tblData
                            
                            for i in 0..<(self.arrJoinedContests?.count ?? 0){
                                var contest = self.arrJoinedContests?[i]
                                var contestData = contest?.contestData
                                contestData?.is_joined = contest?.is_joined
                                contest?.contestData = contestData
                                self.arrJoinedContests?[i] = contest!
                            }
                            
                            GlobalDataPersistance.shared.myContestCount = self.arrJoinedContests?.count ?? 0
                            if GlobalDataPersistance.shared.myContestCount > 0{
                                self.btnSelfContents.setTitle("My Contests (\(GlobalDataPersistance.shared.myContestCount))", for: .normal)
                            }else{
                                self.btnSelfContents.setTitle("My Contests", for: .normal)
                            }
                            
                            
                            if  GlobalDataPersistance.shared.myTeamCount > 0{
                                self.btnMyTeams.setTitle("My Teams (\(GlobalDataPersistance.shared.myTeamCount))", for: .normal)
                            }else{
                                self.btnMyTeams.setTitle("My Team", for: .normal)
                            }

                            
                            
                            self.tblContests.reloadData()
                            
                        }
                }
                
            }
            
            else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
            AppManager.stopActivityIndicator(self.view)
            
            self.lblNoData.text = "No Contests Available!"
            if (self.arrJoinedContests?.count ?? 0) > 0{
                self.lblNoData.isHidden = true
            }else{
                self.lblNoData.isHidden = false
            }
        }
        
        if hideLoader == false{
            AppManager.startActivityIndicator(sender: self.view)
        }
    }
    
    @objc func getTeamLists (){
        
        WebCommunication.shared.getTeams(hostController: self, match_id: (GDP.selectedMatch?.match_id ?? 0), series_id: (GDP.selectedMatch?.series_id ?? 0), showLoader: true) { team in
            if let tblData = team{
                self.arrTeamList = tblData
                
                
                for i in 0..<(self.arrTeamList?.count ?? 0){
                    var team = self.arrTeamList?[i]
                    let notAnnouncedPlayers = team?.seriesPlayer?.filter({($0.is_playing ?? false) == false})
                    team?.lineUpPlayerNotAnnounced = notAnnouncedPlayers?.count ?? 0
                    self.arrTeamList?[i] = team!
                }
                
                self.tblContests.reloadData()
               
                GlobalDataPersistance.shared.myTeamCount = self.arrTeamList?.count ?? 0
                GlobalDataPersistance.shared.myTeams = self.arrTeamList ?? [Team]()
                if  GlobalDataPersistance.shared.myTeamCount > 0{
                    self.btnMyTeams.setTitle("My Teams (\(GlobalDataPersistance.shared.myTeamCount))", for: .normal)
                }else{
                    self.btnMyTeams.setTitle("My Team", for: .normal)
                }
                
                if GlobalDataPersistance.shared.isContestJoinFlow == true{
                    GlobalDataPersistance.shared.isContestJoinFlow = false
                    if GlobalDataPersistance.shared.myTeamCount > 0{
                        if let team = tblData.last{
                            if (GDP.selectedContest?.entry_fee ?? 0) == 0{
                                self.setTeamId(team: team, teamCount: String(GlobalDataPersistance.shared.myTeamCount), contestData: GDP.selectedContest)
                            }
                            else if LocationManager.sharedInstance.isPLayingInLegalState() == true {
                                self.setTeamId(team: team, teamCount: String(GlobalDataPersistance.shared.myTeamCount), contestData: GDP.selectedContest)

                            }
                        }
                    }
                }
            }
            
            self.lblNoData.text = "No Teams Available!"
            if (self.arrTeamList?.count ?? 0) > 0{
                self.lblNoData.isHidden = true
            }else{
                self.lblNoData.isHidden = false
            }
        }
    }
}

extension MatchContestViewController : EditTeamDelegate
{
    func editMyTeam(index: Int) {
        
        let dataDict = self.arrTeamList?[index]
        let navData = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "CreateTeamViewController") as! CreateTeamViewController
        //navData.setSelectTeamDelegate = true
        navData.isFromEdit = "Edit"
        navData.TeamData = dataDict
        navData.strCaptainID = "\(dataDict?.captain_player_id ?? "0")"
        navData.strViceCaptainID = "\(dataDict?.vice_captain_player_id ?? "0")"
        navData.teamID = "\(dataDict?.team_id ?? "0")"
        navData.strTeamNumber = "\(dataDict?.team_number ?? 1)"
        self.navigationController?.pushViewController(navData, animated: true)
        
    }
}
extension MatchContestViewController : UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.tipView.tipView.dismiss()
    }
}

//MARK: - Directly Apply Booster Functionality
extension MatchContestViewController {
    
    func getPlayerList(team: Team) {
        let params:[String:String] = [
            "match_id":String(GDP.selectedMatch?.match_id ?? 0),
            "series_id":String(GDP.selectedMatch?.series_id ?? 0),
            "local_team_id":String(GDP.selectedMatch?.localteam_id ?? 0),
            "visitor_team_id":String(GDP.selectedMatch?.visitorteam_id ?? 0)
        ]
        
        let url = URLMethods.BaseURL + URLMethods().getPlayersList

        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                if result != nil {

                    let data = result?.object(forKey: "results") as? [[String:Any]]
                        if data != nil{
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted),
                                  let players = try? JSONDecoder().decode([Player].self, from: jsonData)else {return }
                           
                            self.populateEditTeamData(dataResponse: players, team: team)
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
    
    func populateEditTeamData(dataResponse:[Player], team: Team){
        
        if dataResponse.count > 0 {
            
            var selectedPlayers = [Player]()
            var playerTypeCount = SelectedPlayerTypes()
            
            var localPlayersCount = 0
            var visitorPlayersCount = 0
            var usedCreditsCount = 0.0
            
            for i in 0..<dataResponse.count
            {
                for j in 0..<team.seriesPlayer!.count
                {
                    if "\(dataResponse[i].player_id ?? 0)" == "\(team.seriesPlayer![j].player_id ?? 0)"
                    {
                        selectedPlayers.append(dataResponse[i])
                        usedCreditsCount += self.getDouble(for: dataResponse[i].player_credit ?? "0")
                        //print("usedCreditsCount-->",usedCreditsCount)
                        if "\(GDP.selectedMatch?.localteam_id ?? 0)" == "\(dataResponse[i].team_id ?? 0)"
                        {
                            localPlayersCount += 1
                        }
                        else if "\(GDP.selectedMatch?.visitorteam_id ?? 0)" == "\(dataResponse[i].team_id ?? 0)"
                        {
                            visitorPlayersCount += 1
                        }
                        break
                    }
                }
                
            }
            
            if usedCreditsCount == 0
            {
                usedCreditsCount = 100.0
            }
            
            playerTypeCount.wicketkeeper = team.total_wicketkeeper ?? 0
            playerTypeCount.batsman = team.total_batsman ?? 0
            playerTypeCount.bowler = team.total_bowler ?? 0
            playerTypeCount.allrounder = team.total_allrounder ?? 0
            playerTypeCount.totalSelectedPlayers = 11
            playerTypeCount.localPlayers = localPlayersCount
            playerTypeCount.visitorPlayers = visitorPlayersCount
            playerTypeCount.usedCredits = usedCreditsCount
            playerTypeCount.captainId = team.captain_player_id ?? ""
            playerTypeCount.viceCaptainId = team.vice_captain_player_id ?? ""
            playerTypeCount.teamId = team.team_id ?? ""
            playerTypeCount.extraPlayers = 3
            
            let vc = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "ChooseCaptainViewController") as! ChooseCaptainViewController
            
            vc.arrAllPlayers = dataResponse
            vc.arrPlayers = selectedPlayers
            vc.playerTypeCount = playerTypeCount
            vc.isFromEdit = "Edit"
            //vc.selectedBooster = team.boosterDetails
            
            vc.strTeamID = "\(team.team_id ?? "0")"
            vc.strCaptain = "\(team.captain_player_id ?? "0")"
            vc.strViceCaptain = "\(team.vice_captain_player_id ?? "0")"
            vc.isFromVC = "Edit"
            
//            if let appliedBooster = team.boosterDetails, appliedBooster.contains(where: {$0.boosterName == BoosterType.TRIPLE_SCORER.name}), !(team.boostedPlayer?.isEmpty ?? true) {
//                vc.strBoosterPlayerId = "\(team.boostedPlayer?.first ?? 0)"
//            }
            
            vc.strTeamNumber = "\(team.team_number ?? 1)"
            //vc.currentTeamCount = "0"
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

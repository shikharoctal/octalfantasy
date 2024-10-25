//
//  LiveContestDetailViewController.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 09/03/22.
//

import UIKit
import SDWebImage

class LiveContestDetailViewController: BaseClassWithoutTabNavigation {

    @IBOutlet weak var viewLiveIcon: UIView!
    @IBOutlet weak var lblMatchComment: UILabel!
    @IBOutlet weak var navigationView: CustomNavigation!
    @IBOutlet weak var lblVisitorTeamScore: UILabel!
    @IBOutlet weak var lblLocalTeamScore: UILabel!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var btnVisitorTeam: UIButton!
    @IBOutlet weak var btnHomeTeam: UIButton!
    @IBOutlet weak var imgVisitorTeam: UIImageView!
    @IBOutlet weak var imgLocalTeam: UIImageView!
    @IBOutlet weak var headerHeight: NSLayoutConstraint!  //280 , 64

    @IBOutlet weak var lblVS: UILabel!

    
    @IBOutlet weak var tblContestDetails: UITableView!
    @IBOutlet weak var viewLeaderboard: UIView!
    @IBOutlet weak var viewWinnings: UIView!
    @IBOutlet weak var btnLeaderboard: UIButton!
    @IBOutlet weak var btnWinnings: UIButton!
    
    @IBOutlet weak var viewFirstToJoinHeightConst: NSLayoutConstraint!
    @IBOutlet weak var lblFirstJoinContest: UILabel!
    @IBOutlet weak var btnDownloadPress: UIButton!
    
    @IBOutlet weak var viewLiveScore: LiveScoreBallView!
    @IBOutlet weak var viewLiveScoreHeight: NSLayoutConstraint! //64

    var contestData:ContestData? = nil
    
    var arrTeam = [Team]()
    
    @IBOutlet weak var EntryModuleWidth: NSLayoutConstraint!
    var isLiveContest:Bool = false
    
    var strFromVC = ""
    var selectedUserRank = ""
    var selectedTeamName = ""
    
    var teamCount = "0"
    var selectedTeam:Team? = nil
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let title = GDP.getFantasyTitle()
        navigationView.configureNavigationBarWithController(controller: self, title: title, hideNotification: false, hideAddMoney: true, hideBackBtn:false)
        navigationView.img_BG.isHidden = true
        self.setupUI()
        self.btnWinningLeaderboardPressed(btnWinnings)
        if #available(iOS 15.0, *) {
            self.tblContestDetails.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
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
    
    
    func startTimer()
    {
//        CommonFunctions().timerStart(date: self.lblHeader, strTime: GDP.selectedMatch?.start_time ?? "", strDate: GDP.selectedMatch?.start_date, viewcontroller: self)
//        CommonFunctions().timerStart(date: self.lblVS, strTime: GDP.selectedMatch?.start_time ?? "", strDate: GDP.selectedMatch?.start_date, viewcontroller: self)
        
        CommonFunctions().timerStart(lblTime: self.lblHeader, strDate: GDP.selectedMatch?.match_date ?? "", viewcontroller: self, fromSeasonMyTeams: false, isFromHome: true)
        CommonFunctions().timerStart(lblTime: self.lblVS, strDate: GDP.selectedMatch?.match_date ?? "", viewcontroller: self, fromSeasonMyTeams: false, isFromHome: true)
    }
    
    func setupUI(){

        if GDP.selectedMatch?.match_status?.uppercased() ?? "" == "LIVE" || GDP.selectedMatch?.match_status?.uppercased() ?? "" == "IN PROGRESS" || GDP.selectedMatch?.match_status?.uppercased() ?? "" == "RUNNING"{
            self.viewLiveScore.controller = self
            WebCommunication.shared.getTeamScore(hostController: self, series_id: GDP.selectedMatch?.series_id ?? 0, match_id: GDP.selectedMatch?.match_id ?? 0, showLoader: false) { score in
                self.viewLiveScore.updateView(selectedMatch: GDP.selectedMatch, score: score)
            }
            self.headerHeight.constant = 280
            viewLiveScoreHeight.constant = 64
            viewLiveIcon.isHidden = false
            
        }else{
            lblVS.textColor = UIColor.white
            lblVS.text = "Completed"
            viewLiveIcon.isHidden = true
            
            if GDP.fantasyType == Constants.kCricketFantasy {
                viewLiveScore.isHidden = true
                headerHeight.constant = 220
                viewLiveScoreHeight.constant = 0
            }else {
                viewLiveScore.controller = self
                WebCommunication.shared.getTeamScore(hostController: self, series_id: GDP.selectedMatch?.series_id ?? 0, match_id: GDP.selectedMatch?.match_id ?? 0, showLoader: false) { score in
                    self.viewLiveScore.updateView(selectedMatch: GDP.selectedMatch, score: score)
                }
                headerHeight.constant = 250
                viewLiveScoreHeight.constant = 64
            }
            
            self.btnHomeTeam.setImage(nil, for: .normal)
            self.btnVisitorTeam.setImage(nil, for: .normal)
        }
        
        
        btnHomeTeam.setTitle(GDP.selectedMatch?.localteam_short_name ?? "", for: .normal)
        btnVisitorTeam.setTitle(GDP.selectedMatch?.visitorteam_short_name ?? "", for: .normal)
        
        imgLocalTeam.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgLocalTeam.sd_setImage(with: URL(string: GDP.selectedMatch?.localteam_flag ?? ""), placeholderImage: Constants.kNoImageUser)

        imgVisitorTeam.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imgVisitorTeam.sd_setImage(with: URL(string: GDP.selectedMatch?.visitorteam_flag ?? ""), placeholderImage: Constants.kNoImageUser)
        
        WebCommunication.shared.getTeamScore(hostController: self, series_id: GDP.selectedMatch?.series_id ?? 0, match_id: GDP.selectedMatch?.match_id ?? 0, showLoader: false) { score in
            if GDP.selectedMatch?.match_status?.uppercased() ?? "" == "LIVE" || GDP.selectedMatch?.match_status?.uppercased() ?? "" == "IN PROGRESS" || GDP.selectedMatch?.match_status?.uppercased() ?? "" == "RUNNING"{
                self.lblMatchComment.text = score?.comment ?? ""
                self.highLightBattingBowlingTeams(score: score)
            }else{
                self.lblMatchComment.text = score?.finalComment ?? ""
            }
            self.lblLocalTeamScore.text = score?.local_team_score ?? ""
            self.lblVisitorTeamScore.text = score?.visitor_team_score ?? ""
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
    
    func highLightBattingBowlingTeams(score:Score?){
        if (score?.battingTeamId ?? 0 == GDP.selectedMatch?.localteam_id ?? 0){
            self.btnHomeTeam.setImage(Constants.kBattingImage, for: .normal)
            self.btnVisitorTeam.setImage(Constants.kBowlingImage, for: .normal)

        }else{
            self.btnHomeTeam.setImage(Constants.kBowlingImage, for: .normal)
            self.btnVisitorTeam.setImage(Constants.kBattingImage, for: .normal)
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
   
    @IBAction func btnWinningLeaderboardPressed(_ sender: UIButton) {
        btnWinnings.isSelected = false
        btnLeaderboard.isSelected = false
        viewWinnings.backgroundColor = UIColor.clear
        viewLeaderboard.backgroundColor = UIColor.clear
        
        switch sender{
        case btnWinnings:
            btnWinnings.isSelected = true
            viewWinnings.backgroundColor =  UIColor.appRedColor
            viewFirstToJoinHeightConst.constant = 0
            lblFirstJoinContest.isHidden = true
            btnDownloadPress.isHidden = true
            tblContestDetails.reloadData()
            break
        case btnLeaderboard:
            btnLeaderboard.isSelected = true
            viewLeaderboard.backgroundColor =  UIColor.appRedColor
            viewFirstToJoinHeightConst.constant = 40
            lblFirstJoinContest.isHidden = false
            btnDownloadPress.isHidden = false
            
            tblContestDetails.reloadData()
            
            break
        default:
            
            
            break
            
            
            
        }
    }
    
    @IBAction func btnInviteFriendsPressed(_ sender: UIButton) {
        
        guard let link = URL(string: "\(URLMethods.DeepLinkURL)/?inviteCode=\(self.contestData?.invite_code ?? "")") else { return }
        
        CommonFunctions().getDynamicLink(link: link) { dynamicLink in
            
            //let text = "You've been challenged! \n\nThink you can beat me? Join the contest on India’s fantasy for the \(GDP.selectedMatch?.series_name ?? "") match and prove it! \n\nClick on this link \(dynamicLink) or use my invite code \(self.contestData?.invite_code?.uppercased() ?? "") to accept this challenge!"
            
            let textToShare = [ dynamicLink ]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnWalletPressed(_ sender: Any) {
        let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "MyAccountDetailsVC") as! MyAccountDetailsVC
        self.navigationController?.pushViewController(pushVC, animated: true)
    }
  
}
extension LiveContestDetailViewController{
    
    //MARK: Api getDownloadTeamFile
    func getDownloadTeamFile(winningTeam:Bool){
        
        AppManager.startActivityIndicator("", sender: view)
        let params:[String:Any] = ["contest_id": contestData?.id ?? "0",
                                   "match_id": GDP.selectedMatch?.match_id ?? 0,
                                   "series_id": GDP.selectedMatch?.series_id ?? 0,
                                   "winning_team": winningTeam
        ]
        
        let url = URLMethods.BaseURL + URLMethods().getContestTeam
        
        ApiClient().postRequest(params, request: url, view: self.view) { (msg, result) in
         
            if result != nil {
                let status = result?.object(forKey: "success") as? Bool ?? false
                if status == true{
                    let pdfUrl = result?.object(forKey: "result") as? String
                    if let pdfURL = pdfUrl, pdfURL != "" {
                        self.openDownloadFile(url: pdfURL)
                    }
                }else{
                    AppManager.showToast(msg ?? "", view: (self.view)!)
                    AppManager.stopActivityIndicator(self.view)
                }
                
            }else{
                AppManager.showToast(msg ?? "", view: (self.view)!)
                AppManager.stopActivityIndicator(self.view)
            }
        }
    }
    
    
    func getTeamLists (){
        
        WebCommunication.shared.getTeams(hostController: self, match_id: (GDP.selectedMatch?.match_id ?? 0), series_id: (GDP.selectedMatch?.series_id ?? 0), showLoader: true) { team in
            if let tblData = team{
                GlobalDataPersistance.shared.myTeamCount = tblData.count
                GlobalDataPersistance.shared.myTeams = tblData
            }
            self.getContestDetails()
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
                            
                            self.refreshControl.endRefreshing()
                            self.tblContestDetails.reloadData()
                            
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
//
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
    
    func loadTeamPreview(team_id: String, userId: String) {
        
        WebCommunication.shared.dailyContestTeamPreview(hostController: self, seriesId: "\(GDP.selectedMatch?.series_id ?? 0)", matchId: (GDP.selectedMatch?.match_id ?? 0), teamId: team_id, userId: userId, showLoader: true) { team in
            
            guard let dictTeam = team else { return }
           
            var arrPlayerData = [PlayerDetails]()
            var selectedPlayers = SelectedPlayerTypes()
            
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
    }
}

extension LiveContestDetailViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if btnWinnings.isSelected == true{
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
        if btnWinnings.isSelected == true{
            return 110
        }
        return 40;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))

        if btnWinnings.isSelected == true{
            let winningHeader:WinningsHeaderView = WinningsHeaderView.instanceFromNib() as! WinningsHeaderView
            winningHeader.controller = self
            winningHeader.contestData = self.contestData
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
            leaderHeader.lblPoints.isHidden = false
            leaderHeader.lblRank.isHidden = false
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
                cell.lblWinnings.text = breakUp?.reward ?? ""//"XP"
            }else {
                cell.lblWinnings.text = "\(GDP.globalCurrency)\(CommonFunctions.suffixNumberIndian(currency: breakUp?.each_price ?? 0))"
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
            cell.lblPoints.isHidden = false
            cell.lblRank.isHidden = false
          
            var breakUp:JoinedTeam? = nil
            if indexPath.section == 0 {
                cell.contentView.backgroundColor = UIColor.hexStringToUIColor(hex: "040F19")
                cell.lblTeamCount.textColor = UIColor.appRedColor
                cell.viewBackground.backgroundColor = UIColor.bgDarkSepratorColor
                breakUp = contestData?.my_teams?[indexPath.row]
            }else{
                cell.contentView.backgroundColor = UIColor.hexStringToUIColor(hex: "040F19")
                cell.lblTeamCount.textColor = UIColor.appRedColor
                cell.viewBackground.backgroundColor = UIColor.appPrimaryColor
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
                    var suffix = "Won Amount:"
                    if indexPath.section == 0{
                       suffix = "You Won:"
                    }
                    cell.lblReward.text = "\(suffix) \(GDP.globalCurrency)\(breakUp?.win_amount?.rounded(toPlaces: 2) ?? 0)"
                    //cell.WinningAmountHeight.constant = 15
                }else{
                    cell.lblReward.text =  breakUp?.reward
                    //cell.WinningAmountHeight.constant = 15
                }
                
            }else{
                cell.lblReward.text = ""
                //cell.WinningAmountHeight.constant = 0
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
            self.selectedTeamName = "\(dataDict?.username ?? "") Team \(Int(dataDict?.team_count ?? 0))"
            
            if self.strFromVC == "Live" || self.strFromVC == "Completed"
            {
               
                self.loadTeamPreview(team_id: dataDict?.id ?? "", userId: (dataDict?.user_id ?? ""))
               
            }
            else
            {
                if (Constants.kAppDelegate.user?.id ?? "") == (dataDict?.user_id ?? "")
                {
                    self.loadTeamPreview(team_id: dataDict?.id ?? "", userId: (dataDict?.user_id ?? ""))
                }
                else
                {
                    AppManager.showToast(ConstantMessages.VIEW_OTHER_TEAMS_AFTER_MATCH_STARTED, view: self.view)
                }
            }
        }
    }
}
extension LiveContestDetailViewController : EditTeamDelegate
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
//extension LiveContestDetailViewController:UIDocumentInteractionControllerDelegate {
//
////MARK: UIDocumentInteractionController delegates
//func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
//    return self//or use return self.navigationController for fetching app navigation bar colour
//}
//}

//
//  SelectTeamViewController.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 14/03/22.
//

import UIKit
import SDWebImage
import CoreMIDI

class SelectTeamViewController: BaseClassWithoutTabNavigation {

    @IBOutlet weak var tblTeams: UITableView!
    
    var arrTeamList:[Team]? = nil {
        didSet {
            if arrTeamList?.count == 0 {
                tblTeams.setEmptyMessage(ConstantMessages.NoTeamAvailable)
            }else {
                tblTeams.restoreEmptyMessage()
            }
            tblTeams.reloadData()
        }
    }
    
    var completionHandler : ((Team, Int) -> Void)?

    var createTeamcompletionHandler : ((Bool) -> Void)?
    var editTeamcompletionHandler : ((Team) -> Void)?

    var selectedIndex = -2
    var contestData:ContestData? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getTeamLists()
    }
    
    
    
    @IBAction func btnBackPressed(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func btnJoinContestPressed(_ sender: UIButton) {
        
        if self.selectedIndex < 0{
            AppManager.showToast(ConstantMessages.SELECT_OR_CREATE_TEAM_JOIN, view: self.view)
            return
        }
        
        self.dismiss(animated: false) {
            if let teamModal = self.arrTeamList?[self.selectedIndex]{
                if let comp = self.completionHandler{
                    comp(teamModal, (self.arrTeamList?.count ?? 0))
                }
            }
        }        
    }
    
    
    @IBAction func btnCreateTeamPressed(_ sender: Any) {
        if let createTeamcompletionHandler = createTeamcompletionHandler {
            self.dismiss(animated: false) {
                createTeamcompletionHandler(true)
            }
        }
//        if GlobalDataPersistance.shared.myTeamCount == 6{
//            AppManager.showToast(ConstantMessages.CAN_NOT_CREATE_MORE_TEAMS, view: self.view)
//            return
//        }
        
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
    
    func resetTeamSelections(){

        for i in 0..<(self.arrTeamList?.count ?? 0) {
            var teamModal = self.arrTeamList?[i]
            teamModal?.isSelected = false
            self.arrTeamList?[i] = teamModal!
        }
                    
        tblTeams.reloadData()
    }
    
    func selectFirstTeam(){
        var isFirstTeamSelected = false
        for i in 0..<(self.arrTeamList?.count ?? 0) {
            var teamModal = self.arrTeamList?[i]
            teamModal?.isSelected = false
            if teamModal?.isJoined == false && isFirstTeamSelected == false{
                self.selectedIndex = i
                teamModal?.isSelected = true
                isFirstTeamSelected = true
            }
            self.arrTeamList?[i] = teamModal!
        }
    }
}


extension SelectTeamViewController:UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTeamList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectTeamTVCell", for: indexPath) as! SelectTeamTVCell

        cell.selectionStyle = .none

        let team = self.arrTeamList?[indexPath.row]
        cell.setData = team
        
        let players:[Player]? = self.arrTeamList?[indexPath.row].seriesPlayer
    
        if let players = players{
            let arrlocalTeamPlayers = players.filter({($0.team_id! == GDP.selectedMatch?.localteam_id)})
            cell.lblLocalTeamName.text = "\(GDP.selectedMatch?.localteam_short_name?.uppercased() ?? "") (\(arrlocalTeamPlayers.count))"
            
            let arrVisitorTeamPlayers = players.filter({($0.team_id! == GDP.selectedMatch?.visitorteam_id)})
            cell.lblVisitorTeamName.text = "\(GDP.selectedMatch?.visitorteam_short_name?.uppercased() ?? "") (\(arrVisitorTeamPlayers.count))"
        }
    
        
        if let captianRow = players?.firstIndex(where: {$0.player_id == (Int(team?.captain_player_id ?? "0"))}) {
            let player = players?[captianRow]
            
            cell.btnCaptain.setTitle(player?.name ?? "", for: .normal)
            cell.imgViewCaptain.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imgViewCaptain.sd_setImage(with: URL(string: player?.image ?? ""), placeholderImage: Constants.kNoImageUser)
        }

        if let vcRow = players?.firstIndex(where: {$0.player_id == (Int(team?.vice_captain_player_id ?? "0"))}) {
            let player = players?[vcRow]
            
            cell.btnViceCaptain.setTitle(player?.name ?? "", for: .normal)
            cell.imgViewViceCaptain.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imgViewViceCaptain.sd_setImage(with: URL(string: player?.image ?? ""), placeholderImage: Constants.kNoImageUser)
        }
        
        cell.btnSelection.isSelected = team?.isSelected ?? false
        cell.btnPreview.tag = indexPath.row
        cell.btnPreview.addTarget(self, action: #selector(btnPreviewPressed(_:)), for: .touchUpInside)
        
        cell.selectionStyle = .none
    
        if team?.isJoined == true{
            cell.btnSelection.isHidden = true
            cell.lblTeamTitle.text = "TEAM \(String(team?.team_number ?? 0)) (Joined)"
            cell.lblTeamTitleLeading.constant = 0
            cell.btnSelectionWidth.constant = 0
            
        }else{
            cell.lblTeamTitle.text = "TEAM \(String(team?.team_number ?? 0))"
            cell.btnSelection.isHidden = false
            cell.lblTeamTitleLeading.constant = 10
            cell.btnSelectionWidth.constant = 12
        }
        
        return cell
     
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var teamModal = self.arrTeamList?[indexPath.row]
        if teamModal?.isJoined == true{
            return
        }
        self.selectedIndex = indexPath.row
        self.resetTeamSelections()
        teamModal?.isSelected = true
        self.arrTeamList?[indexPath.row] = teamModal!
        
        tblTeams.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension SelectTeamViewController{
    func getTeamLists (){
        
        WebCommunication.shared.getTeams(hostController: self, match_id: (GDP.selectedMatch?.match_id ?? 0), series_id: (GDP.selectedMatch?.series_id ?? 0), showLoader: true) { team in
            if let tblData = team{
                self.arrTeamList = tblData
                
                self.populateTeamList()

                self.selectFirstTeam()

                self.tblTeams.reloadData()
            }
        }    
    }
    
    func populateTeamList(){
        if self.contestData != nil && (self.contestData?.my_teams_ids?.count ?? 0) > 0{
            for index  in 0..<(self.arrTeamList?.count ?? 0){
                var teamModel = self.arrTeamList?[index]
                print("contest Team Model \(teamModel?.id ?? "")")
                for jIndex in 0..<(self.contestData?.my_teams_ids?.count ?? 0){
                    let myTeamId = self.contestData?.my_teams_ids?[jIndex] ?? ""
                    if (teamModel?.id ?? "") == myTeamId{
                        teamModel?.isJoined = true
                        self.arrTeamList?[index] = teamModel!
                    }
                }
            }
        }
    }
}
extension SelectTeamViewController : EditTeamDelegate
{
    func editMyTeam(index: Int) {
        let dataDict = self.arrTeamList?[index]

        if let editTeamcompletionHandler = editTeamcompletionHandler {
            self.dismiss(animated: false) {
                if let dataDict = dataDict{
                    editTeamcompletionHandler(dataDict)
                }
            }
        }        
    }
}

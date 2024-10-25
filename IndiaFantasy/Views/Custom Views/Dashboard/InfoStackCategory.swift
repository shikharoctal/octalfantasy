//
//  InfoStackCategory.swift
//  YangoosServiceProvider
//
//  Created by mac307 on 01/06/22.
//

import UIKit

class InfoStackCategory: UIView, UITextFieldDelegate {
    @IBOutlet var contentView: UIView!
   
    var team:JoinedTeam?
    var controller:UIViewController? = nil
    
    var arrTeam = [Team]()
    
    @IBOutlet weak var btnTeamName: UIButton!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInilized()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupInilized()
    }
    
    override func layoutSubviews() {
        self.layer.cornerRadius = 2.0
        super.layoutSubviews()
       
    }
    
    
    func setupInilized() {
        Bundle.main.loadNibNamed("InfoStackCategory", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    @IBAction func btnTeamPressed(_ sender: UIButton) {
        self.loadTeamPreview(team_id: team?.id ?? "", userId: team?.user_id ?? "", team: team)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}
extension InfoStackCategory {
    
    func loadTeamPreview(team_id:String, userId:String, team:JoinedTeam?) {
        
        WebCommunication.shared.dailyContestTeamPreview(hostController: self.controller!, seriesId: "\(GDP.selectedMatch?.series_id ?? 0)", matchId: (GDP.selectedMatch?.match_id ?? 0), teamId: team_id, userId: userId, showLoader: true) { teamData in
         
            guard let dictTeam = teamData else { return }
            
            self.arrTeam = [dictTeam]
            
            var arrPlayerData = [PlayerDetails]()
            var selectedPlayers = SelectedPlayerTypes()            
            
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
            vc.strFromVC = "Leaderboard"
            
            vc.otherUserId = userId
            vc.playerDetails = arrPlayerData
            vc.selectedPlayers = selectedPlayers
            vc.teamName = "\(team?.username ?? "") Team \(team?.team_count ?? 0)"
            vc.strCaptainId = captain.count > 0 ? captain[0].player_id : ""
            vc.strViceCaptainId = viceCaptain.count > 0 ? viceCaptain[0].player_id : ""
            vc.strPointsSuffix = "Cr"
            vc.modalPresentationStyle = .custom
            vc.userTeamRank = "\((team?.rank ?? 0).forTrailingZero())"
            vc.userTeamName = "\(team?.username ?? "")-T\(team?.team_count ?? 0)"
            vc.TeamData = dictTeam
            vc.validTeamID = dictTeam.id ?? ""
            vc.delegate = self
            UIApplication.getTopMostViewController()?.present(vc, animated: true, completion: nil)
            
        }
    }
    
//    func getTeamAPI (team_id:String, userId:String, team:JoinedTeam?){
//        let params:[String:String] = ["team_id": team_id,
//                                      "match_id":String(GDP.selectedMatch?.match_id ?? 0),
//                                      "series_id":String(GDP.selectedMatch?.series_id ?? 0)
//        ]
//        
//        let url = URLMethods.BaseURL + URLMethods().getTeamList
//
//        ApiClient.init().postRequest(params, request: url, view: self.controller!.view) { (msg,result) in
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
//                                    
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
//                            vc.strFromVC = "Leaderboard"
//                            
//                            vc.otherUserId = userId
//                            vc.playerDetails = arrPlayerData
//                            vc.selectedPlayers = selectedPlayers
//                            vc.teamName = "\(team?.username ?? "") Team \(team?.team_count ?? 0)"
//                            vc.strCaptainId = captain.count > 0 ? captain[0].player_id : ""
//                            vc.strViceCaptainId = viceCaptain.count > 0 ? viceCaptain[0].player_id : ""
//                            vc.strPointsSuffix = "Cr"
//                            vc.modalPresentationStyle = .custom
//                            vc.userTeamRank = "\((team?.rank ?? 0).forTrailingZero())"
//                            vc.userTeamName = "\(team?.username ?? "")-T\(team?.team_count ?? 0)"
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
//                AppManager.showToast(msg ?? "", view: self.controller!.view)
//            }
//            AppManager.stopActivityIndicator(self.controller!.view)
//            
//        }
//        AppManager.startActivityIndicator(sender: self.controller!.view)
//    }
}
extension InfoStackCategory : EditTeamDelegate
{
    func editMyTeam(index: Int) {
        
        let dataDict = self.arrTeam[0]
        let navData = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "CreateTeamViewController") as! CreateTeamViewController
        GlobalDataPersistance.shared.isFromContestList = false
        //navData.setSelectTeamDelegate = true
        navData.isFromEdit = "Edit"
        navData.TeamData = dataDict
        navData.strCaptainID = "\(dataDict.captain_player_id ?? "0")"
        navData.strViceCaptainID = "\(dataDict.vice_captain_player_id ?? "0")"
        navData.teamID = "\(dataDict.team_id ?? "0")"
        navData.strTeamNumber = "\(dataDict.team_number ?? 1)"
        self.controller!.navigationController?.pushViewController(navData, animated: true)
        
    }
}

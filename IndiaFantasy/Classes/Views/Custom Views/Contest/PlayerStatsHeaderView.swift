//
//  PlayerStatsHeaderView.swift
//  GymPod
//
//  Created by Octal Mac 217 on 23/11/21.
//

import UIKit
import DropDown

class PlayerStatsHeaderView: UIView {

    @IBOutlet weak var imgViewBanner: UIImageView!
    @IBOutlet weak var btnHiglited: UIButton!
    @IBOutlet weak var btnPoints: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
   
    weak var controller:UIViewController? = nil
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "PlayerStatsHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
      }
        
    func updateView(){
        
        if let controller = controller as? LiveContestViewController {
            if controller.currentHighLightedTeam != nil{
                self.btnHiglited.setTitle("Highlight T\(controller.currentHighLightedTeam?.team_count ?? 0)", for: .normal)
            }else{
                self.btnHiglited.setTitle("Highlight", for: .normal)
            }
        }else if let controller = controller as? SeasonsContestVC {
            
            lblTitle.text = "Player Stats"
            if controller.currentHighLightedTeam != nil{
                self.btnHiglited.setTitle("Highlight T\(controller.currentHighLightedTeam?.teamCount ?? 0)", for: .normal)
            }else{
                self.btnHiglited.setTitle("Highlight", for: .normal)
            }
        }else if let controller = controller as? SeasonContestDetailsVC {
            
            lblTitle.text = "Player Stats"
            if controller.currentHighLightedTeam != nil{
                self.btnHiglited.setTitle("Highlight T\(controller.currentHighLightedTeam?.teamCount ?? 0)", for: .normal)
            }else{
                if controller.fromMyContest {
                    self.btnHiglited.setTitle("Highlight", for: .normal)
                }else {
                    self.btnHiglited.isHidden = true
                }
                
            }
        }
    }
    
    @IBAction func btnHighLightPressed(_ sender: UIButton) {
        let dropDown = DropDown()

        // The view to which the drop down will appear on
        dropDown.anchorView = sender // UIView or UIBarButtonItem
        dropDown.textFont = UIFont(name: "Gilroy-Regular", size: 12.0)!
        // The list of items to display. Can be changed dynamically
        if let controller = controller as? LiveContestViewController {
            if let teams = controller.arrMyTeams{
                var arrTeam = [String]()
                for team in teams {
                    arrTeam.append("T\(team.team_count ?? 0)")
                }
                dropDown.dataSource = arrTeam
                
                dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                  print("Selected item: \(item) at index: \(index)")
                    self.btnHiglited.setTitle("Highlight \(item)", for: .normal)
                    controller.populateHighLightedPlayersForTeam(team: teams[index])
                    dropDown.hide()
                }
                dropDown.show()

            }
        }else if let controller = controller as? SeasonsContestVC {
            
            let teams = controller.arrLeagueMyteam
            if !teams.isEmpty {
                var arrTeam = [String]()
                for team in teams {
                    arrTeam.append("T\(team.teamCount ?? 0)")
                }
                dropDown.dataSource = arrTeam
                
                dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                  print("Selected item: \(item) at index: \(index)")
                    self.btnHiglited.setTitle("Highlight \(item)", for: .normal)
                    controller.populateHighLightedPlayersForTeam(team: teams[index])
                    dropDown.hide()
                }
                dropDown.show()

            }
        }else if let controller = controller as? SeasonContestDetailsVC {
            
            let teams = controller.arrLeagueMyteam
            if !teams.isEmpty {
                var arrTeam = [String]()
                for team in teams {
                    arrTeam.append("T\(team.teamCount ?? 0)")
                }
                dropDown.dataSource = arrTeam
                
                dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                  print("Selected item: \(item) at index: \(index)")
                    self.btnHiglited.setTitle("Highlight \(item)", for: .normal)
                    controller.populateHighLightedPlayersForTeam(team: teams[index])
                    dropDown.hide()
                }
                dropDown.show()

            }
        }
        
    }
}

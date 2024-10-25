//
//  BoosterHeaderView.swift
//  India’s fantasy
//
//  Created by admin on 25/04/23.
//

import UIKit
import DropDown

class BoosterHeaderView: UIView {

    @IBOutlet weak var lblBoosterLeft: UILabel!
    @IBOutlet weak var btnTeam: UIButton!
    
    var completion: ((_ teamNumber: Int) -> Void)?
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "BoosterHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    @IBAction func btnSelectTeamPressed(_ sender: UIButton) {
        
        let dropDown = DropDown()
        
        dropDown.anchorView = sender // UIView or UIBarButtonItem
        dropDown.textFont = UIFont(name: "Gilroy-Regular", size: 12.0)!
        
        let myLeagueTeams = GDP.leagueMyTeams
        var arrTeam = [String]()
        for team in myLeagueTeams {
            arrTeam.append("Team \(team.teamCount ?? 0)")
        }
        dropDown.dataSource = arrTeam
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in

            print("Selected item: \(item) at index: \(index)")
            
            self.btnTeam.setTitle("\(item) ", for: .normal)
            if let completion = completion {
                completion(myLeagueTeams[index].teamCount ?? 0)
            }
            
            dropDown.hide()
        }
        dropDown.show()
    }
}

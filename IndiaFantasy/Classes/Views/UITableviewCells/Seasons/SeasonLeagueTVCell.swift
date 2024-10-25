//
//  SeasonLeagueTVCell.swift
//  India’s fantasy
//
//  Created by admin on 16/05/23.
//

import UIKit

class SeasonLeagueTVCell: UITableViewCell {

    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var lblLeagueName: UILabel!
    @IBOutlet weak var lblLeagueDescription: UILabel!
    @IBOutlet weak var btnEnter: UIButton!
    
    var setData: LeagueList? {
        didSet {
            guard let league = setData else { return }
            lblLeagueName.text = league.name
            //lblLeagueDescription.text = "Play with multiple Teams and Contests."
        }
    }
    
    var setContestData: ContestData? {
        didSet {
            guard let contest = setContestData else { return }
            viewBackground.backgroundColor = .clear
            lblLeagueName.textColor = .black
            lblLeagueName.text = contest.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

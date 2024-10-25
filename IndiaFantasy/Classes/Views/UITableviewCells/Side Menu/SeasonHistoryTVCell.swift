//
//  SeasonHistoryTVCell.swift
//  India’s fantasy
//
//  Created by admin on 03/08/23.
//

import UIKit

class SeasonHistoryTVCell: UITableViewCell {

    @IBOutlet weak var lblLeagueTitle: UILabel!
    @IBOutlet weak var lblRanking: UILabel!
    @IBOutlet weak var lblTotalPoints: UILabel!
    @IBOutlet weak var lblPrizeWon: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var setData: LeagueHistory? {
        didSet {
            guard let league = setData else { return }
            lblLeagueTitle.text = league.leagueName
            lblRanking.text = "\(league.rank ?? 0)"
            lblTotalPoints.text = league.totalSeriesPoint?.formattedNumber()
            lblPrizeWon.text = league.winAmount?.formattedNumber()
        }
    }
}

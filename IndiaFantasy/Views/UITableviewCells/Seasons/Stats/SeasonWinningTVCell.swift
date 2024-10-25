//
//  SeasonWinningTVCell.swift
//  IndiaFantasy
//
//  Created by Harendra Singh Rathore on 18/04/24.
//

import UIKit

class SeasonWinningTVCell: UITableViewCell {

    @IBOutlet weak var lblRank: UILabel!
    @IBOutlet weak var lblPrize: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var setData: SeasonWinning? {
        didSet {
            guard let winner = setData else { return }
            lblRank.text = "\(winner.rank ?? 0)"
            lblPrize.text = winner.prize ?? ""
        }
    }
}

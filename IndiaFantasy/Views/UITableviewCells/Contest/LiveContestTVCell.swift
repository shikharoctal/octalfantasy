//
//  LiveContestTVCell.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 15/03/22.
//

import UIKit

class LiveContestTVCell: UITableViewCell {

    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lblTeamName: UILabel!
    @IBOutlet weak var lblPrizeWon: UILabel!
    @IBOutlet weak var lblPoints: UILabel!
    @IBOutlet weak var lblRank: UILabel!
    @IBOutlet weak var lblTeamNumber: UILabel!
    
    @IBOutlet weak var winningBottom: NSLayoutConstraint!
    //@IBOutlet weak var winningHeight: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

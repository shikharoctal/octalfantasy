//
//  LeaderBoardTVCell.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 10/03/22.
//

import UIKit

class LeaderBoardTVCell: UITableViewCell {

    @IBOutlet weak var viewImgProfile: UIView!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var winningAmountBottom: NSLayoutConstraint!  //13
    @IBOutlet weak var WinningAmountHeight: NSLayoutConstraint!  // 15
    @IBOutlet weak var imgViewProfile: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblReward: UILabel!
    @IBOutlet weak var lblPoints: UILabel!
    @IBOutlet weak var lblRank: UILabel!
    
    @IBOutlet weak var lblTeamCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

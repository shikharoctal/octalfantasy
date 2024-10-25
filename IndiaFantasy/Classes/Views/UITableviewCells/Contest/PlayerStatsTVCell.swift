//
//  PlayerStatsTVCell.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 16/03/22.
//

import UIKit

class PlayerStatsTVCell: UITableViewCell {

    @IBOutlet weak var lblPlayerName: UILabel!
    @IBOutlet weak var imgViewPlayer: UIImageView!
   
    @IBOutlet weak var lblPlayerTeamName: UILabel!
    @IBOutlet weak var lblPlayerRole: UILabel!
    @IBOutlet weak var viewProfilePic: UIView!
    @IBOutlet weak var lblSelectionPercantage: UILabel!
    @IBOutlet weak var lblPoints: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateView(player:Player?, match:Match?){
        if (player?.team_id ?? 0) == (match?.localteam_id ?? 0){
            self.viewProfilePic.borderColor = UIColor.appGreenColor
        }else{
            self.viewProfilePic.borderColor = UIColor.red
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

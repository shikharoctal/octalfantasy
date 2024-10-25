//
//  ChoosePlayerTVCell.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 08/03/22.
//

import UIKit

class ChoosePlayerTVCell: UITableViewCell {

    @IBOutlet weak var viewPlayerImage: UIView!
    @IBOutlet weak var imgViewCountryFlag: UIImageView!
    @IBOutlet weak var lblPlayerName: UILabel!
    @IBOutlet weak var imgViewPlayer: UIImageView!
    @IBOutlet weak var lblTeamShortName: UILabel!
    @IBOutlet weak var lblPoints: UILabel!
    @IBOutlet weak var lblCredits: UILabel!
    @IBOutlet weak var btnAddPlayer: UIButton!
    
    @IBOutlet weak var imgViewAnnounced: UIImageView!
    @IBOutlet weak var lblAnnounced: UILabel!
    @IBOutlet weak var lblSel: UILabel!
    @IBOutlet weak var btnPlayerProfile: UIButton!
    @IBOutlet weak var viewAnnounced: UIView!
    @IBOutlet weak var viewGrayout: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnPlayerProfile.isExclusiveTouch = true
        btnAddPlayer.isExclusiveTouch = true
    }

    func updateView(player:Player?, match:Match?){
        if (player?.team_id ?? 0) == (match?.localteam_id ?? 0){
            self.viewPlayerImage.borderColor = UIColor.appGreenColor
        }else{
            self.viewPlayerImage.borderColor = UIColor.red
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

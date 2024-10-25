//
//  PlayerListTVCell.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 09/03/22.
//

import UIKit

class PlayerListTVCell: UITableViewCell {

    @IBOutlet weak var viewPlayerImage: UIView!
    @IBOutlet weak var btnPlayerProfile: UIButton!
    @IBOutlet weak var btnViceCaptain: UIButton!
    @IBOutlet weak var btnCaptain: UIButton!
    @IBOutlet weak var lblPoints: UILabel!
    @IBOutlet weak var lblPlayerRole: UILabel!
    @IBOutlet weak var lblTeamShortName: UILabel!
    @IBOutlet weak var lblPlayerName: UILabel!
    
    @IBOutlet weak var imgViewPlayer: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

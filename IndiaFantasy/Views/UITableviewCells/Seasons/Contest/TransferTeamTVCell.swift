//
//  TransferTeamTVCell.swift
//  India’s fantasy
//
//  Created by admin on 12/05/23.
//

import UIKit

class TransferTeamTVCell: UITableViewCell {

    @IBOutlet weak var imgOldPlayer: UIImageView!
    @IBOutlet weak var lblOldPlayerName: UILabel!
    @IBOutlet weak var lblOldPlayerTeam: UILabel!
    
    @IBOutlet weak var imgTransferPlayer: UIImageView!
    @IBOutlet weak var lblTransferPlayerName: UILabel!
    @IBOutlet weak var lblTransferPlayerTeam: UILabel!
    
    var setData: TransferdPlayer? {
        
        didSet {
            guard let player = setData else {
                return
            }

            if let fromPlayer = player.fromPlayer {
                imgOldPlayer.loadImage(urlS: fromPlayer.player_image, placeHolder: Constants.kNoImageUser)
                lblOldPlayerName.text = fromPlayer.player_name
                lblOldPlayerTeam.text = (fromPlayer.team_short_name ?? "") + " " + (fromPlayer.player_role ?? "")
            }
            
            if let toPlayer = player.toPlayer {
                imgTransferPlayer.loadImage(urlS: toPlayer.player_image, placeHolder: Constants.kNoImageUser)
                lblTransferPlayerName.text = toPlayer.player_name
                lblTransferPlayerTeam.text = (toPlayer.team_short_name ?? "") + " " + (toPlayer.player_role ?? "")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
}

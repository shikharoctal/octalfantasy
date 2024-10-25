//
//  ChooseCaptainPlayerTVCell.swift
//  India’s fantasy
//
//  Created by admin on 09/05/23.
//

import UIKit

class ChooseCaptainPlayerTVCell: UITableViewCell {

    @IBOutlet weak var viewPlayerImage: UIView!
    @IBOutlet weak var btnPlayerProfile: UIButton!
    @IBOutlet weak var btnViceCaptain: UIButton!
    @IBOutlet weak var btnCaptain: UIButton!
    @IBOutlet weak var lblViceCaptainPercent: UILabel!
    @IBOutlet weak var lblCaptainPercent: UILabel!
    @IBOutlet weak var lblPoints: UILabel!
    @IBOutlet weak var lblPlayerRole: UILabel!
    @IBOutlet weak var lblTeamShortName: UILabel!
    @IBOutlet weak var lblPlayerName: UILabel!
    
    @IBOutlet weak var imgViewPlayer: UIImageView!
    @IBOutlet weak var imgViewTeamFlag: UIImageView!
    @IBOutlet weak var imgViewOverseas: UIImageView!
    @IBOutlet weak var btnBooster: UIButton!
    
    var setData: Player? {
        didSet {
            guard let player = setData else { return }
            
            lblPlayerName.text = player.player_name ?? ""
            imgViewPlayer.loadImage(urlS: player.player_image, placeHolder: Constants.kNoImageCVC)
            imgViewTeamFlag.loadImage(urlS: player.team_flag, placeHolder: Constants.kNoImageUser)
            
            imgViewOverseas.isHidden = true
            
            lblTeamShortName.text = player.team_short_name?.trimmingCharacters(in: .whitespaces)
            
            lblPoints.text = "\((self.getDouble(for: player.player_points as Any)).forTrailingZero()) pts"
            lblPlayerRole.text = "\(player.player_role ?? "")"
            lblCaptainPercent.text = "\((player.captain_percent ?? 0).rounded(toPlaces: 1).forTrailingZero())%"
            lblViceCaptainPercent.text = "\((player.vice_captain_percent ?? 0).rounded(toPlaces: 1).forTrailingZero())%"
            
            if (player.isCaptain ?? false) == true {
                btnCaptain.isSelected = true
            }else{
                btnCaptain.isSelected = false
            }
            
            if (player.isViceCaptain ?? false) == true {
                btnViceCaptain.isSelected = true
            }else{
                btnViceCaptain.isSelected = false
            }
            
            if (player.isCaptain ?? false) || (player.isViceCaptain ?? false) {
                self.contentView.backgroundColor = UIColor.appSelectedBlueColor
            } else {
                self.contentView.backgroundColor = UIColor.hexStringToUIColor(hex: "#13212D")
            }
    
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    

}

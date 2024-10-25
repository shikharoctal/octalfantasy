//
//  ContestMyTeamsTVCell.swift
//  India’s fantasy
//
//  Created by admin on 01/05/23.
//

import UIKit

class ContestMyTeamsTVCell: UITableViewCell {

    @IBOutlet weak var lblMatchesPlayed: UILabel!
    @IBOutlet weak var lblTotalPoints: UILabel!
    @IBOutlet weak var lblTransferMade: UILabel!
    @IBOutlet weak var lblTransfersEficiency: UILabel!
    
    @IBOutlet weak var lblMatchName: UILabel!
    @IBOutlet weak var lblUnlimtedTransfer: UILabel!
    @IBOutlet weak var viewBooster: UIView!
    @IBOutlet weak var imgBooster: UIImageView!
    @IBOutlet weak var imgBoosterSecond: UIImageView!
    
    @IBOutlet weak var imgLocalTeam: UIImageView!
    @IBOutlet weak var lblLocalTeamName: UILabel!
    @IBOutlet weak var imgVisitorTeam: UIImageView!
    @IBOutlet weak var lblVisitorTeamName: UILabel!
    
    @IBOutlet weak var lblPoints: UILabel!
    @IBOutlet weak var imgCaptain: UIImageView!
    @IBOutlet weak var btnCaptain: UIButton!
    @IBOutlet weak var imgViceCaptain: UIImageView!
    @IBOutlet weak var btnViceCaptain: UIButton!
    
    @IBOutlet weak var lblWK: UILabel!
    @IBOutlet weak var lblBT: UILabel!
    @IBOutlet weak var lblAR: UILabel!
    @IBOutlet weak var lblBowl: UILabel!
    
    @IBOutlet weak var lblClosesTime: UILabel!
    @IBOutlet weak var lblTransferLeft: UILabel!
    
    @IBOutlet weak var btnMakeTransfer: UIButton!
    @IBOutlet weak var btnApplyBoosters: UIButton!
    
    var setData: Team? {
        didSet {
            guard let team = setData else { return }
            
            lblMatchesPlayed.text = "\(team.matches_played ?? 0)"
            lblTotalPoints.text = team.total_point?.formattedNumber() ?? "0"
            lblTransferMade.text = team.transfer_made?.formattedNumber() ?? "0"
            if let transferEfficiency = team.transfer_efficiency {
                lblTransfersEficiency.text = transferEfficiency.clean
            }else {
                lblTransfersEficiency.text = "N/A"
            }
            
            lblMatchName.text = "Match \(team.next_match_number ?? 0)"
            lblUnlimtedTransfer.text = "\(team.playerTransferInMatch ?? 0) Transfers made"
        
            imgLocalTeam.loadImage(urlS: team.localteam_flag, placeHolder: Constants.kNoImageUser)
            lblLocalTeamName.text = team.localteam
            imgVisitorTeam.loadImage(urlS: team.visitorteam_flag, placeHolder: Constants.kNoImageUser)
            lblVisitorTeamName.text = team.visitorteam
            
            viewBooster.isHidden = true
            imgBooster.isHidden = true
            imgBoosterSecond.isHidden = true
            
            if let booster = team.boosterDetails, booster.boosterImage != nil  {
                viewBooster.isHidden = false
                imgBooster.loadImage(urlS: booster.boosterImage, placeHolder: nil)
                imgBooster.isHidden = false
            }
            
            
            lblWK.text = "\(GDP.wkShort)(\(String(team.total_wicketkeeper ?? 0)))"
            lblBT.text = "\(GDP.batShort)(\(String(team.total_batsman ?? 0)))"
            lblAR.text = "\(GDP.arShort)(\(String(team.total_allrounder ?? 0)))"
            lblBowl.text = "\(GDP.bowlShort)(\(String(team.total_bowler ?? 0)))"
            
            lblPoints.text = team.total_point?.formattedNumber() ?? "0"
            
            let players = team.seriesPlayer
            if let captianRow = players?.firstIndex(where: {$0.player_id == (Int(team.captain_player_id ?? "0"))}) {
                let player = players?[captianRow]
                
                btnCaptain.setTitle(player?.name ?? "", for: .normal)
                imgCaptain.loadImage(urlS: player?.image, placeHolder: Constants.kNoImageUser)
            }

            if let vcRow = players?.firstIndex(where: {$0.player_id == (Int(team.vice_captain_player_id ?? "0"))}) {
                let player = players?[vcRow]
                
                btnViceCaptain.setTitle(player?.name ?? "", for: .normal)
                imgViceCaptain.loadImage(urlS: player?.image, placeHolder: Constants.kNoImageUser)
            }
            
            if GDP.leagueType == "fun" {
                lblTransferLeft.text = "Unlimited"
            }else {
                lblTransferLeft.text = team.available_transfer?.formattedNumber() ?? "0"
            }
            
        }
    
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

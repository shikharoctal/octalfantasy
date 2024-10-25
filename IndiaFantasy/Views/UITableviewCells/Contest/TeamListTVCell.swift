//
//  TeamListTVCell.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 07/03/22.
//

import UIKit
import SDWebImage

class TeamListTVCell: UITableViewCell {

    @IBOutlet weak var lblTeamTitle: UILabel!
    @IBOutlet weak var btnCaptain: UIButton!
    @IBOutlet weak var btnViceCaptain: UIButton!
    
    //@IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var lblTotalPoints: UILabel!
    @IBOutlet weak var lblBat: UILabel!
    @IBOutlet weak var lblWk: UILabel!
    @IBOutlet weak var imgViewViceCaptain: UIImageView!
    @IBOutlet weak var imgViewCaptain: UIImageView!
    @IBOutlet weak var lblAr: UILabel!
    @IBOutlet weak var lblBowl: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnClone: UIButton!
    @IBOutlet weak var btnPreview: UIButton!
    
    @IBOutlet weak var lblNotAnnouncedTeamLabel: UILabel!
    @IBOutlet weak var lblTeamOne: UILabel!
    @IBOutlet weak var lblTeamTwo: UILabel!
    
    @IBOutlet weak var lblRank: UILabel!
    @IBOutlet weak var lblPoints: UILabel!
    
    @IBOutlet weak var viewBooster: UIView!
    @IBOutlet weak var imgBoosterFirst: UIImageView!
    @IBOutlet weak var imgBoosterSecond: UIImageView!
    @IBOutlet weak var btnApplyBoosters: UIButton!
    @IBOutlet weak var viewLineUp: UIView!
    
    @IBOutlet weak var viewForwards: UIView!
    @IBOutlet weak var lblPRP: UILabel!
    @IBOutlet weak var lblHKR: UILabel!
    @IBOutlet weak var lblLCK: UILabel!
    @IBOutlet weak var lblLSF: UILabel!
    
    @IBOutlet weak var stackViewRugbyBooster: UIStackView!
    @IBOutlet weak var btnRugbyBooster: UIButton!
    @IBOutlet weak var btnMakeTransfer: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateUI(){
        self.btnCaptain.titleLabel?.numberOfLines = 0
        self.btnCaptain.titleLabel?.textAlignment = .center
        self.btnViceCaptain.titleLabel?.numberOfLines = 0
        self.btnViceCaptain.titleLabel?.textAlignment = .center
        self.btnCaptain.titleLabel?.lineBreakMode = .byWordWrapping
        self.btnViceCaptain.titleLabel?.lineBreakMode = .byWordWrapping
        self.btnCaptain.titleLabel?.adjustsFontSizeToFitWidth = true
        self.btnViceCaptain.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    func updateView(team:Team?, indexPath:IndexPath){
        self.lblTeamTitle.text = "TEAM \(String(team?.team_number ?? 0))"
        self.lblRank.text = ""
        self.lblPoints.text = ""

        self.updateUI()
        
        self.lblWk.text = "\(GDP.wkShort)(\(String(team?.total_wicketkeeper ?? 0)))"
        self.lblBat.text = "\(GDP.batShort)(\(String(team?.total_batsman ?? 0)))"
        self.lblAr.text = "\(GDP.arShort)(\(String(team?.total_allrounder ?? 0)))"
        self.lblBowl.text = "\(GDP.bowlShort)(\(String(team?.total_bowler ?? 0)))"
        viewForwards.isHidden = true
        
        self.selectionStyle = .none

        
        if let players = team?.seriesPlayer{
            let arrlocalTeamPlayers = players.filter({($0.team_id! == GDP.selectedMatch?.localteam_id)})
            self.lblTeamOne.text = "\(GDP.selectedMatch?.localteam_short_name?.uppercased() ?? "") (\(arrlocalTeamPlayers.count))"
            
            let arrVisitorTeamPlayers = players.filter({($0.team_id! == GDP.selectedMatch?.visitorteam_id)})
            self.lblTeamTwo.text = "\(GDP.selectedMatch?.visitorteam_short_name?.uppercased() ?? "") (\(arrVisitorTeamPlayers.count))"
            
            if let captianRow = players.firstIndex(where: {$0.player_id == (Int(team?.captain_player_id ?? "0"))}) {
                let player = players[captianRow]
                
                self.btnCaptain.setTitle(player.name ?? "", for: .normal)
                self.imgViewCaptain.sd_imageIndicator = SDWebImageActivityIndicator.gray
                self.imgViewCaptain.sd_setImage(with: URL(string: player.image ?? ""), placeholderImage: Constants.kNoImageUser)
            }else {
                self.imgViewCaptain.image = Constants.kNoPlayer
                self.btnCaptain.setTitle("-", for: .normal)
            }

            if let vcRow = players.firstIndex(where: {$0.player_id == (Int(team?.vice_captain_player_id ?? "0"))}) {
                let player = players[vcRow]
                
                self.btnViceCaptain.setTitle(player.name ?? "", for: .normal)
                self.imgViewViceCaptain.sd_imageIndicator = SDWebImageActivityIndicator.gray
                self.imgViewViceCaptain.sd_setImage(with: URL(string: player.image ?? ""), placeholderImage: Constants.kNoImageUser)
            }else {
                self.imgViewViceCaptain.image = Constants.kNoPlayer
                self.btnViceCaptain.setTitle("-", for: .normal)
            }
        }
        
        viewBooster.isHidden = true
        imgBoosterFirst.isHidden = true
        imgBoosterSecond.isHidden = true
        
        if let booster = team?.boosterDetails {
            viewBooster.isHidden = false
            imgBoosterFirst.loadImage(urlS: booster.boosterImage, placeHolder: Constants.kNoImage)
            imgBoosterFirst.isHidden = false
        }
        
        if (GDP.selectedMatch?.lineup ?? false) == true && team?.lineUpPlayerNotAnnounced != 0 {
            
            self.viewLineUp.isHidden = false
            if (team?.lineUpPlayerNotAnnounced ?? 0) > 1{
                self.lblNotAnnouncedTeamLabel.text = "\(team?.lineUpPlayerNotAnnounced ?? 0) players are not announced in playing XI."
            }else{
                self.lblNotAnnouncedTeamLabel.text = "\(team?.lineUpPlayerNotAnnounced ?? 0) player is not announced in playing XI."
            }
        }else{
            self.viewLineUp.isHidden = true
        }

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

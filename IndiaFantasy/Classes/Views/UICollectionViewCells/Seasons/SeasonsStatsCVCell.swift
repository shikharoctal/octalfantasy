//
//  SeasonsStatsCVCell.swift
//  India’s fantasy
//
//  Created by admin on 27/04/23.
//

import UIKit

class SeasonsStatsCVCell: UICollectionViewCell {

    @IBOutlet weak var viewProfile: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPoints: UILabel!
    @IBOutlet weak var imgTeamLogo: UIImageView!
    @IBOutlet weak var viewRank: UIView!
    @IBOutlet weak var lblRank: UILabel!
    
    var setPlayers: LeaguePlayers? {
        didSet {
            
            guard let player = setPlayers else { return }
            
            lblName.text = player.username ?? player.playerName ?? ""
            
            if let points = player.points {
                lblPoints.text = points.formattedNumber() + " pts"
            }else {
                lblPoints.text = (player.selectedBy?.clean ?? "-") + "%"
            }
            
            if let rank = player.rank {
                viewRank.isHidden = false
                lblRank.text = "#\(rank)"
            }else {
                viewRank.isHidden = true
            }
            
            if let teamFlag = player.teamFlag {
                imgTeamLogo.isHidden = false
                imgTeamLogo.loadImage(urlS: teamFlag, placeHolder: Constants.kNoImageUser)
            }else {
                imgTeamLogo.isHidden = true
            }
            
            if let playerImage = player.playerImage {
                imgProfile.loadImage(urlS: playerImage, placeHolder: Constants.kNoImageUser)
            }else {
                imgProfile.loadImage(urlS: player.userImage, placeHolder: Constants.kNoImageUser)
            }
           
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        viewProfile.cornerRadius = 8
        viewProfile.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

}

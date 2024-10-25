//
//  SeasonTeamPreviewCVCell.swift
//  India’s fantasy
//
//  Created by admin on 15/05/23.
//

import UIKit

class SeasonTeamPreviewCVCell: UICollectionViewCell {
    
    @IBOutlet weak var imgPlayer: UIImageView!
    @IBOutlet weak var lblPlayerName: UILabel!
    @IBOutlet weak var lblPlayerCredit: UILabel!
    @IBOutlet weak var lblCaptain: UILabel!
    @IBOutlet weak var imgOverseasPlayer: UIImageView!
    @IBOutlet weak var viewTeamShortTame: UIView!
    @IBOutlet weak var lblTeamShortName: UILabel!
    @IBOutlet weak var lblLineup: UILabel!
    @IBOutlet weak var viewLineup: UIView!
    @IBOutlet weak var playingIcon: UIImageView!
    
    @IBOutlet weak var playingLeading: NSLayoutConstraint!
    @IBOutlet weak var playingWidth: NSLayoutConstraint!
    @IBOutlet weak var playingTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var imgBooster: UIImageView!
    
    func updateView(isLocalTeam: Bool){
        imgPlayer.borderWidth = 1
        if isLocalTeam == true {
            self.imgPlayer.borderColor = UIColor.appLocalTeamBackgroundColor
        }else{
            self.imgPlayer.borderColor = UIColor.appVisitorTeamBackgroundColor
        }
    }
    
}

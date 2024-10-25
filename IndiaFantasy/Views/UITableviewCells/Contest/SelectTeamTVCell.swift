//
//  SelectTeamTVCell.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 14/03/22.
//

import UIKit

class SelectTeamTVCell: UITableViewCell {

    @IBOutlet weak var lblTeamTitleLeading: NSLayoutConstraint! // 10
    @IBOutlet weak var btnSelectionWidth: NSLayoutConstraint! //12
    
    @IBOutlet weak var lblVisitorTeamName: UILabel!
    @IBOutlet weak var lblLocalTeamName: UILabel!
    @IBOutlet weak var lblTeamTitle: UILabel!
    @IBOutlet weak var btnCaptain: UIButton!
    @IBOutlet weak var btnViceCaptain: UIButton!
    
    @IBOutlet weak var btnSelection: UIButton!
    @IBOutlet weak var lblBat: UILabel!
    @IBOutlet weak var lblWk: UILabel!
    @IBOutlet weak var imgViewViceCaptain: UIImageView!
    @IBOutlet weak var imgViewCaptain: UIImageView!
    @IBOutlet weak var lblAr: UILabel!
    @IBOutlet weak var lblBowl: UILabel!
    @IBOutlet weak var btnPreview: UIButton!
    
    @IBOutlet weak var viewForwards: UIView!
    @IBOutlet weak var lblPRP: UILabel!
    @IBOutlet weak var lblHKR: UILabel!
    @IBOutlet weak var lblLCK: UILabel!
    @IBOutlet weak var lblLSF: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var setData: Team? {
        didSet {
            guard let team = setData else { return }
            viewForwards.isHidden = true
            lblWk.text = "\(GDP.wkShort)(\(team.total_wicketkeeper ?? 0))"
            lblBat.text = "\(GDP.batShort)(\(team.total_batsman ?? 0))"
            lblAr.text = "\(GDP.arShort)(\(team.total_allrounder ?? 0))"
            lblBowl.text = "\(GDP.bowlShort)(\(team.total_bowler ?? 0))"
        }
    }

}

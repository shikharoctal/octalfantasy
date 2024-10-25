//
//  BoosterHistoryTVCell.swift
//  India’s fantasy
//
//  Created by admin on 27/04/23.
//

import UIKit

class BoosterHistoryTVCell: UITableViewCell {

    @IBOutlet weak var imgLocalTeam: UIImageView!
    @IBOutlet weak var lblLocalTeamShortName: UILabel!
    @IBOutlet weak var lblLocalTeamFullName: UILabel!
    @IBOutlet weak var imgVisitorTeam: UIImageView!
    @IBOutlet weak var lblVisitorTeamShortName: UILabel!
    @IBOutlet weak var lblVisitorTeamFullName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgBooster: UIImageView!
    
    var setData: BoosterHistoryData? {
        didSet {
            guard let match = setData else { return }
            
            imgLocalTeam.loadImage(urlS: match.localteamFlag, placeHolder: Constants.kNoImage)
            lblLocalTeamShortName.text = match.localteamShortName
            lblLocalTeamFullName.text = match.localteam
            
            imgVisitorTeam.loadImage(urlS: match.visitorteamFlag, placeHolder: Constants.kNoImage)
            lblVisitorTeamShortName.text = match.visitorteamShortName
            lblVisitorTeamFullName.text = match.visitorteam
            
            imgBooster.loadImage(urlS: match.boosterImageURL, placeHolder: Constants.kNoImage)
            let usedDate = CommonFunctions.getDateFromString(strDate: match.boosterHistory?[0].usedDate ?? "", currentFormat: "dd-MM-yyyy'T'HH:mm:ss", requiredFormat: "d MMM yyyy")
            lblDate.text = usedDate
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

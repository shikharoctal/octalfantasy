//
//  SeasonMatchCell.swift
//  India’s fantasy
//
//  Created by admin on 24/04/23.
//

import UIKit

class SeasonMatchCell: UITableViewCell {

    @IBOutlet weak var lblMatchName: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var imgTeam1: UIImageView!
    @IBOutlet weak var lblTeam1: UILabel!
    @IBOutlet weak var imgTeam2: UIImageView!
    @IBOutlet weak var lblTeam2: UILabel!
    
    var setData: Match? {
        didSet {
            
            guard let match = setData else { return }
            
            let matchDate = CommonFunctions.getDateFromString(strDate: match.match_date ?? "", currentFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", requiredFormat: "d, MMM yyyy")
            lblMatchName.text = matchDate//"Match \(match.matchNumber ?? 0)-\(matchDate)"
            lblSubtitle.text = match.venue
            
            imgTeam1.loadImage(urlS: match.localteam_flag, placeHolder: Constants.kNoImageUser)
            lblTeam1.text = match.localteam_short_name
            imgTeam2.loadImage(urlS: match.visitorteam_flag, placeHolder: Constants.kNoImageUser)
            lblTeam2.text = match.visitorteam_short_name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
}

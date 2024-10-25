//
//  FantasyStatsTVCell.swift
//  CrypTech
//
//  Created by New on 15/03/22.
//

import UIKit

class FantasyStatsTVCell: UITableViewCell {

    @IBOutlet weak var lblTeamName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPoints: UILabel!
    
    @IBOutlet weak var lblCredit: UILabel!
    
    var metchDetails:MatchDetails? {
        didSet {
            
            let str = metchDetails?.match ?? ""
            
            let arrStr = str.components(separatedBy: " ")
            
            if arrStr.count > 1{
                lblTeamName.text = (arrStr.first ?? "") + " vs " + (arrStr.last ?? "")
                

            }else{
                lblTeamName.text = metchDetails?.match ?? ""
            }
            
            lblPoints.text = "\(metchDetails?.player_points ?? 0)"
            lblCredit.text = "\(metchDetails?.player_credit ?? 0)"
            let finalDate = "\(metchDetails?.date ?? "")".UTCToLocal(incomingFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outGoingFormat: "MMM d, yyyy")
            lblDate.text = finalDate
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

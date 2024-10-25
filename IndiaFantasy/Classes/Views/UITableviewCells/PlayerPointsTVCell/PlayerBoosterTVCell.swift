//
//  PlayerBoosterTVCell.swift
//  India’s fantasy
//
//  Created by admin on 14/09/23.
//

import UIKit

class PlayerBoosterTVCell: UITableViewCell {

    @IBOutlet weak var lblBoosterTitle: UILabel!
    @IBOutlet weak var lblBoosterInfo: UILabel!
    @IBOutlet weak var lblTimeLeft: UILabel!
    
    var setData: Booster? {
        didSet {
            guard let booster = setData else { return }

            lblBoosterTitle.text = booster.title
            lblBoosterInfo.text = booster.description
            
            let usedDate = CommonFunctions.getDateFromString(strDate: booster.usedDate ?? "", currentFormat: "dd-MM-yyyy'T'HH:mm:ss", requiredFormat: "d MMM yyyy")
            lblTimeLeft.text = usedDate
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

//
//  BoostersHistoryTVCell.swift
//  India’s fantasy
//
//  Created by admin on 26/07/23.
//

import UIKit

class BoostersHistoryTVCell: UITableViewCell {

    @IBOutlet weak var imgBooster: UIImageView!
    @IBOutlet weak var lblBoosterName: UILabel!
    @IBOutlet weak var lblBoosterDetails: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblPoints: UILabel!
    @IBOutlet weak var lblLeagueName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblMatch: UILabel!
    @IBOutlet weak var lblTeam: UILabel!
    
    var setData: BoostersHistory? {
        didSet {
            guard let booster = setData else { return }
            
            imgBooster.loadImage(urlS: booster.boosterImage, placeHolder: Constants.kNoImage)
            
            lblBoosterName.text = booster.title
            lblBoosterDetails.text = booster.description
            lblType.text = (booster.categoryName == "Debuff") ? "Debuff" : "Booster"
            lblPoints.text = ""
            lblLeagueName.text = booster.leagueName
            lblMatch.text = booster.matchName
            lblTeam.text = booster.teamName
            
            let usedDate = CommonFunctions.getDateFromString(strDate: booster.usedDate ?? "", currentFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", requiredFormat: "dd MMM yyyy")
            lblDate.text = usedDate
            
            if let subcategory = booster.subCategoryName {
                switch subcategory.lowercased() {
                case "elite":
                    imgBooster.borderColor = .Color.eliteBooster.value
                    break
                case "legendary":
                    imgBooster.borderColor = .Color.legendaryBooster.value
                    break
                default:
                    imgBooster.borderColor = .Color.standardBooster.value
                    break
                }
            }
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()

    }

}

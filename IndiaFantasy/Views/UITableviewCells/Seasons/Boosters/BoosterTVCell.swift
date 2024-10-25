//
//  BoosterTVCell.swift
//  India’s fantasy
//
//  Created by admin on 25/04/23.
//

import UIKit
import SDWebImage

class BoosterTVCell: UITableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgBooster: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblExpiryDate: UILabel!
    @IBOutlet weak var imgSendGift: UIImageView!
    
    var setData: Booster? {
        didSet {
            guard let booster = setData else { return }
            
            lblTitle.text = booster.title
            lblDescription.text = booster.description
            imgBooster.loadImage(urlS: booster.boosterImage, placeHolder: Constants.kNoImage)
            lblDate.isHidden = true
          
            if (booster.isApplied ?? false) == true {
                viewContainer.isUserInteractionEnabled = false
                viewContainer.backgroundColor = .Color.boosterDisableColor.value
            }else {
                viewContainer.isUserInteractionEnabled = true
                viewContainer.backgroundColor = .Color.footerBackground.value
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
}

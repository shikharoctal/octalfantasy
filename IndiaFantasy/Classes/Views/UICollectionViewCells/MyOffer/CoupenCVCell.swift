//
//  CoupenCVCell.swift
//  KnockOut11
//
//  Created by Subhash Sharma on 16/09/22.
//

import UIKit

class CoupenCVCell: UICollectionViewCell {

    @IBOutlet weak var lblDiscountValue: UILabel!
    @IBOutlet weak var lblDiscountDescription: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgViewDiscount: UIImageView!
    @IBOutlet weak var lblExpireDate: UILabel!
    @IBOutlet weak var btnApplyCode: UIButton!
    @IBOutlet weak var lblCoupenCode: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

}

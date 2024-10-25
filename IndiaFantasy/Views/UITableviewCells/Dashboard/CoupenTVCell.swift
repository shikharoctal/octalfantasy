//
//  CoupenTVCell.swift
//  KnockOut11
//
//  Created by Subhash Sharma on 16/09/22.
//

import UIKit

class CoupenTVCell: UITableViewCell {
    
    @IBOutlet weak var lblDiscountValue: UILabel!
    @IBOutlet weak var lblDicountDescription: UILabel!
    @IBOutlet weak var lblReceivedDate: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imViewProfile: UIImageView!
    @IBOutlet weak var btnCopyCode: UIButton!
    @IBOutlet weak var lblCopyCode: UILabel!
    @IBOutlet weak var lblExpiryDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

   
}

//
//  RecentTransactionTVCell.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 14/03/22.
//

import UIKit

class RecentTransactionTVCell: UITableViewCell {

    @IBOutlet weak var amountWidth: NSLayoutConstraint! // 90
    @IBOutlet weak var iconWidth: NSLayoutConstraint! //70
    @IBOutlet weak var imgViewIcon: UIImageView!
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblDays: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

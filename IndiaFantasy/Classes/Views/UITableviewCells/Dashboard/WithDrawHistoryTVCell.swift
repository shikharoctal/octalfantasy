//
//  WithDrawHistoryTVCell.swift
//
//  Created by Octal-Mac on 22/11/22.
//

import UIKit

class WithDrawHistoryTVCell: UITableViewCell {

    @IBOutlet weak var lblRequestedAmount: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblWithdrawlFrom: UILabel!
    @IBOutlet weak var lblTransactionId: UILabel!
    @IBOutlet weak var lblStatus: OctalLabel!
    @IBOutlet weak var imgViewDebit: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

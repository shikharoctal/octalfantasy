//
//  WinnersListTVCell.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 22/03/22.
//

import UIKit

class WinnersListTVCell: UITableViewCell {

    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblPercantage: UILabel!
    @IBOutlet weak var lblWinners: UILabel!
    @IBOutlet weak var btnSelect: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

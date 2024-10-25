//
//  WinningsTVCell.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 10/03/22.
//

import UIKit

class WinningsTVCell: UITableViewCell {

    @IBOutlet weak var btnRank: UIButton!
    @IBOutlet weak var lblWinnings: UILabel!
    @IBOutlet weak var lblRank: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

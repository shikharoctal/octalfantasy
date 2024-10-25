//
//  PlayerPointsBreakupTVCell.swift
//  CrypTech
//
//  Created by New on 23/03/22.
//

import UIKit

class PlayerPointsBreakupTVCell: UITableViewCell {

    @IBOutlet weak var containerStkView: UIStackView!
    @IBOutlet weak var lblEvents: UILabel!
    @IBOutlet weak var lblActualValue: UILabel!
    @IBOutlet weak var lblPointsEarned: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

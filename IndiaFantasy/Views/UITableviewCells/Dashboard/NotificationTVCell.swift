//
//  NotificationTVCell.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 10/03/22.
//

import UIKit

class NotificationTVCell: UITableViewCell {

    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
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

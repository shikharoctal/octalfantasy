//
//  HowToPlayTVCell.swift
//
//  Created by Rahul Gahlot on 11/11/22.
//

import UIKit

class HowToPlayTVCell: UITableViewCell {

    @IBOutlet weak var viewBg: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgArrow: UIImageView!
    @IBOutlet weak var imgIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

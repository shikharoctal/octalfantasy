//
//  SideMenuTVCell.swift
//  GymPod
//
//  Created by Octal Mac 217 on 23/11/21.
//

import UIKit

class SideMenuTVCell: UITableViewCell {

    @IBOutlet weak var topViews: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgViewIcon: UIImageView!
    

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  SeasonsTVCell.swift
//  India’s fantasy
//
//  Created by admin on 17/04/23.
//

import UIKit

class SeasonsTVCell: UITableViewCell {

    @IBOutlet weak var bgImgViewSeason: UIImageView!
    @IBOutlet weak var imgViewSeason: UIImageView!
    @IBOutlet weak var lblTitleSeason: UILabel!
    //@IBOutlet weak var btnJoin: UIButton!
    @IBOutlet weak var lblJoin: UILabel!
    
    var setData: [String: Any]? {
        didSet {
            guard let season = setData else { return }
            bgImgViewSeason.image = UIImage(named: season["background"] as? String ?? "")
            imgViewSeason.image = UIImage(named: season["image"] as? String ?? "")
            lblTitleSeason.text = season["title"] as? String
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

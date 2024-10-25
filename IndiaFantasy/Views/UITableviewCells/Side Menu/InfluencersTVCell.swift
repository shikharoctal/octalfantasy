//
//  InfluencersTVCell.swift
//  IndiaFantasy
//
//  Created by Harendra Singh Rathore on 11/06/24.
//

import UIKit

class InfluencersTVCell: UITableViewCell {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblRank: UILabel!
    @IBOutlet weak var btnCode: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var setData: InfluencersInfo? {
        didSet {
            guard let influencer = setData else { return }
            
            lblName.text = influencer.name
            btnCode.setTitle("\((influencer.code ?? "").uppercased())  ", for: .normal)
            imgProfile.loadImage(urlS: influencer.image, placeHolder: Constants.kNoImageUser)
        }
    }
}

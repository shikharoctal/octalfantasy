//
//  ContestUserTVCell.swift
//  India’s fantasy
//
//  Created by admin on 13/07/23.
//

import UIKit

class ContestUserTVCell: UITableViewCell {

    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var viewTeamNumber: UIView!
    @IBOutlet weak var lblTeamNumber: UILabel!
    @IBOutlet weak var lblPoints: UILabel!
    @IBOutlet weak var lblRank: UILabel!
    
    var setData: ContestUser? {
        didSet {
            guard let user = setData else { return }
            imgUser.loadImage(urlS: user.userImage, placeHolder: Constants.kNoPlayer)
            lblUserName.text = user.username
            lblTeamNumber.text = "T" + "\(user.teamCount ?? 1)"
            lblPoints.text = ""
            lblRank.text = "#\((user.rank ?? 0).formattedNumber())"
        }
    }
    
    func selectUser(status: Bool) {
        self.backgroundColor = status ? .tabTitleColor : .clear
        viewTeamNumber.backgroundColor = status ? .tabTitleColor : .white
        lblUserName.textColor = status ? .white : .tabTitleColor
        viewTeamNumber.backgroundColor = status ? .white : .tabTitleColor
        lblTeamNumber.textColor = status ? .tabTitleColor : .white
        lblRank.textColor = status ? .white : .tabTitleColor
        lblPoints.textColor = status ? .white : .tabTitleColor
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

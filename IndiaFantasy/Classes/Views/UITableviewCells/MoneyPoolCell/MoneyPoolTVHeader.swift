//
//  MoneyPoolTVHeader.swift
//  IndiaFantasy
//
//  Created by Harendra Singh Rathore on 15/03/24.
//

import UIKit

class MoneyPoolTVHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var viewTeamImage: UIView!
    @IBOutlet weak var imgLocalTeam: UIImageView!
    @IBOutlet weak var imgVisitorTeam: UIImageView!
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var btnCollapse: UIButton!
    @IBOutlet weak var lblWinningAmount: UILabel!
    @IBOutlet weak var btnTap: UIButton!
    
    var setData: PoolQuestionResult? {
        didSet {
            guard let pool = setData else { return }
            
            imgLocalTeam.loadImage(urlS: pool.localteamFlag, placeHolder: Constants.kNoImageUser)
            imgVisitorTeam.loadImage(urlS: pool.visitorteamFlag, placeHolder: Constants.kNoImageUser)
            lblQuestion.text = pool.questionText ?? ""
            btnCollapse.isSelected = pool.isSelected
            
            //self.viewMain.layer.masksToBounds = true
            DispatchQueue.main.async {
                if pool.isSelected == false {
                    self.viewMain.roundCorners(corners: [.allCorners], radius: 12)
                }else {
                    self.viewMain.roundCorners(corners: [.topLeft, .topRight], radius: 12)
                }
            }
        }
    }
}

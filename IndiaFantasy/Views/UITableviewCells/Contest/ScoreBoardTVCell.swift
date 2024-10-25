//
//  ScoreBoardTVCell.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 05/05/22.
//

import UIKit

class ScoreBoardTVCell: UITableViewCell {

    @IBOutlet weak var lblSR: UILabel!
    @IBOutlet weak var lblSixes: UILabel!
    @IBOutlet weak var lblFours: UILabel!
    @IBOutlet weak var lblBalls: UILabel!
    @IBOutlet weak var lblRuns: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateColors(highlight:Bool){
        if highlight{
            self.lblTitle.textColor = UIColor.appGreenColor
            self.lblRuns.textColor = UIColor.appGreenColor
            self.lblBalls.textColor = UIColor.appGreenColor
            self.lblFours.textColor = UIColor.appGreenColor
            self.lblSixes.textColor = UIColor.appGreenColor
            self.lblSR.textColor = UIColor.appGreenColor
        }else{
            self.lblTitle.textColor = UIColor.white
            self.lblRuns.textColor = UIColor.white
            self.lblBalls.textColor = UIColor.white
            self.lblFours.textColor = UIColor.white
            self.lblSixes.textColor = UIColor.white
            self.lblSR.textColor = UIColor.white
        }
    }
}

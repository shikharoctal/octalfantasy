//
//  WinningsHeaderView.swift
//  GymPod
//
//  Created by Octal Mac 217 on 23/11/21.
//

import UIKit

class WinningsHeaderView: UIView {

    @IBOutlet weak var viewPrizePool: UIView!
    @IBOutlet weak var imgViewBanner: UIImageView!
    var controller:UIViewController? = nil
    var contestData:ContestData? = nil

    @IBOutlet weak var lblTitle: UILabel!
   
    @IBOutlet weak var lblEntry: UILabel!
    @IBOutlet weak var lblContestName: UILabel!
    @IBOutlet weak var viewPrize: UIView!
    @IBOutlet weak var lblPrizePool: UILabel!
    @IBOutlet weak var lblSpots: UILabel!
    @IBOutlet weak var lblRank: UILabel!
    @IBOutlet weak var lblWinnings: UILabel!
    
    var tipView = EasyTipHelper()
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "WinningsHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
      }
        
    func updateView(){
//        self.lblContestName.text = contestData?.name ?? ""
        self.lblContestName.text = "Prize"
        
        if self.contestData?.winning_amount ?? 0 == 0 {
            if let firstPrize = self.contestData?.price_breakup?.first(where: {$0.start_rank == 1}) {
                lblPrizePool.text = firstPrize.reward
            }else {
                if contestData?.created_by == "user" {
                    lblPrizePool.text = " Punishment "
                    viewPrize.backgroundColor = .appHighlightedTextColor
                    lblPrizePool.textColor = .black
                    lblPrizePool.font = .init(name: Constants.kSemiBoldFont, size: 14)
                    viewPrize.layer.cornerRadius = 5
                }
            }
            lblEntry.text =  "Free"
        }else {
            lblPrizePool.text = "\(GDP.globalCurrency)\(CommonFunctions.suffixNumberIndian(currency: self.contestData?.winning_amount ?? 0))"
            lblEntry.text =  "\(GDP.globalCurrency)\(self.contestData?.entry_fee ?? 0)"
        }
        
        lblSpots.text = "\(self.contestData?.users_limit ?? 0)"

    }
    
    @IBAction func btnPrizePoolPressed(_ sender: UIButton) {
        
        if self.contestData?.created_by == "user", let punishment = contestData?.loserPunishment {
            sender.isSelected = !sender.isSelected
            tipView.showEasyTip(sender: sender, onView: self.controller!.navigationController?.view ?? UIView(), withText: punishment)
        }
        
    }
    
}

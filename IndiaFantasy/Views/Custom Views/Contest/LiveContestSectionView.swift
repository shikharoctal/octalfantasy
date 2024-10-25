//
//  LiveContestSectionView.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 06/06/22.
//

import UIKit

class LiveContestSectionView: UIView {

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var viewContestName: UIView!
    @IBOutlet weak var lblContestTitle: UILabel!
    
    @IBOutlet weak var seasonLeagueView: UIView!
    @IBOutlet weak var viewContestInfo: UIView!
    @IBOutlet weak var lblMatchNumber: UILabel!
    @IBOutlet weak var lblContestName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblMatchCount: UILabel!
    @IBOutlet weak var lblPoints: UILabel!
    @IBOutlet weak var lblRank: UILabel!
    
    @IBOutlet weak var viewPrizePool: UIView!
    @IBOutlet weak var lblPrizePool: UILabel!
    @IBOutlet weak var lblTotalSpots: UILabel!
    @IBOutlet weak var lblEntry: UILabel!
    
    @IBOutlet weak var btnGuaranteeStatus: UIButton!
    @IBOutlet weak var btnTrophyPercantage: UIButton!
    @IBOutlet weak var btnRewardAmount: UIButton!
    @IBOutlet weak var btnMaxTeams: UIButton!

    @IBOutlet weak var lblContestNamr: UILabel!
    @IBOutlet weak var btnTap: UIButton!
    @IBOutlet weak var containerTopConstraint: NSLayoutConstraint!
    
    var contestData:ContestData? = nil
    
    var controller:UIViewController? =  nil
    var tipView = EasyTipHelper()
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "LiveContestSectionView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
      }
        
    var setLeagueData: LeagueJoinedContest? {
        didSet {
            guard let contest = setLeagueData else { return }
            seasonLeagueView.isHidden = false
            viewContestInfo.isHidden = false
            
            lblContestName.text = contest.data?.contestData?.name
            lblTime.text = " "
            
            if let totalMatches = contest.totalMatches {
                if totalMatches > 1 {
                    lblMatchCount.text = "\(totalMatches) matches"
                }else {
                    lblMatchCount.text = "\(totalMatches) match"
                }
            }
            
            lblPoints.text = "\((contest.totalPoints ?? 0).formattedNumber()) pts"
            
            let totalUsers = CommonFunctions.suffixNumber(number: Double(contest.data?.joined_teams_count ?? 0))
            lblRank.text = "#\((contest.rank ?? 0).formattedNumber())/\(totalUsers)"
        }
    }
    
    var setLeagueContestData: ContestData? {
        didSet {
            guard let contest = setLeagueContestData else { return }
            seasonLeagueView.isHidden = false
            viewContestInfo.isHidden = true
            
            lblContestName.text = contest.name
            lblTime.text = " "
            
            
            if let totalMatches = contest.matchNumber {
                if totalMatches > 1 {
                    lblMatchNumber.text = "\(totalMatches) matches"
                }else {
                    lblMatchNumber.text = "\(totalMatches) match"
                }
            }else {
                lblMatchNumber.text = "0 Match"
            }
            
            lblMatchCount.text = "-"
            lblPoints.text = "-"
            lblRank.text = "-"
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if ((parentViewController as? SeasonsContestVC) != nil) {
            self.containerTopConstraint.constant = 0
        }else {
            self.containerView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
        }
        
    }
    
    @IBAction func btnPrizePoolPressed(_ sender: UIButton) {
        if self.contestData?.created_by == "user", let punishment = contestData?.loserPunishment {
            sender.isSelected = !sender.isSelected
            tipView.showEasyTip(sender: sender, onView: self.controller!.navigationController?.view ?? UIView(), withText: punishment)
        }
    }
    
    @IBAction func btnToolTipPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        var str = "My easy Tip"
        if sender.titleLabel?.text == ConstantMessages.kGloryMessageShort{
            return
        }
        if sender.tag == 1{
            
            btnMaxTeams.isSelected = false
            btnTrophyPercantage.isSelected = false
            btnGuaranteeStatus.isSelected = false
            if self.contestData?.price_breakup?.count ?? 0 > 0
            {
                let strAmount = CommonFunctions.suffixNumberIndian(currency: (self.contestData?.price_breakup?[0].each_price ?? 0))
                if (self.contestData?.entry_fee ?? 0) > 0{
                    str = "First Prize = \(GDP.globalCurrency)\(strAmount)"
                }else{
                    guard let reward = contestData?.price_breakup?[0].reward else {
                        tipView.tipView.dismiss()
                        return
                    }
                    str = reward
                }
            }
        }else if sender.tag == 2{
            btnMaxTeams.isSelected = false
            btnRewardAmount.isSelected = false
            btnGuaranteeStatus.isSelected = false
            str = "\(self.contestData?.total_winners ?? 0) teams win in this contest"
        }else if sender.tag == 3{
            btnRewardAmount.isSelected = false
            btnTrophyPercantage.isSelected = false
            btnGuaranteeStatus.isSelected = false
            str = "Max \(self.contestData?.max_team_join_count ?? 0) entries allowed in this contest"
        }else if sender.tag == 4{
            btnMaxTeams.isSelected = false
            btnTrophyPercantage.isSelected = false
            btnRewardAmount.isSelected = false
            str = ConstantMessages.kGuaranteeMessage

        }
        
        tipView.showEasyTip(sender: sender, onView: self.controller!.navigationController?.view ?? UIView(), withText: str)
    }
    
}

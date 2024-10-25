//
//  MatchContestTVCell.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 07/03/22.
//

import UIKit

class MatchContestTVCell: UITableViewCell {

    @IBOutlet weak var btnShareFriends: UIButton!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var btnMultiTeam: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var btnGuaranteeStatus: UIButton!
    @IBOutlet weak var btnTrophyPercantage: UIButton!
    @IBOutlet weak var btnRewardAmount: UIButton!
    @IBOutlet weak var btnJoin: UIButton!
    @IBOutlet weak var lblTotalSpots: UILabel!
    @IBOutlet weak var lblLeftSpots: UILabel!
   // @IBOutlet weak var lblEntryFee: UILabel!
    @IBOutlet weak var viewPrize: UIView!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblContestNamr: UILabel!
    
    @IBOutlet weak var lblJoinedWith: UILabel!
    @IBOutlet weak var stckViewTeams: UIStackView!
    
    @IBOutlet weak var viewJoinedTeams: UIView!
    @IBOutlet weak var joinedTeamsHeight: NSLayoutConstraint!
    
    var controller:UIViewController? = nil
        
    var tipView = EasyTipHelper()

    var contestDataValue:ContestData? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func emptyStackView(){
        stckViewTeams.arrangedSubviews.forEach { view in
            stckViewTeams.removeArrangedSubview(view)
                    view.removeFromSuperview()
            }
    }
    func updateCell(contestDataValue:ContestData?){
        self.contestDataValue = contestDataValue
        self.viewContainer.layer.shadowOffset = CGSize(width: 0, height: 3)

//        if contestDataValue?.join_multiple_team ?? false == true{
//            self.btnMultiTeam.isHidden = false
//
//        }else{
//            self.btnMultiTeam.isHidden = true
//        }
        
        if (contestDataValue?.max_team_join_count ?? 0) == 1{
            self.btnMultiTeam.setTitle("Max 1 Team", for: .normal)
        }else{
            self.btnMultiTeam.setTitle("Max \(contestDataValue?.max_team_join_count ?? 0) Teams", for: .normal)
        }
        
        self.lblContestNamr.text = contestDataValue?.name ?? ""
        
        viewPrize.backgroundColor = .clear
        lblAmount.textColor = .white
        lblAmount.font = .init(name: Constants.kSemiBoldFont, size: 16)
        viewPrize.layer.cornerRadius = 0
        lblAmount.text = ""
        
        if self.contestDataValue?.winning_amount ?? 0 == 0 {
            if let firstPrize = self.contestDataValue?.price_breakup?.first(where: {$0.start_rank == 1}) {
                lblAmount.text = firstPrize.reward
            }else {
                if contestDataValue?.created_by == "user" {
                    lblAmount.text = " Punishment "
                    viewPrize.backgroundColor = .appHighlightedTextColor
                    lblAmount.textColor = .black
                    lblAmount.font = .init(name: Constants.kSemiBoldFont, size: 14)
                    viewPrize.layer.cornerRadius = 5
                }
            }
        }else {
            let amount = CommonFunctions.suffixNumberIndian(currency: (contestDataValue?.winning_amount ?? 0))
            self.lblAmount.text = "\(GDP.globalCurrency)\(amount)"
        }
        
        self.btnJoin.backgroundColor = .clear
        self.btnJoin.setTitleColor(.appHighlightedTextColor, for: .normal)
        self.btnJoin.isUserInteractionEnabled = false
        
        if contestDataValue?.entry_fee ?? 0 <= 0 {
            self.btnJoin.setTitle("Free", for: .normal)
        }else {
            let strAmount = CommonFunctions.suffixNumberIndian(currency: (contestDataValue?.entry_fee ?? 0))
            self.btnJoin.setTitle("\(GDP.globalCurrency)\(strAmount)", for: .normal)
        }
        
       // cellMatch.lblEntryFee.text = "₹\(contestDataValue?.entry_fee ?? 0)"
        
        let spotLeft = Int(contestDataValue?.users_limit ?? 0) - (contestDataValue?.joined_teams_count ?? 0)
        
        self.progressBar.progress = Float(contestDataValue?.joined_teams_count ?? 0)/Float(contestDataValue?.users_limit ?? 0)
        
        if spotLeft < 2
        {
            if spotLeft == 0{
                lblLeftSpots.text = "Contest Full"
            }else{
                lblLeftSpots.text = "\(spotLeft.formattedNumber()) spot left"
            }
        }
        else
        {
            self.lblLeftSpots.text = "\(spotLeft.formattedNumber()) spots left"
        }
        
        self.lblTotalSpots.text = "\((contestDataValue?.users_limit ?? 0).formattedNumber()) spots"
        
        let firstWinnerPrize = Double(contestDataValue?.total_winners ?? 0)/Double(contestDataValue?.users_limit ?? 0)
        
        if Double(firstWinnerPrize * 100).rounded(toPlaces: 2).isInteger
        {
            self.btnTrophyPercantage.setTitle("\(Int(firstWinnerPrize * 100))%", for: .normal)
        }
        else
        {
            self.btnTrophyPercantage.setTitle("\(Double(firstWinnerPrize * 100).rounded(toPlaces: 2))%", for: .normal)
        }
        
        if contestDataValue?.price_breakup?.count ?? 0 > 0
        {
            let strAmount = CommonFunctions.suffixNumberIndian(currency: (contestDataValue?.price_breakup?[0].each_price ?? 0))
            if (contestDataValue?.entry_fee ?? 0) > 0{
                self.btnRewardAmount.setTitle("\(GDP.globalCurrency)\(strAmount)", for: .normal)
                self.btnTrophyPercantage.isHidden = false
            }else{
                
                let prize = lblAmount.text ?? ""
                self.btnRewardAmount.setTitle(prize == "" ? "" : prize, for: .normal)
                self.btnTrophyPercantage.isHidden = true
            }
        }else {
            self.btnRewardAmount.setTitle("", for: .normal)
            self.btnTrophyPercantage.isHidden = true
        }
        
        

        if contestDataValue?.confirm_winning == true{
            self.btnGuaranteeStatus.isHidden = false
        }else{
            self.btnGuaranteeStatus.isHidden = true
        }
        
        if (contestDataValue?.created_by?.lowercased() ?? "") == "admin"{
            self.btnShareFriends.isHidden = true
        }else{
            self.btnShareFriends.isHidden = false
        }
    }
    
    func updateJoinedTeams(teams:[JoinedTeam]?, controller:UIViewController){
        self.emptyStackView()

        if let teams = teams {
            teams.forEach { team in
                let categoryView = InfoStackCategory()
                categoryView.team = team
                categoryView.controller = self.controller
                categoryView.btnTeamName.setTitle("T\(team.team_count ?? 0)", for: .normal)
                self.stckViewTeams.addArrangedSubview(categoryView)
            }
        }
    }
    
    @IBAction func btnPrizeToolTipPressed(_ sender: UIButton) {
        if contestDataValue?.created_by == "user", let punishment = contestDataValue?.loserPunishment {
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
            btnMultiTeam.isSelected = false
            btnTrophyPercantage.isSelected = false
            btnGuaranteeStatus.isSelected = false
            if contestDataValue?.price_breakup?.count ?? 0 > 0
            {
                let strAmount = CommonFunctions.suffixNumberIndian(currency: (contestDataValue?.price_breakup?[0].each_price ?? 0))
                if (contestDataValue?.entry_fee ?? 0) > 0{
                    str = "First Prize = \(GDP.globalCurrency)\(strAmount)"
                }else{
                    //str = ConstantMessages.kGloryMessage
                    guard let reward = contestDataValue?.price_breakup?[0].reward else {
                        tipView.tipView.dismiss()
                        return
                    }
                    str = reward
                }
            }
            //return
        }else if sender.tag == 2{
            btnMultiTeam.isSelected = false
            btnRewardAmount.isSelected = false
            btnGuaranteeStatus.isSelected = false
            str = "\(contestDataValue?.total_winners ?? 0) teams win in this contest"
        }else if sender.tag == 3{
            btnRewardAmount.isSelected = false
            btnTrophyPercantage.isSelected = false
            btnGuaranteeStatus.isSelected = false
            str = "Max \(contestDataValue?.max_team_join_count ?? 0) entries allowed in this contest"
        }else if sender.tag == 4{
            btnMultiTeam.isSelected = false
            btnTrophyPercantage.isSelected = false
            btnRewardAmount.isSelected = false
            str = ConstantMessages.kGuaranteeMessage

        }
        
        tipView.showEasyTip(sender: sender, onView: self.controller!.navigationController?.view ?? UIView(), withText: str)
    }
    
    
}

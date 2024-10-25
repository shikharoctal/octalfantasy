//
//  SeasonHomeHeaderView.swift
//  India’s fantasy
//
//  Created by admin on 25/04/23.
//

import UIKit

class SeasonHomeHeaderView: UIView {

    @IBOutlet weak var imgHeader: UIImageView!
    @IBOutlet weak var viewPointsBoard: UIView!
    @IBOutlet weak var viewTitleHeader: UIView!
    @IBOutlet weak var btnInfo: UIButton!
    @IBOutlet weak var lblTitleHeader: UILabel!
    @IBOutlet weak var lblPoins: UILabel!
    @IBOutlet weak var lblTransfers: UILabel!
    @IBOutlet weak var lblBoosters: UILabel!
    
    @IBOutlet weak var btnPoints: UIButton!
    @IBOutlet weak var btnTransfers: UIButton!
    @IBOutlet weak var btnBoosters: UIButton!
    @IBOutlet weak var lblInstruction: UILabel!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "SeasonHomeHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

    var setData: LeagueDetails? {
        didSet {
            
            guard let league = setData else { return }
            
//            lblTitleHeader.text = "Welecome, \(Constants.kAppDelegate.user?.username ?? "")"
//            lblPoins.text = league.totalPoints?.clean
//            if league.isMatchPlayed == false {
//                lblTransfers.text = "Unlimited"
//            }else {
//                if GDP.leagueType == "fun" {
//                    lblTransfers.text = "Unlimited"
//                }else {
//                    lblTransfers.text = league.availableTransfer?.clean
//                }
//
//            }
//            lblBoosters.text = league.availableboosterCount?.clean ?? "-"
            lblInstruction.text = "Welcome to the \(GDP.leagueName). Click on the \"Create Team\" button below to create a team from this league, and then click on the \"Contest\" button below to join the available contests"
            imgHeader.loadImage(urlS: league.bannerImage, placeHolder: Constants.kNoImagePromo)
        }
    }
    
    func setupUI() {
        viewTitleHeader.layer.cornerRadius = 14
        viewTitleHeader.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}

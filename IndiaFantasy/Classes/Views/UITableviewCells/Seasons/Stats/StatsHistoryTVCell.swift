//
//  StatsHistoryTVCell.swift
//  India’s fantasy
//
//  Created by admin on 27/04/23.
//

import UIKit

class StatsHistoryTVCell: UITableViewCell {

    @IBOutlet weak var viewMatchName: UIView!
    @IBOutlet weak var lblMatchName: UILabel!
    
    @IBOutlet weak var viewMatchDetails: UIView!
    @IBOutlet weak var imgLocalTeam: UIImageView!
    @IBOutlet weak var lblLocalTeamShort: UILabel!
    @IBOutlet weak var lblLocalTeamFull: UILabel!
    @IBOutlet weak var imgVisitorTeam: UIImageView!
    @IBOutlet weak var lblVisitorTeamShort: UILabel!
    @IBOutlet weak var lblVisitorTeamFull: UILabel!
    
    @IBOutlet weak var lblPoints: UILabel!
    @IBOutlet weak var lblPointType: UILabel!
    
    var isTypePoints = true
    
    var setData: LeagueStatsMatch? {
        didSet {
            guard let match = setData else { return }
            
            lblPointType.text = isTypePoints ? "Points" : "Transfers"
            
            let matchDate = CommonFunctions.getDateFromString(strDate: match.matchDate ?? "", currentFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", requiredFormat: "dd MMM yyyy")
            lblMatchName.text = "Match \(match.matchNumber ?? "0")- \(matchDate)"
            
            lblLocalTeamShort.text = match.localteamShortName
            lblLocalTeamFull.text = match.localteam
            imgLocalTeam.loadImage(urlS: match.localteamFlag, placeHolder: Constants.kNoImageUser)
            
            lblVisitorTeamShort.text = match.visitorteamShortName
            lblVisitorTeamFull.text = match.visitorteam
            imgVisitorTeam.loadImage(urlS: match.visitorteamFlag, placeHolder: Constants.kNoImageUser)
            
            if isTypePoints {
                lblPoints.text = match.totalPoint?.formattedNumber()
            }else {
                lblPoints.text = match.playerTransferList?.formattedNumber()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewMatchName.cornerRadius = 10
        viewMatchName.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        viewMatchDetails.cornerRadius = 10
        viewMatchDetails.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
}

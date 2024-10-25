//
//  FantasyStatsTVHeader.swift
//  KnockOut11
//
//  Created by admin on 20/10/22.
//

import UIKit

class FantasyStatsTVHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var viewHeaderTitle: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var lblTeamName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPoints: UILabel!
    @IBOutlet weak var btnDropDown: UIButton!
    @IBOutlet weak var lblSel: UILabel!
    
    @IBOutlet weak var viewBottomHeader: UIView!
    @IBOutlet weak var lblCredit: UILabel!
    
    var metchDetails:MatchDetails? {
        didSet {
            let str = metchDetails?.match ?? ""
            
            let arrStr = str.components(separatedBy: " ")
            
            if arrStr.count > 1{
                lblTeamName.text = (arrStr.first ?? "") + " vs " + (arrStr.last ?? "")
                

            }else{
                lblTeamName.text = "vs " + (metchDetails?.match ?? "")
            }
            lblSel.text = "\(metchDetails?.selection_percent ?? "0")"
            lblPoints.text = "\(metchDetails?.player_points ?? 0)"
            lblCredit.text = "\(metchDetails?.player_credit ?? 0)"
            let finalDate = "\(metchDetails?.date ?? "")".UTCToLocal(incomingFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outGoingFormat: "MMM d, yyyy")
            lblDate.text = finalDate
            
            if let playerBreckup = metchDetails?.playerBreckup, !playerBreckup.isEmpty {
                if metchDetails?.isPlayerBreckupShow == true {
                    viewBottomHeader.isHidden = false
                    btnDropDown.isSelected = true
                }else {
                    viewBottomHeader.isHidden = true
                    btnDropDown.isSelected = false
                }
                btnDropDown.isHidden = false
            }else {
                viewBottomHeader.isHidden = true
                btnDropDown.isHidden = true
            }
            
            if btnDropDown.isSelected {
                containerView.cornerRadius = 10
                containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else {
                containerView.cornerRadius = 10
            }
        }
    }
    
    func updateView(){
//        self.containerView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
    }
}

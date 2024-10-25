//
//  MoneyPoolJoinedTVCell.swift
//  IndiaFantasy
//
//  Created by Harendra Singh Rathore on 15/03/24.
//

import UIKit

class MoneyPoolJoinedTVCell: UITableViewCell {

    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewAnswer: UIView!
    @IBOutlet weak var lblAnswer: UILabel!
    @IBOutlet weak var lblResult: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var setFirstRow: PoolQuestionResult? {
        didSet {
            guard let pool = setFirstRow else { return }
            lblTitle.text = "Your Option"
            lblResult.isHidden = true
            viewAnswer.isHidden = false
            switch pool.winningData?.yourOption {
            case "optionA": lblAnswer.text = pool.optionA ?? ""
            case "optionB": lblAnswer.text = pool.optionB ?? ""
            case "optionC": lblAnswer.text = pool.optionC ?? ""
            case "optionD": lblAnswer.text = pool.optionD ?? ""
            default: lblAnswer.text = pool.isCancelled == 1 ? "Cancelled": "Not Joined"
            }
        
            
//            if pool.winningData == nil {
//                self.viewMain.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 12)
//            }else {
//                self.viewMain.layer.cornerRadius = 0
//            }
        }
    }
    
    func setData(row: Int, data: PoolQuestionResult?) {
        
        viewAnswer.isHidden = true
        lblResult.isHidden = true
        lblResult.textColor = .white
        
        DispatchQueue.main.async {
            self.viewMain.roundCorners(corners: .allCorners, radius: 0)
        }
        
        guard let pool = data else { return }
        
        switch row {
        case 0:
            setFirstRow = pool
        case 1:
            lblTitle.text = "Result"
            lblResult.isHidden = false
            lblResult.text = pool.winningData?.matchResult ?? ""
            lblResult.textColor = .appYellowColor
        case 2:
            lblTitle.text = "Your Invt Money"
            lblResult.isHidden = false
            lblResult.text = Constants.KCurrency + (pool.winningData?.entryFee?.cleanValue ?? "0")
        case 3:
            lblTitle.text = "Total Winning Amount"
            lblResult.isHidden = false
            lblResult.text = Constants.KCurrency + (pool.winningData?.winngsAmount?.cleanValue ?? "0")
            DispatchQueue.main.async {
                self.viewMain.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 12)
            }
        default: break
        }
    }
}

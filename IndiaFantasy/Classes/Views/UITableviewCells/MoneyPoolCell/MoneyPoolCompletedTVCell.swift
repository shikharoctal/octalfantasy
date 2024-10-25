//
//  MoneyPoolCompletedTVCell.swift
//  IndiaFantasy
//
//  Created by Harendra Singh Rathore on 11/04/24.
//

import UIKit
import Lottie

class MoneyPoolCompletedTVCell: UITableViewCell {

    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var viewTeamImage: UIView!
    @IBOutlet weak var imgLocalTeam: UIImageView!
    @IBOutlet weak var imgVisitorTeam: UIImageView!
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var btnCollapse: UIButton!
    @IBOutlet weak var lblWinningAmount: UILabel!
    @IBOutlet weak var btnTap: UIButton!
    
    @IBOutlet weak var viewDetails: UIView!
    @IBOutlet weak var lblYourOption: UILabel!
    @IBOutlet weak var lblResult: UILabel!
    @IBOutlet weak var lblInvtMoney: UILabel!
    @IBOutlet weak var lblTotalWinningAmount: UILabel!
    
    var refreshCell: (()-> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnTap.addTarget(self, action: #selector(btnCollapsePressed(_:)), for: .touchUpInside)
    }
    
    var setData: PoolQuestionResult? {
        didSet {
            guard let pool = setData else { return }
            
            imgLocalTeam.loadImage(urlS: pool.localteamFlag, placeHolder: Constants.kNoImageUser)
            imgVisitorTeam.loadImage(urlS: pool.visitorteamFlag, placeHolder: Constants.kNoImageUser)
            lblQuestion.text = pool.questionText ?? ""
            lblWinningAmount.text = (pool.isCancelled == 1) ? "Cancelled" : "Winning Amount \(Constants.KCurrency)\(pool.winningData?.winngsAmount?.cleanValue ?? "0")"
            
            btnCollapse.isSelected = pool.isSelected
            viewDetails.isHidden = !pool.isSelected
            
            //self.viewMain.layer.masksToBounds = true
            DispatchQueue.main.async {
                if pool.isSelected == false {
                    self.viewHeader.roundCorners(corners: [.allCorners], radius: 12)
                }else {
                    self.viewHeader.roundCorners(corners: [.topLeft, .topRight], radius: 12)
                }
                self.viewDetails.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 12)
            }
          
            //Your Option
            switch pool.winningData?.yourOption {
            case "optionA": lblYourOption.text = pool.optionA ?? ""
            case "optionB": lblYourOption.text = pool.optionB ?? ""
            case "optionC": lblYourOption.text = pool.optionC ?? ""
            case "optionD": lblYourOption.text = pool.optionD ?? ""
            default: lblYourOption.text = "Not Joined" //pool.isCancelled == 1 ? "Cancelled": "Not Joined"
            }
            
            lblResult.text = pool.winningData?.matchResult ?? ""
            lblInvtMoney.text = Constants.KCurrency + (pool.winningData?.entryFee?.cleanValue ?? "0")
            lblTotalWinningAmount.text = Constants.KCurrency + (pool.winningData?.winngsAmount?.cleanValue ?? "0")
        }
    }
    
    @objc func btnCollapsePressed(_ sender: UIButton) {
        refreshCell?()
    }
    
    func showAnimationView() {

        DispatchQueue.main.async() {
           
            var animationView = LottieAnimationView()
            animationView.isHidden = false
            animationView = .init(name: "congrats")
            animationView.frame = self.viewDetails.bounds
            animationView.contentMode = .scaleAspectFill
            animationView.loopMode = .playOnce
            animationView.animationSpeed = 0.8
            animationView.isUserInteractionEnabled = false
            self.viewDetails.addSubview(animationView)
            animationView.play { (finished) in
                animationView.stop()
                animationView.isHidden = true
                animationView.removeFromSuperview()
            }
        }
    }
}

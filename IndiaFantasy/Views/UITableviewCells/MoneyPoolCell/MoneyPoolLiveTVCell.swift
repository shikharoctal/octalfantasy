//
//  MoneyPoolLiveTVCell.swift
//  IndiaFantasy
//
//  Created by Harendra Singh Rathore on 15/03/24.
//

import UIKit

protocol PoolTimeExpiredDelegate: AnyObject {
    func poolEventExpired(indexPath: IndexPath, id: String)
}

class MoneyPoolLiveTVCell: UITableViewCell {

    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var viewTeamImage: UIView!
    @IBOutlet weak var imgLocalTeam: UIImageView!
    @IBOutlet weak var imgVisitorTeam: UIImageView!
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    @IBOutlet weak var btnTie: UIButton!
    @IBOutlet weak var lblYesPercentage: UILabel!
    @IBOutlet weak var lblNoPercentage: UILabel!
    @IBOutlet weak var lblTiePercentage: UILabel!
    @IBOutlet weak var lblInvtMoney: UILabel!
    
    var countDownTimer: CountDown?
    var currentIndex: IndexPath?
    
    weak var delegate: PoolTimeExpiredDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        lblTimer.superview?.isHidden = true
        btnYes.titleLabel?.textAlignment = .center
        btnNo.titleLabel?.textAlignment = .center
        btnTie.titleLabel?.textAlignment = .center
        
        btnYes.titleLabel?.numberOfLines = 0
        btnNo.titleLabel?.numberOfLines = 0
        btnTie.titleLabel?.numberOfLines = 0

        self.lblTimer.superview?.roundCorners(corners: [.layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 10)
        
        countDownTimer?.reset()
        countDownTimer = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        countDownTimer?.reset()
        countDownTimer = nil
    }
    
    var setData: PoolQuestionResult? {
        didSet {
            guard let pool = setData else { return }
            
            imgLocalTeam.loadImage(urlS: pool.localteamFlag, placeHolder: Constants.kNoImageUser)
            imgVisitorTeam.loadImage(urlS: pool.visitorteamFlag, placeHolder: Constants.kNoImageUser)
            lblQuestion.text = pool.questionText ?? ""
            
            btnYes.isHidden = true
            btnNo.isHidden = true
            btnTie.isHidden = true
            
            lblYesPercentage.isHidden = true
            lblNoPercentage.isHidden = true
            lblTiePercentage.isHidden = true
            
            if let optionA = pool.optionA, !optionA.isEmpty {
                btnYes.setTitle(optionA, for: .normal)
                btnYes.isHidden = false
                lblYesPercentage.text = (pool.optionAPercentage?.cleanValue ?? "0") + "%"
                lblYesPercentage.isHidden = false
            }
            
            if let optionB = pool.optionB, !optionB.isEmpty {
                btnNo.setTitle(optionB, for: .normal)
                btnNo.isHidden = false
                lblNoPercentage.text = (pool.optionBPercentage?.cleanValue ?? "0") + "%"
                lblNoPercentage.isHidden = false
            }
        
            if let optionC = pool.optionC, !optionC.isEmpty {
                btnTie.setTitle(optionC, for: .normal)
                lblTiePercentage.text = (pool.optionCPercentage?.cleanValue ?? "0") + "%"
                btnTie.isHidden = false
                lblTiePercentage.isHidden = false
            }
            
            lblInvtMoney.superview?.isHidden = true
            
            btnYes.alpha = 1
            btnNo.alpha = 1
            btnTie.alpha = 1
            
            startTimer(expireTime: pool.expireTime)
            lblTimer.superview?.isHidden = false
        }
    }
    
    var setJoinedData: PoolQuestionResult? {
        didSet {
            guard let pool = setJoinedData else { return }
            lblTimer.superview?.isHidden = true
            
            imgLocalTeam.loadImage(urlS: pool.localteamFlag, placeHolder: Constants.kNoImageUser)
            imgVisitorTeam.loadImage(urlS: pool.visitorteamFlag, placeHolder: Constants.kNoImageUser)
            lblQuestion.text = pool.questionText ?? ""
            
            btnYes.setTitle(pool.optionA ?? "", for: .normal)
            btnNo.setTitle(pool.optionB ?? "", for: .normal)
        
            if let optionC = pool.optionC, !optionC.isEmpty {
                btnTie.setTitle(pool.optionC, for: .normal)
                lblTiePercentage.text = (pool.optionCPercentage?.cleanValue ?? "0") + "%"
                btnTie.isHidden = false
                lblTiePercentage.isHidden = false
            }else {
                btnTie.isHidden = true
                lblTiePercentage.isHidden = true
            }
            
            lblYesPercentage.text = (pool.optionAPercentage?.cleanValue ?? "0") + "%"
            lblNoPercentage.text = (pool.optionBPercentage?.cleanValue ?? "0") + "%"
            
            lblInvtMoney.superview?.isHidden = false
            lblInvtMoney.text = "You have invested \(Constants.KCurrency)\(pool.investedFee?.cleanValue ?? "0")"
            
            btnYes.alpha = 0.4
            btnNo.alpha = 0.4
            btnTie.alpha = 0.4
            
            switch pool.option {
            case "optionA": btnYes.alpha = 1
            case "optionB": btnNo.alpha = 1
            case "optionC": btnTie.alpha = 1
            default: break
            }
        }
    }
}

//MARK: - Timer Functionality
extension MoneyPoolLiveTVCell {
    
    func startTimer(expireTime: Int?) {
        
        guard let expireTime = expireTime else { return }
        
        let timestamp = TimeInterval(expireTime) / 1000 // Convert milliseconds to seconds
        let date = Date(timeIntervalSince1970: timestamp)

        countDownTimer = CountDownTimer(endsOn: date, repeatingTask: countDownTimerRepeatingTask, completion: countDownTimerCompletion)
        countDownTimer?.start()
    }
    
    private var countDownTimerRepeatingTask: CompletionHandler? {
        let handler: CompletionHandler = { [weak self] in
            guard let `self` = self,
                  let countDownTimer = self.countDownTimer
            else {return}
            
            DispatchQueue.main.async {
                self.lblTimer.text = countDownTimer.timeLeft
            }
        }
        return handler
    }
    
    private var countDownTimerCompletion: CompletionHandler? {
        let handler: CompletionHandler = { [weak self] in
            guard let `self` = self else {return}
            guard let currentIndex = self.currentIndex else { return }
            delegate?.poolEventExpired(indexPath: currentIndex, id:setData?.id ?? "")
        }
        return handler
    }
}

//
//  PerceptionTVCell.swift
//  IndiaFantasy
//
//  Created by Harendra Singh Rathore on 03/04/24.
//

import UIKit

class PerceptionTVCell: UITableViewCell {

    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var btnOptionA: UIButton!
    @IBOutlet weak var btnOptionB: UIButton!
    @IBOutlet weak var btnOptionC: UIButton!
    @IBOutlet weak var btnOptionD: UIButton!
    @IBOutlet weak var lblInvtMoney: UILabel!
    
    var countDownTimer: CountDown?
    var currentIndex: IndexPath?
    
    weak var delegate: PoolTimeExpiredDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
            lblInvtMoney.isHidden = true
            setupData(pool: pool)
            lblTimer.superview?.isHidden = false
        }
    }
    
    var setJoinedData: PoolQuestionResult? {
        didSet {
            guard let pool = setJoinedData else { return }
            setupData(pool: pool)
            lblTimer.superview?.isHidden = true
            
            switch pool.option {
            case "optionA":
                btnOptionA.backgroundColor = .appGreenTextColor
                btnOptionA.isSelected = true
            case "optionB":
                btnOptionB.backgroundColor = .appGreenTextColor
                btnOptionB.isSelected = true
            case "optionC":
                btnOptionC.backgroundColor = .appGreenTextColor
                btnOptionC.isSelected = true
            case "optionD":
                btnOptionD.backgroundColor = .appGreenTextColor
                btnOptionD.isSelected = true
            default: break
            }
            
            lblInvtMoney.isHidden = false
            lblInvtMoney.text = "You have invested \(Constants.KCurrency)\(pool.investedFee?.cleanValue ?? "0")"
        }
    }
    
    func setupData(pool: PoolQuestionResult) {
        
        btnOptionA.isHidden = true
        btnOptionB.isHidden = true
        btnOptionC.isHidden = true
        btnOptionD.isHidden = true
        
        btnOptionA.backgroundColor = .white
        btnOptionB.backgroundColor = .white
        btnOptionC.backgroundColor = .white
        btnOptionD.backgroundColor = .white
        
        btnOptionA.isSelected = false
        btnOptionB.isSelected = false
        btnOptionC.isSelected = false
        btnOptionD.isSelected = false
        
        lblQuestion.text = pool.questionText ?? ""
        
        if let optionA = pool.optionA, !optionA.isEmpty {
            btnOptionA.setTitle(optionA, for: .normal)
            btnOptionA.isHidden = false
        }
        
        if let optionB = pool.optionB, !optionB.isEmpty {
            btnOptionB.setTitle(optionB, for: .normal)
            btnOptionB.isHidden = false
        }
    
        if let optionC = pool.optionC, !optionC.isEmpty {
            btnOptionC.setTitle(optionC, for: .normal)
            btnOptionC.isHidden = false
        }
        
        if let optionD = pool.optionD, !optionD.isEmpty {
            btnOptionD.setTitle(optionD, for: .normal)
            btnOptionD.isHidden = false
        }
        
        startTimer(expireTime: pool.expireTime)
    }
    
}

//MARK: - Timer Functionality
extension PerceptionTVCell {
    
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
            delegate?.poolEventExpired(indexPath: currentIndex, id: setData?.id ?? "")
        }
        return handler
    }
}

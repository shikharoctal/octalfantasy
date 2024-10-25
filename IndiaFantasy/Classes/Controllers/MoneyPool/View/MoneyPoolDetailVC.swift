//
//  MoneyPoolDetailVC.swift
//  IndiaFantasy
//
//  Created by Harendra Singh Rathore on 15/03/24.
//

import UIKit

class MoneyPoolDetailVC: UIViewController {

    @IBOutlet weak var navigationView: CustomNavigation!
    
    @IBOutlet weak var viewLiveEvent: UIView!
    @IBOutlet weak var viewPerception: UIView!
 
    @IBOutlet weak var viewTeamImage: UIView!
    @IBOutlet weak var imgLocalTeam: UIImageView!
    @IBOutlet weak var imgVisitorTeam: UIImageView!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var btnOptionA: UIButton!
    @IBOutlet weak var btnOptionB: UIButton!
    @IBOutlet weak var btnOptionC: UIButton!
    
    @IBOutlet weak var lblPerTimer: UILabel!
    @IBOutlet weak var lblPerQuestion: UILabel!
    @IBOutlet weak var btnPerOptionA: UIButton!
    @IBOutlet weak var btnPerOptionB: UIButton!
    @IBOutlet weak var btnPerOptionC: UIButton!
    @IBOutlet weak var btnPerOptionD: UIButton!
    
    @IBOutlet weak var viewQuantity: UIView!
    @IBOutlet weak var tfQuantity: UITextField!
    
    @IBOutlet weak var lblYesPercentage: UILabel!
    @IBOutlet weak var lblNoPercentage: UILabel!
    @IBOutlet weak var lblTiePercentage: UILabel!
    
    @IBOutlet weak var viewQuickSelect: UIView!
    @IBOutlet weak var btn10: UIButton!
    @IBOutlet weak var btn20: UIButton!
    @IBOutlet weak var btn50: UIButton!
    @IBOutlet weak var btn100: UIButton!
    @IBOutlet weak var btn500: UIButton!
    @IBOutlet weak var btn1000: UIButton!
    
    @IBOutlet weak var lblYouPut: UILabel!
    @IBOutlet weak var lblYouGet: UILabel!
    
    @IBOutlet weak var lblBalance: UILabel!
    @IBOutlet weak var lblUsableBonus: UILabel!
    @IBOutlet weak var lblSlotFee: UILabel!
    @IBOutlet weak var btnConfirm: UIButton!
    
    private let runner = DelayedRunner.initWithDuration(seconds: 0.5)
    
    var type: PoolType = .liveEvent
    var category = ""
    var questionData: PoolQuestionResult?
    var selectedAnswer = ""
    var totalWalletBalance: Double = 0
    var countDownTimer: CountDown?
    
    var completionJoin: (()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationView()
        setupData()
    }
    
    override func viewDidLayoutSubviews() {
        switch type {
        case .liveEvent:
            self.lblTimer.superview?.roundCorners(corners: [.layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 10)
        case .perception:
            self.lblPerTimer.superview?.roundCorners(corners: [.layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 10)
        }
    }

    private func setupNavigationView() {
        
        navigationView.configureNavigationBarWithController(controller: self, title: "Money Pool", hideNotification: true, hideAddMoney: true, hideBackBtn: false)
        navigationView.sideMenuBtnView.isHidden = true
        navigationView.avatar.isHidden = true
    }
    
    private func setupData() {
        guard let pool = questionData else { return }
        
        switch type {
        case .liveEvent:
            
            viewTeamImage.isHidden = !(category == "Cricket")
            tfQuantity.addTarget(self, action: #selector(textEditingChanged(_:)), for: .editingChanged)
            
            viewLiveEvent.isHidden = false
            viewQuantity.isHidden = false
            viewQuickSelect.isHidden = false
            viewPerception.isHidden = true
            
            imgLocalTeam.loadImage(urlS: pool.localteamFlag, placeHolder: Constants.kNoImageUser)
            imgVisitorTeam.loadImage(urlS: pool.visitorteamFlag, placeHolder: Constants.kNoImageUser)
            lblQuestion.text = pool.questionText ?? ""
            
            btnOptionA.setTitle(pool.optionA ?? "", for: .normal)
            btnOptionB.setTitle(pool.optionB ?? "", for: .normal)
            lblYesPercentage.text = (pool.optionAPercentage?.cleanValue ?? "0") + "%"
            lblNoPercentage.text = (pool.optionBPercentage?.cleanValue ?? "0") + "%"
            
            if let optionC = pool.optionC, !optionC.isEmpty {
                btnOptionC.setTitle(pool.optionC, for: .normal)
                lblTiePercentage.text = (pool.optionCPercentage?.cleanValue ?? "0") + "%"
                btnOptionC.isHidden = false
                lblTiePercentage.isHidden = false
            }else {
                btnOptionC.isHidden = true
                lblTiePercentage.isHidden = true
            }
            
            self.lblBalance.text = Constants.KCurrency + "0"
            self.lblSlotFee.text = Constants.KCurrency + "0"
            
            btnQuickSelectActions(btn10)
            
            btnOptionA.alpha = 0.4
            btnOptionB.alpha = 0.4
            btnOptionC.alpha = 0.4
            
            switch selectedAnswer {
            case "optionA": btnOptionA.alpha = 1
            case "optionB": btnOptionB.alpha = 1
            case "optionC": btnOptionC.alpha = 1
            default: break
            }
            
        case .perception:
            
            viewLiveEvent.isHidden = true
            viewQuantity.isHidden = true
            viewQuickSelect.isHidden = true
            viewPerception.isHidden = false
            
            btnPerOptionA.isHidden = true
            btnPerOptionB.isHidden = true
            btnPerOptionC.isHidden = true
            btnPerOptionD.isHidden = true
            
            lblPerQuestion.text = pool.questionText ?? ""
            
            if let optionA = pool.optionA, !optionA.isEmpty {
                btnPerOptionA.setTitle(optionA, for: .normal)
                btnPerOptionA.isHidden = false
            }
            
            if let optionB = pool.optionB, !optionB.isEmpty {
                btnPerOptionB.setTitle(optionB, for: .normal)
                btnPerOptionB.isHidden = false
            }
        
            if let optionC = pool.optionC, !optionC.isEmpty {
                btnPerOptionC.setTitle(optionC, for: .normal)
                btnPerOptionC.isHidden = false
            }
            
            if let optionD = pool.optionD, !optionD.isEmpty {
                btnPerOptionD.setTitle(optionD, for: .normal)
                btnPerOptionD.isHidden = false
            }
            
            switch selectedAnswer {
            case "optionA": btnPerceptionOptionsActions(btnPerOptionA)
            case "optionB": btnPerceptionOptionsActions(btnPerOptionB)
            case "optionC": btnPerceptionOptionsActions(btnPerOptionC)
            case "optionD": btnPerceptionOptionsActions(btnPerOptionD)
            default: break
            }
            
            validateWalletRequest()
        }
        
        self.startTimer(expireTime: pool.expireTime)
    }
    
    @objc func textEditingChanged(_ sender: UITextField) {
   
        unSelectQuickOptions()
        
        switch sender.text {
        case "10":  btn10.backgroundColor = .appLightBlueColor
        case "20":  btn20.backgroundColor = .appLightBlueColor
        case "50":  btn50.backgroundColor = .appLightBlueColor
        case "100": btn100.backgroundColor = .appLightBlueColor
        case "500": btn500.backgroundColor = .appLightBlueColor
        case "1000": btn1000.backgroundColor = .appLightBlueColor
        default: break
        }
        
        guard let quantity = sender.text, !quantity.isEmptyOrWhitespace else {
            return
        }
        
        runner.run {
            self.validateWalletRequest()
        }
    }
    
    @IBAction func btnConfirmAction(_ sender: UIButton) {
        
        WebCommunication.shared.getUserProfile(hostController: self, showLoader: false) { user in
            if let user = user{
                if (user.state ?? "") == "" || (user.dob ?? "") == ""{
                    let VC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "DOBStateViewController") as! DOBStateViewController
                    VC.completionHandler = { (success) in
                        if success == true{
                            self.validatePoolRequest()
                        }
                    }
                    UIApplication.getTopMostViewController()?.present(VC, animated: true, completion: nil)
                }
                else{
                    self.validatePoolRequest()
                }
            }
        }
    }
    
    func validatePoolRequest() {
        guard validateQuantity() else { return }
        
        let enteryFee = lblSlotFee.text ?? "0"
        let message = "Wallet Balance: \((Constants.KCurrency + (totalWalletBalance.cleanValue)))\nSlot Fee: \(enteryFee)"
        alertBoxWithAction(message: message, btn1Title: ConstantMessages.CancelBtn, btn2Title: ConstantMessages.ConfirmBtn) {
            self.joinPoolRequest()
        }
    }
    
    @IBAction func btnQuickSelectActions(_ sender: UIButton) {
        
        unSelectQuickOptions()
        
        sender.backgroundColor = .appLightBlueColor
        
        switch sender {
        case btn10: tfQuantity.text = "10"
        case btn20: tfQuantity.text = "20"
        case btn50: tfQuantity.text = "50"
        case btn100: tfQuantity.text = "100"
        case btn500: tfQuantity.text = "500"
        case btn1000: tfQuantity.text = "1000"
        default: break
        }
        
        validateWalletRequest()
    }
    
    private func unSelectQuickOptions() {
        btn10.backgroundColor = .white
        btn20.backgroundColor = .white
        btn50.backgroundColor = .white
        btn100.backgroundColor = .white
        btn500.backgroundColor = .white
        btn1000.backgroundColor = .white
    }
    
    @IBAction func btnOptionsSelectActions(_ sender: UIButton) {
            
        btnOptionA.alpha = 0.4
        btnOptionB.alpha = 0.4
        btnOptionC.alpha = 0.4
        
        switch sender {
        case btnOptionA:
            btnOptionA.alpha = 1
            selectedAnswer = "optionA"
        case btnOptionB:
            btnOptionB.alpha = 1
            selectedAnswer = "optionB"
        case btnOptionC:
            btnOptionC.alpha = 1
            selectedAnswer = "optionC"
        default: break
        }
    }
    
    @IBAction func btnPerceptionOptionsActions(_ sender: UIButton) {
            
        btnPerOptionA.backgroundColor = .white
        btnPerOptionB.backgroundColor = .white
        btnPerOptionC.backgroundColor = .white
        btnPerOptionD.backgroundColor = .white
        
        btnPerOptionA.isSelected = false
        btnPerOptionB.isSelected = false
        btnPerOptionC.isSelected = false
        btnPerOptionD.isSelected = false
        
        sender.isSelected = true
        sender.backgroundColor = .appGreenTextColor
        
        switch sender {
        case btnPerOptionA:
            selectedAnswer = "optionA"
        case btnPerOptionB:
            selectedAnswer = "optionB"
        case btnPerOptionC:
            selectedAnswer = "optionC"
        case btnPerOptionD:
            selectedAnswer = "optionD"
        default: break
        }
    }
}

extension MoneyPoolDetailVC {
    
    func validateWalletRequest() {
        
        btnConfirm.isUserInteractionEnabled = false
        guard let pool = questionData else { return }
        let entryFee = type == .liveEvent ?  (tfQuantity.text ?? "0") : (pool.entryFee?.cleanValue ?? "0")
        
        let request: [String: Any] = ["match_id": pool.matchID ?? 0,
                                      "series_id": pool.seriesID ?? 0,
                                      "contest_id":"pool",
                                      "entry_fees": entryFee,
                                      "league_type": "money_pool",
                                      "question_id": pool.id ?? 0,]
        
        WebCommunication.shared.validateWallet(request: request, showLoader: false) { data, status, msg in
            guard let walletData = data else { return }
            
            let entryFee = walletData.entryFee?.rounded(toPlaces: 2) ?? 0
            let usableBonus = walletData.usableBonus?.rounded(toPlaces: 2) ?? 0
            let totalBalance = ((walletData.cashBalance?.rounded(toPlaces: 2) ?? 0) + (walletData.winningBalance?.rounded(toPlaces: 2) ?? 0)).rounded(toPlaces: 2)
            
            self.totalWalletBalance = totalBalance
            
            DispatchQueue.main.async {
                self.lblBalance.text = (Constants.KCurrency + (totalBalance.cleanValue))
                if usableBonus > 0 {
                    self.lblUsableBonus.text = "-" + (Constants.KCurrency + (usableBonus.cleanValue))
                }else {
                    self.lblUsableBonus.text = (Constants.KCurrency + (usableBonus.cleanValue))
                }
                self.lblSlotFee.text = (Constants.KCurrency + (entryFee - usableBonus).rounded(toPlaces: 2).cleanValue)
            }
            
            self.btnConfirm.isUserInteractionEnabled = true
            if status == false {
                AppManager.showToast(msg, view: self.view)
            }
        }
    }
    
    func joinPoolRequest() {
        
        //let amount = (lblSlotFee.text ?? "0").replacingOccurrences(of: Constants.KCurrency, with: "")
        guard let pool = questionData else { return }
        let entryFee = type == .liveEvent ?  (tfQuantity.text ?? "0") : (pool.entryFee?.clean ?? "0")
        
        let request: [String: Any] = ["match_id": pool.matchID ?? 0,
                                      "question_id": pool.id ?? 0,
                                      "series_id": pool.seriesID ?? 0,
                                      "amount": entryFee,
                                      "option": selectedAnswer]
        
        WebCommunication.shared.joinPoolRequest(request: request) { status, msg in
            guard status == true else { return }
            self.completionJoin?()
            self.alertBoxWithAction(message: msg, btnTitle: ConstantMessages.OkBtn) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func validateQuantity() -> Bool {
        
        guard !selectedAnswer.isEmpty else {
            Constants.kAppDelegate.showAlert(msg: ConstantMessages.kSelectYourAnswer, isLogout: false, isLocationAlert: false)
            return false
        }
        
        switch type {
        case .liveEvent:
            guard let quantity =  tfQuantity.text, !quantity.isEmptyOrWhitespace else {
                Constants.kAppDelegate.showAlert(msg: ConstantMessages.kEmptyQuantityError, isLogout: false, isLocationAlert: false)
                return false
            }
            
            guard (Double(quantity) ?? 0) > 0 else {
                Constants.kAppDelegate.showAlert(msg: ConstantMessages.kQuantityZeroError, isLogout: false, isLocationAlert: false)
                return false
            }
            
            guard (Double(quantity) ?? 0) <= 100000 else {
                Constants.kAppDelegate.showAlert(msg: ConstantMessages.kQuantityLimitError, isLogout: false, isLocationAlert: false)
                return false
            }

        case .perception:
            break
        }
        
        guard totalWalletBalance >= Double(lblSlotFee.text ?? "0") ?? 0 else {
            let remainingBalance = (Double(lblSlotFee.text ?? "0") ?? 0) - totalWalletBalance
            
            alertBoxWithAction(message: ConstantMessages.kLowWalletBalanceError, btn1Title: ConstantMessages.CancelBtn, btn2Title: ConstantMessages.OkBtn) {
                
                let vc = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "AddCashViewController") as! AddCashViewController
                vc.requiredCash = ceil(remainingBalance*100)/100
                vc.completionHandler = { (balance) in
                    print(balance)
                    self.validateWalletRequest()
                }
                self.navigationController?.pushViewController(vc, animated: false)
            }
            return false
        }
        return true
    }
}

//MARK: - Timer Functionality
extension MoneyPoolDetailVC {
    
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
            
            switch type {
            case .liveEvent:
                DispatchQueue.main.async {
                    self.lblTimer.text = countDownTimer.timeLeft
                }
            case .perception:
                DispatchQueue.main.async {
                    self.lblPerTimer.text = countDownTimer.timeLeft
                }
            }
            
           
        }
        return handler
    }
    
    private var countDownTimerCompletion: CompletionHandler? {
        let handler: CompletionHandler = { [weak self] in
            guard let `self` = self else {return}
            self.alertBoxWithAction(message: ConstantMessages.kPoolExpired, btnTitle: ConstantMessages.OkBtn) {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        return handler
    }
}

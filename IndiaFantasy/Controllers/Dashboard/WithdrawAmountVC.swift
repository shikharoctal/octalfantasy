//
//  WithdrawAmountVC.swift
//  CrypTech
//
//  Created by New on 16/03/22.
//

import UIKit
import MaterialComponents

class WithdrawAmountVC: BaseClassWithoutTabNavigation {

    @IBOutlet weak var lblWithdrawlHistory: UILabel!
    @IBOutlet weak var lblWinningAmount: UILabel!
    @IBOutlet weak var txtFAmount: MDCOutlinedTextField!

//    @IBOutlet weak var btnUpdatePan: UIButton!
//    @IBOutlet weak var btnUpdateBank: UIButton!

    @IBOutlet weak var navigationView: CustomNavigation!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewTopContant: UIView!

    var arrTransactions:[WithDrawHistoryModel]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblWinningAmount.text = "\(Constants.kAppDelegate.user?.winngs_amount?.rounded(toPlaces: 2) ?? 0)"
        navigationView.configureNavigationBarWithController(controller: self, title: "Withdraw Amount", hideNotification: false, hideAddMoney: true, hideBackBtn: false)
      
        self.txtFAmount.label.text = "Withdraw Amount"
        self.txtFAmount.setNormalLabelColor(.darkGray, for: .normal)

        [self.txtFAmount].forEach({$0?.setOutlineColor(UIColor.appTextFieldBorder, for: .normal)})
        [self.txtFAmount].forEach({$0?.setOutlineColor(UIColor.appTextFieldBorder, for: .editing)})
        
        txtFAmount.setFloatingLabelColor(.white, for: .normal)
        txtFAmount.setTextColor(.white, for: .normal)
        txtFAmount.setNormalLabelColor(.gray, for: .normal)
        
        txtFAmount.setFloatingLabelColor(.white, for: .editing)
        txtFAmount.setTextColor(.white, for: .editing)
        txtFAmount.setNormalLabelColor(.gray, for: .editing)

        self.loadWithDrawHistory()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        WebCommunication.shared.getUserProfile(hostController: self, showLoader: false) { user in
            self.lblWinningAmount.text = "\(Constants.kAppDelegate.user?.winngs_amount?.rounded(toPlaces: 2) ?? 0)"
            WebCommunication.shared.getCommonDetails(hostController: self, showLoader: false) { user in
                if GlobalDataPersistance.shared.pan_verified == 3{
                    //self.btnUpdatePan.setTitle("View Pan Details", for: .normal)
                }
                if GlobalDataPersistance.shared.bank_verified == 3{
                   // self.btnUpdateBank.setTitle("View Bank Details", for: .normal)
                }
            }
        }
    }
    
    @IBAction func btnWithDrawPressed(_ sender: Any) {
        if LocationManager.sharedInstance.isPLayingInLegalState() == false{
            return
        }
        
        if self.txtFAmount.text?.count == 0
        {
            AppManager.showToast(ConstantMessages.Amount_Empty_Withdraw, view: (self.view)!)
            return
        }
        if (Int(txtFAmount.text ?? "0") ?? 0) > 0
        {
            WebCommunication.shared.getUserProfile(hostController: self, showLoader: true) { user in
                if (user?.kyc_verified ?? false) == true{
                    self.submitValidData()
                }else{
                    if (Constants.kAppDelegate.user?.email ?? "") == ""{
                        let alert = UIAlertController(title: Constants.kAppDisplayName, message: ConstantMessages.UPDATE_PROFILE_KYC, preferredStyle:.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            let pushVC = Constants.KHelpStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                            self.navigationController?.pushViewController(pushVC, animated: true)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        let alert = UIAlertController(title: Constants.kAppDisplayName, message: ConstantMessages.VERIFY_KYC, preferredStyle:.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "VerificationOptionsVC") as! VerificationOptionsVC
                            self.navigationController?.pushViewController(pushVC, animated: true)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        else
        {
            AppManager.showToast(ConstantMessages.VALID_AMOUNT, view: (self.view)!)
            return
        }
        

    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension WithdrawAmountVC{
    func submitValidData(){
        self.view.endEditing(true)
        let winningAmount = Constants.kAppDelegate.user?.winngs_amount ?? 0
        
        if winningAmount == 0{
            AppManager.showToast(ConstantMessages.ENOUGH_AMOUNT, view: (self.view)!)
            return
        }
        if self.txtFAmount.text?.count == 0
        {
            AppManager.showToast(ConstantMessages.Amount_Empty_Withdraw, view: (self.view)!)
            return
        }
        
        if LocationManager.sharedInstance.isPLayingInLegalState() == false{
            return
        }
        
        if (Int(txtFAmount.text ?? "0") ?? 0) > 0
        {
            let winningAmount = Constants.kAppDelegate.user?.winngs_amount ?? 0
            if winningAmount > (Double((txtFAmount.text ?? "0")) ?? 0){
                self.sendWithDrawRequest()
            }else{
                AppManager.showToast(ConstantMessages.ENOUGH_AMOUNT, view: (self.view)!)
            }
        }
        else
        {
            AppManager.showToast(ConstantMessages.VALID_AMOUNT, view: (self.view)!)
        }
    }
    
    func verifyUserEmail(){
        let params:[String:Any] = ["email":Constants.kAppDelegate.user?.email ?? ""]
                                    

        let url = URLMethods.BaseURL + URLMethods.verifyEmail

        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                let alert = UIAlertController(title: Constants.kAppDisplayName, message: msg, preferredStyle:.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    self.navigationController?.popViewController(animated: true)
                }))
                
                self.present(alert, animated: true, completion: nil)

            }
            
            else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
            AppManager.stopActivityIndicator(self.view)
        }
        
        AppManager.startActivityIndicator(sender: self.view)
       
    }
    
    func sendWithDrawRequest(){
        
        let params:[String:Any] = ["request_amount":txtFAmount.text ?? ""]
                                    

        let url = URLMethods.BaseURL + URLMethods.sendWithDrawRequest

        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                
                let VC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "WithdrawStatusViewController") as! WithdrawStatusViewController
                    VC.modalPresentationStyle = .overFullScreen
                VC.msg = "\(GDP.globalCurrency)\(self.txtFAmount.text ?? "") Withdraw request successfully submitted will be reflected in 2-3 working days."
                VC.completionHandler = { success in
                    if success == true{
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
                DispatchQueue.main.async {
                    self.present(VC, animated: true)
                }

            }
            
            else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
            AppManager.stopActivityIndicator(self.view)
        }
        
        AppManager.startActivityIndicator(sender: self.view)

    }
    
    
    func loadWithDrawHistory (){
        let params: [String:String] = ["page":"1",
                                       "itemsPerPage":"1000"
                                        ]
            let url = URLMethods.BaseURL + URLMethods.getWithdrawlHistory
            
            ApiClient.init().getRequest(method: url, parameters: params, view: (self.view)!) { result in
                if result != nil {
                    let status = result?.object(forKey: "success") as? Bool ?? false
                    let msg = result?.object(forKey: "message") as? String ?? ""
                    if status == true{
                        if let docs = result?.object(forKey: "results") as? [String:Any]{
                            if let data = docs["docs"] as? [[String:Any]]{
                                guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                                      let tblData = try? JSONDecoder().decode([WithDrawHistoryModel].self, from: jsonData)else {return }
                                self.arrTransactions = tblData
                                self.tableView.reloadData()
                            }
                            else{
                                AppManager.showToast(msg, view: (self.view)!)
                            }
                        }
                        
                    }else{
                        AppManager.showToast(msg, view: (self.view)!)
                    }
                   
                }else{
                    AppManager.showToast("", view: (self.view)!)
                }
                
                if self.arrTransactions?.count ?? 0 > 0{
                    self.lblWithdrawlHistory.text = "Withdrawal History"
                }else{
                    self.lblWithdrawlHistory.text = "No withdrawal transactions found!"
                }
                AppManager.stopActivityIndicator((self.view)!)
            }
            AppManager.startActivityIndicator(sender: (self.view)!)
    }
}
// MARK: - UITableViewDelegate / UITableViewDataSource
extension WithdrawAmountVC: UITableViewDataSource,UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTransactions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WithDrawHistoryTVCell", for: indexPath) as! WithDrawHistoryTVCell
        
        cell.selectionStyle = .none

        if let model = self.arrTransactions?[indexPath.row]{
            cell.lblWithdrawlFrom.text = model.userID?.fullName ?? ""
            cell.lblTransactionId.text = "Transaction ID: \(model.id ?? "")"
            cell.lblRequestedAmount.text = "-\(GDP.globalCurrency)\(model.requestedAmount?.rounded(toPlaces: 2) ?? 0)"
            
            let finalDate = "\(model.createdAt ?? "")".UTCToLocal(incomingFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outGoingFormat: "MMM d, yyyy h:mm a")
            cell.lblDate.text = finalDate
            
            if (model.status?.capitalized ?? "") == "Pending"{
                cell.lblStatus.textColor = .appYellowColor
            }else if (model.status?.capitalized ?? "") == "Declined"{
                cell.lblStatus.textColor = .appRedBackgroundColor
            }else{
                cell.lblStatus.textColor = .appFilterTitleColor
            }
            cell.lblStatus.text = model.status?.capitalized ?? ""
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

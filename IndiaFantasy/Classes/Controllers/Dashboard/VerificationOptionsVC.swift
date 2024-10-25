//
//  ContestOptionsVC.swift
//  CrypTech
//
//  Created by New on 16/03/22.
//

import UIKit
import KeychainAccess

class VerificationOptionsVC: BaseClassWithoutTabNavigation {
//    var arrItems = CommonFunctions.getItemFromInternalResourcesforKey(key: "KYC")
    @IBOutlet weak var tableView: UITableView!
    
    var arrItems : [KYCItem] = []
    
    @IBOutlet weak var navigationView: CustomNavigation!

    struct KYCItem {
        var title : String
        var subTitle : String
        var status : String
        var iocn : String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationView.configureNavigationBarWithController(controller: self, title: "Verify KYC", hideNotification: false, hideAddMoney: true, hideBackBtn: false)
    }
    override func viewDidAppear(_ animated: Bool) {
        setUI()
    }
    
    func setUI(){
        self.arrItems.removeAll()
        WebCommunication.shared.getUserProfile(hostController: self, showLoader: false) { user in
            if let user = user {
                self.arrItems.append(KYCItem(title: "Aadhar Verification", subTitle: "Takes less than 2 mins!", status: self.getKycVerificationStatus(user: user), iocn: "iconkyc"))
                self.arrItems.append(KYCItem(title: "Pan Card", subTitle: "For safety and security of all transactions.", status: self.getPanVerificationStatus(user: user), iocn: "iocncredit-card-fill"))
                self.arrItems.append(KYCItem(title: "Bank Account", subTitle: "For Quick withdrawals to your bank account.", status: self.getBankVerificationStatus(user: user), iocn: "iconbank"))
                self.tableView.reloadData()
            }
        }
    }
    
    func getPhoneVerificationStatus(user:UserDataModel) -> String{
        
        var str = "Verify"
        
        if user.otpverified == true{
            str = "Verified"
        }
        
        return str
    }
    
    func getEmailVerificationStatus(user:UserDataModel) -> String{
        
        var str = "Verify"
        
        if user.emailverified == true{
            str = "Verified"
        }
        
        return str
    }
    
    func getPanVerificationStatus(user:UserDataModel) -> String{
        
        var str = "Verify"
        
        if user.pan_verified == 0 || user.pan_verified == 2{
            str = "Verify"
        }
        if user.pan_verified == 1{
            str = "In Review"
        }
        if user.pan_verified == 3{
            str = "Verified"
        }
        return str
    }
    
    func getBankVerificationStatus(user:UserDataModel) -> String{
        
        var str = "Verify"
        
        if user.bank_verified == 0 || user.bank_verified == 2{
            str = "Verify"
        }
        if user.bank_verified == 1{
            str = "In Review"
        }
        if user.bank_verified == 3{
            str = "Verified"
        }
        return str
    }
    
    func getKycVerificationStatus(user:UserDataModel) -> String{
        
        var str = "Verify"
        
        if user.is_aadhar_verified == true{
            str = "Verified"
        }
        return str
    }
    
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}


//MARK: UITableView (DataSource & Delegate) Methods
extension VerificationOptionsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "KYCTVCell", for: indexPath) as! KYCTVCell
        
        let dict = arrItems[indexPath.row]
      
        cell.viewStatus.backgroundColor = UIColor.clear

        DispatchQueue.main.async {

            cell.lblTitle.text = dict.title
            cell.lblSubTitle.text = dict.subTitle
            cell.lblStatus.text = dict.status
            cell.imgViewIcon.image = UIImage(named: dict.iocn)
            
            if dict.status == "Verify"{
                cell.viewStatus.borderWidth = 1
                cell.viewStatus.borderColor = UIColor.lightGray
                cell.lblStatus.textColor = UIColor.darkGray

            }else if dict.status == "Verified"{
                cell.viewStatus.borderWidth = 1
                cell.lblStatus.textColor = UIColor.appThemeColor
                cell.viewStatus.borderColor = UIColor.appThemeColor

            }
            else if dict.status == "In Review"{
                cell.viewStatus.borderWidth = 1
                cell.viewStatus.borderColor = UIColor.appGreenColor
                cell.lblStatus.textColor = UIColor.appGreenColor
            }
            tableView.beginUpdates()
            tableView.setNeedsDisplay()
            tableView.endUpdates()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            if (Constants.kAppDelegate.user?.is_aadhar_verified ?? false) == false{
                self.verifyKYCFor(option: "OFFLINE_AADHAAR_VERIFICATION")
            }
            break
        case 1:
            if (Constants.kAppDelegate.user?.pan_verified ?? 0) != 3{
                self.verifyKYCFor(option: "PANDETAILS_VERIFICATION")
            }
            break
        case 2:
            if (Constants.kAppDelegate.user?.bank_verified ?? 0) != 3{
                self.verifyKYCFor(option: "BANKDETAILS_VALIDATION")
            }
            break
       
        default:
            break
        }
    }
}
extension VerificationOptionsVC{
    
    func verifyKYCFor(option:String){
        guard let user = Constants.kAppDelegate.user else { return }

        guard let fullName = user.full_name, !fullName.isEmptyOrWhitespace else {
            self.alertBoxWithAction(message: ConstantMessages.UPDATE_PROFILE_Message, btn1Title: ConstantMessages.CancelBtn, btn2Title: ConstantMessages.UPDATE_PROFILE) {
                let pushVC = Constants.KHelpStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                self.navigationController?.pushViewController(pushVC, animated: true)
            }
            return
        }
        if option == "OFFLINE_AADHAAR_VERIFICATION"{
            let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "SendAadharOTPVC") as! SendAadharOTPVC
            self.navigationController?.pushViewController(pushVC, animated: true)
        }
        else if option == "PANDETAILS_VERIFICATION"{
            let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "PanCardVerificationVC") as! PanCardVerificationVC
            self.navigationController?.pushViewController(pushVC, animated: true)
        }
        else if option == "BANKDETAILS_VALIDATION"{
            let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "BankVerificationVC") as! BankVerificationVC
            self.navigationController?.pushViewController(pushVC, animated: true)
        }
    }
}

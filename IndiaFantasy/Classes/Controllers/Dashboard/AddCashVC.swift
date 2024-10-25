//
//  AddCashViewController.swift
//
//  Created by Rahul Gahlot on 02/11/22.
//

import UIKit
import MaterialComponents

class AddCashCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var imgCheck: UIImageView!

    @IBOutlet weak var lblAdd: UILabel!
    @IBOutlet weak var lblAddPrice: UILabel!
}

class AddCashViewController: BaseClassWithoutTabNavigation {
 
    var tipView = EasyTipHelper()
    let cf = CFHelper()
    
    @IBOutlet weak var lblDisclaimer: UILabel!
    @IBOutlet weak var lblAppliedCoupon: UILabel!
    @IBOutlet weak var offerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewOffer: UIView!
    @IBOutlet weak var lblBonus: UILabel!
    @IBOutlet weak var lblExtraCash: UILabel!
    @IBOutlet weak var clPackView: UICollectionView!
    @IBOutlet weak var coupenColView: UICollectionView!
    @IBOutlet weak var navigationView: CustomNavigation!
    
    @IBOutlet weak var txtCustomeAmount: MDCOutlinedTextField!
    @IBOutlet weak var txtCouponAmount: MDCOutlinedTextField!
    @IBOutlet weak var lblCashBalance: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnApplyCode: UIButton!
    @IBOutlet weak var lblDiscountDescription: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var viewActiveOffers: UIView!
    
   
    @IBOutlet weak var lblAmountWithTax: UILabel!
    @IBOutlet weak var lblTaxPercent: UILabel!
    @IBOutlet weak var lblTaxAmount: UILabel!
    @IBOutlet weak var lblGST: UILabel!
    @IBOutlet weak var lblTaxBonus: UILabel!
    @IBOutlet weak var lblTaxDeductedAmount: UILabel!
    
    var completionHandler : ((Double) -> Void)?
    var arrCoupens = [CoupenResult]()

    private var selectPackage = -1 // Index
    var paymentReady = ""

    var orderId = ""
    var orderAmount = ""
    let notifyUrl = ""
    
    var isFromCoupanCode = false
    var coupanDetails:CouponDetails? = nil
    
    var addBalance : Double = 0.0
    
    var couponCode = ""
    
    var requiredCash:Double = 0
    
    var discountAmount:Double = 0.0
    var discountInPercent = Bool()
    var minAmount = Double()
    var maxDiscount = Double()
    var flatDiscount = Double()
    var finalDiscount = Double()
    var discountValue = Double()
    var currentBalance = Double()
    var coupenType = String()

    struct PackageItem {
        var addAmount : String
        var getAmount : String
    }
    
    var allPackages : [PackageItem] = []
    var completion: ((_ paymentStatus: Bool) -> Void)?
    var currency = "₹"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationView.configureNavigationBarWithController(controller: self, title: "Add Cash", hideNotification: true, hideAddMoney: true, hideBackBtn: false)

        txtCustomeAmount.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneButtonClicked))
        [self.txtCustomeAmount, self.txtCouponAmount].forEach( {$0.setFloatingLabelColor(.white, for: .normal)} )
        [self.txtCustomeAmount, self.txtCouponAmount].forEach( {$0.setTextColor(.white, for: .normal)} )
        [self.txtCustomeAmount, self.txtCouponAmount].forEach( {$0.setNormalLabelColor(.gray, for: .normal)} )
        [self.txtCustomeAmount, self.txtCouponAmount].forEach( {$0.setFloatingLabelColor(.white, for: .editing)} )
        [self.txtCustomeAmount, self.txtCouponAmount].forEach( {$0.setTextColor(.white, for: .editing)} )
        [self.txtCustomeAmount, self.txtCouponAmount].forEach( {$0.setNormalLabelColor(.gray, for: .editing)} )
        
        txtCustomeAmount.addTarget(self, action: #selector(textSearchChanged(_:)), for: .editingChanged)
        
        self.offerViewHeight.constant = 0
        self.lblDisclaimer.text = ConstantMessages.kDisclaimerText

        WebCommunication.shared.getCommonDetails(hostController: self, showLoader: true) { user in
            self.setUiData()
            
            if self.couponCode != ""{
                self.txtCouponAmount.text = self.couponCode
                self.btnApplyPressed(self.btnApplyCode)
            }
        }
    }
    
    //MARK: - Search Field Text Changed
    @objc func textSearchChanged(_ sender: UITextField) {
    
        if let amount = sender.text, amount != "" {
            self.btnAdd.setTitle("Add \(amount)", for: .normal)
        }else {
            self.btnAdd.setTitle("Add Money", for: .normal)
        }
       
    }
    
    @objc func doneButtonClicked(_ sender: Any) {
        self.lblCashBalance.text = "\(GDP.globalCurrency)\(txtCustomeAmount.text ?? "0")"
    }
    
    func setUiData(){
        
        allPackages.append(PackageItem(addAmount: "10", getAmount: "10"))
        allPackages.append(PackageItem(addAmount: "50", getAmount: "50"))
        allPackages.append(PackageItem(addAmount: "500", getAmount: "500"))
        allPackages.append(PackageItem(addAmount: "1000", getAmount: "1000"))

        getCoupons()
        
        self.coupenColView.register(UINib(nibName: "CoupenCVCell", bundle: nil), forCellWithReuseIdentifier: "CoupenCVCell")

        clPackView.delegate = self
        clPackView.dataSource = self
        
        coupenColView.delegate = self
        coupenColView.dataSource = self
        
        coupenColView.reloadData()
        clPackView.reloadData()
        
        self.txtCustomeAmount.label.text = "Enter Custom Amount"
        self.txtCustomeAmount.placeholder = "Enter Custom Amount"
        self.txtCouponAmount.label.text = "Enter Coupon Code"
        self.txtCouponAmount.setNormalLabelColor(.darkGray, for: .normal)
        self.txtCustomeAmount.setNormalLabelColor(.darkGray, for: .normal)
    
        [self.txtCustomeAmount, self.txtCouponAmount].forEach({$0?.setOutlineColor(UIColor.appTextFieldBorder, for: .normal)})
        [self.txtCustomeAmount, self.txtCouponAmount].forEach({$0?.setOutlineColor(UIColor.appTextFieldBorder, for: .editing)})
        
        self.txtCustomeAmount.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        self.txtCustomeAmount.addTarget(self, action: #selector(textFieldAmountDidBegain), for: UIControl.Event.editingDidBegin)
        
        self.txtCouponAmount.addTarget(self, action: #selector(textFieldTapCancel), for: UIControl.Event.touchCancel)
        
        
        self.txtCustomeAmount.keyboardType = .numberPad
        self.txtCustomeAmount.delegate = self
        self.txtCouponAmount.delegate = self

    }

    override func viewDidAppear(_ animated: Bool) {
        
        if self.requiredCash > 0{
           self.txtCustomeAmount.text = "\(currency)\(self.requiredCash)"
           self.addBalance = self.requiredCash
           self.btnAdd.setTitle("Add Money", for: .normal)
           //self.calculateDiscount()
       }else{
           //self.btnAmountSelectionPressed(self.btnH)
       }
            
//        WebCommunication.shared.getUserProfile(hostController: self, showLoader: true) { user in
//            self.lblCurrentBalance.text = "₹\(CommonFunctions.suffixNumberIndian(currency: user?.total_balance?.rounded(toPlaces: 2) ?? 0))"
//        }
    }
    
    func calculateDiscount()
    {
            self.discountValue = self.getDouble(for: coupanDetails?.cashbackPercent ?? 0)
            self.couponCode = String(coupanDetails?.couponCode ?? "")
            self.minAmount = self.getDouble(for: coupanDetails?.minDiscount ?? 0)
            
            
            if addBalance >= minAmount
            {
                if self.getDouble(for: coupanDetails?.maxDiscount ?? 0) == 0
                {
                    //dictDiscountDetail.setValue(String(10000), forKey: "max_discount")//["max_discount"] = String(addBalance)
                    self.coupanDetails?.maxDiscount = 10000
                }
                
                self.discountAmount = (addBalance * discountValue/100 )
                
                if self.discountAmount >= self.getDouble(for: self.coupanDetails?.maxDiscount ?? 0)
                {
                    self.discountAmount = self.getDouble(for: self.coupanDetails?.maxDiscount ?? 0)
                    self.lblBonus.text = ("\(GDP.globalCurrency)" + String(discountAmount.clean))
                }
                else
                {
                    self.lblBonus.text = ("\(GDP.globalCurrency)" + String(discountAmount.clean))
                }
                
            }
            else
            {
                self.lblBonus.text = "\(GDP.globalCurrency)0"
            }
    }
    
    func coupenDiscount() {
        if coupenType != "flat"
        {
            
            if addBalance >= minAmount
            {
                if maxDiscount == 0
                {
                    //dictDiscountDetail.setValue(String(10000), forKey: "max_discount")//["max_discount"] = String(addBalance)
                    self.maxDiscount = 10000
                }
                
                self.discountAmount = (addBalance * discountValue/100 )
                
                if self.discountAmount >= maxDiscount
                {
                    //self.discountAmount = self.getDouble(for: self.coupanDetails?.maxDiscount as Any)
                    self.lblBonus.text = ("\(GDP.globalCurrency)" + String(maxDiscount))
                }
                else
                {
                    self.lblBonus.text = ("\(GDP.globalCurrency)" + String(discountAmount))
                }
                
            }
            else
            {
                self.lblBonus.text = "\(GDP.globalCurrency)0"
            }
        }
        else
        {
            
            if addBalance >= minAmount
            {
                if addBalance >= discountValue{
                    self.discountAmount = (addBalance - discountValue )
                    
                    if self.discountAmount >= maxDiscount
                    {
                        //self.discountAmount = self.getDouble(for: self.coupanDetails?.maxDiscount as Any)
                        self.lblBonus.text = ("\(GDP.globalCurrency)" + String(self.discountValue))
                    }
                    else
                    {
                        self.lblBonus.text = ("\(GDP.globalCurrency)" + String(discountAmount))
                    }
                }else{
                    self.lblBonus.text = "\(GDP.globalCurrency)0"

                }                
            }
            else
            {
                self.lblBonus.text = "\(GDP.globalCurrency)0"
            }
        }
    }
    

    
    
    @IBAction func btnAddCashPressed(_ sender: UIButton){
        
        self.view.endEditing(true)
        
        if LocationManager.sharedInstance.isPLayingInLegalState() == false{
            return
        }
        
        let amount = self.txtCustomeAmount.text?.replace(string: currency, replacement: "")
        
        if amount?.count ?? 0 == 0
        {
            AppManager.showToast(ConstantMessages.Amount_Empty, view: self.view)
            return
        }
        
        if Double(amount ?? "0") ?? 0 < 1
        {
            AppManager.showToast(ConstantMessages.Amount_Minimum, view: self.view)
            return
        }
        
        initAddFlow()
    }
    
    func initAddFlow(){
        let randomNo = Date().currentTimeMillis()
        self.orderId = "\(Constants.kAppDelegate.user?.id ?? "")" + "\(randomNo)"
        let text = (self.txtCustomeAmount.text ?? "0").replace(string: currency, replacement: "")
        self.orderAmount = "\(Double(text)?.rounded(toPlaces: 2).clean ?? "0")"
        cf.controller = self
        self.createTransaction()
        cf.completionHandler = { order_id in
            self.verifyPayment(order_id: order_id)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tipView.tipView.dismiss()
    }
    
    
    @objc func textFieldDidChange(textField : UITextField)
    {
        
        selectPackage = -1
        clPackView.reloadData()
        
        //bottmViewColor.backgroundColor = UIColor.black
        if let coupenCode = UIPasteboard.general.string {
            UIPasteboard.general.string = nil
            let amount = coupenCode.replace(string: currency, replacement: "")
            self.addBalance = Double(amount) ?? 0.0
            self.coupenDiscount()
        } else {
            
            let amount = self.txtCustomeAmount.text?.replace(string: currency, replacement: "") ?? ""
            self.addBalance = Double(amount) ?? 0.0
            self.coupenDiscount()
        }
        
        self.calculateGST(amount: addBalance)
        //self.calculateDiscount()
    }
    
    @objc func textFieldAmountDidBegain(textField : UITextField)
    {
        selectPackage = -1
        clPackView.reloadData()
        
    }
    
    @objc func textFieldTapCancel(textField : UITextField) {
        removeCoupanCode()
    }
    
    @IBAction func btnApplyPressed(_ sender: UIButton) {
        let amountText = (self.txtCustomeAmount.text ?? "0").replace(string: self.currency, replacement: "")
        let amt = (Double(amountText)?.rounded(toPlaces: 2)) ?? 0
        if amt == 0{
            AppManager.showToast(ConstantMessages.Amount_Empty, view: (self.view)!)
            return
        }
        
        if sender.title(for: .normal) == "Remove"{
            self.removeCoupanCode()
        }else{
            if self.txtCouponAmount.text?.count == 0
            {
                AppManager.showToast(ConstantMessages.PromoCode_Empty, view: (self.view)!)
                return
            }
            self.applyCoupan(coupanCode: (self.txtCouponAmount.text ?? ""), amount: amountText)
        }
    }
    
    func removeCoupanCode() {
        self.offerViewHeight.constant = 0
        txtCouponAmount.text = ""
        self.coupanDetails = nil
        self.flatDiscount = 0
        self.discountValue = 0
        self.lblAppliedCoupon.isHidden = true
        self.btnApplyCode.backgroundColor = .Color.blue_0E4990.value
        self.btnApplyCode.setTitle("Apply", for: .normal)
        self.coupenDiscount()
    }
    
    @IBAction func btnKnowMorePressed(_ sender: UIButton) {
        
    }
    
    @IBAction func btnExtraCashInfoPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true{
            tipView.showEasyTip(sender: sender, onView: self.navigationController?.view ?? UIView(), withText: ConstantMessages.kExtraCashMessage)
        }else{
            tipView.tipView.dismiss()
        }
    }
    @IBAction func btnBounsInfoPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected

        if sender.isSelected == true{
            tipView.showEasyTip(sender: sender, onView: self.navigationController?.view ?? UIView(), withText: ConstantMessages.kBonusMessage)
        }else{
            tipView.tipView.dismiss()
        }
    }


}


extension AddCashViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = self.arrCoupens.count
        if clPackView == collectionView {
            return allPackages.count

        }
        return self.arrCoupens.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if clPackView == collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCashCollectionViewCell", for: indexPath) as! AddCashCollectionViewCell
            
            let item = allPackages[indexPath.row]
            
            cell.lblAddPrice.text = item.addAmount
            //cell.lblGetPrice.text = item.getAmount

            if selectPackage == indexPath.row {
                
                cell.imgCheck.isHidden = false
                cell.viewBG.backgroundColor = UIColor.hexStringToUIColor(hex: "#11FFBD")
              
               // cell.btnAnd.isSelected = true
                cell.lblAdd.textColor = .black
                cell.lblAddPrice.textColor = .black
                //cell.lblGet.textColor = .black
                //cell.lblGetPrice.textColor = .black

            }else{
                
                cell.imgCheck.isHidden = true
                cell.viewBG.backgroundColor = UIColor.hexStringToUIColor(hex: "#344452")
                cell.viewBG.borderColor = .lightGray
                cell.viewBG.borderWidth = 0.1
            
                //cell.btnAnd.isSelected = false
                cell.lblAdd.textColor = .white
                cell.lblAddPrice.textColor = .white
                //cell.lblGet.textColor = .white
                //cell.lblGetPrice.textColor = .white
            }
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoupenCVCell", for: indexPath) as! CoupenCVCell
        let coupenDetail = arrCoupens[indexPath.row]
        if coupenDetail.type ?? "" == "percentage" {
            print(coupenDetail.cashbackPercent ?? 0)
            cell.lblDiscountValue.text = "\(coupenDetail.cashbackPercent ?? 0)% Cashback"
            cell.lblDescription.text = coupenDetail.description ?? ""
            cell.lblCoupenCode.text = coupenDetail.couponCode?.uppercased() ?? ""
            cell.lblExpireDate.text = "Expires in \(coupenDetail.expireInDays ?? 0) days!"
            cell.btnApplyCode.tag = indexPath.row
            cell.btnApplyCode.addTarget(self, action: #selector(applyCode(sender:)), for: .touchUpInside)
        } else {
            cell.lblDiscountValue.text = "Flat \(GDP.globalCurrency)\(coupenDetail.flatDiscount ?? 0)"
            cell.lblDescription.text = coupenDetail.description ?? ""
            cell.lblCoupenCode.text = coupenDetail.couponCode?.uppercased() ?? ""
            cell.lblExpireDate.text = "Expires in \(coupenDetail.expireInDays ?? 0) days!"
            cell.btnApplyCode.tag = indexPath.row
            cell.btnApplyCode.addTarget(self, action: #selector(applyCode(sender:)), for: .touchUpInside)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if clPackView == collectionView {
            selectPackage = indexPath.row
            clPackView.reloadData()
            
            let item = allPackages[indexPath.row]
            
            let price = item.addAmount.replace(string: currency, replacement: "")
            txtCustomeAmount.text = "\(currency)\(item.addAmount)"
            addBalance = Double(price) ?? 0.0
            calculateGST(amount: addBalance)
            
            self.lblCashBalance.text = "\(txtCustomeAmount.text ?? "0")"
            
            btnAdd.setTitle("Add \(currency)\(item.addAmount)", for: .normal)
            //self.coupenDiscount()
            self.removeCoupanCode()
            
        }
    }
    
    @objc func applyCode(sender: UIButton){
        let amountText = (self.txtCustomeAmount.text ?? "0").replace(string: self.currency, replacement: "")
        let amt = (Double(amountText)?.rounded(toPlaces: 2)) ?? 0
        if amt == 0{
            AppManager.showToast(ConstantMessages.Amount_Empty, view: (self.view)!)
            return
        }
        
        txtCouponAmount.text = "\(arrCoupens[sender.tag].couponCode ?? "")"
        self.coupenType = arrCoupens[sender.tag].type ?? ""
        if self.coupenType == "flat" {
            self.discountValue = self.getDouble(for: arrCoupens[sender.tag].flatDiscount ?? 0)
            flatDiscount = self.getDouble(for: arrCoupens[sender.tag].flatDiscount ?? 0)
        }else {
            self.discountValue = self.getDouble(for: arrCoupens[sender.tag].cashbackPercent ?? 0)
        }
        self.couponCode = arrCoupens[sender.tag].couponCode ?? ""
        self.minAmount = self.getDouble(for: arrCoupens[sender.tag].minDiscount ?? 0)
        self.maxDiscount = self.getDouble(for: arrCoupens[sender.tag].maxDiscount ?? 0)

        self.applyCoupan(coupanCode: self.txtCouponAmount.text ?? "", amount: amountText)
       // btnDelete.isHidden = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.tipView.tipView.dismiss()
        let witdh = scrollView.frame.width - (scrollView.contentInset.left*2)
        let index = scrollView.contentOffset.x / witdh
        let roundedIndex = round(index)
        self.pageControl?.currentPage = Int(roundedIndex)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if clPackView == collectionView {
            return CGSize(width: 72, height: collectionView.frame.size.height)
        }
        let collectionWidth = collectionView.bounds.width
        return CGSize(width: collectionWidth, height:148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

extension AddCashViewController {
    
    func getCoupons() {
        let params: [String:String] = [String:String]()
        
        let url = URLMethods.BaseURL + URLMethods.getCoupens
        ApiClient.init().getRequest(method: url, parameters: params, view: (self.view)!) { result in
            if result != nil {
                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "msg") as? String ?? ""
                if status == true{
                    if let data = result?.object(forKey: "results") as? [[String:Any]]{
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                              let tblData = try? JSONDecoder().decode([CoupenResult].self, from: jsonData)else {return }
                        self.arrCoupens = tblData
                        self.pageControl.isHidden = !(tblData.count > 1)
                        self.viewActiveOffers.isHidden = tblData.isEmpty
                        self.coupenColView.reloadData()
                    }
                    else{
                        AppManager.showToast(msg, view: (self.view)!)
                    }
                }else{
                    AppManager.showToast(msg, view: (self.view)!)
                }
                
            }else{
                AppManager.showToast("", view: (self.view)!)
            }
            AppManager.stopActivityIndicator((self.view)!)
        }
        AppManager.startActivityIndicator(sender: (self.view)!)
    }
    
    func applyCoupan(coupanCode:String, amount:String){
        
        let params:[String:String] = ["coupon_code":coupanCode, "amount":amount]
        
        let url = URLMethods.BaseURL + URLMethods.applyCouppon
        
        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            //self.btnDelete.isHidden = false

            if isSuccess == true{
                AppManager.showToast(result?.object(forKey: "msg") as? String ?? "", view: self.view)
                if let data = result?.object(forKey: "results") as? [String:Any]{
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                          let tblData = try? JSONDecoder().decode(CouponDetails.self, from: jsonData)else {return }
                    self.coupanDetails = tblData
                    self.btnApplyCode.backgroundColor = .Color.orange_EA7643.value
                    self.btnApplyCode.setTitle("Remove", for: .normal)
                    
                    self.coupenType = tblData.type ?? ""
                    self.lblAppliedCoupon.isHidden = false
                    if self.coupenType == "flat" {
                        self.discountValue = tblData.flat_discount ?? 0
                        self.flatDiscount = tblData.flat_discount ?? 0
                        self.lblAppliedCoupon.text = "You will receive flat \(self.currency)\(self.discountValue.clean) cashback"
                    }else {
                        self.discountValue = tblData.cashbackPercent ?? 0
                        self.lblAppliedCoupon.text = "You will receive \(self.discountValue.clean)% cashback"
                    }
                    self.couponCode = tblData.couponCode ?? ""
                    self.minAmount = tblData.minDiscount ?? 0
                    self.maxDiscount = tblData.maxDiscount ?? 0
                    //self.offerViewHeight.constant = 48.0
                    self.lblDiscountDescription.text = tblData.description ?? ""

                    self.coupenDiscount()
                    //self.btnDelete.isHidden = false
                }
            }
            else {
                
                self.lblDiscountDescription.text = ""
                self.removeCoupanCode()
                AppManager.showToast(msg ?? "", view: self.view)
            
            }
            AppManager.stopActivityIndicator(self.view)
        }
        AppManager.startActivityIndicator(sender: self.view)
    }

}

//MARK: - Add Money API Call
extension AddCashViewController {
    
    func getUserAccountDetails (){
        let params: [String:String] = [String:String]()
        
        let url = URLMethods.BaseURL + URLMethods.getUserAccountDetails
        
            ApiClient.init().getRequest(method: url, parameters: params, view: (self.view)!) { result in
                if result != nil {
                    let status = result?.object(forKey: "success") as? Bool ?? false
                    let msg = result?.object(forKey: "message") as? String ?? ""
                    if status == true{
                        let data = result?.object(forKey: "results") as? [String:Any]
                        let balance = (data?["total_balance"] as? Double) ?? 0
                        
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: Constants.kAppDisplayName, message: "Amount added successfully", preferredStyle:.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                if let comp = self.completionHandler{
                                    comp(balance)
                                }
                            }))
                            UIApplication.topViewController?.present(alert, animated: true, completion: nil)
                           // self.present(alert, animated: true, completion: nil)
                        }
                    }else{
                        AppManager.showToast(msg, view: (self.view)!)
                    }
                }else{
                    AppManager.showToast("", view: (self.view)!)
               }
                AppManager.stopActivityIndicator((self.view)!)
            }
            AppManager.startActivityIndicator(sender: (self.view)!)
    }
    
    func createTransaction(){
        
        DispatchQueue.main.async {
            
            let amountText = (self.txtCustomeAmount.text ?? "0").replace(string: self.currency, replacement: "")

            
            let params:[String:Any] = ["amount":"\(Double(amountText)?.rounded(toPlaces: 2).clean ?? "0")"]
            
            let url = URLMethods.BaseURL + URLMethods.createTransactionId
            
            ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
                
                let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
                let results = (result?.object(forKey: "results") as? NSDictionary)
                
                let env = (result?.object(forKey: "env") as? String) ?? ""
                
                if env == "sandbox"{
                    self.cf.env = .SANDBOX
                }else{
                    self.cf.env = .PRODUCTION
                }

                if isSuccess == true{
                    
                    if let token = (results?.object(forKey: "payment_session_id") as? String) {
                        self.cf.token = token
                        if let order_id = (results?.object(forKey: "order_id") as? String){
                            self.cf.orderId = order_id
                            let text = (self.txtCustomeAmount.text ?? "0").replace(string: self.currency, replacement: "")

                            self.cf.amount = "\(Double(text)?.rounded(toPlaces: 2).clean ?? "0")"
                            self.cf.makePayment()

                        }
                    }
                }
                
                else{
                    AppManager.showToast(msg ?? "", view: self.view)
                }
                AppManager.stopActivityIndicator(self.view)
            }
            AppManager.startActivityIndicator(sender: self.view)
        }
    }
    
    func updateCurrentTransaction(params:[String:Any]){
        
        let url = URLMethods.BaseURL + URLMethods.updateTransaction
        
        ApiClient.init().postRequest(params, request: url, view: self.view) { (msg,result) in
            
            let isSuccess = (result?.object(forKey: "success") as? Bool) ?? false
            
            if isSuccess == true{
                self.navigationController?.popViewController(animated: true)
                self.getUserAccountDetails()
            }
            
            else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
            AppManager.stopActivityIndicator(self.view)
        }
        AppManager.startActivityIndicator(sender: self.view)
    }
    
    func verifyPayment(order_id:String){
       var parameters = [String:Any]()
       parameters["order_id"] = order_id
       parameters["txn_id"] = order_id
       parameters["banktxn_id"] = "BANK_CF"
       parameters["txn_date"] = CommonFunctions.getStringFromDate(date:Date(), format:"yyyy-MM-dd")
       parameters["txn_amount"] = self.orderAmount
       parameters["currency"] = "INR"
       parameters["gateway_name"] = "CASH_FREE"
       parameters["checksum"] = "CASHFREE_CHECKSUM"
       parameters["user_id"] = Constants.kAppDelegate.user?.id ?? ""
       parameters["language"] = "en"
       parameters["coupon_code"] = self.couponCode
       parameters["coupon_cashback_amount"] = self.discountAmount
       
       DispatchQueue.main.async {
           AppManager.stopActivityIndicator(self.view)
       }
       
       self.updateCurrentTransaction(params: parameters)
    }
    
}

//MARK: - Textfield Delegate Methods
extension AddCashViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField.text?.count ?? 0) == 0 && string == " "{
            return false
        }
        
        if textField == txtCustomeAmount{
            if textField.text?.count == 0 && string == "0" {
                    return false
            }
            if btnApplyCode.title(for: .normal) == "Remove"{
                self.removeCoupanCode()
            }
            let dotsCount = textField.text!.components(separatedBy: ".").count - 1
               if dotsCount > 0 && (string == "." || string == ",") {
                   return false
               }

               if string == "," {
                   textField.text! += "."
                   return false
               }
            
            if !(textField.text?.contains(currency) ?? false) {
                textField.text = currency + "\(textField.text ?? "")"
            }
           
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtCustomeAmount{
            let amount = self.txtCustomeAmount.text?.replace(string: currency, replacement: "") ?? ""
            self.addBalance = Double(amount) ?? 0.0
            self.calculateGST(amount: addBalance)
        }
    }
}

//MARK: - GST Calculation
extension AddCashViewController {
    
    func populateGSTInfo(taxInfo: TaxInfo) {
        
        self.lblTaxDeductedAmount.text = Constants.KCurrency + "\(taxInfo.calculatedAmount ?? "0")"
        self.lblTaxPercent.text = Constants.KCurrency + "\((taxInfo.gstAmount ?? "0"))"
        self.lblTaxAmount.text = Constants.KCurrency + "\((taxInfo.calculatedAmount ?? "0"))"
        self.lblAmountWithTax.text = Constants.KCurrency + "\((taxInfo.totalAmount ?? "0"))"
        self.lblTaxBonus.text = Constants.KCurrency + "\((taxInfo.bonus ?? "0"))"
        self.lblGST.text = "Govt. Tax (\((taxInfo.gstPercantage ?? "0"))% GST)"
    }
    
    func calculateGST(amount: Double) {
        
        WebCommunication.shared.calculateGST(amount: amount) { response in
            guard let taxInfo = response else { return }
            self.populateGSTInfo(taxInfo: taxInfo)
        }
    }
    
}

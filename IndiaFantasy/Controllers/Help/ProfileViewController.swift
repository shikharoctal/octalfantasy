//
//  ProfileViewController.swift
//  CrypTech
//
//  Created by New on 10/03/22.
//

import UIKit
import Alamofire
import SocketIO
import MaterialComponents

class ProfileViewController: BaseClassWithoutTabNavigation {
    
    @IBOutlet weak var imgUser: UIImageView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(isImagePicker(_:)))
            imgUser.superview?.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var imgIsVerifiedEmail: UIImageView!
    
    @IBOutlet weak var navigationView: CustomNavigation!
    
    @IBOutlet weak var txtUserName: MDCOutlinedTextField!
    @IBOutlet weak var txtFullName: MDCOutlinedTextField!
    @IBOutlet weak var txtEmail: MDCOutlinedTextField!
    @IBOutlet weak var txtPhone: MDCOutlinedTextField!
    @IBOutlet weak var btnPhoneVerify: UIButton! {
        didSet {
            btnPhoneVerify.addTarget(self, action: #selector(btnVerifyPhoneAction(_:)), for: .touchUpInside)
        }
    }
    @IBOutlet weak var txtState: MDCOutlinedTextField!
    @IBOutlet weak var txtAge: MDCOutlinedTextField!
    @IBOutlet weak var viewState: UIView!
    var statePicker = UIPickerView()

    
    @IBOutlet weak var btnMale: UIButton!
    @IBOutlet weak var btnFemale: UIButton!
    
    var selectedImage:UIImage? = nil
    var genderStatus = String()
    var selectedStateIndex = 0

    var arrItems = [[String:Any]]()
    let datePickerView = UIDatePicker()
    var country:Country? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arrItems = CommonFunctions.getItemFromInternalResourcesforKey(key: "StateList")

        SocketIOManager.sharedInstance.delegateToHandleSocketConnection = self
        
        self.txtUserName.label.text = "User Name"
        self.txtFullName.label.text = "Full Name"
        self.txtEmail.label.text = "Email Address"
        self.txtPhone.label.text = "Phone Number"
        self.txtAge.label.text = "Date of Birth"
        self.txtState.label.text = "State"
        
        
        [self.txtUserName,self.txtFullName,self.txtEmail,self.txtPhone,self.txtState,self.txtAge].forEach({$0?.setOutlineColor(UIColor.appTextFieldBorder, for: .normal)})
        [self.txtUserName,self.txtFullName,self.txtEmail,self.txtPhone,self.txtState,self.txtAge].forEach({$0?.setOutlineColor(UIColor.appTextFieldBorder, for: .editing)})
        
        
        [self.txtUserName, self.txtFullName,self.txtEmail, self.txtPhone,self.txtState,self.txtAge].forEach( {$0.setFloatingLabelColor(.white, for: .normal)} )
        [self.txtUserName, self.txtFullName,self.txtEmail, self.txtPhone,self.txtState,self.txtAge].forEach( {$0.setTextColor(.white, for: .normal)} )
        [self.txtUserName, self.txtFullName,self.txtEmail, self.txtPhone,self.txtState,self.txtAge].forEach( {$0.setNormalLabelColor(.gray, for: .normal)} )
        [self.txtUserName, self.txtFullName,self.txtEmail, self.txtPhone,self.txtState,self.txtAge].forEach( {$0.setFloatingLabelColor(.white, for: .editing)} )
        [self.txtUserName, self.txtFullName,self.txtEmail, self.txtPhone,self.txtState,self.txtAge].forEach( {$0.setTextColor(.white, for: .editing)} )
        [self.txtUserName, self.txtFullName,self.txtEmail, self.txtPhone,self.txtState,self.txtAge].forEach( {$0.setNormalLabelColor(.gray, for: .editing)} )
        
        navigationView.configureNavigationBarWithController(controller: self, title: "My Profile", hideNotification: false, hideAddMoney: true, hideBackBtn: false)
        
        WebCommunication.shared.getUserProfile(hostController: self, showLoader: false) { user in
            self.setupUI()
            
        }
        
        self.configureDOBTextField()
        self.configureStateTextField()
    }
    
    func configureDOBTextField(){
        
        datePickerView.datePickerMode = .date
        datePickerView.maximumDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())
        if #available(iOS 13.4, *) {
            datePickerView.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        txtAge.inputView = datePickerView
        if #available(iOS 13.4, *) {
            datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        } else {
            // Fallback on earlier versions
        }
    }
    
    func configureStateTextField(){
        self.statePicker = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.statePicker.delegate = self
        self.statePicker.dataSource = self
        self.statePicker.backgroundColor = UIColor.white
        txtState.inputView = self.statePicker
        
        self.configureDOBTextField()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.kUpdateTopNavigation), object: nil, userInfo: nil)
        
    }
    
    @IBAction func actionChangeGender(_ sender: UIButton) { isChangeGenderSelection(sender) }
    
    @IBAction func actionSubmit(_ sender: Any) {
        
        submitValidData()
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionDelete(_ sender: UIButton) {
        self.alertBoxWithAction(title: ConstantMessages.kDeleteAccount, message: ConstantMessages.kDeleteAccountMessage, btn1Title: ConstantMessages.CancelBtn, btn2Title: ConstantMessages.kDeleteBtn) {
            
            WebCommunication.shared.deleteAccountRequest(showLoader: true) { status, message in
                if status {
                    Constants.kAppDelegate.logOutApp()
                }else {
                    AppManager.showToast(message, view: self.view)
                }
            }
        }
    }
    
    @objc func isImagePicker(_ sender: UITapGestureRecognizer? = nil) {
        
        MediaPicker.shared.showActionSheet(viewController: self, type: .image)
        MediaPicker.shared.imagePickerBlock = { (image) -> Void in
            
            self.selectedImage = image
            self.imgUser.image = image
        }
    }
    
    func isChangeGenderSelection(_ sender:UIButton) {
        
        if sender.tag == 1 {
            genderStatus = "male"
            btnMale.setTitleColor(#colorLiteral(red: 0.9647058824, green: 0.6980392157, blue: 0.1647058824, alpha: 1), for: .normal)
            btnMale.setImage(#imageLiteral(resourceName: "IconMaleSelected"), for: .normal)
            btnMale.borderColor = #colorLiteral(red: 0.9647058824, green: 0.6980392157, blue: 0.1647058824, alpha: 1)
            
            btnFemale.setTitleColor(#colorLiteral(red: 0.3707560301, green: 0.3708249629, blue: 0.3707516789, alpha: 1), for: .normal)
            btnFemale.setImage(#imageLiteral(resourceName: "IconFemaleUnSelected"), for: .normal)
            btnFemale.borderColor = #colorLiteral(red: 0.4705882353, green: 0.4705882353, blue: 0.4705882353, alpha: 1)
        }
        else if sender.tag == 2 {
            genderStatus = "female"
            btnFemale.setTitleColor(#colorLiteral(red: 0.9647058824, green: 0.6980392157, blue: 0.1647058824, alpha: 1), for: .normal)
            btnFemale.setImage(#imageLiteral(resourceName: "IconFemaleSelected"), for: .normal)
            btnFemale.borderColor = #colorLiteral(red: 0.9647058824, green: 0.6980392157, blue: 0.1647058824, alpha: 1)
            
            btnMale.setTitleColor(#colorLiteral(red: 0.3707560301, green: 0.3708249629, blue: 0.3707516789, alpha: 1), for: .normal)
            btnMale.setImage(#imageLiteral(resourceName: "IconMaleUnSelected"), for: .normal)
            btnMale.borderColor = #colorLiteral(red: 0.4705882353, green: 0.4705882353, blue: 0.4705882353, alpha: 1)
        }
    }
    
    func setupUI() {
    
        let userInfo = Constants.kAppDelegate.user
        
        //self.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.imgUser.sd_setImage(with: URL(string: userInfo?.image ?? ""), placeholderImage: Constants.kProfileplaceholder)
        txtFullName.text = (userInfo?.full_name ?? "")
        txtUserName.text = (userInfo?.username ?? "")
        
        if let emailverified = userInfo?.emailverified{
            if emailverified == true{
                txtEmail.isUserInteractionEnabled = false
            }
        }
        
        txtEmail.text = (userInfo?.email ?? "")
        if let phone = userInfo?.phone, !phone.isEmptyOrWhitespace {
            txtPhone.text = (userInfo?.country_code ?? "+91") + "-" + (userInfo?.phone ?? "")
            txtPhone.isUserInteractionEnabled = false
        }else {
            
            txtPhone.text = ""
            txtPhone.isUserInteractionEnabled = true
        }
        
        
        let dob = userInfo?.dob ?? ""
        if dob != ""{
            txtAge.text = CommonFunctions.getDateFromString(strDate: dob, currentFormat: "yyyy-MM-dd'T'HH:mm:ss", requiredFormat: "dd-MMM-yyyy")
        }
        
        txtState.text = userInfo?.state ?? ""
               
        if ((userInfo?.gender ?? "").lowercased() == "male") {
            isChangeGenderSelection(btnMale)
        } else if ((userInfo?.gender ?? "").lowercased() == "female") {
            isChangeGenderSelection(btnFemale)
        }
        
        if userInfo?.emailverified == true {
            imgIsVerifiedEmail.isHidden = false
        }else{
            imgIsVerifiedEmail.isHidden = true
        }
        
        //self.populateKYCResult()
    }
    
    func populateKYCResult(){
        WebCommunication.shared.getCommonDetails(hostController: self, showLoader: false) { user in
            if GlobalDataPersistance.shared.pan_verified == 3 && GlobalDataPersistance.shared.bank_verified == 3{
                //                self.btnKYC.setTitle("KYC Verified", for: .normal)
                //                self.btnKYC.setImage(UIImage(named: "Success"), for: .normal)
                //                self.btnKYC.setTitleColor(UIColor.appKYCVerifiedColor, for: .normal)
                
            }
            else {
                //                self.btnKYC.setTitle("KYC Not Verified", for: .normal)
                //                self.btnKYC.setImage(UIImage(named: "add-more"), for: .normal)
                //                self.btnKYC.setTitleColor(UIColor.red, for: .normal)
            }
        }
    }
    
    @objc func handleStatePicker(sender: UIPickerView) {
        let object = self.arrItems[sender.selectedRow(inComponent: 0)]
        let state =  object["title"] as? String ?? ""
        txtState.text = state
    }
    
    @IBAction func btnKYCPressed(_ sender: Any) {
        WebCommunication.shared.getCommonDetails(hostController: self, showLoader: false) { user in
            if GlobalDataPersistance.shared.pan_verified > 0 && GlobalDataPersistance.shared.bank_verified > 0{
                // Verified
            }
            else{
                let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "WithdrawAmountVC") as! WithdrawAmountVC
                self.navigationController?.pushViewController(pushVC, animated: true)
            }
        }
    }
    
    @objc func btnVerifyPhoneAction(_ sender: UIButton) {
        
    }
}

//MARK: Date Picker -> UITextFieldDelegate
@available(iOS 13.4, *)
extension ProfileViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField.text?.count ?? 0) == 0 && string == " "{
            return false
        }
        
        let currentText = textField.text ?? ""
        guard Range(range, in: currentText) != nil else { return false }

        if textField == txtFullName{
            let currentString: NSString = (textField.text ?? "") as NSString
            let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
            if newString.length <= Constants.kCommonFieldLength{
                do {
                    let regex = try NSRegularExpression(pattern: ".*[^A-Za-z ].*", options: [])
                    if regex.firstMatch(in: string, options: [], range: NSMakeRange(0, string.count)) != nil {
                        return false
                    }
                }
                catch {
                    print("ERROR")
                }
                return true
            }
            return false
        }else if textField == txtPhone {
            
            guard let currentText = textField.text,
                  let stringRange = Range(range, in: currentText) else {
                return false
            }
            
            var updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            // If the new text is empty, do not add the prefix
            if updatedText.isEmpty {
                return true
            }
            
            // Check if the new text still starts with the prefix
            if !updatedText.hasPrefix("+91 ") { // Change this to match your prefix
                // If not, prepend the prefix to the new text
                updatedText = "+91 " + updatedText // Change this to match your prefix
            }
            
            // If the user tries to delete the prefix or the space after the prefix, re-add it
            if string.isEmpty && currentText == "+91 " {
                textField.text = "+91 "
                return false
            }
            
            // If the user tries to delete the space after the prefix, re-add it
            if string.isEmpty && currentText.hasPrefix("+91") && currentText.count == 5 {
                textField.text = "+91 "
                return false
            }
            
            // Update the text field with the modified text
            textField.text = updatedText
            
            return false
        }
        
        return true
    }
    
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        if textField == txtState {
//            if txtCountry.text?.isEmpty ?? true {
//                AppManager.showToast(ConstantMessages.SELECT_COUNTRY_FIRST.localized(), view: self.view)
//                return false
//            }
//        }
//        return true
//    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        txtAge.text = dateFormatter.string(from: sender.date)
    }
}

extension ProfileViewController {
    
    func submitValidData() {
        
//        guard let firstName = txtFullName.text, txtFullName.text?.count != 0  else {
//            AppManager.showToast(ConstantMessages.FullName_Empty.localized(), view: self.view)
//            return
//        }
        guard let username = txtUserName.text, username.count != 0  else {
            AppManager.showToast(ConstantMessages.UserNamr_Empty.localized(), view: self.view)
            return
        }
        
        guard let email = txtEmail.text, email.count != 0  else {
            AppManager.showToast(ConstantMessages.Email_Empty.localized(), view: self.view)
            return
        }
        
        guard let validemail = txtEmail.text, AppManager.validateEmail(with: txtEmail.text) else {
            AppManager.showToast(ConstantMessages.Email_Validate.localized(), view: self.view)
            return
        }
        
//        guard let phone = txtPhone.text, txtPhone.text?.count != 0  else {
//            AppManager.showToast(ConstantMessages.Phone_Validate.localized(), view: self.view)
//            return
//        }
        
        guard let dob = txtAge.text, txtAge.text?.count != 0  else {
            AppManager.showToast(ConstantMessages.SELECT_DOB_.localized(), view: self.view)
            return
        }
        
//        guard genderStatus.count != 0 else {
//
//            AppManager.showToast(ConstantMessages.Gender_Empty.localized(), view: self.view)
//            return
//        }
                
        var selectedState = ""
        if viewState.isHidden == false {
            guard let state = txtState.text, txtState.text?.count != 0  else {
                AppManager.showToast(ConstantMessages.SELECT_STATE.localized(), view: self.view)
                return
            }
            selectedState = state
        }
        
        
        let finalDate = CommonFunctions.getDateFromString(strDate: dob, currentFormat: "dd-MMM-yyyy", requiredFormat: "yyyy-MM-dd'T'HH:mm:ss")
        
        let dataDict:[String:String] = ["full_name": txtFullName.text ?? "",
                                        "email": validemail,
                                        "username":username,
                                        "dob":finalDate,
                                        //"phone":phone,
                                        //"country_code":Constants.kAppDelegate.user?.country_code ?? "",
                                        //"gender":genderStatus,
                                        "state": selectedState,
                                        ]
        
        if self.selectedImage != nil{
            self.submitUploadRequest(params: dataDict, profileImage: self.imgUser.image ?? UIImage())
        }else{
            var profileData = ""
            let encoder = JSONEncoder()
            if let jsonData = try? encoder.encode(dataDict) {
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print(jsonString)
                    profileData = jsonString
                }
            }
            
            let dic = ["data": profileData]
            
            self.updateProfile(params: dic)
        }
        
    }
    
    func submitUploadRequest(params:[String:String], profileImage:UIImage){
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        
        let headers: HTTPHeaders =
        ["Content-type": "multipart/form-data",
         "Accept": "application/json",
         "x-access-token":Constants.kAppDelegate.authToken ?? ""]
        
        let decoder = JSONDecoder()
        
        AppManager.startActivityIndicator(sender: self.view)
        
        AF.upload(
            multipartFormData: { multipartFormData in
                
                multipartFormData.append(jsonData, withName: "data")
                
                guard let bankImage = Media(withImage: profileImage, forKey: "profile_pic") else { return }
                multipartFormData.append(bankImage.data, withName: "profile_pic", fileName: "profile_pic\(Date().millisecondsSince1970).jpg", mimeType: "image/jpeg")
                
                
            },
            to: URLMethods.BaseURL + URLMethods.uploadImage, //URL Here
            method: .post,
            headers: headers)
            .validate(statusCode: 200..<300).responseDecodable(decoder: decoder, completionHandler: { (response: DataResponse<UpdateProfileModel,AFError>) in
                
                print(response.data.map { String(decoding: $0, as: UTF8.self) } ?? "No data.")
                switch response.result {
                case .success(let value):
                    AppManager.stopActivityIndicator(self.view)
                    if value.success ?? false == true
                    {
                        let alert = UIAlertController(title: Constants.kAppDisplayName, message: "\(value.msg ?? "")", preferredStyle:.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            WebCommunication.shared.getUserProfile(hostController: self, showLoader: true) { user in
                                self.navigationController?.popViewController(animated: true)
                            }
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }else {
                        AppManager.showToast(value.msg ?? "", view: self.view)
                    }
                case .failure(let error):
                    AppManager.stopActivityIndicator(self.view)
                    AppManager.showToast(error.underlyingError?.localizedDescription ?? error.localizedDescription, view: self.view)
                }
            })
    }
    
    func updateProfile(params:[String:Any]) {
        
        ApiClient.init().postRequest(params, request: URLMethods.BaseURL + URLMethods.uploadImage, view: self.view) { (msg,result) in
            if result != nil {
                if (result?.object(forKey: "success") as? Bool ?? false) == true {
                    WebCommunication.shared.getUserProfile(hostController: self, showLoader: true) { user in
                        let alert = UIAlertController(title: Constants.kAppDisplayName, message: msg, preferredStyle:.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            WebCommunication.shared.getUserProfile(hostController: self, showLoader: true) { user in
                                self.navigationController?.popViewController(animated: true)
                            }
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                else {
                    AppManager.showToast(msg ?? "", view: self.view)
                }
                
            }else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
            AppManager.stopActivityIndicator(self.view)
        }
        AppManager.startActivityIndicator(sender: self.view)
    }
}

//MARK:- UITextField => Picker Manager
extension ProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == statePicker
        {
            return self.arrItems.count
        }
        else
        {
            return 0
        }
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == statePicker
        {
            let object = self.arrItems[row]
            return object["title"] as? String ?? ""
        }
        else
        {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedStateIndex = row
        let dict = arrItems[row]
        txtState.text =  (dict["title"] as? String) ?? ""
    }
}

extension ProfileViewController:SocketHandlerDelegate {
    
    func handleDraftSocketRoom(data: [Any], ack: SocketAckEmitter) {
        //print("------------------------------------Join  Draft Room------------------------------------")
    }
    
    func handleActiveDraftSocketListners(data: [Any], ack: SocketAckEmitter) {
        // print(data);
    }
}

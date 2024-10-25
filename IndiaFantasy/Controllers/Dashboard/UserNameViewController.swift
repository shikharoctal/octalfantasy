//
//  UserNameViewController.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 10/08/22.
//

import UIKit
import MaterialComponents

class UserNameViewController: UIViewController {

    @IBOutlet weak var txtFUserName: MDCOutlinedTextField!
    @IBOutlet weak var txtFFirstName: MDCOutlinedTextField!
    @IBOutlet weak var txtAge: MDCOutlinedTextField!
    @IBOutlet weak var txtCountry: MDCOutlinedTextField!
    @IBOutlet weak var viewState: UIView!
    
    var fullName = ""
    var email = ""
    
    var selectedStateIndex = 0
    var countryPicker = UIPickerView()
    var arrItems = [State]()
    let datePickerView = UIDatePicker()
    var oldUserName = "" //For Country Update
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //arrItems = CommonFunctions.getItemFromInternalResourcesforKey(key: "StateList")
        
        self.txtFFirstName.label.text = "Enter Full Name"
        self.txtFUserName.label.text = "Enter User Name"
        self.txtAge.label.text = "Enter DOB"
        self.txtCountry.label.text = "Country"
        
        [self.txtFFirstName, self.txtFUserName, self.txtAge, self.txtCountry].forEach({$0?.setOutlineColor(UIColor.appTextFieldBorder, for: .normal)})
        
        [self.txtFFirstName, self.txtFUserName, self.txtAge, self.txtCountry].forEach({$0?.setOutlineColor(UIColor.appTextFieldBorder, for: .editing)})
        
        if !oldUserName.isEmpty {
            txtFUserName.isUserInteractionEnabled = false
            txtFUserName.text = oldUserName
        }
        //self.configureStateTextField()
        //self.getCountryList()
        self.txtFFirstName.text = self.fullName
        txtCountry.text = "India"
    }
    
    func configureStateTextField(){
        self.countryPicker = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.countryPicker.delegate = self
        self.countryPicker.dataSource = self
        self.countryPicker.backgroundColor = UIColor.white
        txtCountry.inputView = self.countryPicker
        
        self.configureDOBTextField()
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
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        txtAge.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func handleStatePicker(sender: UIPickerView) {
        
        let index = sender.selectedRow(inComponent: 0)
        guard arrItems.count > index else { return }
        let state = self.arrItems[index]
        let stateName =  state.name
        txtCountry.text = stateName
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnContinuePressed(_ sender: Any) {
        self.submitValidData()
    }
    
    @IBAction func btnSelectStatePressed(_ sender: UIButton) {
        txtCountry.becomeFirstResponder()
    }
    
    @IBAction func btnDOBPressed(_ sender: UIButton) {
        txtAge.becomeFirstResponder()
    }
    
}

extension UserNameViewController{
    
    func submitValidData(){
        guard let firstName = txtFFirstName.text, txtFFirstName.text?.count != 0  else {
            AppManager.showToast(ConstantMessages.FullName_Empty.localized(), view: self.view)
            return
        }

//        if firstName.count < 3{
//            AppManager.showToast(ConstantMessages.FirstName_Validation.localized(), view: self.view)
//            return
//        }
        
        guard let username = txtFUserName.text, txtFUserName.text?.count != 0  else {
            AppManager.showToast(ConstantMessages.UserNamr_Empty.localized(), view: self.view)
            return
        }
        
        if username.count < 4{
            AppManager.showToast(ConstantMessages.UserNameLength_Validation.localized(), view: self.view)
            return
        }
        

        let dataDict:[String:String] = ["username":username,
                                        "full_name":firstName,
                                        "email":self.email]
        debugPrint(dataDict)
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
    
    func updateProfile(params:[String:Any]) {
        
        ApiClient.init().postRequest(params, request: URLMethods.BaseURL + URLMethods.uploadImage, view: self.view) { (msg,result) in
            if result != nil {
                if (result?.object(forKey: "success") as? Bool ?? false) == true {
                    WebCommunication.shared.getUserProfile(hostController: self, showLoader: true) { user in
                        GlobalDataPersistance.shared.isKeepLoggedIn = true
                        Constants.kAppDelegate.user?.saveToken(Constants.kAppDelegate.authToken ?? "")
                        guard let userData = try? JSONEncoder().encode(user) else {return }
                        Constants.kAppDelegate.user?.saveUser(userData)
                        CommonFunctions().isUserLoginFirstTime = self.oldUserName.isEmpty ? true : false
                        Constants.kAppDelegate.swichToHome()
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
    
    func getCountryList() {
     
        //let userCountryCode = Constants.kAppDelegate.user?.country_code ?? ""
        
        WebCommunication.shared.getCountriesList(showLoader: true) { states in
            self.arrItems = states ?? []
            if self.arrItems.isEmpty {
                self.viewState.isHidden = true
            }
            self.txtCountry.text = ""
        }
    }
}
extension UserNameViewController:UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField.text?.count ?? 0) == 0 && string == " "{
            return false
        }
        
        if textField == txtFFirstName{
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
        }
        if textField == txtFUserName{
            
            if string == " " {
                return false
            }
            let currentString: NSString = (textField.text ?? "") as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= Constants.kCommonFieldLength
        }
         return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtAge{
            self.handleDatePicker(sender: self.datePickerView)
        }
        if textField == txtCountry{
            self.handleStatePicker(sender: self.countryPicker)
        }
   }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
           if action == #selector(UIResponderStandardEditActions.paste(_:)) {
                       return false
           }
           return super.canPerformAction(action, withSender: sender)
    }
}

//MARK:- UITextField => Picker Manager
extension UserNameViewController: UIPickerViewDelegate, UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == countryPicker
        {
            return self.arrItems.count
        }
        else
        {
            return 0
        }
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == countryPicker {
            let state = self.arrItems[row]
            return state.name ?? ""
        }
        else
        {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        guard arrItems.count > row else { return }
        selectedStateIndex = row
        let state = arrItems[row]
        txtCountry.text =  state.name ?? ""
    }
}

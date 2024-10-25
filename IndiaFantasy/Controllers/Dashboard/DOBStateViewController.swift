//
//  DOBStateViewController.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 16/08/22.
//

import UIKit
import MaterialComponents

class DOBStateViewController: UIViewController {

    @IBOutlet weak var txtState: MDCOutlinedTextField!
    @IBOutlet weak var txtAge: MDCOutlinedTextField!
    var selectedStateIndex = 0
    var statePicker = UIPickerView()
    var arrItems = [[String:Any]]()
    let datePickerView = UIDatePicker()
    
    var completionHandler : ((Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        arrItems = CommonFunctions.getItemFromInternalResourcesforKey(key: "StateList")
        
        self.txtAge.label.text = "Enter DOB"
        self.txtState.label.text = "Select State"
        
        [self.txtState, self.txtAge].forEach({$0?.setOutlineColor(UIColor.appTextFieldBorder, for: .normal)})
        
        [self.txtState, self.txtAge].forEach({$0?.setOutlineColor(UIColor.appTextFieldBorder, for: .editing)})
        
        self.configureStateTextField()
        // Do any additional setup after loading the view.
    }
    
    func configureStateTextField(){
        self.statePicker = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.statePicker.delegate = self
        self.statePicker.dataSource = self
        self.statePicker.backgroundColor = UIColor.white
        txtState.inputView = self.statePicker
        
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
        let object = self.arrItems[sender.selectedRow(inComponent: 0)]
        let state =  object["title"] as? String ?? ""
        txtState.text = state
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func btnContinuePressed(_ sender: Any) {
        self.submitValidData()
    }
}

extension DOBStateViewController{
    func submitValidData(){
        guard let dob = txtAge.text, txtAge.text?.count != 0  else {
            AppManager.showToast(ConstantMessages.SELECT_DOB_.localized(), view: self.view)
            return
        }
        
        guard let state = txtState.text, txtState.text?.count != 0  else {
            AppManager.showToast(ConstantMessages.SELECT_STATE.localized(), view: self.view)
            return
        }
        
        let finalDate = CommonFunctions.getDateFromString(strDate: dob, currentFormat: "yyyy-MM-dd", requiredFormat: "yyyy-MM-dd'T'HH:mm:ss")

        
        let dataDict:[String:String] = ["dob":finalDate, "state":state]
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
                        if let comp = self.completionHandler{
                            self.dismiss(animated: true) {
                                comp(true)
                            }
                        }else{
                            self.dismiss(animated: true, completion: nil)
                        }
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
extension DOBStateViewController: UIPickerViewDelegate, UIPickerViewDataSource
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
extension DOBStateViewController:UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtAge{
            self.handleDatePicker(sender: self.datePickerView)
        }
        if textField == txtState{
            self.handleStatePicker(sender: self.statePicker)
        }
   }
}

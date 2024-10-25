//
//  PanCardVerificationVC.swift
//  CrypTech
//
//  Created by New on 16/03/22.
//

import UIKit
import Alamofire
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import SocketIO
class PanCardVerificationVC: BaseClassWithoutTabNavigation {

    @IBOutlet weak var navigationView: CustomNavigation!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var txtFPanNumber: MDCOutlinedTextField!
    @IBOutlet weak var txtFName: MDCOutlinedTextField!

    let datePickerView = UIDatePicker()

    var panDetails: PanDetails? = nil
    var panImage: UIImage? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
   //     SocketIOManager.sharedInstance.delegateToHandleSocketConnection = self
        
        navigationView.configureNavigationBarWithController(controller: self, title: "Verify PAN Card", hideNotification: false, hideAddMoney: true, hideBackBtn: false)
        self.setupMaterialTextFields()
        txtFPanNumber.addTarget(self, action: #selector(capitaliseText(_:)), for: .editingChanged)
        
        if let panDetails = panDetails {
            txtFPanNumber.text = panDetails.idNumber ?? ""
            self.txtFPanNumber.isUserInteractionEnabled = false
        }
    }
    
    func setupMaterialTextFields(){
        self.txtFPanNumber.label.text = "PAN (Enter your 10 digit PAN)*"
        self.txtFName.label.text = "Name on PAN Card*"
        self.txtFName.placeholder = "Name on PAN Card*"

        [txtFName,txtFPanNumber].forEach({$0?.setOutlineColor(UIColor.appTextFieldBorder, for: .normal)})
        [txtFName,txtFPanNumber].forEach({$0?.setOutlineColor(UIColor.appTextFieldBorder, for: .editing)})
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    @objc func capitaliseText (_ sender:UITextField){
        sender.text = sender.text?.uppercased()
    }

    func submitValidData() {
        
        self.view.endEditing(true)
        
        guard let name = txtFName.text, !name.isEmptyOrWhitespace  else {
            AppManager.showToast(ConstantMessages.ENT_NAME.localized(), view: self.view)
            return
        }
        
        guard let pan = txtFPanNumber.text, !pan.isEmptyOrWhitespace  else {
            AppManager.showToast(ConstantMessages.ENT_PAN_NUMBER.localized(), view: self.view)
            return
        }
        
        let params:[String:Any] = ["pan_number":pan, "name":name]
        self.updatePanApi(params: params)
    }
    
    @IBAction func btnNextPressed(_ sender: Any) {
        submitValidData()
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
extension PanCardVerificationVC {
    func updatePanApi(params:[String:Any]) {
        ApiClient.init().postRequest(params, request: URLMethods.BaseURL + URLMethods.updatePan, view: self.view) { (msg,result) in
            AppManager.stopActivityIndicator(self.view)
            if result != nil {
                if (result?.object(forKey: "success") as? Bool ?? false) == true {
                    AppManager.showToast(msg ?? "", view: self.view)
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    //print("MESSAGE :------ ", msg)
                    AppManager.showToast(msg ?? "", view: self.view)
                }
            }else{
                AppManager.showToast(msg ?? "", view: self.view)
            }
        }
        AppManager.startActivityIndicator(sender: self.view)
    }
}


//MARK: Date Picker -> UITextFieldDelegate
@available(iOS 13.4, *)
extension PanCardVerificationVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       
        if (textField.text?.count ?? 0) == 0 && string == " "{
            return false
        }
        if textField == txtFPanNumber{
            if ((textField.text!) + string).count > 10 {
                return false
            }
        }
        
        return true
    }
}


//
//  TransactionFilterVC.swift
//  KnockOut11
//
//  Created by Octal-Mac on 12/10/22.
//

import UIKit

class TransactionFilterVC: UIViewController {

    var completionHandler : ((String, String) -> Void)?
    
    @IBOutlet weak var txtFrom: UITextField!
    @IBOutlet weak var txtTo: UITextField!
    
    var startDate = ""
    var endDate = ""
    let datePicker = CustomDatePicker()
    var allDateTextArr = [UITextField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupDatePicker()
    }
    
     

    func setupDatePicker(){
        self.datePicker.toolbarDelegate = self
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        } else {
            // Fallback on earlier versions
        }
        self.allDateTextArr = [txtFrom, txtTo]
        allDateTextArr.forEach({$0.inputAccessoryView = self.datePicker.toolbar})
        allDateTextArr.forEach({$0.inputView = self.datePicker})
        self.datePicker.addTarget(self, action: #selector(self.dateChanged(_:)), for: .valueChanged)
    }

    @IBAction func btnClosePressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnContibuePressed(_ sender: UIButton) {
        if let comp = self.completionHandler{
            self.dismiss(animated: true) {
                self.startDate = self.txtFrom.text ?? ""
                self.endDate = self.txtTo.text ?? ""
                comp(self.startDate, self.endDate)
            }
        }
    }
}
extension TransactionFilterVC: CustomDatePickerDelegate{
    
    func didDateDone() {
        self.dateChanged(self.datePicker)
        self.view.endEditing(true)
    }
    
    func didDateCancel() {
        self.view.endEditing(true)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: sender.date)
        if let day = components.day, let month = components.month, let year = components.year {
            print("\(day) \(month) \(year)")
            let selectedDate =   CommonFunctions.changeDateFormatStr(currentFormat: "dd:MM:yyyy", targetFormat: "yyyy-MM-dd", date: "\(day):\(month):\(year)")
            if let selectedText = self.getSelectedTextField(){
                if validationForStartEnd(textfield: selectedText, targetDateText:selectedDate ?? ""){
                selectedText.text = selectedDate
                }else {
                    Constants.kAppDelegate.showAlert(msg: "End date should be greater that start date!", isLogout: false, isLocationAlert: false)
                }
            }
        }
    }
    
    func validationForStartEnd(textfield:UITextField, targetDateText:String) -> Bool{
       if textfield == txtFrom{
           if txtTo.text?.isEmpty ?? true{
               return true
           }else{
              return AppManager.compareDates(startDate: targetDateText, endDate: txtTo.text ?? "", formate: "yyyy-MM-dd")
           }
       }
        return true
    }
    
    func getSelectedTextField() -> UITextField?{
        if let txtField =  allDateTextArr.filter({$0.isFirstResponder}).first{
            return txtField
        }
        return nil
    }
}

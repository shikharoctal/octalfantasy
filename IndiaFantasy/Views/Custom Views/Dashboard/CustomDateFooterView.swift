//
//  CustomDateFooterView.swift
//
//  Created by Octal-Mac on 03/11/22.
//

import UIKit

class CustomDateFooterView: UIView {

    @IBOutlet weak var txtFrom: UITextField!
    @IBOutlet weak var txtTo: UITextField!
    @IBOutlet weak var parentView: OctalDropDown? = nil

    let datePicker = CustomDatePicker()
    var allDateTextArr = [UITextField]()
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "CustomDateFooterView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
      }
    
    func updateView(){
        self.setupDatePicker()
        self.txtFrom.text = GlobalDataPersistance.shared.dateFromFilterOptions
        self.txtTo.text = GlobalDataPersistance.shared.dateToFilterOptions

    }

    func setupDatePicker(){
        self.datePicker.toolbarDelegate = self
        self.datePicker.maximumDate = Date()
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
}

extension CustomDateFooterView: CustomDatePickerDelegate{
    
    func didDateDone() {
        self.dateChanged(self.datePicker)
        self.endEditing(true)
    }
    
    func didDateCancel() {
        self.endEditing(true)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: sender.date)
        if let day = components.day, let month = components.month, let year = components.year {
            print("\(day) \(month) \(year)")
            let selectedDate =   CommonFunctions.changeDateFormatStr(currentFormat: "dd:MM:yyyy", targetFormat: "yyyy-MM-dd", date: "\(day):\(month):\(year)")
            if let selectedText = self.getSelectedTextField(){
                if validationForStartEnd(textfield: selectedText, targetDateText:selectedDate ?? ""){
                selectedText.text = selectedDate
                GlobalDataPersistance.shared.timeFilterOptions = ""
                self.parentView?.clearSelections()
                if selectedText == txtFrom{
                    GlobalDataPersistance.shared.dateFromFilterOptions = selectedDate ?? ""
                }else{
                    GlobalDataPersistance.shared.dateToFilterOptions = selectedDate ?? ""
                    }
                }else {
                    Constants.kAppDelegate.showAlert(msg: "End date should be greater than start date!", isLogout: false, isLocationAlert: false)
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
        else if textfield == txtTo{
            if txtFrom.text?.isEmpty ?? true{
                return true
            }else{
                return AppManager.compareDates(startDate: txtFrom.text ?? "", endDate: targetDateText, formate: "yyyy-MM-dd")
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

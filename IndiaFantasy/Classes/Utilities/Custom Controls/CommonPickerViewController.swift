//
//  CommonPickerViewController.swift
//  GymPod
//
//  Created by Octal Mac 217 on 30/11/21.
//

import UIKit

class CommonPickerViewController: UIViewController {

    @IBOutlet weak var lbl_headerName: UILabel!
    @IBOutlet weak var picker: PickerView!
    
    var selectedRow : Int?
    var completionHandler : ((String)-> Void)?
    var pickerType = ""
    var arrCategories = [String]()
    var selectedStr : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbl_headerName.layer.addBorder(edge: .bottom, color:UIColor.appTextFieldBorder, thickness: 2.0)
        self.configurePicker()
        // Do any additional setup after loading the view.
    }
    
    fileprivate func configurePicker() {
        picker.dataSource = self
        picker.delegate = self
        picker.defaultSelectionIndicator.backgroundColor = UIColor.appThemeColor
        picker.defaultSelectionIndicator1.backgroundColor = UIColor.appThemeColor
        picker.pickerType.text = "\(pickerType)"
        picker.pickerType.font = UIFont(name: customFontRegular, size: 18) ?? UIFont.systemFont(ofSize: 18)
        picker.currentSelectedRow = selectedRow ?? 0
    }

}
// MARK: - ClosePopUp Action
extension CommonPickerViewController{
    @IBAction func btnClosePopUpTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Submit Action
extension CommonPickerViewController{
    @IBAction func btnSubmitTapped(_ sender: UIButton) {
        guard let Str = selectedStr else {
            return
        }
        if let comp = completionHandler{
            self.dismiss(animated: true) {
                comp(Str)
            }
        }
    }
}

// MARK: - PickerViewDataSource
extension CommonPickerViewController: PickerViewDataSource {
    
    func pickerViewNumberOfRows(_ pickerView: PickerView) -> Int {
        return arrCategories.count
    }
    func pickerView(_ pickerView: PickerView, titleForRow row: Int) -> String {
        return arrCategories[row]
    }
}
// MARK: - PickerViewDelegate
extension CommonPickerViewController: PickerViewDelegate {
    func pickerViewHeightForRows(_ pickerView: PickerView) -> CGFloat {
        return 60.0
    }

    func pickerView(_ pickerView: PickerView, didSelectRow row: Int) {
        selectedStr = arrCategories[row]
    }
    
    func pickerView(_ pickerView: PickerView, viewForRow row: Int, highlighted: Bool, reusingView view: UIView?) -> UIView? {
        var customView = view
        
        let imageTag = 100
        let labelTag = 101
        
        if (customView == nil) {
            var frame = pickerView.frame
            frame.origin = CGPoint.zero
            frame.size.height = 60
            customView = UIView(frame: frame)
            
            let label = UILabel(frame: frame)
            label.tag = labelTag
            label.textColor = UIColor.black
            label.textAlignment = .center
            
            var fontSize:CGFloat { return 20 }
            var normalFont:UIFont { return UIFont(name: "GlacialIndifference-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)}
            label.font = normalFont
            customView?.addSubview(label)
        }
        
        let imageView = customView?.viewWithTag(imageTag) as? UIImageView
        let label = customView?.viewWithTag(labelTag) as? UILabel
        label?.text = arrCategories[row]
        
        let alpha: CGFloat = highlighted ? 1.0 : 0.3
        imageView?.alpha = alpha
        label?.alpha = alpha
        
        return customView
    }
    
}

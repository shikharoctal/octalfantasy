//
//  CustomDatePicker.swift
//  YangoosServiceProvider
//
//  Created by mac307 on 27/05/22.
//

import Foundation
import UIKit

protocol CustomDatePickerDelegate: AnyObject {
    func didDateDone()
    func didDateCancel()
}

class CustomDatePicker: UIDatePicker {

    public private(set) var toolbar: UIToolbar?
    public weak var toolbarDelegate: CustomDatePickerDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelTapped))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        self.toolbar = toolBar
        
    
        self.datePickerMode = .date
      //  self.maximumDate = Date()
        
    }

    @objc func doneTapped() {
        self.toolbarDelegate?.didDateDone()
    }

    @objc func cancelTapped() {
        self.toolbarDelegate?.didDateCancel()
    }
}

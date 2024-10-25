//
//  CustomButtonView.swift
//  India’s fantasy
//
//  Created by admin on 25/04/23.
//

import UIKit

class CustomButtonView: UIView {

    @IBOutlet weak var btnApply: UIButton!
    @IBOutlet weak var btnClear: UIButton!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "CustomButtonView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
}

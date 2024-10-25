//
//  CustomeHeaderView.swift
//
//  Created by Rahul Gahlot on 01/11/22.
//

import UIKit

class CustomeHeaderView: UIView {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgIcon: UIButton!
    
    var onButtonTapped : (() -> Void)? = nil
    
    @IBAction func btnOnSelect(_ sender: UIButton) {
        if let onButtonTapped = self.onButtonTapped {
                onButtonTapped()
            }
    }
}

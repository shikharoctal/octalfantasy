//
//  HeaderViewSideMenu.swift

//
//  Created by Rahul Gahlot on 03/11/22.
//

import UIKit

class HeaderViewSideMenu: UIView {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var imgArrow: UIImageView!
    @IBOutlet weak var viewLine: UIView!
    
    var onButtonTapped : (() -> Void)? = nil
    
    @IBAction func btnOnSelect(_ sender: UIButton) {
        if let onButtonTapped = self.onButtonTapped {
            onButtonTapped()
        }
    }
}

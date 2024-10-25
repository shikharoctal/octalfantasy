//
//  UpcomingMatchHeaderView.swift
//  India’s fantasy
//
//  Created by admin on 24/05/23.
//

import UIKit

class UpcomingMatchHeaderView: UIView {

    @IBOutlet weak var filterBtn: UIButton!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "UpcomingMatchHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
      }

}

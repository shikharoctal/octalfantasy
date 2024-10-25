//
//  SeasonContestHeaderView.swift
//  India’s fantasy
//
//  Created by admin on 27/04/23.
//

import UIKit

class SeasonContestHeaderView: UIView {

    @IBOutlet weak var containerView: UIView!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "SeasonContestHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
      }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.containerView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
    }
    
}

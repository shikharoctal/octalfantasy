//
//  PrizeHeaderView.swift
//  GymPod
//
//  Created by Octal Mac 217 on 23/11/21.
//

import UIKit

class PrizeHeaderView: UIView {

    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblPrizeAmount: UILabel!
    var controller:LiveContestViewController? = nil
       
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "PrizeHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
      }
        
    func updateView(){
        
    }
    
}

//
//  WinnerBoardHeaderView.swift
//  GymPod
//
//  Created by Octal Mac 217 on 23/11/21.
//

import UIKit

class WinnerBoardHeaderView: UIView {

    var controller:ChooseTotalWinners? = nil
    
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
   
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "WinnerBoardHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
      }
        
    func updateView(){
        
    }
    
}

//
//  ScoreBoardHeaderView.swift
//  GymPod
//
//  Created by Octal Mac 217 on 23/11/21.
//

import UIKit

class ScoreBoardHeaderView: UIView {

    @IBOutlet weak var lblTeamShortName: UILabel!
    @IBOutlet weak var btnExpand: UIButton!
    @IBOutlet weak var lblTeamScore: UILabel!
    
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "ScoreBoardHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
      }
        
    func updateView(){
        
    }
    
}

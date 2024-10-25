//
//  LeaderBoardHeaderView.swift
//  GymPod
//
//  Created by Octal Mac 217 on 23/11/21.
//

import UIKit

class LeaderBoardHeaderView: UIView {

    @IBOutlet weak var lblRank: UILabel!
    @IBOutlet weak var lblPoints: UILabel!
    @IBOutlet weak var imgViewBanner: UIImageView!
    var controller:UIViewController? = nil
    
    @IBOutlet weak var lblTitle: UILabel!
   
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "LeaderBoardHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
      }
        
    func updateView(){
        
    }
    
}

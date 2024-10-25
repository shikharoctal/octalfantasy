//
//  DreamTeamView.swift
//  GymPod
//
//  Created by Octal Mac 217 on 23/11/21.
//

import UIKit

class DreamTeamView: UIView {

    var controller:LiveContestViewController? = nil
       
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "DreamTeamView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
      }
        
    func updateView(){
        
    }
    
    @IBAction func btnDreamTeamPressed(_ sender: Any) {
        self.controller?.dreamTeam()
    }
}

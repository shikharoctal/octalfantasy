//
//  LiveScoreBallView.swift
//  KnockOut11
//
//  Created by Octal Mac 217 on 02/09/22.
//

import UIKit

class LiveScoreBallView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var lblBat1: UILabel!
    @IBOutlet weak var lblBat2: UILabel!
    @IBOutlet weak var lblBowlwe: UILabel!
    @IBOutlet weak var lblBowlerScore: UILabel!
    @IBOutlet weak var scrlViewIndicator: UIScrollView!
    
    @IBOutlet weak var viewFootball: UIView!
    @IBOutlet weak var lblTeam1: UILabel!
    @IBOutlet weak var lblTeam2: UILabel!
    @IBOutlet weak var lblScore: UILabel!
    @IBOutlet weak var lblMinutes: OctalLabel!
    
    var controller:UIViewController? = nil
    
    //    class func instanceFromNib() -> UIView {
    //        return UINib(nibName: "LiveScoreBallView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    //      }
    
    func updateView(selectedMatch: Match?, score: Score? = nil){
        self.loadCricketFantasyBoard(selectedMatch: selectedMatch)
    }
    
    func loadCricketFantasyBoard(selectedMatch:Match?){
        self.lblBat1.text = ""
        self.lblBat2.text = ""
        self.lblBowlerScore.text = ""
        self.lblBowlwe.text = ""
        
        WebCommunication.shared.getTeamScore(hostController: self.controller!, series_id: GDP.selectedMatch?.series_id ?? 0, match_id: GDP.selectedMatch?.match_id ?? 0, showLoader: false) { score in
            
            if (score?.batsmen?.count ?? 0) > 1{
                if let bat1 = score?.batsmen?.first{
                    self.lblBat1.text = "\(bat1.name?.getShortName() ?? "") (\((bat1.runs?.value as? Int) ?? 0)/ \((bat1.ballsFaced?.value as? Int) ?? 0))"
                }
                if let bat2 = score?.batsmen?.last{
                    self.lblBat2.text = "\(bat2.name?.getShortName() ?? "") (\((bat2.runs?.value as? Int) ?? 0)/ \((bat2.ballsFaced?.value as? Int) ?? 0))"
                }
            }
            
            if let bowler = score?.bowlers{
                self.lblBowlerScore.text = "\((bowler.overs?.value as? Double)?.rounded(toPlaces: 1) ?? 0)/ \((bowler.runsConceded?.value as? Int) ?? 0) (\((bowler.overs?.value as? Int) ?? 0))"
                self.lblBowlwe.text = "\((bowler.name ?? "").getShortName())"
            }
            
            if let commentaries = score?.commentaries{
                self.populateScrollView(commentaries: commentaries)
            }
        }
    }
    
    func populateScrollView(commentaries:[Commentary]){
        self.resetScrollViewPoints()
        var currX = 0
        for i  in 0..<commentaries.count {
            let model = commentaries[i]
            _ = scrlViewIndicator.frame.size.width
            //  let itemWidth = width / CGFloat(commentaries.count)
            let view = UIView(frame: CGRect(x: currX, y: 10, width: 15, height: 15))
            
            let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
            view.addSubview(lbl)
            lbl.font = UIFont(name: "Gilroy-Regular", size: 10)
            
            lbl.textAlignment = .center
            
            scrlViewIndicator.addSubview(view)
            
            if (model.event ?? "") == "wicket"{
                lbl.text = (model.score?.value as? String) ?? ""
                lbl.textColor = .white
                view.backgroundColor = UIColor.red
                
            }else{
                lbl.text = "\((model.score?.value as? Int) ?? 0)"
                lbl.textColor = .black
                view.backgroundColor = UIColor.cellSepratorColor
            }
            
            view.clipsToBounds = true
            view.cornerRadius = 2.0
            
            let margin:CGFloat = (lbl.frame.size.width + 7)
            currX = currX + Int(margin)
        }
        scrlViewIndicator.contentSize = CGSize(width: currX, height: 0)
    }
    
    func resetScrollViewPoints(){
        for view in scrlViewIndicator.subviews{
            view.removeFromSuperview()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInilized()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupInilized()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // self.setUpUserInterface()
    }
    
    func setupInilized() {
        Bundle.main.loadNibNamed("LiveScoreBallView", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
}

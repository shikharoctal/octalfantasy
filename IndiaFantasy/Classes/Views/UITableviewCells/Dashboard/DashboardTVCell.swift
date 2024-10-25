//
//  DashboardTVCell.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 04/03/22.
//

import UIKit

class DashboardTVCell: UITableViewCell {

    @IBOutlet weak var imgViewVs: UIImageView!
    @IBOutlet weak var lblCompletedMatchComment: UILabel!
    @IBOutlet weak var vsIcon: UIImageView!
    @IBOutlet weak var btnLive: UIButton!
    @IBOutlet weak var lblHomeTeam: UILabel!
    @IBOutlet weak var lblAwayTeam: UILabel!
    @IBOutlet weak var lblHomeTeamShortName: UILabel!
    @IBOutlet weak var lblAwayTeamShortName: UILabel!
    @IBOutlet weak var lblRemainingTime: UILabel!
    @IBOutlet weak var lblTeamContests: UILabel!
    @IBOutlet weak var lblLineUp: UILabel!
    @IBOutlet weak var lblSeriesName: UILabel!
    
    @IBOutlet weak var btnReminder: UIButton!
    @IBOutlet weak var lblMatchType: UILabel!
    @IBOutlet weak var imgViewAwayTeam: UIImageView!
    @IBOutlet weak var imgViewHomeTeam: UIImageView!
    
    @IBOutlet weak var viewBackground: UIView!
    var controller:DashboardViewController? = nil
    
    var releaseDate: NSDate?
    private var timer: Timer?
    private var timeCounter: Double = 0
    
    var indexPath = IndexPath()
    
    var selectedMatch:Match? = nil
    
    var expiryTimeInterval: TimeInterval? {
        didSet {
            
            if timer == nil
            {
                startTimer()
                RunLoop.current.add(timer!, forMode: .common)
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func startTimer() {
        if let interval = expiryTimeInterval {
            timeCounter = interval
            if #available(iOS 10.0, *) {
                timer = Timer(timeInterval: 1.0,
                              repeats: true,
                              block: { [weak self] _ in
                                guard let strongSelf = self else {
                                    return
                                }
                                strongSelf.onComplete()
                })
            } else {
                timer = Timer(timeInterval: 1.0,
                              target: self,
                              selector: #selector(onComplete),
                              userInfo: nil,
                              repeats: true)
            }
        }
    }
    
    @objc func onComplete() {
        guard timeCounter >= 0 else {
            self.lblRemainingTime.text = self.selectedMatch?.match_status?.capitalized ?? "Match Started"
            timer?.invalidate()
            timer = nil
          //  NotificationCenter.default.post(name: NSNotification.CheckNiftyMatchs, object: nil, userInfo: ["Scroll":"YES"])
            
            return
        }
        let currentDate = Date()
        let calendar = Calendar.current
        //let tomorrow = Calendar.current.date(byAdding: .hour, value: 12, to: Date())
        let matchDate : Date = releaseDate! as Date
        
        //print("currentDate-->",currentDate.toLocalTime())
        let diffDateComponents = calendar.dateComponents([.hour, .minute, .second], from: currentDate.toLocalTime(), to: matchDate.toLocalTime())
        
        //print("matchDate-->",matchDate.toLocalTime())
        if(diffDateComponents.hour ?? 0 >= 0 && diffDateComponents.minute ?? 0 >= 0  && diffDateComponents.second ?? 0 >= 0 )
        {
            //print("diffDateComponents-->",diffDateComponents)
            if diffDateComponents.hour ?? 0 > 24{
                let diffDayComponents = calendar.dateComponents([.day, .hour, .minute], from: currentDate.toLocalTime(), to: matchDate.toLocalTime())
                self.lblRemainingTime.text = "\(diffDayComponents.day ?? 0)d"

            }
            else if diffDateComponents.hour ?? 0 >= 1
            {
                self.lblRemainingTime.text = "\(diffDateComponents.hour ?? 0)h : \(diffDateComponents.minute ?? 0)m"
            }
            else
            {
                self.lblRemainingTime.text = "\(diffDateComponents.minute ?? 0)m : \(diffDateComponents.second ?? 0)S"
            }
        
        }
        else
        {
            self.lblRemainingTime.text = self.selectedMatch?.match_status?.capitalized ?? "Match Started"
            timer?.invalidate()
            timer = nil
          //  NotificationCenter.default.post(name: NSNotification.CheckNiftyMatchs, object: nil, userInfo: ["Scroll":"YES"])
            return
        }
        
        if let controller = controller {
            GDP.selectedMatch?.timerText = self.lblRemainingTime.text ?? ""
            if let match = GDP.selectedMatch{
                if controller.arrMatches?.count ?? 0 > indexPath.row {
                    controller.arrMatches?[indexPath.row] = match
                }
            }
        }
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        timer?.invalidate()
        timer = nil
    }

}

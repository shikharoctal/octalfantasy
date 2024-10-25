//
//  MoneyPoolLiveCVCell.swift
//  IndiaFantasy
//
//  Created by Harendra Singh Rathore on 15/03/24.
//

import UIKit

class MoneyPoolLiveCVCell: UICollectionViewCell {

    @IBOutlet weak var lblMatchStatus: UILabel!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var imgLocalTeam: UIImageView!
    @IBOutlet weak var imgVisitorTeam: UIImageView!
    @IBOutlet weak var lblTeamVS: UILabel!
    
    var releaseDate: NSDate?
    private var timer: Timer?
    private var timeCounter: Double = 0
    
    var expiryTimeInterval: TimeInterval? {
        didSet {
            guard timer == nil else { return }
            startTimer()
            RunLoop.current.add(timer!, forMode: .common)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var setData: Match? {
        didSet {
            guard let match = setData else { return }
            imgLocalTeam.loadImage(urlS: match.localteam_flag, placeHolder: Constants.kNoImageUser)
            imgVisitorTeam.loadImage(urlS: match.visitorteam_flag, placeHolder: Constants.kNoImageUser)
            lblTeamVS.text = (match.localteam_short_name ?? "") + " vs " + (match.visitorteam_short_name ?? "")
            

            if let matchStatus = match.match_status?.uppercased(), matchStatus == "LIVE" || matchStatus == "IN PROGRESS" || matchStatus == "RUNNING" {
                lblMatchStatus.text = "Live"
            }else {
                lblMatchStatus.text = ""
            }
        }
    }

}

extension MoneyPoolLiveCVCell {
    
    func startTimer() {
        if let interval = expiryTimeInterval {
            timeCounter = interval
            if #available(iOS 10.0, *) {
                timer = Timer(timeInterval: 1.0,
                              repeats: true,
                              block: { [weak self] _ in
                    guard let strongSelf = self else { return }
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
            
            if let matchStatus = setData?.match_status?.uppercased(), matchStatus == "LIVE" || matchStatus == "IN PROGRESS" || matchStatus == "RUNNING" {
                lblMatchStatus.text = "Live"
                lblMatchStatus.textColor = .appRedBackgroundColor
            }else {
                lblMatchStatus.text = ""
            }
            
            timer?.invalidate()
            timer = nil
            return
        }
        
        lblMatchStatus.textColor = .appGreenTextColor
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
                self.lblMatchStatus.text = "\(diffDayComponents.day ?? 0)d"
                
            }
            else if diffDateComponents.hour ?? 0 >= 1
            {
                self.lblMatchStatus.text = "\(diffDateComponents.hour ?? 0)h : \(diffDateComponents.minute ?? 0)m"
            }
            else
            {
                self.lblMatchStatus.text = "\(diffDateComponents.minute ?? 0)m : \(diffDateComponents.second ?? 0)S"
            }
            
        } else {
            if let matchStatus = setData?.match_status?.uppercased(), matchStatus == "LIVE" || matchStatus == "IN PROGRESS" || matchStatus == "RUNNING" {
                lblMatchStatus.text = "Live"
                lblMatchStatus.textColor = .appRedBackgroundColor
            }else {
                lblMatchStatus.text = ""
            }
            timer?.invalidate()
            timer = nil
            return
        }
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        timer?.invalidate()
        timer = nil
    }
}

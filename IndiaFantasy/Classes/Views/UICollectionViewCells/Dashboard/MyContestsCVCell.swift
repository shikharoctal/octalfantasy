//
//  MyContestsCVCell.swift
//  India’s fantasy
//
//  Created by admin on 06/04/23.
//

import UIKit
import SDWebImage

class MyContestsCVCell: UICollectionViewCell {

    @IBOutlet weak var lblHomeTeam: UILabel!
    @IBOutlet weak var lblAwayTeam: UILabel!
    @IBOutlet weak var lblHomeTeamShortName: UILabel!
    @IBOutlet weak var lblAwayTeamShortName: UILabel!
    @IBOutlet weak var lblRemainingTime: UILabel!
    @IBOutlet weak var lblTeamContests: UILabel!
    @IBOutlet weak var lblLineUp: UILabel!
    @IBOutlet weak var lblSeriesName: UILabel!
    
    @IBOutlet weak var lblMatchType: UILabel!
    @IBOutlet weak var imgViewAwayTeam: UIImageView!
    @IBOutlet weak var imgViewHomeTeam: UIImageView!
    @IBOutlet weak var btnReminder: UIButton!
    
    var releaseDate: NSDate?
    var controller:DashboardViewController? = nil
    private var timer: Timer?
    private var timeCounter: Double = 0
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

    func updateView(match:Match?, index:Int){
        self.lblHomeTeam.text = match?.localteam ?? ""
        self.lblAwayTeam.text = match?.visitorteam ?? ""
        self.selectedMatch = match
        self.lblHomeTeamShortName.text = match?.localteam_short_name ?? ""
        self.lblAwayTeamShortName.text = match?.visitorteam_short_name ?? ""
        
        self.lblMatchType.text = ""
        if (match?.my_total_contest ?? 0) > 1{
            self.lblTeamContests.text = String(match?.my_total_teams ?? 0) + " " + "Team" + " " + String(match?.my_total_contest ?? 0) + " " + "Contests"
        }else{
            self.lblTeamContests.text = String(match?.my_total_teams ?? 0) + " " + "Team" + " " + String(match?.my_total_contest ?? 0) + " " + "Contest"
        }
        
        self.lblSeriesName.text = "\(match?.series_name ?? "") \(match?.type?.uppercased() ?? "")"
        self.lblRemainingTime.text = ""
        
        if (match?.match_status?.uppercased() ?? "") == "NOT STARTED" || (match?.match_status?.uppercased() ?? "") == "FIXTURE" {
            if (match?.lineup ?? false) == true{
                self.lblLineUp.isHidden = false}
            else{
                self.lblLineUp.isHidden = true}
            DispatchQueue.main.async {

                //let strtDate = "\(match?.start_date ?? "")".components(separatedBy: "T")
                if match?.match_date != nil{
                    //let dataValue = "\(strtDate[0])T\(match?.start_time ?? "")"
                    //let matchDate = CommonFunctions.getNewRemainingTimeWith(strDate : dataValue, serverDate : match?.server_time ?? "")
                    
                    if let matchDate = CommonFunctions.getDateFromString(date: match?.match_date ?? "", format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") {
                        self.releaseDate = matchDate as NSDate
                        let elapseTimeInSeconds =  self.releaseDate!.timeIntervalSince(Date())
                        self.expiryTimeInterval = elapseTimeInSeconds
                        if(elapseTimeInSeconds <= 0){
                            //                        self.isUserInteractionEnabled = false
                        }else{
                            //                        self.isUserInteractionEnabled = true
                        }
                    }
                }else{
                    self.lblRemainingTime.text = ""
                }
            }
        }else{
            if match?.match_status?.uppercased() ?? "" == "LIVE" || match?.match_status?.uppercased() ?? "" == "IN PROGRESS" || match?.match_status?.uppercased() ?? "" == "RUNNING"{
                self.lblRemainingTime.text = "Live"
            }else{
                self.lblRemainingTime.text = match?.match_status ?? ""
            }
            
            self.lblLineUp.isHidden = true
        }
    
        self.imgViewHomeTeam.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.imgViewHomeTeam.sd_setImage(with: URL(string: match?.localteam_flag ?? ""), placeholderImage: Constants.kNoImageUser)

        self.imgViewAwayTeam.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.imgViewAwayTeam.sd_setImage(with: URL(string: match?.visitorteam_flag ?? ""), placeholderImage: Constants.kNoImageUser)
        
        
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
            self.lblRemainingTime.text = self.selectedMatch?.match_status?.capitalized ?? ""
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
            self.lblRemainingTime.text = self.selectedMatch?.match_status?.capitalized ?? ""
            timer?.invalidate()
            timer = nil
          //  NotificationCenter.default.post(name: NSNotification.CheckNiftyMatchs, object: nil, userInfo: ["Scroll":"YES"])
            return
        }
    }
}

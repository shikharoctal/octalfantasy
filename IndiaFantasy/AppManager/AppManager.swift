//
//  ApiClient.swift
//  OlaDoctor
//
//  Created by Sourabh Sharma on 05/08/20.
//  Copyright © 2020 Octal. All rights reserved.
//

import UIKit
import Toast_Swift
//import Alertift
import NVActivityIndicatorView
import CoreLocation

@available(iOS 13.0, *)
class AppManager {
    
    // MARK: - Save Remember me
    public class func saveEmailPassword(email :String, password: String) {
        
        UserDefaults.standard.set(email, forKey: "remember_email")
        UserDefaults.standard.set(password, forKey: "remember_password")
    }
    
    
    // MARK: - UIView+Toast
    public class func showToast(_ msg: String, view:UIView) {
        guard msg != "" else {return}
        view.window?.makeToast(msg, duration: 3.0, position: .center)
    }
    
    // MARK: - UIView+Toast
    public class func showToastCenter(_ msg: String?, view:UIView) {
        
        view.window?.makeToast(msg, duration: 3.0, position: .center)
    }
    
    public class func dismissToast(view:UIView) {
        view.window?.hideAllToasts()
    }
    
    // MARK: - ActivityIndicator
    public class func startActivityIndicator(_ msg: String?="", sender: UIView) {
        
        let activityData = ActivityData(size: CGSize(width: 70, height: 70), message: msg, messageFont: nil, messageSpacing: 0.0, type: .ballRotateChase, color: UIColor.appThemeColor, padding: 5.0, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: .clear, textColor: .clear)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)
        
        
    }
    
    public class func stopActivityIndicator(_ sender: UIView) {
        
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
    }
    
    
    /*************************************************************/
    //MARK:- Clear All UserDefaults Values
    /*************************************************************/
    open class func clearAllAppUserDefaults() {

        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            if !(key == "device_token" || key == "remember_email" || key == "remember_password") {
                Constants.kUserDefaults.removeObject(forKey: key)
            }
        }
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Change currency
    public class func newCurrencyConverterAny(price : Any?) -> String{
       
        if let variableName = price { // If casting, use, eg, if let var = abc as? NSString
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale(identifier: "pt_AO")
            return formatter.string(from: variableName as! NSNumber)!
        } else {
            return "0.0"
        }
    }

    // MARK: - Validation
    public class func validateEmail(with email: String?) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let trimmedString = email?.trimmingCharacters(in: .whitespaces)
        let validateEmail = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let isValidateEmail = validateEmail.evaluate(with: trimmedString)
        return isValidateEmail
    }
    
    public class func validatePhone(value: String) -> Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: value)
    }
    
    // MARK: - convertStringToDate
    public class func convertTimeString(toTime timeStr: String?) -> String? {
        // convert to date
        var time = ""
        if timeStr?.count ?? 0 > 0 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "H:mm"
            let date12 = dateFormatter.date(from: timeStr!)
            
            dateFormatter.dateFormat = "hh:mm a"
            time = dateFormatter.string(from: date12!)
        }
        return time
    }
    
   
    // MARK: - convertStringToDate
    public class func convertTimeToTimeAgo(dateStr : String, dateFormate formate: String?, neededFormate neededFormat: String) -> String{
        let createdDate = AppManager.convertString(toDate: dateStr, dateFormate: formate)
        let quesSeconds = AppManager.diffrenceBetweenDatesSeconds(createdDate, end: Date())
        let quesMin = AppManager.diffrenceBetweenDatesMin(createdDate, end: Date())
        let quesHrs = AppManager.diffrenceBetweenDatesHrs(createdDate, end: Date())
        let dateTime = AppManager.changeDateFormat(dateStr: dateStr, dateFormate: formate, neededFormate: neededFormat)
        var timeAgoStr = ""
        if quesHrs > 24{
            timeAgoStr = "\(dateTime ?? "")"
        }else{
            if quesSeconds < 60{
                timeAgoStr = "\(quesSeconds) seconds ago"
            }
            else{
                let timeAgo = "\((quesMin > 60) ? "hours ago" : "min ago")"
                timeAgoStr = String(format: "%ld %@", (quesMin > 60) ? quesHrs : quesMin, timeAgo)
            }           
        }
        return timeAgoStr
    }
    
    // MARK: - convertStringToDate
    public class func convertString(toDate dateStr: String?, dateFormate formate: String?) -> Date? {
        // convert to date
        let dateFormat = DateFormatter()
        // ignore +11 and use timezone name instead of seconds from gmt
        dateFormat.dateFormat = formate ?? ""
        dateFormat.locale = .current
        let date: Date? = dateFormat.date(from: dateStr ?? "")
        return date
    }
    
    // MARK: - convertDateToString
    public class func convertDate(toString date: Date?, dateFormate formate: String?) -> String? {
        let dateFormat2 = DateFormatter()
        dateFormat2.dateFormat = formate ?? ""
        dateFormat2.locale = .current
        var dateString: String? = nil
        if let aDate = date {
            dateString = dateFormat2.string(from: aDate)
        }
        print("DateString: \(dateString ?? "")")
        return dateString
    }
    
    // MARK: - convertDateToString
    public class func changeDateFormat(dateStr: String, dateFormate formate: String?, neededFormate neededFormat: String) -> String? {
        
        let date = self.convertString(toDate: dateStr, dateFormate: formate)
        let dateString = self.convertDate(toString: date, dateFormate: neededFormat)
        return dateString
    }
    
    public class func compareDates(startDate: String, endDate: String, formate:String) -> Bool {
        
        let fromDate = self.convertString(toDate: startDate, dateFormate: formate)
        let toDate = self.convertString(toDate: endDate, dateFormate: formate)
        
        let fromInterval =  Int((fromDate?.timeIntervalSince1970)!)
        let toInterval = Int((toDate?.timeIntervalSince1970)!)
        
        if toInterval as Int >= fromInterval as Int {
            return true
        } else {
            return false
        }
    }
    
    public class func diffrenceBetweenDatesHrs(_ startdate: Date?, end enddate: Date?) -> Int {
        let nxtTime1 = Int(startdate?.timeIntervalSince1970 ?? 0)
        let nxtTime2 = Int(enddate?.timeIntervalSince1970 ?? 0)
        
        let diffrance = nxtTime2 - nxtTime1
        let hrs = diffrance / (60 * 60)
        return hrs
    }
    
    public class func diffrenceBetweenDatesMin(_ startdate: Date?, end enddate: Date?) -> Int {
        let nxtTime1 = Int(startdate?.timeIntervalSince1970 ?? 0)
        let nxtTime2 = Int(enddate?.timeIntervalSince1970 ?? 0)
        
        let diffrance = nxtTime2 - nxtTime1
        let min = diffrance / (60)
        return min
    }
    
    public class func diffrenceBetweenDatesSeconds(_ startdate: Date?, end enddate: Date?) -> Int {
        let nxtTime1 = Int(startdate?.timeIntervalSince1970 ?? 0)
        let nxtTime2 = Int(enddate?.timeIntervalSince1970 ?? 0)
        
        let diffrance = nxtTime2 - nxtTime1
        let seconds = diffrance
        return seconds
    }
    
    public class func diffrenceBetweenDatesSec(_ startdate: Date?, end enddate: Date?) -> Int {
        let nxtTime1 = Int(startdate?.timeIntervalSince1970 ?? 0)
        let nxtTime2 = Int(enddate?.timeIntervalSince1970 ?? 0)
        
        let diffrance = nxtTime2 - nxtTime1
        
        return diffrance
    }
    
    public class func diffrenceBetweenDatesYear(_ startdate: Date?, end enddate: Date?) -> Int {
        let nxtTime1 = Int(startdate?.timeIntervalSince1970 ?? 0)
        let nxtTime2 = Int(enddate?.timeIntervalSince1970 ?? 0)
        
        let diffrance = nxtTime2 - nxtTime1
        let days = diffrance / (60 * 60 * 24)
        let month = days / 30
        let year = month / 12
        
        return year
    }
    
    public class func diffrenceBetweenDatesMonth(_ startdate: Date?, end enddate: Date?) -> Int {
        let nxtTime1 = Int(startdate?.timeIntervalSince1970 ?? 0)
        let nxtTime2 = Int(enddate?.timeIntervalSince1970 ?? 0)
        
        let diffrance = nxtTime2 - nxtTime1
        
        let days = diffrance / (60 * 60 * 24)
        let month = days / 30
        
        return month
    }
    
    public class func diffrenceBetweenDatesDays(_ startdate: Date?, end enddate: Date?) -> Int {
        let nxtTime1 = Int(startdate?.timeIntervalSince1970 ?? 0)
        let nxtTime2 = Int(enddate?.timeIntervalSince1970 ?? 0)
        
        let diffrance = nxtTime2 - nxtTime1
        
        let days = diffrance / (60 * 60 * 24)
        
        return days
    }
    
    
    public class func getFormatedPrice(price: Double) -> String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let numberAsString = numberFormatter.string(from: NSNumber(value: price))!
        return numberAsString
    }
    
    
    // MARK: - JsonEncoding
    public class func stringifyJson(_ value: Any, prettyPrinted: Bool = true) -> String! {
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : nil
        if JSONSerialization.isValidJSONObject(value) {
            do {
                let data = try JSONSerialization.data(withJSONObject: value, options: options!)
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            }  catch {
                return ""
            }
        }
        return ""
    }
    
    // MARK: - ResponceStatus
    public class func getInt(for value : Any?) -> Int? {
        
        if let stateCode = value as? String {
            return Int(stateCode)
            
        }else if let stateCodeInt = value as? Int {
            return stateCodeInt
            
        }
        return nil
        
    }
    // MARK: - StringToDictionary
    public class func convertStringToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    // MARK: - Array To JSON
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    /*
    // MARK: - Get Address From Lat Long
    public class func getAddressFromLatLon(pdblLatitude: Double, withLongitude pdblLongitude: Double, completion completionBlock: @escaping (_ userAddress: userCurrentAddress?) -> Void) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(pdblLatitude)")!
        //21.228124
        let lon: Double = Double("\(pdblLongitude)")!
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        //let addressString : String = ""
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                
                if placemarks != nil {
                    
                    let pm = placemarks! as [CLPlacemark]
                    
                    if pm.count > 0 {
                        let pm = placemarks![0]
                        print(pm.country as Any)
                        print(pm.locality as Any)
                        print(pm.subLocality as Any)
                        print(pm.thoroughfare as Any)
                        print(pm.postalCode as Any)
                        print(pm.subThoroughfare as Any)
                        var addressString : String = ""
                        if pm.subLocality != nil {
                            addressString = addressString + pm.subLocality! + ", "
                        }
                        if pm.thoroughfare != nil {
                            addressString = addressString + pm.thoroughfare! + ", "
                        }
                        if pm.locality != nil {
                            addressString = addressString + pm.locality! + ", "
                        }
                        if pm.country != nil {
                            addressString = addressString + pm.country! + ", "
                        }
                        if pm.postalCode != nil {
                            addressString = addressString + pm.postalCode! + " "
                        }
                        let address = userCurrentAddress()
                        address.userAddress = addressString
                        address.userLocality = pm.locality ?? ""
                        address.latitude = lat
                        address.longitude = lon
                        completionBlock(address)
                        
                    }
                }
        })
    }
    */
    
    // MARK: - tableEmpty Message
    public class func tableEmpty(msg: String, tableView: UITableView) {
        
        let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        noDataLabel.text = msg
        noDataLabel.textColor = UIColor.black
        noDataLabel.textAlignment = .center
        tableView.backgroundView = noDataLabel
        tableView.separatorStyle = .none
    }
    
    // MARK: - Start Activity Indicator on table background
    public class func startActivityIndicator(baseView : UIView)
        {
            DispatchQueue.main.async {
                let activityIndicator = UIActivityIndicatorView(style: .large)
                activityIndicator.color = UIColor.appThemeColor
                activityIndicator.center = CGPoint(x: baseView.frame.size.width/2, y: baseView.frame.size.height/2)
                activityIndicator.startAnimating()
                activityIndicator.hidesWhenStopped = true
                activityIndicator.tag = 999999
                baseView.addSubview(activityIndicator)
                baseView.bringSubviewToFront(activityIndicator)
            }

        }

    // MARK: - Stop Activity Indicator on table background
    public class func stopActivityIndicator(baseView : UIView)
    {
        DispatchQueue.main.async {
            if let activityIndicator = baseView.subviews.filter(
                { $0.tag == 999999}).first as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Start Footer Activity Indicator on table background
    public class func startFooterActivityIndicator(baseView : UITableView)
    {
        DispatchQueue.main.async {
            let spinner = UIActivityIndicatorView(style: .medium)
           // let loadingTextLabel = UILabel()
            spinner.color = UIColor.appThemeColor
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: baseView.frame.size.width, height: CGFloat(44))
            spinner.hidesWhenStopped = true
            spinner.tag = 888888
            baseView.tableFooterView = spinner
            baseView.tableFooterView?.isHidden = false
            
        }
       
    }
    // MARK: - Stop Footer Activity Indicator on table background
    public class func stopFooterActivityIndicator(baseView : UITableView)
    {
        DispatchQueue.main.async {
            if let activityIndicator = baseView.subviews.filter(
                { $0.tag == 888888}).first as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }
    }

    struct ActivityIndicator {
        
        let viewForActivityIndicator = UIView()
        let view: UIView
        let navigationController: UINavigationController?
        let tabBarController: UITabBarController?
        let activityIndicatorView = UIActivityIndicatorView()
        let loadingTextLabel = UILabel()
        
        var navigationBarHeight: CGFloat { return navigationController?.navigationBar.frame.size.height ?? 0.0 }
        var tabBarHeight: CGFloat { return tabBarController?.tabBar.frame.height ?? 0.0 }
        
        func showActivityIndicator() {
            viewForActivityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            viewForActivityIndicator.backgroundColor = UIColor.white
            view.addSubview(viewForActivityIndicator)
            
            activityIndicatorView.center = CGPoint(x: self.view.frame.size.width / 2.0, y: (self.view.frame.size.height - tabBarHeight - navigationBarHeight) / 2.0)
            
            loadingTextLabel.textColor = UIColor.black
            loadingTextLabel.text = "LOADING"
            loadingTextLabel.font = UIFont(name: customFontRegular, size: 10)
            loadingTextLabel.sizeToFit()
            loadingTextLabel.center = CGPoint(x: activityIndicatorView.center.x, y: activityIndicatorView.center.y + 30)
            viewForActivityIndicator.addSubview(loadingTextLabel)
            
            activityIndicatorView.hidesWhenStopped = true
            activityIndicatorView.style = .large
            viewForActivityIndicator.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
        }
        
        func stopActivityIndicator() {
            viewForActivityIndicator.removeFromSuperview()
            activityIndicatorView.stopAnimating()
            activityIndicatorView.removeFromSuperview()
        }
    }
    
    
}

extension UITableView{
    
    public func setBackgroundMessage(_ message:String?) {
        let messageLabel = UILabel(frame: CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: customFontRegular, size: 15)
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel;
        self.separatorStyle = .none;
    }
    
}

extension UICollectionView {
    
    public func setBackgroundMessage(_ message:String?) {
        let messageLabel = UILabel(frame: CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: customFontRegular, size: 15)
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel;
        
    }
    
}

extension Date {
    
    func convertToString()->String {
        
    let formatter = DateFormatter()
    // initially set the format based on your datepicker date / server String
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

    let myString = formatter.string(from: self) // string purpose I add here
    // convert your string to date
    let yourDate = formatter.date(from: myString)
    //then again set the date format whhich type of output you need
    formatter.dateFormat = "yyyy-MM-dd"
    // again convert your date to string
    let myStringafd = formatter.string(from: yourDate!)

    print(myStringafd)
        
    return myStringafd
}
    
    
    static func getTimeAfterNHours(currentTime:String, nHours:Int, currentFormat:String) -> String{
       var df = DateFormatter()
       df.dateFormat = currentFormat
       
       let currentDate = df.date(from: currentTime) ?? Date()
       
       let modifiedDate = Calendar.current.date(byAdding: .hour, value:nHours, to: currentDate)!
       
       df = DateFormatter()
       df.dateFormat = "hh:mm a"
       
       return df.string(from: modifiedDate)
   }
    
    
}

public extension Dictionary {
    
    static func +<Key, Value> (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
        var result = lhs
        rhs.forEach{ result[$0] = $1 }
        return result
    }
    
    mutating func merge(with dictionary: [Key: Value]) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
    
    func merged(with dictionary: [Key: Value]) -> [Key: Value] {
        let dict = self
      //  dict.merge(with: dictionary)
        return dict
    }
}


public extension Double {
    
    static func convertToDouble(anyValue:Any) -> Double {
        var doubleValue = Double()
        let val = anyValue as? String ?? ""
        if val.isEmpty {
            doubleValue = anyValue as? Double ?? 0
        } else {
            doubleValue = Double(val) ?? 0
        }
        return doubleValue
    }
}


public extension Int {
    
    static func convertToInt(anyValue:Any) -> Int {
        var intValue = Int()
        let val = anyValue as? String ?? ""
        if val.isEmpty {
            intValue = anyValue as? Int ?? 0
        } else {
            intValue = Int(val) ?? 0
        }
        return intValue
    }
}

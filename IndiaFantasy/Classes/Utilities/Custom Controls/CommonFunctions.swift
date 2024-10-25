//
//  CommonFunctions.swift
//  Lifferent
//
//  Created by Octal Mac 217 on 01/11/21.
//

import UIKit
import SideMenu
import KeychainAccess
import FirebaseDynamicLinks

class CommonFunctions: NSObject {

    
    var timeCounter : Double = 0
    var updateDate : NSDate!
    var timer : Timer!
    var label : UILabel!
    var fromSeasonMyTeams = false
    var fromHome = false
    
    var vcontroller : UIViewController!
    
    
    static func saveKeychain(service:String, data:String!) {
        let keychain = Keychain(service: service)
        keychain[service] = data
    }
    
    static func getValuefromKeyChain(service:String) -> String{
        var value = ""
        let items = Keychain(service: service).allItems()
        for item in items{
            value = item["value"] as! String
        }
        
        return value;
    }
    
    static func suffixNumberIndian(currency:Double) -> String{
        var shortenedAmount = currency
        var suffix = ""
        if currency >= 10000000.0 {
            suffix = " Cr"
            shortenedAmount /= 10000000.0
        } else if currency >= 100000.0 {
            suffix = " Lakh"
            shortenedAmount /= 100000.0
        } 
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        let numberAsString = numberFormatter.string(from: NSNumber(value: shortenedAmount))

        var requiredString = "\(numberAsString?.replacingOccurrences(of: "$", with: "") ?? "")\(suffix)"
        
        requiredString = requiredString.replacingOccurrences(of: ".00", with: "")
        
        requiredString = requiredString.replacingOccurrences(of: "SAR", with: "")
        
        requiredString = requiredString.replacingOccurrences(of: "₹", with: "")
        
        requiredString = requiredString.trimmingCharacters(in: .whitespaces)

        return requiredString

    }
    
    static func suffixNumber(number:Double) -> String {

        var num:Double = number;
        let sign = ((num < 0) ? "-" : "" );

        num = fabs(num);

        if (num < 1000.0){
            return "\(sign)\(num)";
        }

        let exp:Int = Int(log10(num) / 3.0 ); //log10(1000));

        let units:[String] = ["K","M","G","T","P","E"];

        let roundedNum:Double = round(10 * num / pow(1000.0,Double(exp))) / 10;

        return "\(sign)\(roundedNum)\(units[exp-1])";
    }
    
    static func getCountryDetails(code:String) -> Country?{
        var countryCode = ""
        var countryName = ""
        var phoneCode = ""

        for jsonObject in CountryList {
            
            print("Code is: \(code)" )
            if jsonObject["code"] == code{
                countryCode = jsonObject["code"] ?? ""
                countryName = jsonObject["name"] ?? ""
                phoneCode = jsonObject["dial_code"] ?? ""
                break;
            }
        }
        
        let country = Country(name: countryName, code: countryCode, phoneCode: phoneCode)
        return country
    }
    
    static func getPhoneCode(by countryName:String) -> String?{

        if let country = CountryList.first(where: {$0["name"] == countryName}) {
            return country["dial_code"] ?? ""
        }
       
        return nil
    }
    
    public func setWelcomeVisitStatusTrue() {
        UserDefaults.standard.set(true, forKey: "tutorial_visited")
        UserDefaults.standard.synchronize()
    }
    
    public static func getWelcomeVisitStatus() -> Bool? {
        if UserDefaults.standard.bool(forKey: "tutorial_visited"){
            let isVisited = UserDefaults.standard.bool(forKey: "tutorial_visited")
            return isVisited

        }
        return false
    }
 
    //MARK:- Save & Get User Login First Time Status
    public var isUserLoginFirstTime: Bool {
        set(value){
            UserDefaults.standard.set(value, forKey: "login_First_Time")
        }
        get{
            UserDefaults.standard.value(forKey: "login_First_Time") as? Bool ?? false
        }
    }
    
    class func getDateFromString(date:String, format : String) -> Date? {
        let dateFormator = DateFormatter()
        dateFormator.locale =  Locale.init(identifier: "en_US")
//         dateFormator.timeZone = NSTimeZone.local
        dateFormator.dateFormat = format
        if date.count > 0 {
            if let dt = (dateFormator.date(from: date)) {
                return dt   
            }else{
                if let convertedDate = date.UTCToLocalDate(incomingFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"){
                    print(CommonFunctions.getStringFromDate(date: convertedDate, format: "HH:mm:ss") ?? "")
                    return convertedDate
                }else if let convertedDate = CommonFunctions.getDateFromString(date: date, format: "yyyy-MM-dd'T'HH:mm"){
                    print(CommonFunctions.getStringFromDate(date: convertedDate, format: "HH:mm:ss") ?? "")
                    return convertedDate
                }
                else{
                    return nil
                }
            }
        }
        else{
            return nil
            
        }
    }
    
    class func getStringFromDate(date:Date, format : String) -> String? {
        let dateFormator = DateFormatter()
        dateFormator.dateFormat = format
        let dt = dateFormator.string(from: date)
       
        //print("Converted Date-->",dt as Any)
        return dt
    }
    
    class func getNewRemainingTimeWith(strDate : String?, serverDate : String?) -> Date {
        
        let gmtDate = CommonFunctions.getDateFromString(date: strDate ?? "", format: "yyyy-MM-dd'T'HH:mm:ss")
        let correctDate =  gmtDate ?? CommonFunctions.getDateFromString(date: serverDate ?? "", format: "yyyy-MM-dd'T'HH:mm:ss") ?? Date()
        
       // print("corrected date-->",correctDate)
        return correctDate
        
    }
    
    class func getNewRemainingTimeWith(strDate : String?, strTime : String?) -> Date {

        var strtDate = strDate
        strtDate = strtDate! + "T" + strTime!
       
        let gmtDate = CommonFunctions.getDateFromString(date: strtDate ?? "", format: "yyyy-MM-dd'T'HH:mm:ss")
        let correctDate =  gmtDate ?? CommonFunctions.getDateFromString(date: strtDate ?? "", format: "yyyy-MM-dd'T'HH:mm:ss") ?? Date()
        return correctDate
        
    }
    
    func timerStart(date: UILabel ,strTime : String!, strDate: String!,viewcontroller:UIViewController!)  {
        label = date
        fromSeasonMyTeams = false
        let strtDate = strDate.components(separatedBy: "T")
        
        let matchDate = CommonFunctions.getNewRemainingTimeWith(strDate : strtDate[0], strTime : strTime ?? "")
        vcontroller = viewcontroller
        updateDate = self.timeshowinLabel(releaseDate: matchDate as NSDate, time: date, timer: nil,vc: viewcontroller, fromSeasonMyTeams: fromSeasonMyTeams, isFromHome: false)
        let elapseTimeInSeconds =  matchDate.timeIntervalSince(Date())
        timeCounter = elapseTimeInSeconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.onComplete), userInfo: nil, repeats: true)
    }
    
    func timerStart(lblTime: UILabel , strDate: String!, viewcontroller:UIViewController!, fromSeasonMyTeams:Bool = true, isFromHome: Bool = false) {
        
        label = lblTime
        self.fromSeasonMyTeams = fromSeasonMyTeams
        self.fromHome = isFromHome
        
        let gmtDate = CommonFunctions.getDateFromString(date: strDate ?? "", format: "yyyy-MM-dd'T'HH:mm:ss")
        let matchDate = gmtDate ?? CommonFunctions.getDateFromString(date: strDate ?? "", format: "yyyy-MM-dd'T'HH:mm:ss") ?? Date()
        
        vcontroller = viewcontroller
        updateDate = self.timeshowinLabel(releaseDate: matchDate as NSDate, time: lblTime, timer: nil,vc: viewcontroller, fromSeasonMyTeams: fromSeasonMyTeams, isFromHome: isFromHome)
        let elapseTimeInSeconds =  matchDate.timeIntervalSince(Date())
        timeCounter = elapseTimeInSeconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.onComplete), userInfo: nil, repeats: true)
    }


    @objc func onComplete() {
        guard timeCounter >= 0 else {
            label.text     = GDP.selectedMatch?.match_status?.capitalized ?? "Match Started"
            timer?.invalidate()
            timer = nil
            return
        }

        updateDate = CommonFunctions().timeshowinLabel(releaseDate: updateDate as NSDate, time: label, timer: nil, vc: vcontroller, fromSeasonMyTeams: fromSeasonMyTeams, isFromHome: fromHome)

    }
    
    static func changeDateFormatStr(currentFormat:String, targetFormat:String, date:String) -> String?{
           
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = currentFormat
            
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // fixes nil if device time in 24 hour format
            guard let date = dateFormatter.date(from: date) else { return nil }
            dateFormatter.dateFormat = targetFormat
           
            let date12 = dateFormatter.string(from: date)
            return date12
    }
    
    func timeshowinLabel(releaseDate : NSDate!,time :UILabel!,timer: Timer! ,vc:UIViewController!, fromSeasonMyTeams: Bool, isFromHome: Bool) -> NSDate {
        let currentDate = Date()
        let calendar = Calendar.current
        let matchDate : Date = releaseDate! as Date
        
        let diffDateComponents = calendar.dateComponents([.hour, .minute, .second], from: currentDate.toLocalTime(), to: matchDate.toLocalTime())
        var leftTime = ""
        
        //print("matchDate-->",matchDate.toLocalTime())
        if(diffDateComponents.hour ?? 0 >= 0 && diffDateComponents.minute ?? 0 >= 0  && diffDateComponents.second ?? 0 >= 0 )
        {
            //print("diffDateComponents-->",diffDateComponents)
            if diffDateComponents.hour ?? 0 > 24{
                let diffDayComponents = calendar.dateComponents([.day, .hour, .minute], from: currentDate.toLocalTime(), to: matchDate.toLocalTime())
                leftTime = "\(diffDayComponents.day ?? 0)d : \(diffDayComponents.hour ?? 0)h"

            }
            else if diffDateComponents.hour ?? 0 >= 1
            {
                leftTime = "\(diffDateComponents.hour ?? 0)h : \(diffDateComponents.minute ?? 0)m"
            }
            else
            {
                leftTime = "\(diffDateComponents.minute ?? 0)m : \(diffDateComponents.second ?? 0)s"
            }
            
            DispatchQueue.main.async {
                if fromSeasonMyTeams == true {
                    time.text = "Closes in " + leftTime
                }else if isFromHome == true{
                    time.text = leftTime
                }else {
                    time.text = leftTime + " left"
                }
            }
        
            return matchDate as (NSDate)

        }
        else
        {
            DispatchQueue.main.async {
                time.text = ""
            }
           
            timer?.invalidate()
           // timer = nil
            return matchDate as NSDate
        }
    }
    
    static func getCountryFromCode(dialCode:String) -> Country?{
        var model:Country? = nil
        
        for country in CountryList{
            if country["dial_code"] == dialCode{
                model = Country(name: country["name"] ?? "", code:  country["code"] ?? "", phoneCode: country["dial_code"] ?? "")
                break
            }
        }
        return model
    }
    
    static func getUITextFieldWithLoginUI (textfield:UITextField, padding:CGFloat) -> UITextField{
        textfield.borderWidth = 1.0
        textfield.borderColor = Constants.kTextFieldColor
        textfield.setLeftPaddingPoints(padding)
        
        return textfield
    }
    
    static func getUITextViewUI (textView:UITextView, padding:CGFloat) -> UITextView{
        textView.borderWidth = 1.0
        textView.borderColor = Constants.kTextFieldColor
        textView.textContainer.lineFragmentPadding = padding
        
        return textView
    }
    
    static func getUITextFieldOfDatePicker (textfield:UITextField, padding:CGFloat) -> UITextField{
        textfield.borderWidth = 1.0
        textfield.borderColor = Constants.kTextFieldColor
        textfield.setLeftPaddingPoints(padding)
        
        return textfield
    }
    
    static func getUITextFieldWithPromoCodeUI (textfield:UITextField) -> UITextField{
        textfield.setLeftPaddingPoints(10)
        
        return textfield
    }
    
    static func getItemFromInternalResourcesforKey(key:String) -> [[String:Any]] {
        
        let url = Bundle.main.url(forResource: "InternalItems", withExtension: "plist")!
        let equipmentsData = try! Data(contentsOf: url)
        let dictEquipments = try! PropertyListSerialization.propertyList(from: equipmentsData, options: [], format: nil) as! [String : Any]
        
        let arrItems = dictEquipments[key] as! [[String:Any]]
        
        return arrItems
    }
    
    static func getStringItemFromInternalResourcesforKey(key:String) -> [String] {
        
        let url = Bundle.main.url(forResource: "InternalItems", withExtension: "plist")!
        let equipmentsData = try! Data(contentsOf: url)
        let dictEquipments = try! PropertyListSerialization.propertyList(from: equipmentsData, options: [], format: nil) as! [String : Any]
        
        let arrItems = dictEquipments[key] as! [String]
        
        return arrItems
    }
    
    static func getArrayforKey(key:String, array:[[String:Any]]) -> [String]{
        var arr = [String]()
            for dict in array {
                arr.append(dict[key] as! String)
        }
        
        return arr
    }
    
    static func getUIButtonWithLoginUI (button:UIButton) -> UIButton{
//        button.cornerRadius = 25.0
        return button
    }
    
    static func setupSideMenu(controller:UIViewController!) {
        // Define the menus
        SideMenuManager.default.leftMenuNavigationController = Constants.KSideMenuStoryboard.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
          // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
        SideMenuManager.default.addPanGestureToPresent(toView: controller.navigationController!.navigationBar)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: controller.view)
        
        var settings = SideMenuSettings()
        settings.menuWidth = Constants.kScreenWidth * 0.80
        settings.presentationStyle = .menuSlideIn
        SideMenuManager.default.leftMenuNavigationController?.settings = settings

    }
    
    static func updateSecureTextEntry(txtf:UITextField) -> Bool{
        txtf.isSecureTextEntry = !txtf.isSecureTextEntry
        return txtf.isSecureTextEntry
    }
    
    static func getCombinedAttributedString(first:String, second:String) -> NSMutableAttributedString{
        
        let attr1 = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: customFontBold, size: 16.0)]
        let attr2 = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: customFontBold, size: 12.0)]
        
        
        let partOne = NSMutableAttributedString(string: (first), attributes: attr1 as [NSAttributedString.Key : Any])
        let partTwo = NSMutableAttributedString(string: second, attributes: attr2 as [NSAttributedString.Key : Any])
        
        let combination = NSMutableAttributedString()
        combination.append(partOne)
        combination.append(partTwo)
        
        return combination
    }
    
    
    static func getWelcomeAttributedString(first:String, second:String) -> NSMutableAttributedString{
        
        let attr1 = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: kanitFontBold, size: 22.0)]
        let attr2 = [NSAttributedString.Key.foregroundColor: UIColor.appHighlightedTextColor, NSAttributedString.Key.font: UIFont(name: kanitFontBold, size: 22.0)]
        
        
        let partOne = NSMutableAttributedString(string: (first), attributes: attr1 as [NSAttributedString.Key : Any])
        let partTwo = NSMutableAttributedString(string: second, attributes: attr2 as [NSAttributedString.Key : Any])
        
        let combination = NSMutableAttributedString()
        combination.append(partOne)
        combination.append(partTwo)
        
        return combination
    }
    
    static func isValidPassword(password:String) -> Bool {
        
        //Minimum 8 characters at least 1 Uppercase 1 lowercase 1 special charater and 1 Number:
        
        let passwordRegex = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&<>*~:`-]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    static func isValidIFSCCode(code:String) -> Bool {
        
        //The IFSC is an 11-character code with the first four alphabetic characters representing the bank name, and the last six characters (usually numeric, but can be alphabetic) representing the branch. The fifth character is 0 (zero) and reserved for future use. Bank IFS Code is used by the NEFT & RTGS systems to route the messages to the destination banks/branches.
        let passwordRegex = "^[A-Z]{4}[0][A-Z0-9]{6}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: code)
    }
    
    
   static func validatePANCardNumber(_ strPANNumber : String) -> Bool{
            let regularExpression = "[A-Z]{5}[0-9]{4}[A-Z]{1}"
            let panCardValidation = NSPredicate(format : "SELF MATCHES %@", regularExpression)
            return panCardValidation.evaluate(with: strPANNumber)
        }
    
    static func getDateFromString(strDate:String?, currentFormat:String, requiredFormat:String) -> String{
        if let strDate = strDate {
            if strDate == ""{
                return ""
            }
            var date = Date()
            var df = DateFormatter()
            df.dateFormat = currentFormat
            if let myDate = df.date(from: strDate){
                date = myDate
                df = DateFormatter()
                df.dateFormat = requiredFormat
                return df.string(from: date)
            }
        }
        return ""
    }
    
    static func getDateFromDate(date:Date?, requiredFormat:String) -> String{
                
        let df = DateFormatter()
        df.dateFormat = requiredFormat
        
        return df.string(from: date ?? Date())
    }
    
    
    static func getDateFromStringInLocalTime(strDate:String, currentFormat:String, requiredFormat:String) -> String{
        let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = currentFormat
       dateFormatter.locale = Locale(identifier: "en_US_POSIX")
       dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
       if let dt = dateFormatter.date(from: strDate) {
           dateFormatter.locale = Locale.current
           dateFormatter.timeZone = TimeZone.current
           dateFormatter.dateFormat = requiredFormat

           return dateFormatter.string(from: dt)
       }
        else {
           return ""
       }
    }
    
    
    static func compareDate(date1:Date, date2:Date) -> Bool {
        let order = NSCalendar.current.compare(date1, to: date2, toGranularity: .day)
        switch order {
        case .orderedSame:
            return true
        default:
            return false
        }
    }
    
    static func shareDatafromTheApp(title:String, subtitle:String, image:UIImage?, controller:UIViewController){
        // Setting description
        let firstActivityItem = title
        let activityViewController : UIActivityViewController = UIActivityViewController(
        activityItems: [firstActivityItem, subtitle, image ?? UIImage()], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = controller.view // so that iPads won't crash
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
          // present the view controller
        controller.present(activityViewController, animated: true, completion: nil)
    }
    
    static func createEmailUrl(to: String, subject: String, body: String) -> URL? {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!

        let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)")
        let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")

        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
            return gmailUrl
        } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
            return outlookUrl
        } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
            return yahooMail
        } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
            return sparkUrl
        }

        return defaultUrl
    }
    
    func getDynamicLink(link: URL, completion completionBlock: @escaping (_ dynamicLink: String) -> Void){
        
        let dynamicLinksDomainURIPrefix = "\(URLMethods.DeepLinkURL)"
        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix)
        linkBuilder!.iOSParameters = DynamicLinkIOSParameters(bundleID: Constants.kBundleID ?? "")
        linkBuilder!.androidParameters = DynamicLinkAndroidParameters(packageName: Constants.kAndroiPackageName)
        linkBuilder!.iOSParameters?.appStoreID = Constants.kAppStoreID

        linkBuilder!.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        linkBuilder!.socialMetaTagParameters?.title = link.absoluteString.contains("referralCode") ? "Join The India’s fantasy Now!" : "Join the contest now!"
        linkBuilder!.socialMetaTagParameters?.descriptionText = "Start playing on India’s fantasy."

        guard var dynamicLink = linkBuilder?.url?.absoluteString else {
            completionBlock("")
            return
        }
        print("The long URL is: \(dynamicLink)")

        linkBuilder!.shorten() { url, warnings, error in
        
            if let url = url, error == nil {
                dynamicLink = url.absoluteString
                print("The short URL is: \(url.absoluteString)")
            }
            completionBlock(dynamicLink)
        }
    }
}
extension String {
    var boolValue: Bool {
        return (self as NSString).boolValue
    }
    
    
}

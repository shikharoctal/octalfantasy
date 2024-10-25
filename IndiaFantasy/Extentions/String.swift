
import Foundation
import UIKit


extension String {
    
    func UTCToLocal(incomingFormat: String, outGoingFormat: String) -> String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = incomingFormat
      dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

      let dt = dateFormatter.date(from: self)
      dateFormatter.timeZone = TimeZone.current
      dateFormatter.dateFormat = outGoingFormat

      return dateFormatter.string(from: dt ?? Date())
    }

    
    func UTCToLocalDate(incomingFormat: String) -> Date? {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = incomingFormat
      //dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if self.count > 0{
            let dt = (dateFormatter.date(from: self)) 
            return dt
        }else{
            return nil
            
        }

    }
    
    func convertJsonStringToDictionary() -> [String:Any]?{
          let jsonText = self
          var dictonary:NSDictionary?
          if let data = jsonText.data(using: String.Encoding.utf8) {
              do {
                  dictonary = (try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]) as NSDictionary?
              } catch let error as NSError {
                  print(error)
              }
          }
        
        return dictonary as? [String:Any]
    }
    
    
    //MARK:- Convert Local To UTC Date by passing date formats value
    func localToUTC(incomingFormat: String, outGoingFormat: String) -> String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = incomingFormat
      dateFormatter.calendar = NSCalendar.current
      dateFormatter.timeZone = TimeZone.current

      let dt = dateFormatter.date(from: self)
      dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
      dateFormatter.dateFormat = outGoingFormat

      return dateFormatter.string(from: dt ?? Date())
    }
    
    func makeAttributedString(for attributes: [(title: String, color: UIColor, font: UIFont)]) -> NSAttributedString {
        
        let attributedText = NSMutableAttributedString()
        
        _ = attributes.map {
            let str: NSString = self as NSString
            let range = (str).range(of: $0.title)
            let attribute = [NSAttributedString.Key.font: $0.font,
                             NSAttributedString.Key.foregroundColor: $0.color]
            
            let string = NSMutableAttributedString.init(string: self)
            string.addAttributes(attribute, range: range)
            attributedText.append(string)
        }
        return attributedText
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func fileExtension() -> String? {
        let url = Bundle.main.url(forResource: self, withExtension: "")
        return url?.deletingPathExtension().lastPathComponent
    }
    
    func makeURL() -> URL? {
        return URL(string: self)
    }
    
    public func replace(string: String, replacement: String) -> String
    {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    var floatValue: Float {
        return (self as NSString).floatValue
    }
    
    var doubleValue : Double {
        if let value = Double(self.components(separatedBy: CharacterSet.init(charactersIn: "0123456789.").inverted).joined(separator: ""))
        {
            return value
        }else{
            return 0.0
        }
    }
    
    
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    
    var date: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: self)
        {
            return date
        }
        print("Invalid arguments ! Returning Current Date . ")
        return Date()
    }
    
    
    public func date(from format: String, UTC: Bool = true) -> Date {
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        if UTC { //for GMT Time
            formatter.timeZone = TimeZone(identifier: "UTC")
        }
        
        formatter.dateFormat = format //"yyyy-MM-dd HH:mm:ss.SSS"//2014-09-23 15:15:28.252
        
        let defaultTimeZoneStr = formatter.date(from: self)
        
        return defaultTimeZoneStr ?? Date()
    }
   
     var isNumber: Bool {
           return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
       }
    
}


extension NSMutableAttributedString {
    var fontSize:CGFloat { return 16}
    var boldFont:UIFont { return UIFont(name: "SFProText-Semibold", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize) }
    var normalFont:UIFont { return UIFont(name: "SFProText-Light", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)}
    
    func bold(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : boldFont]
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    func boldWithColor(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : boldFont,
            .foregroundColor : UIColor.red]
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func normal(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : normalFont,
            .foregroundColor : UIColor.black]
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func normalTerm(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : normalFont,
            .foregroundColor : UIColor.attributedTextColor]
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    /* Other styling methods */
    func normalwithHighlight(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.appHighlightedTextColor]
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func boldWithHighlight(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  boldFont,
            .foregroundColor : UIColor.appThemeColor]
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func underlined(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .underlineStyle : NSUnderlineStyle.single.rawValue,
            .foregroundColor : UIColor.appThemeColor]
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y:
            locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}


import Foundation

internal let DEFAULT_MIME_TYPE = "application/octet-stream"

internal let mimeTypes = [
    "md": "text/markdown",
    "html": "text/html",
    "htm": "text/html",
    "shtml": "text/html",
    "css": "text/css",
    "xml": "text/xml",
    "gif": "image/gif",
    "jpeg": "image/jpeg",
    "jpg": "image/jpeg",
    "js": "application/javascript",
    "atom": "application/atom+xml",
    "rss": "application/rss+xml",
    "mml": "text/mathml",
    "txt": "text/plain",
    "jad": "text/vnd.sun.j2me.app-descriptor",
    "wml": "text/vnd.wap.wml",
    "htc": "text/x-component",
    "png": "image/png",
    "tif": "image/tiff",
    "tiff": "image/tiff",
    "wbmp": "image/vnd.wap.wbmp",
    "ico": "image/x-icon",
    "jng": "image/x-jng",
    "bmp": "image/x-ms-bmp",
    "svg": "image/svg+xml",
    "svgz": "image/svg+xml",
    "webp": "image/webp",
    "woff": "application/font-woff",
    "jar": "application/java-archive",
    "war": "application/java-archive",
    "ear": "application/java-archive",
    "json": "application/json",
    "hqx": "application/mac-binhex40",
    "doc": "application/msword",
    "pdf": "application/pdf",
    "ps": "application/postscript",
    "eps": "application/postscript",
    "ai": "application/postscript",
    "rtf": "application/rtf",
    "m3u8": "application/vnd.apple.mpegurl",
    "xls": "application/vnd.ms-excel",
    "eot": "application/vnd.ms-fontobject",
    "ppt": "application/vnd.ms-powerpoint",
    "wmlc": "application/vnd.wap.wmlc",
    "kml": "application/vnd.google-earth.kml+xml",
    "kmz": "application/vnd.google-earth.kmz",
    "7z": "application/x-7z-compressed",
    "cco": "application/x-cocoa",
    "jardiff": "application/x-java-archive-diff",
    "jnlp": "application/x-java-jnlp-file",
    "run": "application/x-makeself",
    "pl": "application/x-perl",
    "pm": "application/x-perl",
    "prc": "application/x-pilot",
    "pdb": "application/x-pilot",
    "rar": "application/x-rar-compressed",
    "rpm": "application/x-redhat-package-manager",
    "sea": "application/x-sea",
    "swf": "application/x-shockwave-flash",
    "sit": "application/x-stuffit",
    "tcl": "application/x-tcl",
    "tk": "application/x-tcl",
    "der": "application/x-x509-ca-cert",
    "pem": "application/x-x509-ca-cert",
    "crt": "application/x-x509-ca-cert",
    "xpi": "application/x-xpinstall",
    "xhtml": "application/xhtml+xml",
    "xspf": "application/xspf+xml",
    "zip": "application/zip",
    "bin": "application/octet-stream",
    "exe": "application/octet-stream",
    "dll": "application/octet-stream",
    "deb": "application/octet-stream",
    "dmg": "application/octet-stream",
    "iso": "application/octet-stream",
    "img": "application/octet-stream",
    "msi": "application/octet-stream",
    "msp": "application/octet-stream",
    "msm": "application/octet-stream",
    "docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    "pptx": "application/vnd.openxmlformats-officedocument.presentationml.presentation",
    "mid": "audio/midi",
    "midi": "audio/midi",
    "kar": "audio/midi",
    "mp3": "audio/mpeg",
    "ogg": "audio/ogg",
    "m4a": "audio/x-m4a",
    "ra": "audio/x-realaudio",
    "3gpp": "video/3gpp",
    "3gp": "video/3gpp",
    "ts": "video/mp2t",
    "mp4": "video/mp4",
    "mpeg": "video/mpeg",
    "mpg": "video/mpeg",
    "mov": "video/quicktime",
    "webm": "video/webm",
    "flv": "video/x-flv",
    "m4v": "video/x-m4v",
    "mng": "video/x-mng",
    "asx": "video/x-ms-asf",
    "asf": "video/x-ms-asf",
    "wmv": "video/x-ms-wmv",
    "avi": "video/x-msvideo"
]

internal func MimeType(ext: String?) -> String {
    let lowercase_ext: String = ext!.lowercased()
    if ext != nil && mimeTypes.contains(where: { $0.0 == lowercase_ext }) {
        return mimeTypes[lowercase_ext]!
    }
    return DEFAULT_MIME_TYPE
}

extension NSURL {
    public func mimeType() -> String {
        return MimeType(ext: self.pathExtension)
    }
}


extension NSString {
    public func mimeType() -> String {
        return MimeType(ext: self.pathExtension)
    }
}

extension String {
    public func mimeType() -> String {
        return (self as NSString).mimeType()
    }
    
    func getShortName() -> String{
        var playerName = self.components(separatedBy: " ")
        var strName = ""
        if self.count > 0 {
            strName = playerName.last ?? ""
            playerName.removeLast()
            var prefix = ""
            for str in playerName {
                if str != ""
                {
                    prefix = prefix + "\(String((str.first ?? self.character(at: 0))!)). "
                }
                
            }
            strName = prefix + strName
        }else {
            strName = self
        }
        
        return strName
    }
}


extension CALayer {

    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {

        let border = CALayer()

        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: self.frame.height - thickness, width: UIScreen.main.bounds.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height)
            break
        default:
            break
        }

        border.backgroundColor = color.cgColor;

        self.addSublayer(border)
    }

}


fileprivate struct AssociatedKeys {
    static var index = 0
}

extension UIButton {

    var indexPath: IndexPath? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.index) as? IndexPath
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.index, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension Date {
    
    func timeAgoSinceDate() -> String {
        
        // From Time
        let fromDate = self
        
        // To Time
        let toDate = Date()
        
        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "year ago" : "\(interval)" + " " + "years ago"
        }
        
        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "month ago" : "\(interval)" + " " + "months ago"
        }
        
        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "day ago" : "\(interval)" + " " + "days ago"
        }
        
        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "hour ago" : "\(interval)" + " " + "hours ago"
        }
        
        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "minute ago" : "\(interval)" + " " + "minutes ago"
        }
        
        return "a moment ago"
    }
}
    

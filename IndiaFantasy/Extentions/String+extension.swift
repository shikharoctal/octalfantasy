//
//  String.swift
//  VPay
//
//  Created by Pankaj on 02/12/21.
//

import Foundation
import UIKit

extension String {
    func replaceAll(with char: Int) -> String {
        var starC = ""
        for _ in 0..<char{
            starC.append("*")
        }
       return starC
    }
}

enum DateStyle: String {
    case utcDate = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    case consoleDate = "yyyy-MM-dd HH:mm:ss Z"
}

extension String {
    func date(formate: DateStyle) -> Date? {
        let sourceFormatter = DateFormatter()
        sourceFormatter.timeZone = TimeZone(abbreviation: "UTC")
        sourceFormatter.dateFormat = formate.rawValue
        let sourceDate = sourceFormatter.date(from: self)
        return sourceDate
    }
    func dateConversion(_ sourceDateFormate: DateStyle, targetDateFormate: DateStyle, selectedTimeZone: String = "UTC") -> String? {
        let sourceFormatter = DateFormatter()
        sourceFormatter.locale = Locale(identifier: "en_US_POSIX")
        sourceFormatter.dateFormat = sourceDateFormate.rawValue
        sourceFormatter.timeZone = TimeZone(abbreviation: selectedTimeZone)
        if let sourceDate = sourceFormatter.date(from: self) {
            let timeZone = TimeZone(abbreviation: selectedTimeZone)
            let timezoneOffset = timeZone?.secondsFromGMT(for: sourceDate) ?? 0
            let targetFormatter = DateFormatter()
            let timestamp = sourceDate.timeIntervalSince1970
            let timezoneEpochOffset = timestamp + Double(timezoneOffset)
            targetFormatter.dateFormat = targetDateFormate.rawValue
            let targetDate = targetFormatter.string(from: sourceDate)
            let newDate = Date(timeIntervalSince1970: timezoneEpochOffset)
            debugPrint(newDate)
            return targetDate
        }
        return nil
    }
    func dateNewConversion(_ sourceDateFormate: DateStyle, targetDateFormate: DateStyle, selectedTimeZone: String = "UTC") -> Date? {
        let sourceFormatter = DateFormatter()
        sourceFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        sourceFormatter.dateFormat = sourceDateFormate.rawValue
        sourceFormatter.timeZone = TimeZone(abbreviation: selectedTimeZone)
        if let sourceDate = sourceFormatter.date(from: self) {
            let timeZone = TimeZone(abbreviation: selectedTimeZone)
            let timezoneOffset = timeZone?.secondsFromGMT(for: sourceDate) ?? 0
            let targetFormatter = DateFormatter()
            let timestamp = sourceDate.timeIntervalSince1970
            let timezoneEpochOffset = timestamp + Double(timezoneOffset)
            targetFormatter.dateFormat = targetDateFormate.rawValue
            let targetDate = targetFormatter.string(from: sourceDate)
            let newDate = Date(timeIntervalSince1970: timezoneEpochOffset)
            let data = sourceFormatter.date(from: targetDate)
            debugPrint(newDate)
            return data
        }
        return nil
    }
    // MARK: - Methods
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
    func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    func addSpaceAtBeginning() -> String {
        " " + self
    }
    
    var condensedWhitespace: String {
            let components = self.components(separatedBy: .whitespacesAndNewlines)
            return components.filter { !$0.isEmpty }.joined(separator: " ")
        }
}
extension String {
    
    public func isImageType() -> Bool {
        // image formats which you want to check
        let imageFormats = ["jpg", "png", "gif"]

        if URL(string: self) != nil  {

            let extensi = (self as NSString).pathExtension

            return imageFormats.contains(extensi)
        }
        return false
    }
    
    var isEmptyOrWhitespace : Bool {
        // Check empty string
        if self.isEmpty {
            return true
        }
        // Trim and check empty string
        return (self.trimmingCharacters(in: .whitespaces) == "")
    }
    
    var isEmptyOrNextWhitespace : Bool {
        // Check empty string
        if self.isEmpty {
            return true
        }
        // Trim and check empty string
        return (self.trimmingCharacters(in: .whitespacesAndNewlines) == "")
    }
    
    func subscriptionDateStringFormatter() -> String{
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
        dateformatter.locale = Locale(identifier: "en")
        
        if let date = dateformatter.date(from: self) {
            dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return dateformatter.string(from: date)
        }
        return self
    }
    
    func subscriptionAppleDateFormatter() -> Date? {
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
        
        let loc = Locale(identifier: "en")
        dateformatter.locale = loc
        
        if let date = dateformatter.date(from: self) {
            return date
        }
        return nil
    }
    
    func subscriptionDateFormatter() -> Date? {
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateformatter.locale = Locale(identifier: "en")
        
        if let date = dateformatter.date(from: self) {
            return date
        }
        
        return nil
    }
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

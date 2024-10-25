

import UIKit

// MARK: - App Color Codes

extension UIColor {
    
    enum Color: String {
        case primary = "023D44"
        case textPrimary = "001E20"
        case purple = "641DB1"
        case yellow = "FFD600"
        case red = "E23333"
        case light = "C7D0FF"
        case blue = "C8D0FF"
        case grey = "7C8494"
        case darkBlue = "4A0CCC"
        case green = "61E15D"
        case darkGreen = "498100"
        case separator = "8B3ADB"
        case storySeparator = "DFE2E7"
        case notch = "CBCDCC"
        case chatText = "010101"
        case chatBg = "DFE7FF"
        case lightGrey = "969696"
        case borderColor = "FFFFFF"
        case bgColor = "E5E5E5"
        case statusBlue = "0313A1"
        case ratingColor = "e5e5e5"
        case ekycSelectedColor = "19638E"
        case lightGrayText = "B2B2B2"
        case timeGreen = "6EC631"
        case headerYellow = "F7B32B"
        case footerBackground = "13212D"
        case boosterDisableColor = "5B6F84"
        case headerDark = "243848"
        case backgroundDark = "0B1823"
        case headerBlue = "22474F"
        
        case standardBooster = "344452"
        case eliteBooster = "413452"
        case legendaryBooster = "7C754E"
        case filterBG = "607180"
        case blue_0E4990 = "0E4990"
        case orange_EA7643 = "EA7643"
        
        // MARK: -
        var value: UIColor {
            UIColor.hexStringToUIColor(hex: rawValue)
        }
    }
    
    public class var appLightGrayText: UIColor {
        get {
            return #colorLiteral(red: 0.6980392157, green: 0.6980392157, blue: 0.6980392157, alpha: 1) //color_literal //UIColor(hex: "B2B2B2")
        }
    }
    
    public class var appTextFieldBorder: UIColor {
        get {
            return #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.9176470588, alpha: 1) //color_literal //UIColor(hex: "E6E6E6")
        }
    }
//    open class var appThemeColor: UIColor {
//        get {
//            return #colorLiteral(red: 0.8392156863, green: 0.1333333333, blue: 0.2745098039, alpha: 1)  //color_literal //UIColor(hex: "#CD2133")
//        }
//    }
    
    public class var appThemeColor: UIColor {
        get {
            return #colorLiteral(red: 0.06666666667, green: 1, blue: 0.7411764706, alpha: 1)  //color_literal //UIColor(hex: "#CD2133")
        }
    }
    
    public class var appThemePrimaryColor: UIColor {
        get {
            return #colorLiteral(red: 0.1294117647, green: 0.4156862745, blue: 0.5607843137, alpha: 1)  //color_literal //UIColor(hex: "#CD2133")
        }
    }
    
    
    
    public class var appFilterTitleColor: UIColor {
        get {
            return #colorLiteral(red: 0.06666666667, green: 1, blue: 0.7411764706, alpha: 1)  //color_literal //UIColor(hex: "#CD2133")
        }
    }
    
    
    
    public class var appLocalTeamBackgroundColor: UIColor {
        get {
//            return #colorLiteral(red: 0.8, green: 0.3607843137, blue: 0.03529411765, alpha: 1)  //color_literal //UIColor(hex: "#CD2133") // old
            return #colorLiteral(red: 0.6588235294, green: 0, blue: 0, alpha: 1)  //color_literal //UIColor(hex: "#A80000") // new
        }
    }
    
    public class var appVisitorTeamBackgroundColor: UIColor {
        get {
//            return #colorLiteral(red: 0.07450980392, green: 0.1294117647, blue: 0.1764705882, alpha: 1)  //color_literal //UIColor(hex: "#CD2133") // old
            return #colorLiteral(red: 0.05490196078, green: 0.2862745098, blue: 0.5647058824, alpha: 1)  //color_literal //UIColor(hex: "##0E4990") // new
        }
    }
    
    
    public class var tabTitleColor: UIColor {
        get {
            return   #colorLiteral(red: 0.2039215686, green: 0.2666666667, blue: 0.3215686275, alpha: 1)
           
        }
    }
    
    
    public class var appFilterBtnColor: UIColor {
        get {
            return #colorLiteral(red: 0.9333333333, green: 0.9647058824, blue: 0.9882352941, alpha: 1)  //color_literal //UIColor(hex: "#CD2133")
        }
    }
    public class var appTitleColor: UIColor {
        get {
            return #colorLiteral(red: 0, green: 0.2274509804, blue: 0.3450980392, alpha: 1)  //color_literal //UIColor(hex: "#0F2E3F")
        }
    }
    //#252931
    public class var appTxtColor252931: UIColor {
        get {
            return #colorLiteral(red: 0.1450980392, green: 0.1607843137, blue: 0.1921568627, alpha: 1)  //color_literal //UIColor(hex: "#CD2133")
        }
    }
    
    public class var cellHighlightColor: UIColor {
        get {
            return #colorLiteral(red: 0.6823529412, green: 0.7647058824, blue: 0.8705882353, alpha: 1)  //color_literal //UIColor(hex: "#CD2133")
        }
    }
    
    
    public class var blueHighlighColor: UIColor {
        get {
            return #colorLiteral(red: 0.6823529412, green: 0.7647058824, blue: 0.8705882353, alpha: 1)  //color_literal //UIColor(hex: "#CD2133")
        }
    }
    
    public class var cellStatsSelectedColor: UIColor {
        get {
            return #colorLiteral(red: 0.2631615996, green: 0.3374142647, blue: 0.3957754374, alpha: 1)  //color_literal //UIColor(hex: "#CD2133")
        }
    }
    
    public class var cellSepratorColor: UIColor {
        get {
            return #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9215686275, alpha: 1)  //color_literal //UIColor(hex: "#CD2133")
        }
    }
    
    public class var bgDarkSepratorColor: UIColor {
        get {
            return #colorLiteral(red: 0.04377351701, green: 0.09231250733, blue: 0.1360198855, alpha: 1)
            //color_literal //UIColor(hex: "#FB6D31")
        }
    }
    
    //#FB6D31
    public class var cellUnselectedColor: UIColor {
        get {
            return #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)  //color_literal //UIColor(hex: "#CD2133")
        }
    }    
    
    public class var appRedColor: UIColor {
        get {
            return #colorLiteral(red: 0.9795405269, green: 0.7490429282, blue: 0.2159744501, alpha: 1)  //color_literal //UIColor(hex: "#CD2133")
        }
    }
    
    public class var appKYCVerifiedColor: UIColor {
        get {
            return UIColor(red: 87, green: 127, blue: 35)  //color_literal //UIColor(hex: "#CD2133")
        }
    }
    
    public class var attributedTextColor: UIColor {
        get {
            return #colorLiteral(red: 0.5411764706, green: 0.5411764706, blue: 0.5607843137, alpha: 1)  //color_literal //UIColor(hex: "8A8A8F") UIColor.init(red: 114/255, green: 107/255, blue: 128/255, alpha: 1.0)
        }
    }
    public class var appPrimaryColor: UIColor {
        get {
            return #colorLiteral(red: 0.3764705882, green: 0.4431372549, blue: 0.5019607843, alpha: 1)  //color_literal //UIColor(hex: "00FFFF")
        }
    }
    
    public class var appGreenColor: UIColor {
        get {
            return #colorLiteral(red: 0.9795405269, green: 0.7490429282, blue: 0.2159744501, alpha: 1)  //color_literal //UIColor(hex: "00FFFF")
        }
    }
    
    public class var appMainThemeColor: UIColor {
        get {
            return #colorLiteral(red: 0.05882352941, green: 0.368627451, blue: 0.5019607843, alpha: 1)  //color_literal //UIColor(hex: "00FFFF")
        }
    }
    
    public class var appHighlightedTextColor: UIColor {
        get {
            return #colorLiteral(red: 0.06666666667, green: 1, blue: 0.7411764706, alpha: 1) //color_literal //UIColor(hex: "00FFFF")
        }
    }
    
    public class var appGreenTextColor: UIColor {
        get {
            return #colorLiteral(red: 0.01176470588, green: 0.5333333333, blue: 0.1019607843, alpha: 1) //color_literal //UIColor(hex: "#03881A")
        }
    }
     public class var appSelectedBlueColor: UIColor {
        get {
            return #colorLiteral(red: 0.05490196078, green: 0.2862745098, blue: 0.5647058824, alpha: 1) //color_literal //UIColor(hex: "#03881A")
        }
    }
    
    public class var appKycSelectedColor: UIColor {
        get {
            return #colorLiteral(red: 0.09803921569, green: 0.3882352941, blue: 0.5568627451, alpha: 1) //color_literal //UIColor(hex: "19638E")
        }
    }
    
    public class var appYellowColor: UIColor {
        get {
            return #colorLiteral(red: 0.968627451, green: 0.7019607843, blue: 0.168627451, alpha: 1)  //color_literal //UIColor(hex: "#F7B32B")
        }
    }    
    
    public class var appRedBackgroundColor: UIColor {
        get {
            return #colorLiteral(red: 0.6588235294, green: 0, blue: 0, alpha: 1)  //color_literal //UIColor(hex: "#A80000")
        }
    }
    
    public class var appLightBlueColor: UIColor {
        get {
            return #colorLiteral(red: 0.7058823529, green: 0.8823529412, blue: 1, alpha: 1)  //color_literal //UIColor(hex: "#B4E1FF")
        }
    }
    
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}


class UISwitchCustom: UISwitch {
    @IBInspectable var OffTint: UIColor? {
        didSet {
            self.tintColor = OffTint
            self.layer.cornerRadius = 16
            self.backgroundColor = OffTint
        }
    }
}


@IBDesignable
public class Gradient: UIView {
    @IBInspectable var startColor:   UIColor = .black { didSet { updateColors() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}
    @IBInspectable var startLocation: Double =   0.05 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   0.95 { didSet { updateLocations() }}
    @IBInspectable var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    @IBInspectable var diagonalMode:    Bool =  false { didSet { updatePoints() }}

    override public class var layerClass: AnyClass { CAGradientLayer.self }

    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? .init(x: 1, y: 0) : .init(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 0, y: 1) : .init(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? .init(x: 0, y: 0) : .init(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 1, y: 1) : .init(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updatePoints()
        updateLocations()
        updateColors()
    }

}

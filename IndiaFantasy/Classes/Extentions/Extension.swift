//
//  Extension.swift
//  VPAY
//
//  Created by Octal Mac 217 on 24/12/21.
//

import UIKit
import SDWebImage

extension Locale {
    static let currency: [String: (code: String?, symbol: String?, name: String?)] = isoRegionCodes.reduce(into: [:]) {
        let locale = Locale(identifier: identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: $1]))
        $0[$1] = (locale.currencyCode, locale.currencySymbol, locale.localizedString(forCurrencyCode: locale.currencyCode ?? ""))
    }
}
extension UIImage {

    func isEqualToImage(_ image: UIImage) -> Bool {
        let data1 = self.pngData()
        let data2 = image.pngData()
        return data1 == data2
    }

}

extension Bool {
    var intValue: Int {
        return self ? 1 : 0
    }
}
extension UIViewController
{
    func navigationView()->CustomNavigation?{
        for view in self.view.subviews{
            if "\(type(of: view)).Type" == "\(type(of: CustomNavigation.self))"{
                return view as? CustomNavigation
            }
        }
        return nil
    }
    
    func getDouble(for value: Any) -> Double {
        
        if let val = value as? Int64 {
            return Double(val)
        } else if let val = value as? Double {
            return Double(val)
        } else if let val = value as? String {
            return Double(val) ?? 0.0
        } else if let val = value as? Int {
            return Double(val)
        }
        else {
            return value as? Double ?? 0.0
        }
    }
    
    func topViewController() -> UIViewController {
            if self.presentedViewController == nil {
                return self
            }
            if let navigation = self.presentedViewController as? UINavigationController {
                return navigation.visibleViewController?.topViewController() ?? UIViewController()
            }
            if let tab = self.presentedViewController as? UITabBarController {
                if let selectedTab = tab.selectedViewController {
                    return selectedTab.topViewController()
                }
                return tab.topViewController()
            }
            return self.presentedViewController!.topViewController()
    }
    
    //MARK: - Alert with two button one action
    func alertBoxWithAction(title: String = Constants.kAppDisplayName, message: String?, btn1Title: String, btn2Title: String ,okaction:@escaping (()->Void))
    {
      
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      let action=UIAlertAction(title: btn2Title.localized(), style: .default) { (action) in
        okaction()
      }
      let cancel = UIAlertAction(title: btn1Title.localized(), style: .cancel, handler: nil)
    
      alert.addAction(action)
      alert.addAction(cancel)
      present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Alert with one button action
    func alertBoxWithAction(title: String = Constants.kAppDisplayName, message: String?, btnTitle: String, okaction:@escaping (()->Void))
    {
      
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      let action=UIAlertAction(title: btnTitle.localized(), style: .default) { (action) in
        okaction()
      }
    
      alert.addAction(action)
      present(alert, animated: true, completion: nil)
    }
}

extension UIView
{
    var parentViewController: UIViewController? {
        sequence(first: self) { $0.next }
            .first(where: { $0 is UIViewController })
            .flatMap { $0 as? UIViewController }
    }
    // OUTPUT 2
    func dropShadow12(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true,Cradius: CGFloat = 1) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        layer.cornerRadius = Cradius

        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
      }
    
    func getDouble(for value: Any) -> Double {
        
        if let val = value as? Int64 {
            return Double(val)
        } else if let val = value as? Double {
            return Double(val)
        } else if let val = value as? String {
            return Double(val) ?? 0.0
        } else if let val = value as? Int {
            return Double(val)
        }
        else {
            return value as? Double ?? 0.0
        }
    }
    
    // OUTPUT 1
      func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1

        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
      }

      // OUTPUT 2
      func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius

        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
      }
}

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    var millisecondsSince1970:UInt64 {
        return UInt64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

//MARK: - UIImage View Extension
extension UIImageView {
    
    func loadImage(urlS: String?, placeHolder: UIImage?) {
        
        guard let urlS = urlS, urlS != "" else {
            self.image = placeHolder
            return
        }
        
        if let url = URL(string: urlS) {
    
            //DispatchQueue.main.async {
                self.sd_imageIndicator = SDWebImageActivityIndicator.gray
            //}
            self.sd_setImage(with: url, placeholderImage: placeHolder)
        }
    }
}

extension UIButton {
  
  func setImage(urlS: String?, placeHolder: UIImage?) {
    
    guard let urlS = urlS, urlS != "" else {
        self.setImage(placeHolder, for: .normal)
      return
    }

    if let url = URL(string: urlS) {
        self.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.sd_setImage(with: url, for: .normal, placeholderImage: placeHolder)
    }
  }
}


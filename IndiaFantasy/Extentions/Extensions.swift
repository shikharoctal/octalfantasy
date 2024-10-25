//
//  Extensions.swift
//  VPay
//
//  Created by octal-mac on 19/11/21.
//

import UIKit

enum AppStoryboard : String {
    case Main = "Main"
    case Home = "Home"

    var instance : UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
}

@IBDesignable
final class GradientView: UIView {
    @IBInspectable var startColor: UIColor = UIColor.clear
    @IBInspectable var endColor: UIColor = UIColor.clear

    override func draw(_ rect: CGRect) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = CGRect(x: CGFloat(0),
                                y: CGFloat(0),
                                width: self.frame.size.width,
                                height: self.frame.size.height)
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        gradient.zPosition = -1
        gradient.cornerRadius = 8
        layer.addSublayer(gradient)
    }
}

typealias CollectionViewCellId = UICollectionViewCell.CollectionViewCell
extension UICollectionViewCell {
    enum CollectionViewCell: String {
        case splashCollectionViewCell = "SplashCollectionViewCell"
        
        // MARK: - Var
        var cellId: String {
            switch self {
            case .splashCollectionViewCell: return "SplashCollectionViewCell"
            }
        }
        // MARK: - Methods
        func makeCollectionCell(for collectionview: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
            collectionview.dequeueReusableCell(withReuseIdentifier: self.rawValue, for: indexPath)
        }
    }
}
extension FloatingPoint {
    var isInteger: Bool {
        return truncatingRemainder(dividingBy: 1) == 0
    }
}
extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
    
    var cleanValue: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.2f", self)
    }
    
    func forTrailingZero() -> String {
        let tempVar = String(format: "%.2f", self)
        return tempVar.replacingOccurrences(of: ".00", with: "")
    }
    
    func formattedNumber() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:self))
        return formattedNumber ?? "0"
    }
    
}

extension Float{
    
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
    
    func forTrailingZero() -> String {
        let tempVar = String(format: "%.2f", self)
        return tempVar.replacingOccurrences(of: ".00", with: "")

    }
    
    func formattedNumber() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:self))
        return formattedNumber ?? "0"
    }
}

extension Int {
    
    func formattedNumber() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:self))
        return formattedNumber ?? "0"
    }
}

//MARK: Share Text Method
extension UIApplication {
    class func getTopMostViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return getTopMostViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return getTopMostViewController(base: presented)
        }
        return base
    }
    
    class var topViewController: UIViewController? { return getTopViewController() }
    class func getTopViewController(base: UIViewController? = Constants.kAppDelegate.window?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController { return getTopViewController(base: nav.visibleViewController) }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController { return getTopViewController(base: selected) }
        }
        if let presented = base?.presentedViewController { return getTopViewController(base: presented) }
        return base
    }

    private class func _share(_ data: [Any],
                              applicationActivities: [UIActivity]?,
                              setupViewControllerCompletion: ((UIActivityViewController) -> Void)?) {
        let activityViewController = UIActivityViewController(activityItems: data, applicationActivities: nil)
        setupViewControllerCompletion?(activityViewController)
        UIApplication.topViewController?.present(activityViewController, animated: true, completion: nil)
    }

    class func share(_ data: Any...,
                     applicationActivities: [UIActivity]? = nil,
                     setupViewControllerCompletion: ((UIActivityViewController) -> Void)? = nil) {
        _share(data, applicationActivities: applicationActivities, setupViewControllerCompletion: setupViewControllerCompletion)
    }
    class func share(_ data: [Any],
                     applicationActivities: [UIActivity]? = nil,
                     setupViewControllerCompletion: ((UIActivityViewController) -> Void)? = nil) {
        _share(data, applicationActivities: applicationActivities, setupViewControllerCompletion: setupViewControllerCompletion)
    }
}

extension UINavigationController {
    func getViewController<T: UIViewController>(of type: T.Type) -> UIViewController? {
        return self.viewControllers.first(where: { $0 is T })
    }

    func popToViewController<T: UIViewController>(of type: T.Type, animated: Bool) {
        guard let viewController = self.getViewController(of: type) else { return }
        self.popToViewController(viewController, animated: animated)
    }
    
    func pushViewController(viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
           pushViewController(viewController, animated: animated)

           if animated, let coordinator = transitionCoordinator {
               coordinator.animate(alongsideTransition: nil) { _ in
                   completion()
               }
           } else {
               completion()
           }
       }

       func popViewController(animated: Bool, completion: @escaping () -> Void) {
           popViewController(animated: animated)

           if animated, let coordinator = transitionCoordinator {
               coordinator.animate(alongsideTransition: nil) { _ in
                   completion()
               }
           } else {
               completion()
           }
       }
}

extension NSNotification.Name {
    static let MoveToMyTeam = NSNotification.Name(Constants.kMoveToMyTeam)
    static let MoveToMyContest = NSNotification.Name(Constants.kMoveToAllContest)
    static let LeagueTeamCreation = NSNotification.Name(Constants.kLeagueTeamCreation)
    static let MoveToLeagueStats = NSNotification.Name(Constants.kMoveToLeagueStats)
    static let RefreshBoosterList = NSNotification.Name(Constants.kRefreshBoosterList)
}

func postNotification(_ postKey: NSNotification.Name, userInfo:[AnyHashable: Any] = [AnyHashable: Any]()) {
    
    NotificationCenter.default.post(name: postKey, object: nil, userInfo: userInfo)
}

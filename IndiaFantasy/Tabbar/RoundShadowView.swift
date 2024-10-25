//
//  RoundShadowView.swift
//  KnockOut11
//
//  Created by Octal-Mac on 15/10/22.
//

import UIKit

class RoundShadowView: UIView {

    let containerView = UIView()

        override init(frame: CGRect) {
            super.init(frame: frame)
            layoutView()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func layoutView() {

            // set the shadow of the view's layer
            layer.backgroundColor = UIColor.clear.cgColor
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: -8.0)
            layer.shadowOpacity = 0.12
            layer.shadowRadius = 10.0
            layer.masksToBounds = true
            containerView.layer.cornerRadius = cornerRadius
            containerView.layer.masksToBounds = true

            addSubview(containerView)
            containerView.translatesAutoresizingMaskIntoConstraints = false

            // pin the containerView to the edges to the view
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
}
extension UIImage {
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

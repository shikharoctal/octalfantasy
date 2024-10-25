//
//  EasyTipHelper.swift
//
//  Created by Octal-Mac on 30/11/22.
//

import UIKit
import EasyTipView

class EasyTipHelper: NSObject {

    var tipView = EasyTipView(text: "")
    
    func showEasyTip(sender:UIButton, onView:UIView, withText:String, textAlignemnt: NSTextAlignment = .center){
        tipView.dismiss()
        var preferences = EasyTipView.Preferences()
        preferences.drawing.font = UIFont(name: customFontRegular, size: 12)!
        preferences.drawing.foregroundColor = UIColor.black
        preferences.drawing.backgroundColor = UIColor.appFilterTitleColor
        preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.top
        preferences.drawing.textAlignment = textAlignemnt
        EasyTipView.globalPreferences = preferences
        
         if sender.isSelected == true{
             tipView = EasyTipView(text: withText, preferences: preferences)
             tipView.show(forView: sender, withinSuperview: onView)
         }else{
             tipView.dismiss()
         }
    }
}

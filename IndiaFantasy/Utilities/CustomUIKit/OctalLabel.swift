//
//  OctalLabel.swift
//  MVVM_Template
//
//  Created by Octal-Mac on 21/02/23.
//

import UIKit

let customFontLight = "Montserrat-Regular"
let customFontRegular = "Montserrat-Regular"
let customFontMedium = "Montserrat-SemiBold"
let customFontSemiBold = "Montserrat-SemiBold"
let customFontBold = "Montserrat-Bold"
let customFontItalic = "Montserrat-Regular"

let kanitFontBold = "Kanit-Bold"

class OctalLabel: UILabel {

    required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)!
            self.commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    func commonInit(){
        self.setFonts()
    }
    
    func setFonts(){
        //set fonts here
        self.font = UIFont(name: customFontSemiBold, size: self.font!.pointSize)

         if self.tag == 101{
             self.font = UIFont(name: customFontLight, size: self.font!.pointSize)
         }
         if self.tag == 102{
             self.font = UIFont(name: customFontRegular, size: self.font!.pointSize)
         }
         if self.tag == 103{
             self.font = UIFont(name: customFontMedium, size: self.font!.pointSize)
         }
         if self.tag == 104{
             self.font = UIFont(name: customFontSemiBold, size: self.font!.pointSize)
         }
         if self.tag == 105{
             self.font = UIFont(name: customFontBold, size: self.font!.pointSize)
         }
         if self.tag == 106{
             self.font = UIFont(name: customFontItalic, size: self.font!.pointSize)
         }
    }
}

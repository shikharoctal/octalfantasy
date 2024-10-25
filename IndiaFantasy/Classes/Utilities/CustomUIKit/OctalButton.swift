//
//  OctalButton.swift
//  MVVM_Template
//
//  Created by Octal-Mac on 21/02/23.
//

import UIKit

class OctalButton: UIButton {
   
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
        self.titleLabel!.font = UIFont(name: customFontSemiBold, size: self.titleLabel!.font.pointSize)

         if self.tag == 101{
             self.titleLabel!.font = UIFont(name: customFontLight, size: self.titleLabel!.font.pointSize)
         }
         if self.tag == 102{
             self.titleLabel!.font = UIFont(name: customFontRegular, size: self.titleLabel!.font.pointSize)
         }
         if self.tag == 103{
             self.titleLabel!.font = UIFont(name: customFontMedium, size: self.titleLabel!.font.pointSize)
         }
         if self.tag == 104{
             self.titleLabel!.font = UIFont(name: customFontSemiBold, size: self.titleLabel!.font.pointSize)
         }
         if self.tag == 105{
             self.titleLabel!.font = UIFont(name: customFontBold, size: self.titleLabel!.font.pointSize)
         }
         if self.tag == 106{
             self.titleLabel!.font = UIFont(name: customFontItalic, size: self.titleLabel!.font.pointSize)
         }
    }

}

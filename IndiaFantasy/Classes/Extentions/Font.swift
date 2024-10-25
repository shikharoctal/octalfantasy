//
//  Font.swift
//  VPay
//
//  Created by Pankaj on 02/12/21.
//

import Foundation
import UIKit

struct Font {
    
    enum FontName: String {
        
        case redHatDisplayBlack = "RedHatDisplay-Black"
        case HelveticaLight = "Helvetica-Light"
        case HelveticaRegular = "Helvetica"
        case HelveticaSemiBold = "Nunito-SemiBold"
        case HelveticaBold = "Helvetica-Bold"
        case HelveticaExtraBold = "Nunito-ExtraBold"
    }
    enum StandardSize: Double {
        case h1 = 40.0
        case h10 = 30.0
        case h20 = 20.0
        case h36 = 26.0
        case h28 = 18.0
        case h26 = 16.0
        case h24 = 14.0
        case h22 = 12.0
        case h21 = 11.0
        case h30 = 10.0
    }
    enum FontType {
        case installed(FontName)
    }
    enum FontSize {
        case standard(StandardSize)
        case custom(Double)
        // MARK: - variable
        var value: Double {
            switch self {
            case .standard(let size):
                return size.rawValue
            case .custom(let customSize):
                return customSize
            }
        }
    }
    // MARK: - variable
    var type: FontType
    var size: FontSize
    // MARK: - Life Cycle
    init(_ type: FontType, size: FontSize) {
        self.type = type
        self.size = size
    }
}
extension Font {
    var instance: UIFont {
        var instanceFont: UIFont!
        switch type {
        case .installed(let fontName):
            guard let font = UIFont(name: fontName.rawValue, size: CGFloat(size.value)) else {
                fatalError("\(fontName.rawValue) font is not installed, make sure it is added in Info.plist and logged with Utility.logAllAvailableFonts()")
            }
            instanceFont = font
        }
        return instanceFont
    }
}

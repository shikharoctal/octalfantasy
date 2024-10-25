//
//  ViewPagerTab.swift
//  ViewPager-Swift
//
//  Created by Yashwant Jangid on 2/9/16.
//  Copyright © 2016 Yashwant Jangid. All rights reserved.
//

import Foundation
import UIKit

enum ViewPagerTabType {
    case basic
    case image
    case imageWithText
}

class ViewPagerTab:NSObject {
    
    var title:String!
    var image:UIImage?
    
    init(title:String, image:UIImage?) {
        self.title = title
        self.image = image
    }
}

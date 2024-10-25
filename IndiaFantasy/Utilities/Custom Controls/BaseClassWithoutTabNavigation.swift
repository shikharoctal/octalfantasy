

import UIKit

class BaseClassWithoutTabNavigation: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.kUpdateTopNavigation), object: nil, userInfo: nil)
    }
    
    override func viewWillLayoutSubviews() {
       // self.header.roundCorners(corners: [.layerMinXMaxYCorner], radius: 35)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        if let nv = self.navigationView(){
            NotificationCenter.default.removeObserver(nv, name: NSNotification.Name(rawValue: Constants.kUpdateTopNavigation), object: nil)
        }
    }
    
}

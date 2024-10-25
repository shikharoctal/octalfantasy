

import UIKit

class BaseClassVC: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.kUpdateTopNavigation), object: nil, userInfo: nil)
        //self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //self.tabBarController?.tabBar.isHidden = true

    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        if let nv = self.navigationView(){
//            NotificationCenter.default.removeObserver(nv, name: NSNotification.Name(rawValue: Constants.kUpdateTopNavigation), object: nil)
//        }
//    }
    
    override func viewWillLayoutSubviews() {
       // self.header.roundCorners(corners: [.layerMinXMaxYCorner], radius: 35)
    }
   
    
    // MARK: - Press Back
    @IBAction func pressBack(_ sender: UIButton) {
//        if self.navigationController?.viewControllers.count ?? 0 > 0{
//            self.navigationController?.popViewController(animated: true)
//        }else{
//            exit(0)
//        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
}

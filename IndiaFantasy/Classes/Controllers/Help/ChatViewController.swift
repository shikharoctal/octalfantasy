//
//  ChatViewController.swift
//  GymPod
//
//  Created by Octal Mac 217 on 21/01/22.
//

import UIKit
//import ChatSDK
//import MessagingSDK

class ChatViewController: BaseClassWithoutTabNavigation {

    @IBOutlet weak var navigationView: CustomNavigation!
    @IBOutlet weak var viewChat: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationView.configureNavigationBarWithController(controller: self, title: "Help", hideNotification: false, hideAddMoney: true, hideBackBtn: false)
        self.perform(#selector(initialiseChatBot), with: self, afterDelay: 1.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    
    @IBAction func btnBackPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func initialiseChatBot(){
//        do {
//               let chatEngine = try ChatEngine.engine()
//               let viewController = try Messaging.instance.buildUI(engines: [chatEngine], configs: [])
////               self.navigationController?.pushViewController(viewController, animated: true)
//            self.configureChildViewController(childController: viewController, onView: viewChat)
//             } catch {
//               // handle error
//             }
    }
}
extension UIViewController {
func configureChildViewController(childController: UIViewController, onView: UIView?) {
    var holderView = self.view
    if let onView = onView {
        holderView = onView
    }
    addChild(childController)
    holderView!.addSubview(childController.view)
    constrainViewEqual(holderView: holderView!, view: childController.view)
    childController.didMove(toParent: self)
    childController.willMove(toParent: self)
}


func constrainViewEqual(holderView: UIView, view: UIView) {
    view.translatesAutoresizingMaskIntoConstraints = false
    //pin 100 points from the top of the super
    let pinTop = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal,
        toItem: holderView, attribute: .top, multiplier: 1.0, constant: 0)
    let pinBottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal,
        toItem: holderView, attribute: .bottom, multiplier: 1.0, constant: 0)
    let pinLeft = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal,
        toItem: holderView, attribute: .left, multiplier: 1.0, constant: 0)
    let pinRight = NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal,
        toItem: holderView, attribute: .right, multiplier: 1.0, constant: 0)

    holderView.addConstraints([pinTop, pinBottom, pinLeft, pinRight])
}}

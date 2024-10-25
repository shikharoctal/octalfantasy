//
//  WebPageViewController.swift
//  GymPod
//
//  Created by Octal Mac 217 on 23/12/21.
//

import UIKit
import WebKit

class WebPageViewController: BaseClassWithoutTabNavigation {

    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var navigationView: CustomNavigation!
    @IBOutlet weak var bgView: UIView!

    var url:URL? = nil
    var headerText:String? = nil
    var isFromLeague: Bool = false
    var htmlData:[String:Any]? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationView.configureNavigationBarWithController(controller: self, title: headerText ?? "", hideNotification: isFromLeague, hideAddMoney: true, hideBackBtn: false)

        webView.uiDelegate = self
        webView.navigationDelegate = self

        self.loadWebView()
    }
    
    func loadWebView(){
        if htmlData != nil{
            let htmlString = htmlData?["content"] ?? ""
            webView.loadHTMLString(htmlString as! String, baseURL: Bundle.main.bundleURL)
        }else{
            let request = NSURLRequest(url: (url ?? URL(string: ""))!)
            webView.load(request as URLRequest)
        }
        
    }
    
    @IBAction func bttnBackAction(_ sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
}

extension WebPageViewController:WKUIDelegate, WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
        AppManager.stopActivityIndicator(self.view)

    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Strat to load")
        
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish to load")
        AppManager.stopActivityIndicator(self.view)
    }
}

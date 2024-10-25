//
//  RummyWebViewController.swift
//
//

import UIKit
import WebKit
import SocketIO

class RummyWebViewController: BaseClassWithoutTabNavigation {

    var webView: WKWebView!
    
    var url:URL? = nil
    var headerText:String? = nil
    
    var htmlData:[String:Any]? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupWebView()

        // Do any additional setup after loading the view.
        self.loadWebView()
    }
    
    func setupWebView(){
        
        let contentController = WKUserContentController();
        contentController.add(
            self,
            name: "callbackHandler"
        )
        
        let webConfiguration = WKWebViewConfiguration()
        let source = """
        window.addEventListener('message', function(e) { window.webkit.messageHandlers.iosListener.postMessage(JSON.stringify(e.data)) } )
        """
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        contentController.addUserScript(script)

        contentController.add(self, name: "iosListener")
        webConfiguration.userContentController = contentController
        let frame =  CGRect(x: 0, y: 44, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

        self.webView = WKWebView(frame: frame, configuration: webConfiguration)
        self.webView.backgroundColor = .clear
        self.webView.configuration.preferences.javaScriptEnabled = true
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        self.webView.translatesAutoresizingMaskIntoConstraints = true
        self.view.addSubview(webView)
       // self.addConst()

    }
    
    func addConst(){
        let leading = NSLayoutConstraint(item: self.webView!, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant:0)
        let trailing = NSLayoutConstraint(item: self.webView!, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant:0)
        let top =  NSLayoutConstraint(item: self.webView!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant:0)
        let bottom =  NSLayoutConstraint(item: self.webView!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant:0)
        view.addConstraints([leading, trailing, top, bottom])
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
    
    //MARK:
    @IBAction func bttnBackAction(_ sender : UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval){
        var currY:CGFloat = 0.0
        if toInterfaceOrientation == .portrait{
            currY = 44
        }
        self.webView.frame = CGRect(x: 0, y: currY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
}
extension RummyWebViewController:WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler{
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
        AppManager.stopActivityIndicator(self.view)

    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Start to load")
        
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish to load")
        AppManager.stopActivityIndicator(self.view)

    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
        
        if let str = message.body as? String{
            if str.contains("landscape"){
                let value = UIInterfaceOrientation.landscapeLeft.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
            }
            if str.contains("portrait") {
                let value = UIInterfaceOrientation.portrait.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
            }
            if str.contains("LeaveRummy") {
                let alert = UIAlertController(title: Constants.kAppDisplayName, message: ConstantMessages.LeaveRummyApp, preferredStyle:.alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                    let value = UIInterfaceOrientation.portrait.rawValue
                    UIDevice.current.setValue(value, forKey: "orientation")
                    self.navigationController?.popViewController(animated: true)
                }))
                
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

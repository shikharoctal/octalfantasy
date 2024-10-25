//
//  ReportingWebVC.swift
//  Actorpay Merchant
//
//  Created by octal-mac206 on 20/09/22.
//

import UIKit
import WebKit

class VCShowTeams: UIViewController,WKUIDelegate, WKNavigationDelegate {

    
    @IBOutlet weak var webView: WKWebView!
    var webUrl = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.load(NSMutableURLRequest(url: URL(fileURLWithPath: (webUrl))) as URLRequest)
        
    }

    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnShare(_ sender: Any) {
        shareFile(filePath: webUrl)
    }
    
    func shareFile(filePath:String){
        let fileURL = NSURL(fileURLWithPath: filePath)

        // Create the Array which includes the files you want to share
        var filesToShare = [Any]()

        // Add the path of the file to the Array
        filesToShare.append(fileURL)

        // Make the activityViewContoller which shows the share-view
        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)

        // Show the share-view
        self.present(activityViewController, animated: true, completion: nil)
    }

}

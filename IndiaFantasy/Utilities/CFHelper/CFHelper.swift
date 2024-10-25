//
//  CFHelper.swift
//  Hungama
//
//  Created by Octal-Mac on 24/11/22.
//

import UIKit
import CashfreePGCoreSDK
import CashfreePGUISDK
import CashfreePG

class CFHelper: NSObject {

    var controller:UIViewController? = nil
    var token = ""
    var orderId = ""
    var amount = "0"
    
    var env:CFENVIRONMENT = .SANDBOX
    
    let cfPaymentGatewayService = CFPaymentGatewayService.getInstance()


    var completionHandler : ((String) -> Void)?

    
    func getCashfreeToken(orderAmount:String, completion:@escaping ()->()) {
        self.amount = orderAmount
        self.cfPaymentGatewayService.setCallback(self)
        DispatchQueue.main.async {
            AppManager.startActivityIndicator(sender: self.controller!.view)
        }
        // let Url = String(format: "https://api.cashfree.com/api/v2/cftoken/order")
        let Url = GlobalDataPersistance.shared.cash_end_point
        
        guard let serviceUrl = URL(string: Url) else { return }
        
        let customerDetails  = ["customer_id":Constants.kAppDelegate.user?.id ?? "",
                                "customer_name":Constants.kAppDelegate.user?.full_name ?? "",
                                "customer_email":Constants.kAppDelegate.user?.email ?? "",
                                "customer_phone":Constants.kAppDelegate.user?.phone ?? ""]

        let parameterDictionary:[String:Any] = [
                                   "order_amount":orderAmount,
                                   "order_currency":"INR",
                                   "customer_details":customerDetails
                                    ]
        
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue(GlobalDataPersistance.shared.cash_app_id , forHTTPHeaderField: "x-client-id")
        request.setValue(GlobalDataPersistance.shared.cash_secret, forHTTPHeaderField: "x-client-secret")
        request.setValue(GlobalDataPersistance.shared.cash_api_version, forHTTPHeaderField: "x-api-version")

        request.setValue("application/json", forHTTPHeaderField:"Content-Type" )
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                    if let token = (json as! NSDictionary)["order_token"] as? String {
                        self.token = token
                        if let order_id = (json as! NSDictionary)["order_id"] as? String {
                            self.orderId = order_id
                        }
                        
                        completion()
                    }
                } catch {
                    AppManager.showToast(error.localizedDescription, view: self.controller!.view)
                    print(error)
                }
            }
            DispatchQueue.main.async {
                AppManager.stopActivityIndicator(self.controller!.view)
            }
            
        }.resume()
        
    }
    
    private func getSession() -> CFSession? {
       do {
           let session = try CFSession.CFSessionBuilder()
               .setEnvironment(self.env)
               .setOrderID(self.orderId)
               .setPaymentSessionId(self.token)
               .build()
           return session
       } catch let e {
           let error = e as! CashfreeError
           print(error.localizedDescription)
           // Handle errors here
       }
       return nil
    }
    
    func makePayment(){
        self.cfPaymentGatewayService.setCallback(self)
        if let session = self.getSession() {
            do {
              
                // Set Components
                let paymentComponents = try CFPaymentComponent.CFPaymentComponentBuilder()
                    .enableComponents([
                        "order-details",
                        "card",
                        "paylater",
                        "wallet",
                        "emi",
                        "netbanking",
                        "upi"
                    ])
                    .build()
                
                // Set Theme
                let theme = try CFTheme.CFThemeBuilder()
                    .setPrimaryFont("Lato-Medium")
                    .setSecondaryFont("Lato-Medium")
                    .setButtonTextColor("#FFFFFF")
                    .setButtonBackgroundColor("#0F2E3F")
                    .setNavigationBarTextColor("#FFFFFF")
                    .setNavigationBarBackgroundColor("#0F2E3F")
                    .setPrimaryTextColor("#0F2E3F")
                    .setSecondaryTextColor("#0F2E3F")
                    .build()
                
                // Native payment
                let nativePayment = try CFDropCheckoutPayment.CFDropCheckoutPaymentBuilder()
                    .setSession(session)
                    .setTheme(theme)
                    .setComponent(paymentComponents)
                    .build()
                
                // Invoke SDK
                try self.cfPaymentGatewayService.doPayment(nativePayment, viewController: self.controller!)
                
                
            } catch let e {
                let error = e as! CashfreeError
                print(error.localizedDescription)
                // Handle errors here
            }
        }
    }
}

extension CFHelper: CFResponseDelegate {
    
    func onError(_ error: CFErrorResponse, order_id: String) {
        print(error.message ?? "")
        AppManager.showToast(error.message ?? "", view: self.controller!.view)
    }
    
    func verifyPayment(order_id: String) {
        DispatchQueue.main.async {
            AppManager.stopActivityIndicator(self.controller!.view)
            if let comp = self.completionHandler{
                comp(order_id)
            }
        }
    }
    
}

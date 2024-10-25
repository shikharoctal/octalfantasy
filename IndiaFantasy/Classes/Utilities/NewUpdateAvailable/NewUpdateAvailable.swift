//
//  NewUpdateAvailable.swift
//  MVVM_Template
//
//  Created by Yashwant Jangid on 02/05/24.
//

import UIKit

struct NewUpdateAvailable {
    
    func checkForUpdate() {
    
        guard let url = URL(string: "https://itunes.apple.com/in/lookup?id=\(Constants.kAppStoreID)") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let results = json?["results"] as? [[String: Any]], let appStoreVersion = results.first?["version"] as? String {
                        // Compare appStoreVersion with app's current version
                        let currentVersion = Constants.kAppVersion
                        if currentVersion != appStoreVersion {
                            DispatchQueue.main.async {
                                self.showUpdatePopup()
                            }
                        }
                    }
                    
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
        }
        
        task.resume()
    }
    
    private func showUpdatePopup() {
        
        let alertController = UIAlertController(title: "Update Available", message: "A new version of the app is available. Would you like to update now?", preferredStyle: .alert)
        let updateAction = UIAlertAction(title: "Update Now", style: .default) { _ in
            // Open App Store or navigate to update page
            if let url = URL(string: "https://apps.apple.com/app/id\(Constants.kAppStoreID)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(updateAction)
        
        let remindLaterAction = UIAlertAction(title: "Remind Me Later", style: .default, handler: nil)
        alertController.addAction(remindLaterAction)
        
        if let top = UIApplication.topViewController {
            top.present(alertController, animated: true)
        }
    }
}

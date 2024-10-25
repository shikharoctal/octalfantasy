//
//  CountryPickerVC.swift
//  Lifferent
//
//  Created by sumit sharma on 04/06/21.
//

import UIKit

class CountryPickerVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txt_Search: UITextField!
    
    var countries: [Country] = {
        var countries = [Country]()
            for jsonObject in CountryList {
                
                guard let name = jsonObject["name"],
                      let code = jsonObject["code"],
                      let phoneCode = jsonObject["dial_code"] else {
                        continue
                }
                
                let country = Country(name: name, code: code, phoneCode: phoneCode)
                countries.append(country)
            }
        
        return countries
    }()
    
    var filteredCountries : [Country] = []
    var searchActive : Bool = false
    
    var completionHandler : ((Country) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filteredCountries = countries
        txt_Search.addTarget(self, action: #selector(textFieldDidChange(_:)),
                             for: UIControl.Event.editingChanged)
        // Do any additional setup after loading the view.
    }
    

    
    @objc func textFieldDidChange(_ textField: UITextField) {

      let searchText  = textField.text ?? ""

        filteredCountries = filteredCountries.filter({ (dic) -> Bool in
            let tmp: NSString = NSString(string: dic.name)
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
       
        if(filteredCountries.count == 0){
            filteredCountries = countries
            searchActive = false
        } else {
            searchActive = true
        }
         self.tableView.reloadData()

    }
    
    @IBAction func btnCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate / UITableViewDataSource
extension CountryPickerVC: UITableViewDataSource,UITableViewDelegate {
  
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCountries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryNameCell", for: indexPath)
        let countyImag = cell.viewWithTag(1) as? UIImageView
        let lblName = cell.viewWithTag(2) as? UILabel
       
        let dic = filteredCountries[indexPath.row]
        countyImag?.image = dic.flag
        let phoneCode = dic.phoneCode
        lblName?.text = "(\(phoneCode)) " + dic.name
        
       
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        let dic = filteredCountries[indexPath.row]
        if let comp = completionHandler{
            comp(dic)
        }
        self.dismiss(animated: true, completion: nil)
    }
}

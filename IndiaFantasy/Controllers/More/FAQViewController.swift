//
//  FAQViewController.swift
//
//  Created by Octal-Mac on 09/11/22.
//

import UIKit

class FAQViewController: BaseClassWithoutTabNavigation {

    @IBOutlet weak var navigationView: CustomNavigation!
    @IBOutlet weak var tbaleView: UITableView!
    var faqsList: [Doc] = []
    private var selectFaqIndex : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationView.configureNavigationBarWithController(controller: self, title: "FAQs", hideNotification: false, hideAddMoney: true, hideBackBtn: false)
        self.apiGetFaqs()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension FAQViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return faqsList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.numberOfLines = 0
        cell.selectionStyle = .none
        if let attributedString = faqsList[indexPath.section].answer.htmlToAttributedString {
            cell.textLabel?.attributedText = attributedString
        }else {
            cell.textLabel?.text = faqsList[indexPath.section].answer
        }
        
        cell.textLabel?.font = UIFont(name: "Gilroy-Medium", size: 14.0)
        return cell
    }

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view:CustomeHeaderView = Bundle.main.loadNibNamed("CustomeHeaderView", owner: self, options: nil)?.first as! CustomeHeaderView
        view.lblTitle.text = faqsList[section].question
        view.onButtonTapped = {
            self.selectFaqIndex = section
            self.tbaleView.reloadData()
        }
        return view
    }

    @objc func handleTap(gestureRecognizer: UIGestureRecognizer) {
        print("Tapped")
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let index = selectFaqIndex {
            if index == indexPath.section {
                return UITableView.automaticDimension
            }
            return 0

        }else{
            return 0
        }
    }
}
extension FAQViewController{

    func apiGetFaqs(){
        
        let url = URLMethods.BaseURL + URLMethods.getfaqs
        let params: [String:String] = ["page":"1",
                                       "itemsPerPage":"1000"]

        ApiClient.init().getRequest(method: url, parameters: params, view: (self.view)!) { result in
            if result != nil {
                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "message") as? String ?? ""
                if status == true{
                    
                    if let data = result?.object(forKey: "results") as? [String:Any]{
                        let list = data["docs"] as? [[String:Any]]
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: list!, options: .prettyPrinted),
                              let tblData = try? JSONDecoder().decode([Doc].self, from: jsonData)else {return }
                        self.faqsList = tblData
                        self.tbaleView.reloadData()
                    }
                    else{
                        AppManager.showToast(msg, view: (self.view)!)
                    }
                    
                }else{
                    AppManager.showToast(msg, view: (self.view)!)
                }
                
            }else{
                AppManager.showToast("", view: (self.view)!)
            }
            AppManager.stopActivityIndicator((self.view)!)
        }
        AppManager.startActivityIndicator(sender: (self.view)!)
    }
    
}



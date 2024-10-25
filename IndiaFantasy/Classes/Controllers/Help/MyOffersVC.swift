//
//  MyOffersVC.swift
//  CrypTech
//
//  Created by New on 09/03/22.
//

import UIKit

class MyOffersVC: BaseClassVC {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var navigationView: CustomNavigation!
    
    var arrCoupons = [CoupenResult]() {
        didSet {
            if arrCoupons.count == 0 {
                tblView.setEmptyMessage(ConstantMessages.NotFound)
            }else {
                tblView.restoreEmptyMessage()
            }
            DispatchQueue.main.async {
                self.tblView.reloadData()
            }
        }
    }
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationView.configureNavigationBarWithController(controller: self, title: "My Offers", hideNotification: false, hideAddMoney: true, hideBackBtn: true)
        navigationView.sideMenuBtnView.isHidden = false
        navigationView.avatar.isHidden = true
        
        tblView.contentInset = .init(top: 0, left: 0, bottom: 55, right: 0)
        setupRefreshControl()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getCoupons()
    }
    
    //MARK: - Setup Refresh Control
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: attributes)
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(getDataFromServer), for: .valueChanged)
        refreshControl.tintColor = .white
        tblView.refreshControl = refreshControl
    }
    
    @objc func getDataFromServer() {
        
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
        
        getCoupons()
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension MyOffersVC {
    func getCoupons() {
        
        let params: [String:String] = [String:String]()
        let url = URLMethods.BaseURL + URLMethods.getCoupens
        ApiClient.init().getRequest(method: url, parameters: params, view: (self.view)!) { result in
            if result != nil {
                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "message") as? String ?? ""
                if status == true{
                    if let data = result?.object(forKey: "results") as? [[String:Any]]{
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                              let tblData = try? JSONDecoder().decode([CoupenResult].self, from: jsonData)else {return }
                        self.arrCoupons = tblData
                        self.tblView.reloadData()
                    } else { AppManager.showToast(msg, view: (self.view)!) }
                } else { AppManager.showToast(msg, view: (self.view)!) }
            } else { AppManager.showToast("", view: (self.view)!) }
            AppManager.stopActivityIndicator((self.view)!)
        }
        AppManager.startActivityIndicator(sender: (self.view)!)
    }
}

//MARK: UITableView (DataSource & Delegate) Methods
extension MyOffersVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrCoupons.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoupenTVCell", for: indexPath) as! CoupenTVCell
        cell.selectionStyle = .none
        let couponDetail = arrCoupons[indexPath.row]
        if couponDetail.type ?? "" == "percentage" {
            cell.lblDiscountValue.text = "\(couponDetail.cashbackPercent ?? 0)% Cashback"
            cell.lblDescription.text = couponDetail.description ?? ""
            cell.lblCopyCode.text = couponDetail.couponCode?.uppercased() ?? ""
            //cell.lblExpiryDate.text = "Expires in \(coupenDetail.expireInDays ?? 0) days!"
            cell.btnCopyCode.tag = indexPath.row
            cell.btnCopyCode.addTarget(self, action: #selector(applyCodePressed(sender:)), for: .touchUpInside)
        } else {
            cell.lblDiscountValue.text = "Flat \(GDP.globalCurrency)\(couponDetail.flatDiscount ?? 0)"
            cell.lblDescription.text = couponDetail.description ?? ""
            cell.lblCopyCode.text = couponDetail.couponCode?.uppercased() ?? ""
            //cell.lblExpiryDate.text = "Expires in \(coupenDetail.expireInDays ?? 0) days!"
            cell.btnCopyCode.tag = indexPath.row
            cell.btnCopyCode.addTarget(self, action: #selector(applyCodePressed(sender:)), for: .touchUpInside)
        }
        
        if (couponDetail.expireInDays ?? 0) < 2 {
            
            if (couponDetail.expireInDays ?? 0) == 0 {
                cell.lblExpiryDate.text = "Expired"
            }else {
                cell.lblExpiryDate.text = "Expires in \(couponDetail.expireInDays ?? 0) day!"
            }
        
        }else {
            cell.lblExpiryDate.text = "Expires in \(couponDetail.expireInDays ?? 0) days!"
        }
        
        return cell
    }
    
    @objc func applyCodePressed(sender: UIButton) {
        UIPasteboard.general.string = arrCoupons[sender.tag].couponCode ?? ""
        AppManager.showToast("Copied to clipboard", view: (self.view)!)
        
//        let pushVC = Constants.KDashboardStoryboard.instantiateViewController(withIdentifier: "AddCashViewController") as! AddCashViewController
//        pushVC.couponCode = arrCoupens[sender.tag].couponCode ?? ""
//        self.navigationController?.pushViewController(pushVC, animated: true)
        
    }
}



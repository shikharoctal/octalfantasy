//
//  RecentTransactionsVC.swift
//  CrypTech
//
//  Created by New on 14/03/22.
//

import UIKit

class RecentTransactionsVC: BaseClassWithoutTabNavigation {

    @IBOutlet weak var lblNoData: UILabel!
    @IBOutlet weak var btnGameFilter: UIButton!
    @IBOutlet weak var btnTransactionFilter: UIButton!
    @IBOutlet weak var btnTimeFilter: UIButton!
    @IBOutlet weak var lblTransactionType: UILabel!
    @IBOutlet weak var lblTimeType: UILabel!
    @IBOutlet weak var lblGameType: UILabel!
    @IBOutlet weak var tblTransactions: UITableView!
    @IBOutlet weak var navigationView: CustomNavigation!
  
    var arrTransactions = [Transaction]()
    var startDate = ""
    var endDate = ""
    var dropDown:OctalDropDown? = nil
    
    private var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.resetFilter()
        self.navigationView.configureNavigationBarWithController(controller: self, title: "My Transactions", hideNotification: false, hideAddMoney: true, hideBackBtn: false)
        
        self.tblTransactions.rowHeight = UITableView.automaticDimension;
        self.tblTransactions.estimatedRowHeight = 44.0; //
        
        self.setupRefreshControl()
        self.loadTransactionList()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Setup Refresh Control
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: attributes)
        refreshControl.addTarget(self, action: #selector(getDataFromServer), for: .valueChanged)
        refreshControl.tintColor = .white
        tblTransactions.refreshControl = refreshControl
    }
    
    @objc func getDataFromServer() {
        
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
        
        self.loadTransactionList()
    }
    
    func resetFilter(){
        GlobalDataPersistance.shared.transactionFilterOptions = ""
        GlobalDataPersistance.shared.gameFilterOptions = ""
        GlobalDataPersistance.shared.timeFilterOptions = ""
        GlobalDataPersistance.shared.dateFromFilterOptions = ""
        GlobalDataPersistance.shared.dateToFilterOptions = ""
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnFilterPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func btnTimeFilterPressed(_ sender: UIButton) {
        btnGameFilter.isSelected = false
        btnTransactionFilter.isSelected = false
        
        sender.isSelected = !sender.isSelected
        let arrTimeFilter = CommonFunctions.getStringItemFromInternalResourcesforKey(key: "TimeFilter")
        
        if sender.isSelected == true{
            self.addDropDown(sender: sender, dataArray: arrTimeFilter, isSingleSelection: true, selectedString: GlobalDataPersistance.shared.timeFilterOptions, showClearFilter: true)
        }else{
            self.removeDropDown()
        }
    }
    
    @IBAction func btnTransactionTypeFilterPressed(_ sender: UIButton) {
        btnGameFilter.isSelected = false
        btnTimeFilter.isSelected = false
        sender.isSelected = !sender.isSelected
        let arrTransactionFilter = CommonFunctions.getStringItemFromInternalResourcesforKey(key: "TransactionTypeFilter")

        if sender.isSelected == true{
            self.addDropDown(sender: sender, dataArray: arrTransactionFilter, isSingleSelection: false, selectedString: GlobalDataPersistance.shared.transactionFilterOptions, showClearFilter: false)
        }else{
            self.removeDropDown()
        }
    }
    
    @IBAction func btnGameTypeFilterPressed(_ sender: UIButton) {
        btnTransactionFilter.isSelected = false
        btnTimeFilter.isSelected = false
        sender.isSelected = !sender.isSelected
        let arrGameFilter = CommonFunctions.getStringItemFromInternalResourcesforKey(key: "GameTypeFilter")

        if sender.isSelected == true{
            self.addDropDown(sender: sender, dataArray: arrGameFilter, isSingleSelection: false, selectedString: GlobalDataPersistance.shared.gameFilterOptions, showClearFilter: false)
        }else{
            self.removeDropDown()
        }
    }
    
}

//MARK: UITableView (Delegate & DataSource)
extension RecentTransactionsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTransactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentTransactionTVCell", for: indexPath) as! RecentTransactionTVCell
        cell.lblTitle.numberOfLines = 2
        let object = arrTransactions[indexPath.row]
        cell.lblSubtitle.text = object.details?.remarks ?? ""
        
        if object.details?.credit == nil && (object.details?.debit == nil) {
            cell.iconWidth.constant = 0
            cell.amountWidth.constant = 0
            cell.lblTitle.text = Constants.kAppDisplayName

        }else{
            cell.lblTitle.text = "Transaction ID: \(object.details?.id?.uppercased() ?? "")"
            cell.iconWidth.constant = 57
            cell.amountWidth.constant = 90

            if object.details?.credit != nil{
                cell.imgViewIcon.image = UIImage(named: "iconRsRight")
                cell.lblAmount.text = "+\(GDP.globalCurrency)\(object.details?.credit?.rounded(toPlaces: 2) ?? 0)"
                cell.lblAmount.textColor = UIColor.systemGreen
            }
            if object.details?.debit != nil{
                cell.imgViewIcon.image = UIImage(named: "icPriceLogo")
                cell.lblAmount.text = "-\(GDP.globalCurrency)\(object.details?.debit?.rounded(toPlaces: 2) ?? 0)"
                cell.lblAmount.textColor = UIColor.systemRed

            }
            
            if let withdrawalAmount = object.details?.withdrawalAmount, withdrawalAmount > 0{
                cell.imgViewIcon.image = UIImage(named: "icPriceLogo")
                cell.lblAmount.text = "-\(GDP.globalCurrency)\(withdrawalAmount.rounded(toPlaces: 2))"
                cell.lblAmount.textColor = UIColor.systemRed
            }
        }
        
        let finalDate = "\(object.details?.createdAt ?? "")".UTCToLocal(incomingFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outGoingFormat: "MMM d, yyyy h:mm a")
        cell.lblDays.text = finalDate
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension RecentTransactionsVC{
    func loadTransactionList (){
            let params: [String:String] = ["page":"1",
                                           "itemsPerPage":"100",
                                           "account_start_date":GlobalDataPersistance.shared.dateFromFilterOptions,
                                           "account_end_date":GlobalDataPersistance.shared.dateToFilterOptions,
                                           "time":self.getTimeParamerter(),
                                           "statement_type":self.getStatementParamerter(),
                                           "game_type":self.getGameTypeParamerter()
            ]
            
            print(params)
            let url = URLMethods.BaseURL + URLMethods.getTransactionsList
            
            ApiClient.init().getRequest(method: url, parameters: params, view: (self.view)!) { result in
                if result != nil {
                    let status = result?.object(forKey: "success") as? Bool ?? false
                    let msg = result?.object(forKey: "message") as? String ?? ""
                    if status == true{
                        if let data = result?.object(forKey: "results") as? [[String:Any]]{
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                                  let tblData = try? JSONDecoder().decode([Transaction].self, from: jsonData)else {return }
                            self.arrTransactions = tblData
                            self.tblTransactions.reloadData()
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
                
                
                if self.arrTransactions.count > 0{
                    self.lblNoData.isHidden = true
                }else{
                    self.lblNoData.isHidden = false
                }
                AppManager.stopActivityIndicator((self.view)!)
            }
            AppManager.startActivityIndicator(sender: (self.view)!)
    }
    
    func getTimeParamerter()->String{
        var str = ""
        
        if GlobalDataPersistance.shared.timeFilterOptions.contains("7"){
            str = "7"
        }
        if GlobalDataPersistance.shared.timeFilterOptions.contains("1"){
            str = "1"
        }
        if GlobalDataPersistance.shared.timeFilterOptions.contains("3"){
            str = "3"
        }
        
        return str
    }
    
    func getStatementParamerter()->String{
        var str = ""
        
        if GlobalDataPersistance.shared.transactionFilterOptions.contains("All"){
            str = ""
        }
        else{
            let arr = GlobalDataPersistance.shared.transactionFilterOptions.components(separatedBy: ",")
            var arrStatementType = [String]()
            for string in arr {
                if string.contains("Withdrawal"){
                    arrStatementType.append("withdrawals")
                }
                if string.contains("Deposit"){
                    arrStatementType.append("wallet_deposit")
                }
                if string.contains("Entry Fee"){
                    arrStatementType.append("entry_fees")
                }
                if string.contains("Winning"){
                    arrStatementType.append("cricket_contest")
                }
                if string.contains("Refund"){
                    arrStatementType.append("refund")
                }
                if string.contains("Refer"){
                    arrStatementType.append("refer")
                }
//                if string.contains("Bonus"){
//                    arrStatementType.append("bonus")
//                }
            }
            
            str = arrStatementType.joined(separator: ",")
        }
        
        return str
    }
    
    func getGameTypeParamerter()->String{
        var str = ""
        
        if GlobalDataPersistance.shared.gameFilterOptions.contains("All"){
            str = ""
        }
        else{
            let arr = GlobalDataPersistance.shared.gameFilterOptions.components(separatedBy: ",")
            var arrStatementType = [String]()
            for string in arr {
                if string.contains("Football"){
                    arrStatementType.append("soccer")
                }
                if string.contains("Cricket"){
                    arrStatementType.append("fantasy")
                }
            }
            
            str = arrStatementType.joined(separator: ",")
        }
        
        return str
    }
    
    @objc func btnApplyFilterPressed(sender:UIButton){
        btnGameFilter.isSelected = false
        btnTransactionFilter.isSelected = false
        btnTimeFilter.isSelected = false
        self.removeDropDown()
        
        if GlobalDataPersistance.shared.timeFilterOptions != "" {
            btnTimeFilter.superview?.backgroundColor = .appHighlightedTextColor
        }else {
            if GlobalDataPersistance.shared.dateFromFilterOptions != "" ||  GlobalDataPersistance.shared.dateToFilterOptions != "" {
                btnTimeFilter.superview?.backgroundColor = .appHighlightedTextColor
            }else {
                btnTimeFilter.superview?.backgroundColor = .appFilterBtnColor
            }
        }
        if  GlobalDataPersistance.shared.gameFilterOptions != "" {
            btnGameFilter.superview?.backgroundColor = .appHighlightedTextColor
        }else {
            btnGameFilter.superview?.backgroundColor = .appFilterBtnColor
        }
        if GlobalDataPersistance.shared.transactionFilterOptions != "" {
            btnTransactionFilter.superview?.backgroundColor = .appHighlightedTextColor
        }else {
            btnTransactionFilter.superview?.backgroundColor = .appFilterBtnColor
        }
        
        self.loadTransactionList()
    }
    
    @objc func btnClearFilterPressed(sender:UIButton){
        if btnTimeFilter.isSelected == true{
            GlobalDataPersistance.shared.dateFromFilterOptions = ""
            GlobalDataPersistance.shared.dateToFilterOptions = ""
            GlobalDataPersistance.shared.timeFilterOptions = ""
            if let dd = self.dropDown{
                dd.refreshAllSelections()
            }
        }
        
    }
    
    func addDropDown(sender:UIButton, dataArray:[String], isSingleSelection:Bool, selectedString:String, showClearFilter:Bool){
        if dropDown != nil{
            dropDown?.removeFromSuperview()
            dropDown = nil
        }
        
        self.dropDown = OctalDropDown.instanceFromNib() as? OctalDropDown
        if let dropDown = dropDown {
            dropDown.data = dataArray
            dropDown.isSingleSelection = isSingleSelection
            dropDown.selectedString = selectedString
            dropDown.showClearFilter = showClearFilter
            dropDown.btnApply.addTarget(self, action: #selector(btnApplyFilterPressed(sender:)), for: .touchUpInside)
            dropDown.btnClear.addTarget(self, action: #selector(btnClearFilterPressed(sender:)), for: .touchUpInside)

            dropDown.delegate = self
            if sender == btnTimeFilter{
                dropDown.showDateFilter = true
            }else{
                dropDown.showDateFilter = false
            }
            dropDown.updateView()
            self.view.addSubview(dropDown)
            
            var width:CGFloat = sender.frame.size.width
            
            var height:CGFloat = dropDown.frame.size.height
            
            if sender == btnTimeFilter{
                width = 200
            }
            
            if sender == btnGameFilter{
//                height = 170
                height = 130
            }
            
            if sender == btnTransactionFilter {
                height += 90
            }
            
            //let globalPoint = sender.superview?.convert(sender.frame.origin, to: nil)

            dropDown.translatesAutoresizingMaskIntoConstraints = false
            let horizontalConstraint = NSLayoutConstraint(item: dropDown, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: sender.superview?.superview, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: sender.superview?.frame.origin.x ?? 0)
            let verticalConstraint = NSLayoutConstraint(item: dropDown, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: sender.superview?.superview, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: (sender.superview?.superview?.frame.size.height ?? 0) + 1)
            let widthConstraint = NSLayoutConstraint(item: dropDown, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: width)
            let heightConstraint = NSLayoutConstraint(item: dropDown, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: height)
                view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        }
    }
    
    func removeDropDown(){
        if dropDown != nil{
            dropDown?.removeFromSuperview()
            dropDown = nil
        }
    }
}

extension RecentTransactionsVC:OctalDropDownDelegate{
    
    func didSelectOptionAtIndex(index: Int, selectedString: String) {
        print(selectedString)
        if btnTimeFilter.isSelected == true {
            GlobalDataPersistance.shared.dateFromFilterOptions = ""
            GlobalDataPersistance.shared.dateToFilterOptions = ""
            GlobalDataPersistance.shared.timeFilterOptions = selectedString
            
            if let dropdown = self.dropDown{
                dropdown.updateDateFilter()
            }
        }else if btnTransactionFilter.isSelected == true{
            GlobalDataPersistance.shared.transactionFilterOptions = selectedString
        }else if btnGameFilter.isSelected == true{
            GlobalDataPersistance.shared.gameFilterOptions = selectedString
        }
    }
}

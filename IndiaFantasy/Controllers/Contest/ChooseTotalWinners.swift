//
//  ChooseTotalWinners.swift
//  CrypTech
//
//  Created by Octal Mac 217 on 22/03/22.
//

import UIKit

class ChooseTotalWinners: UIViewController {

    var arrWinList = [CAWinningBreakupDatum]()
    var selectedIndexList = -2
    
    var contestData = NewContestData()

    @IBOutlet weak var tblWinnersChoice: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func btnBackPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func btnSavePressed(_ sender: Any) {
    }
    
    @IBAction func onListSelection(_ sender : UIButton) {
       self.selectedIndexList = sender.tag
        self.tblWinnersChoice.reloadData()
       let getTask = DispatchWorkItem {
           self.selectIndex(index: sender.tag)
       }
       DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: getTask)
    }
    
    func selectIndex(index : Int) {
        let data = ["index" : index]
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateList"), object: nil, userInfo: data)
        }
    }
}

extension ChooseTotalWinners : UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrWinList.count
    }
        
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dict = self.arrWinList[section]
        
        let headerView = WinnerBoardHeaderView.instanceFromNib() as? WinnerBoardHeaderView
        headerView?.controller = self
        
        var title = ""
        title = "\(dict.id ?? 0) Winners"
//        if section == 0 {
//            title = "\(dict.id ?? 0) Winners (Recommended)"
//        }else {
//            title = "\(dict.id ?? 0) Winners"
//        }
        
        headerView?.lblTitle.text = title
        headerView?.btnSelect.tag = section
        headerView?.btnSelect.addTarget(self, action: #selector(self.onListSelection(_:)), for: .touchUpInside)
        if selectedIndexList == section {
            headerView?.btnSelect.isSelected = true
        }
        else {
            headerView?.btnSelect.isSelected = false
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tempDict = self.arrWinList[section]
        let arrayD =  tempDict.info!
        return arrayD.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WinnersListTVCell", for: indexPath) as! WinnersListTVCell
        cell.selectionStyle = .none
        let tempDict = self.arrWinList[indexPath.section]
        let arrayD =  tempDict.info!
        let dict = arrayD[indexPath.row]
        cell.lblWinners.text = "\(dict.rankSize ?? "")"
        cell.lblPercantage.text = String(format : "%@%%",("\(dict.percent!.value)"))
       
        let percent =        Float("\(dict.percent!.value)")
        let totalPrize = Float(self.contestData.prizeAmount)
        let finalPrize = ( percent! * totalPrize! ) / 100.0
        cell.lblAmount.text = String(format : "%.1f",finalPrize)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 38
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
}

//
//  FilterVC.swift
//  KnockOut11
//
//  Created by Subhash Sharma on 06/09/22.
//

import UIKit

class FilterVC: UIViewController {
    
    @IBOutlet weak var filterColView: UICollectionView!
    @IBOutlet weak var viewContainer: UIView!
    
    var groups = [CommonFunctions.getItemFromInternalResourcesforKey(key: "FilterEntry") as [[String:Any]], CommonFunctions.getItemFromInternalResourcesforKey(key: "Winnings") as [[String:Any]], CommonFunctions.getItemFromInternalResourcesforKey(key: "Contest Type") as [[String:Any]], CommonFunctions.getItemFromInternalResourcesforKey(key: "Contest Size") as [[String:Any]]] as NSMutableArray
    
    var titleArray = ["Entry","Winnings","Contest Type","Contest Size"]
    
    var filterData = [String : Any]()
    var filterClouser: (([String:Any], NSMutableArray)->())?
    var btnStatusTrack = [String : Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterColView.delegate = self
        
        let nib = UINib(nibName: "FilterCVCell", bundle: nil)
        filterColView.register(nib, forCellWithReuseIdentifier: "FilterCVCell")
        
        filterColView.register(UINib(nibName: "FilterHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier:"FilterHeaderView")
        filterColView.register(UINib(nibName: "FilterFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier:"FilterFooterView")
        
        print(btnStatusTrack)
    }
    
    override func viewDidLayoutSubviews() {
        viewContainer.roundCorners(corners: [.topLeft, .topRight], radius: 30)
    }
    
    @IBAction func btnBackPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnResetPressed(_ sender: UIButton) {
       groups = [CommonFunctions.getItemFromInternalResourcesforKey(key: "FilterEntry") as [[String:Any]], CommonFunctions.getItemFromInternalResourcesforKey(key: "Winnings") as [[String:Any]], CommonFunctions.getItemFromInternalResourcesforKey(key: "Contest Type") as [[String:Any]], CommonFunctions.getItemFromInternalResourcesforKey(key: "Contest Size") as [[String:Any]]] as NSMutableArray
        filterClouser?([:], groups)
        filterColView.reloadData()
    }
}

extension FilterVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return groups.count
    }
    
    func collectionView(_ collectionView: UICollectionView,viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FilterHeaderView", for: indexPath) as! FilterHeaderView
            print("section Index-->",indexPath.section)
            headerView.lblTitle.text = "\(titleArray[indexPath.section])"
            return headerView
            
        case UICollectionView.elementKindSectionFooter:
            if indexPath.section ==  (groups.count - 1) {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FilterFooterView", for: indexPath) as! FilterFooterView
                headerView.btnApply.addTarget(self, action: #selector(btnApply(sender:)), for: .touchUpInside)
                return headerView
            } else {
                return UICollectionReusableView()
            }
        default:
            assert(false, "Unexpected element kind")
        }

        return UICollectionReusableView()

    }
    
    @objc func btnApply(sender: UIButton) {
        print("Apply Button Press")
        
        var dic  = [String : Any]()
        
        for (index,value) in groups.enumerated() {
            let arr = value as! [[String:Any]]
            var selctIdnex = -1
            for j in 0 ..< arr.count {
                let isSelect = (arr[j] as NSDictionary)["isSelected"] as? Bool ?? false
                if isSelect {
                    selctIdnex = j
                }
            }
            
            if index == 0 {
                if selctIdnex != -1 {
                    let minValue = arr[selctIdnex]["min_value"] as? Int ?? 0
                    let maxValue = arr[selctIdnex]["max_value"] as? Int ?? 0
                    var entryDict  = [String : Any]()
                    entryDict["min_entry_fee"] = minValue
                    entryDict["max_entry_fee"] = maxValue
                    dic["entry_fee"] = entryDict
                } else {
                    dic["entry_fee"] = [:]
                }
            }
            if index == 1 {
                if selctIdnex != -1 {
                    let minValue = arr[selctIdnex]["min_value"] as? Int ?? 0
                    let maxValue = arr[selctIdnex]["max_value"] as? Int ?? 0
                    var winningDict  = [String : Any]()
                    winningDict["min_winning_amount"] = minValue
                    winningDict["max_winning_amount"] = maxValue
                    dic["winning_amount"] = winningDict
                }else {
                    dic["winning_amount"] = [:]
                }
               
            }
            if index == 2 {
               
                if selctIdnex != -1 {
                    let titleContant = arr[selctIdnex]["title"] as? String ?? ""
                    var contestTypeDict  = [String : Any]()
                    
                    if titleContant == "Multi Entry" {
                        contestTypeDict["join_multiple_team"] = true
                    }else if titleContant == "Multi Winner" {
                        contestTypeDict["total_winners"] = true
                    }else {
                        contestTypeDict["confirm_winning"] = true
                    }
                    dic["others"] = contestTypeDict
                }else{
                    
                    dic["others"] = [:]
                }
                
            }
            if index == 3 {
                if selctIdnex != -1 {
                    let minValue = arr[selctIdnex]["min_value"] as? Int ?? 0
                    let maxValue = arr[selctIdnex]["max_value"] as? Int ?? 0
                    var contestDict  = [String : Any]()
                    contestDict["min_contest_size"] = minValue
                    contestDict["max_contest_size"] = maxValue
                    dic["contest_size"] = contestDict
                }else{
                    dic["contest_size"] = [:]
                }

            }
        }
        
        self.dismiss(animated: true) { [self] in
            filterClouser?(dic, groups)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: 50.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        if section ==  (groups.count - 1){
            return CGSize(width: collectionView.frame.width, height: 110)
        }
        
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let arr = groups[section] as! [[String:Any]]
        return arr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCVCell", for: indexPath) as! FilterCVCell
        cell.contentView.isUserInteractionEnabled = false
        let arr = groups[indexPath.section] as! [[String:Any]]
        
        cell.btnTap.titleLabel?.adjustsFontSizeToFitWidth = true
        cell.btnTap.setTitle(arr[indexPath.row]["title"] as? String ?? "", for: .normal)
        
        if arr[indexPath.row]["isSelected"] as? Bool ?? false == true {
            cell.btnTap.backgroundColor = UIColor.appThemeColor
            //cell.btnTap.borderColor = UIColor.appThemeColor
            cell.btnTap.setTitleColor(UIColor.tabTitleColor, for: .normal)
        } else {
            cell.btnTap.backgroundColor = #colorLiteral(red: 0.3764705882, green: 0.4431372549, blue: 0.5019607843, alpha: 1)
         //   cell.btnTap.borderColor = UIColor.white
            cell.btnTap.setTitleColor(UIColor.white, for: .normal)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var arr = groups[indexPath.section] as! [[String:Any]]
        for (index, _) in arr.enumerated() {
            arr[index]["isSelected"] = false
        }
        arr[indexPath.row]["isSelected"] = true
        groups.replaceObject(at: indexPath.section, with: arr)
        filterColView.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionWidth = (collectionView.bounds.width / 2) - 20
        return CGSize(width: collectionWidth, height: 45)
    }
}

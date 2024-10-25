//
//  RewardsVC.swift
//
//  Created by Rahul Gahlot on 03/11/22.
//

import UIKit

class RewardsVC: BaseClassWithoutTabNavigation {
    
    @IBOutlet weak var navigationView: CustomNavigation!
    @IBOutlet weak var collectionViewRewards: UICollectionView!
    @IBOutlet weak var lblTotalRewardAmount: UILabel!
    var arrRewards : [Reward] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUIData()

    }
    
    func setUIData(){
        navigationView.configureNavigationBarWithController(controller: self, title: "Rewards", hideNotification: false, hideAddMoney: true, hideBackBtn: false)
        
//        collectionViewRewards.delegate = self
//        collectionViewRewards.dataSource = self
//        collectionViewRewards.reloadData()
//
//        lblTotalRewardAmount.text = ""
//
//        getRewards()
    }
   
}

extension RewardsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: ((self.collectionViewRewards.frame.width - 6) / 2), height: 200)
    }
}

extension RewardsVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrRewards.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RewardsCell", for: indexPath)
        let lblDate = cell.viewWithTag(2) as? UILabel
        let lblPrice = cell.viewWithTag(3) as? UILabel
        let lblTitleCashBack = cell.viewWithTag(4) as? UILabel
        
        let item = arrRewards[indexPath.row]
        lblPrice?.text = "\(GDP.globalCurrency)"+String(item.rows?.credit ?? 0)
        lblTitleCashBack?.text = item.rows?.rewardText ?? ""
        if let date = item.rows?.createdAt,date.count > 0 {
            let finalDate = date.UTCToLocal(incomingFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ", outGoingFormat: "dd MMM yyyy")
            lblDate?.text = finalDate
        }

        return cell
    }
}

extension RewardsVC {
    
    func getRewards() {
        
        let params: [String:String] = [String:String]()
        let url = URLMethods.BaseURL + URLMethods.getUserRewards
        ApiClient.init().getRequest(method: url, parameters: params, view: (self.view)!) { result in
            if result != nil {
                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "message") as? String ?? ""
                if status == true{
                    if let data = result?.object(forKey: "results") as? NSArray{
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                              let tblData = try? JSONDecoder().decode([Reward].self, from: jsonData)else {return }
                        self.arrRewards = tblData
                       
                        self.collectionViewRewards.reloadData()
                        self.lblTotalRewardAmount.text = "\(GDP.globalCurrency)\((result?.object(forKey: "totalRewards") as? Double ?? 0).formattedNumber())"
                    } else { AppManager.showToast(msg, view: (self.view)!) }
                } else { AppManager.showToast(msg, view: (self.view)!) }
            } else { AppManager.showToast("", view: (self.view)!) }
            AppManager.stopActivityIndicator((self.view)!)
        }
        AppManager.startActivityIndicator(sender: (self.view)!)
    }
}

//
//  YourReferralsVC.swift
//  CrypTech
//
//  Created by New on 14/03/22.
//

import UIKit
import SDWebImage

class YourReferralsVC: UIViewController {
    
    @IBOutlet weak var lblNoData: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var arrFriends = [Friend]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadFriendsList()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func actionBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: UICollectionView (DataSource & Delegate) Methods
extension YourReferralsVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrFriends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendListCVCell", for: indexPath) as! FriendListCVCell
        
        let friend = arrFriends[indexPath.row]
        
        cell.lblName.text = (friend.first_name ?? "") + " " + (friend.last_name ?? "")
        cell.lblReferralAmount.text = "Referral Amount - \(friend.referred_amount?.rounded(toPlaces: 2) ?? 0)"
        cell.lblPaidReferralAmount.text = "Paid Amount - \(friend.referred_amount_paid?.rounded(toPlaces: 2) ?? 0)"
        
        cell.imgViewProfile.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.imgViewProfile.sd_setImage(with: URL(string: friend.image ?? ""), placeholderImage: Constants.kNoImageUser)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
        let size:CGFloat = (collectionView.frame.size.width - space) / 2.0
        return CGSize(width: size, height: size)
    }
}
extension YourReferralsVC{
    func loadFriendsList (){
        let params: [String:String] = [String:String]()
        
        let url = URLMethods.BaseURL + URLMethods().getCompleteProfile
        
        ApiClient.init().getRequest(method: url, parameters: params, view: (self.view)!) { result in
            if result != nil {
                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "message") as? String ?? ""
                if status == true{
                    if let data = result?.object(forKey: "results") as? [String:Any]{
                        let list = data["referral_list"] as? [[String:Any]]
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: list!, options: .prettyPrinted),
                        let tblData = try? JSONDecoder().decode([Friend].self, from: jsonData)else {return }
                        self.arrFriends = tblData
                        self.collectionView.reloadData()
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
            
            if self.arrFriends.count > 0{
                self.lblNoData.isHidden = true
            }else{
                self.lblNoData.isHidden = false
            }
        }
        AppManager.startActivityIndicator(sender: (self.view)!)
    }
}

//
//  MyMatchesContainer.swift
//  KnockOut11
//
//  Created by Octal Mac 217 on 05/09/22.
//

import UIKit
import Network
import CoreAudio
import SDWebImage
import SwiftyJSON

class MyMatchesContainer: UIView {
    
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var bannerCollectionView: UICollectionView!
    @IBOutlet weak var viewPageControl: UIPageControl!
    @IBOutlet weak var viewMyContest: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewMatch: UIView!
    @IBOutlet weak var viewBanner: UIView!
    
    var scrollImageTimer: Timer!
    var counter = 0

    private let bannerCellId = "BannerCVCell"
    private let cellId = "MyContestsCVCell"
    
    var controller:DashboardViewController? = nil
    var arrMyMatches:[Match]? = nil
    
    var arrBanners:[Banner]? = nil
    var bannerPath:String = ""
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MyMatchesContainer", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    func updateView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let nib = UINib(nibName: cellId, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: cellId)
        
        let bannerNib = UINib(nibName: bannerCellId, bundle: nil)
        bannerCollectionView.register(bannerNib, forCellWithReuseIdentifier: bannerCellId)
        
        self.loadBanners()
    }
    
    @IBAction func btnViewAllPressed(_ sender: UIButton) {
//        let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "ContestViewController") as! ContestViewController
//        self.controller!.navigationController?.pushViewController(VC, animated: true)
        
        if let tabbarController = Constants.kAppDelegate.tabbarController{
            if tabbarController.selectedIndex != 2{
                tabbarController.selectedIndex = 2
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(name: .init(rawValue: Constants.kMoveToContest), object: nil)
            }
        }
    }
    
    @objc func btnReminderPressed(_ sender: UIButton){
        
        let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "SetRemindersVC") as! SetRemindersVC
        VC.isModalInPresentation = true
        VC.selectedMatch = self.arrMyMatches?[sender.tag]
        VC.completionHandler = {(match, isReminder) in
            self.arrMyMatches?[sender.tag] = match
            self.collectionView.reloadData()
            self.controller!.getMatchesFromServer()
            
        }
        self.controller!.present(VC, animated: false)
    }
    
}

extension MyMatchesContainer{
    
    func saveMatch(match:Match, index:Int) {
        
        let params = ["match_id":match.match_id ?? 0,
                      "series_id":match.series_id ?? 0
        ]
        
        ApiClient.init().postRequest(params, request: URLMethods.BaseURL + URLMethods().saveMatchReminder, view: self.controller!.view) { (msg,result) in
            if result != nil {
                WebCommunication.shared.getMatchDetail(hostController: self.controller!, match_id: match.match_id ?? 0, showLoader: false) { match in
                    self.arrMyMatches?[index] = match ?? self.arrMyMatches![index]
                    self.collectionView.reloadData()
                }
            }else{
                AppManager.showToast(msg ?? "", view: self.controller!.view)
            }
            AppManager.stopActivityIndicator(self.controller!.view)
        }
        AppManager.startActivityIndicator(sender: self.controller!.view)
    }
}

//MARK: - CollectionView Methods
extension MyMatchesContainer: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == bannerCollectionView {
            return self.arrBanners?.count ?? 0
        }
        return self.arrMyMatches?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == bannerCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bannerCellId, for: indexPath) as! BannerCVCell
            
            let banner = arrBanners?[indexPath.item]
            
            cell.imageViewBanner.contentMode = .scaleToFill
            cell.imageViewBanner.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imageViewBanner.sd_setImage(with: URL(string: bannerPath + (banner?.image ?? "")), placeholderImage: Constants.kNoImagePromo)
            return cell
            
        }else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)  as! MyContestsCVCell
            
            cell.controller = self.controller
            
            cell.btnReminder.tag = indexPath.item
            cell.btnReminder.addTarget(self, action: #selector(btnReminderPressed(_:)), for: .touchUpInside)
            
            if let match = self.arrMyMatches?[indexPath.item]{
                if match.match_status?.uppercased() ?? "" == "NOT STARTED" || match.match_status?.uppercased() ?? "" == "UPCOMING" || (match.match_status?.uppercased() ?? "") == "FIXTURE"{
                    cell.btnReminder.isHidden = false
                    if (match.is_match_reminder ?? false) == true || (match.is_series_reminder ?? false) == true{
                        cell.btnReminder.isSelected = true
                    }else{
                        cell.btnReminder.isSelected = false
                    }
                }else{
                    cell.btnReminder.isHidden = true
                }
                
                cell.updateView(match: match, index: indexPath.item)
            }
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == bannerCollectionView {
            self.viewPageControl.currentPage = indexPath.item
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == bannerCollectionView {
            guard let banner = arrBanners?[indexPath.item] else { return }
            
            if (banner.banner_type ?? "").lowercased() == "match" {
                let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "MatchContestViewController") as! MatchContestViewController
                WebCommunication.shared.getMatchDetail(hostController: controller!, match_id: Int(banner.match_id ?? "") ?? 0, showLoader: true) { match in
                    GDP.selectedMatch = match
                    self.controller!.navigationController?.pushViewController(VC, animated: true)
                }
               
            }else if (banner.banner_type ?? "").lowercased() == "offer" {
                if let tabbarController = Constants.kAppDelegate.tabbarController{
                    tabbarController.selectedIndex = 3
                }
            }
            else {
                self.showWebView(banner: banner)
            }
        }else {
            self.controller!.navigateToMatchDetails(index: indexPath.item)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    func showWebView(banner: Banner) {
        let vc = Constants.KSideMenuStoryboard.instantiateViewController(withIdentifier: "WebPageViewController") as! WebPageViewController
        
        vc.url = URL(string: (URLMethods.BaseURL + URLMethods.FAQ))
        vc.url = URL(string: (banner.link ?? ""))
        vc.headerText = banner.title ?? ""
//        controller?.hidesBottomBarWhenPushed = true
        controller!.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension MyMatchesContainer {
    
    //MARK: - API Calls
    
    func loadBanners (){
        
        let params: [String:String] = ["page":"1",
                                       "itemsPerPage":"100"
        ]
        
        let url = URLMethods.BaseURL + URLMethods.homebanner
        
        ApiClient.init().getRequest(method: url, parameters: params, view: (self.controller?.view)!) { result in
            if result != nil {
                let status = result?.object(forKey: "success") as? Bool ?? false
                let msg = result?.object(forKey: "message") as? String ?? ""
                if status == true{
                    let data = result?.object(forKey: "results") as? [String:Any]
                    self.bannerPath = (result?.object(forKey: "banner_path") as? String ) ?? ""
                    if let results = data?["docs"] as? [[String:Any]]{
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: results, options: .prettyPrinted),
                              let tblData = try? JSONDecoder().decode([Banner].self, from: jsonData)else {return }
                        self.arrBanners = tblData
                        self.viewPageControl.numberOfPages = tblData.count
                        if tblData.count <= 1 {
                            self.viewPageControl.isHidden = true
                        }else {
                            self.viewPageControl.isHidden = false
                        }
                        self.bannerCollectionView.reloadData()
                        
                        if (self.arrBanners?.count ?? 0) > 1{
                            if self.scrollImageTimer != nil{
                                self.scrollImageTimer.invalidate()
                                self.scrollImageTimer = nil
                            }
                            self.setTimer()
                        }
                    }else{
                        AppManager.showToast(msg, view: (self.controller?.view)!)
                    }
                }else{
                    AppManager.showToast(msg, view: (self.controller?.view)!)
                }
                
            }else{
                AppManager.showToast("", view: (self.controller?.view)!)
            }
            self.progressIndicator.stopAnimating()
        }
        self.progressIndicator.startAnimating()
    }
    
    func setTimer() {
    scrollImageTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(moveToNextPage), userInfo: nil, repeats: true)
    }
    
    @objc func moveToNextPage() {
        
        if counter < arrBanners?.count ?? 0{
            let index = IndexPath.init(item: counter, section: 0)
            self.bannerCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
            viewPageControl.currentPage = counter
            counter += 1
        } else {
            counter = 0
            let index = IndexPath.init(item: counter, section: 0)
            self.bannerCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
            viewPageControl.currentPage = counter
            counter = 1
        }
    }
}

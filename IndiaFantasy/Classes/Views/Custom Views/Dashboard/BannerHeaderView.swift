//
//  BannerHeaderView.swift
//  IndiaFantasy
//
//  Created by Harendra Singh Rathore on 31/05/24.
//

import UIKit

class BannerHeaderView: UIView {

    @IBOutlet weak var bannerCollectionView: UICollectionView!
    @IBOutlet weak var viewPageControl: UIPageControl!
    @IBOutlet weak var viewMyContest: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewBanner: UIView!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "BannerHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
      }
    
    private let bannerCellId = "BannerCVCell"
    private let cellId = "MyContestsCVCell"
    
    var arrMyMatches: [Match]? = nil
    var arrBanners:[Banner]? = nil
    var bannerPath:String = ""
    var controller: CricketFantasyVC? = nil
    
    var scrollImageTimer: Timer!
    var counter = 0

    func updateView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        
        bannerCollectionView.delegate = self
        bannerCollectionView.dataSource = self
        
        let nib = UINib(nibName: cellId, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: cellId)
        
        let bannerNib = UINib(nibName: bannerCellId, bundle: nil)
        bannerCollectionView.register(bannerNib, forCellWithReuseIdentifier: bannerCellId)
        
        viewMyContest.isHidden = (arrMyMatches?.isEmpty ?? true)
        viewBanner.isHidden = arrBanners?.isEmpty ?? true
        
        if arrBanners?.isEmpty == false {
            self.viewPageControl.numberOfPages = arrBanners?.count ?? 0
            if arrBanners?.count ?? 0 <= 1 {
                self.viewPageControl.isHidden = true
            }else {
                self.viewPageControl.isHidden = false
            }
            
            if (self.arrBanners?.count ?? 0) > 1{
                if self.scrollImageTimer != nil{
                    self.scrollImageTimer.invalidate()
                    self.scrollImageTimer = nil
                }
                self.setTimer()
            }
        }
        
        collectionView.reloadData()
    }
    
    @IBAction func btnViewAllPressed(_ sender: UIButton) {
        
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
            self.controller?.getMatchesFromServer()
            
        }
        if let topVC = UIApplication.topViewController {
            topVC.present(VC, animated: false)
        }
    }
}

//MARK: - CollectionView Methods
extension BannerHeaderView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
            cell.imageViewBanner.loadImage(urlS: (bannerPath + (banner?.image ?? "")), placeHolder: Constants.kNoImagePromo)
            return cell
            
        }else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)  as! MyContestsCVCell
            
           //cell.controller = self.controller
            
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
            guard let banner = arrBanners?[indexPath.item], let topVC = UIApplication.topViewController else { return }
            
            if (banner.banner_type ?? "").lowercased() == "match" {
                let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "MatchContestViewController") as! MatchContestViewController
                WebCommunication.shared.getMatchDetail(hostController: topVC, match_id: Int(banner.match_id ?? "") ?? 0, showLoader: true) { match in
                    GDP.selectedMatch = match
                    if let topVC = UIApplication.topViewController {
                        topVC.navigationController?.pushViewController(VC, animated: true)
                    }
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
            self.navigateToMatchDetails(index: indexPath.item)
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
        if let topVC = UIApplication.topViewController {
            topVC.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func navigateToMatchDetails(index: Int){
        guard let match = self.arrMyMatches?[index] else { return }
        if (match.match_status?.uppercased() ?? "") == "NOT STARTED" || (match.match_status?.uppercased() ?? "") == "FIXTURE" {
            let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "MatchContestViewController") as! MatchContestViewController
            GDP.selectedMatch = match
            if let topVC = UIApplication.topViewController {
                topVC.navigationController?.pushViewController(VC, animated: true)
            }
        }
        else{
            if (match.match_status?.uppercased() ?? "") == "CANCELLED"{
                return
            }
            let VC = Constants.KContestStoryboard.instantiateViewController(withIdentifier: "LiveContestViewController") as! LiveContestViewController
            GDP.selectedMatch = match
            if let topVC = UIApplication.topViewController {
                topVC.navigationController?.pushViewController(VC, animated: true)
            }
        }
    }
}

extension BannerHeaderView {
    
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

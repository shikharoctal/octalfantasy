//
//  WelcomeViewController.swift
//  VPay
//
//  Created by Pankaj on 20/12/21.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var btnSkip: OctalButton!
    
    @IBOutlet weak var splashCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: CustomPageControl!
  
    // MARK: - Variables
   
    let cell = CollectionViewCellId.splashCollectionViewCell
    let collectionMargin = CGFloat(0)
    let itemSpacing = CGFloat(0)
    let itemHeight = CGFloat(322)
    var itemWidth = CGFloat(0)
    var currentItem = 0
  
    // MARK: - Life Cycle
 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        startActivity()
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //        signupButton.addCurve()
    }

    private func startActivity() {
        configure()
        setUI()
        setData()
    }
    private func configure() {
        self.navigationController?.navigationBar.isHidden = true
    }
    private func setUI() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        itemWidth =  UIScreen.main.bounds.width - collectionMargin * 2.0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.headerReferenceSize = CGSize(width: collectionMargin, height: 0)
        layout.footerReferenceSize = CGSize(width: collectionMargin, height: 0)
        layout.minimumLineSpacing = itemSpacing
        layout.scrollDirection = .horizontal
        splashCollectionView!.collectionViewLayout = layout
        splashCollectionView?.decelerationRate = UIScrollView.DecelerationRate.fast
    }
    private func setData() {
        splashCollectionView.register(UINib(nibName: SplashCollectionViewCell.cellId, bundle: nil), forCellWithReuseIdentifier: SplashCollectionViewCell.cellId)
    }
    
    @IBAction func btnSkipPressed(_ sender: Any) {
        //self.gotoWelcomeVC()
        CommonFunctions().setWelcomeVisitStatusTrue()
        Constants.kAppDelegate.swichToLogin()
    }
    
    
    @IBAction func nextButtonAction(_ sender: UIButton) {
        if pageControl.currentPage == 2 {
            CommonFunctions().setWelcomeVisitStatusTrue()
            Constants.kAppDelegate.swichToLogin()
            return
        }
        let visibleItems: NSArray = self.splashCollectionView.indexPathsForVisibleItems as NSArray
        var minItem: NSIndexPath = visibleItems.object(at: 0) as! NSIndexPath
        for itr in visibleItems {
            if minItem.row > (itr as AnyObject).row {
                minItem = itr as! NSIndexPath
            }
        }
        let nextItem = NSIndexPath(row: minItem.row + 1, section: 0)
        if self.pageControl.currentPage == 2 {
            self.pageControl.currentPage = 0
        } else {
            self.pageControl.currentPage = minItem.row + 1
        }
        
        if self.pageControl.currentPage == 2{
            btnSkip.isHidden = true
        }else{
            btnSkip.isHidden = false
        }
        
        self.splashCollectionView.scrollToItem(at: nextItem as IndexPath, at: .left, animated: true)
    }
    
    @IBAction func btnCtrlValueChanged(_ sender: UIPageControl) {
        if sender.currentPage == 2{
            btnSkip.isHidden = true
        }else{
            btnSkip.isHidden = false
        }
        let x = CGFloat(sender.currentPage) * self.splashCollectionView.frame.size.width
        self.splashCollectionView.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }
    
}
extension WelcomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: self.splashCollectionView.frame.width, height: splashCollectionView.frame.height)
    }
}
extension WelcomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.cell.makeCollectionCell(for: collectionView, indexPath: indexPath)
                as? SplashCollectionViewCell else { return UICollectionViewCell() }
        switch indexPath.item {
        case 0:
            cell.introLabel.text = "CREATE YOUR"
            cell.imageView.image = UIImage(named: "intro-1")
            cell.subtitleLabel.text = String(format:"FANTASY TEAM")
            break
        case 1:
            cell.introLabel.text = "CONTEST"
            cell.imageView.image = UIImage(named: "intro-2")
            cell.subtitleLabel.text = String(format:"JOIN CONTESTS")

//            cell.subtitleLabel.attributedText = CommonFunctions.getWelcomeAttributedString(first: "JOIN ", second: "CONTESTS")
            break
        case 2:
            cell.introLabel.text = "AND BATTLE"
            cell.imageView.image = UIImage(named: "intro-3")
            cell.subtitleLabel.text = String(format:"HEAD-TO-HEAD")
            break
        default:
            break
        }

        return cell
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let pageWidth = Float(itemWidth + itemSpacing)
        let targetXContentOffset = Float(targetContentOffset.pointee.x)
        let contentWidth = Float(splashCollectionView!.contentSize.width  )
        var newPage = Float(self.pageControl.currentPage)
        
        if velocity.x == 0 {
            newPage = floor( (targetXContentOffset - Float(pageWidth) / 2) / Float(pageWidth)) + 1.0
        } else {
            newPage = Float(velocity.x > 0 ? self.pageControl.currentPage + 1 : self.pageControl.currentPage - 1)
            if newPage < 0 {
                newPage = 0
            }
            if (newPage > contentWidth / pageWidth) {
                newPage = ceil(contentWidth / pageWidth) - 1.0
            }
        }
        self.pageControl.currentPage = Int(newPage)
      
        if newPage == 2{
            btnSkip.isHidden = true
        }else{
            btnSkip.isHidden = false
        }
        let point = CGPoint (x: CGFloat(newPage * pageWidth), y: targetContentOffset.pointee.y)
        targetContentOffset.pointee = point
    }
}
extension Bundle {
    // Name of the app - title under the icon.
    var displayName: String? {
            return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
                object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}

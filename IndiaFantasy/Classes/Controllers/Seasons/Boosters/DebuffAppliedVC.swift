//
//  DebuffAppliedVC.swift
//  India’s fantasy
//
//  Created by admin on 17/07/23.
//

import UIKit

class DebuffAppliedVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var imgBanner: UIImageView!
    
    var teamName = ""
    var bannerImg = ""
    var bannerTitle = ""
    var isFromGift = false
    var completion: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgBanner.loadImage(urlS: bannerImg, placeHolder: Constants.kNoImagePromo)
        
        if isFromGift {
            
            let friend = "Your friend ".withAttributes([
                .textColor(UIColor.white),
                .font(UIFont(name: Constants.kSemiBoldFont, size: lblTitle.font.pointSize)!)
                ])
            
            let teamName = teamName.withAttributes([
                .textColor(.appHighlightedTextColor),
                .font(UIFont(name: Constants.kSemiBoldFont, size: lblTitle.font.pointSize)!)
                ])
            
            let hasGifted = " has gifted you a booster.".withAttributes([
                .textColor(UIColor.white),
                .font(UIFont(name: Constants.kSemiBoldFont, size: lblTitle.font.pointSize)!)
                ])
            
            let result = NSMutableAttributedString()
            result.append(friend)
            result.append(teamName)
            result.append(hasGifted)
            
            lblTitle.attributedText = result
            lblSubTitle.text = "Make the most of it."
            
        }else {
            
            lblTitle.text = bannerTitle
            lblSubTitle.text = ""
        }
        
    }
    
    @IBAction func btnBannerPressed(_ sender: UIButton) {
        
        guard isFromGift == false else { return }
        
        dismiss(animated: false) {
            if let completion = self.completion {
                completion()
            }
        }
    }
    
    @IBAction func btnClosePressed(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
}

//
//  SplashCollectionViewCell.swift
//  VPay
//
//  Created by Pankaj on 20/12/21.
//


import UIKit

class SplashCollectionViewCell: UICollectionViewCell {
    
    // MARK: -
    static let cellId = "SplashCollectionViewCell"
    // MARK: - IBOutlet
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
  
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        startActivity()
        // Initialization code
    }
    
    private func startActivity() {
        configure()
        setUI()
        setData()
    }
    private func configure() {
    }
    func setUI() {
       // logoView.backgroundColor = VPayColor.primary.value
//        logoView.addCurve()
//        logoImageView.addCurve()
//        introLabel.font = Font(.installed(.HelveticaBold), size: .standard(.h10)).instance
//        subtitleLabel.font = Font(.installed(.HelveticaRegular), size: .standard(.h26)).instance
    }
    func setUIPremium() {
        
    }
    func setUIBasic() {
        
    }
    func setData() {
        
    }
    
    
}

//
//  SeasonNavigation.swift
//  India’s fantasy
//
//  Created by admin on 15/05/23.
//

import UIKit

class SeasonNavigation: UIView {
    
    //MARK: - Outlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnBackWidth: NSLayoutConstraint!
    @IBOutlet weak var imgViewBG: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var btnCreateTeam: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInitialized()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupInitialized()
    }

    //MARK: - Initialized XIB View
    private func setupInitialized() {
        Bundle.main.loadNibNamed("SeasonNavigation", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    //MARK: - Setup UI
    func setupUI(title: String, hideBG: Bool = false, hideBackBtn: Bool = false) {
        
        lblTitle.text = title
        imgViewBG.isHidden = hideBG
        btnBack.isHidden = hideBackBtn
        btnBackWidth.constant = hideBackBtn ? 0 : 30
    }
    
    //MARK: - Back Btn Action
    @IBAction func btnBackPressed(_ sender: Any) {
        
        guard let parent = self.parentViewController else { return }
        
        if parent.navigationController != nil {
            
            if ((parent as? SeasonCreateTeamVC) != nil) {
                parent.alertBoxWithAction(message: ConstantMessages.DiscardTeamAlert, btn1Title: ConstantMessages.CancelBtn, btn2Title: ConstantMessages.OkBtn) {
                    parent.navigationController?.popViewController(animated: true)
                }
            }else {
                if ((parent as? SeasonsHomeVC) != nil) {
                    parent.navigationController?.popToRootViewController(animated: true)
                }else {
                    parent.navigationController?.popViewController(animated: true)
                }
            }
            
        }else {
            parent.dismiss(animated: true)
        }
    }
    
    //MARK: - Create Team Btn Action
    @IBAction func btnCreateTeamPressed(_ sender: UIButton) {
        checkUnJoinedTeams()
    }
}

extension SeasonNavigation {
    
    func checkUnJoinedTeams() {
        
        guard let parent = self.parentViewController else { return }

        WebCommunication.shared.checkUnJoinedTeam(hostController: parent, seriesId: GDP.leagueSeriesId, showLoader: true) { status in

            if status == true {
                let vc = Constants.KSeasonsStoryboard.instantiateViewController(withIdentifier: "SeasonCreateTeamVC") as! SeasonCreateTeamVC
                self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}

//
//  SeasonHelpVC.swift
//  India’s fantasy
//
//  Created by admin on 22/05/23.
//

import UIKit

class SeasonHelpVC: UIViewController {

    @IBOutlet weak var navigationView: SeasonNavigation!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationView()
    }
    

    private func setupNavigationView() {
        navigationView.setupUI(title: GDP.leagueName)
    }

}

//
//  MoneyPoolCategoryVC.swift
//  IndiaFantasy
//
//  Created by Harendra Singh Rathore on 02/04/24.
//

import UIKit

class MoneyPoolCategoryVC: UIViewController {

    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private let cellId = "MoneyPoolCategoryTVCell"
    var arrCategory = [PoolCategoryData]()
    var selectedCategory: PoolCategoryData?
    var completionHandler : ((PoolCategoryData?)-> Void)?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimate()
        setupTableView()
    }
    
    override func viewDidLayoutSubviews() {
        viewMain.roundCorners(corners: [.topLeft, .topRight], radius: 50)
    }
    
    //MARK: Setup TableView
    private func setupTableView() {
        
        let nib = UINib(nibName: cellId, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        tableView.contentInset = .init(top: 10, left: 0, bottom: 0, right: 0)
        tableView.reloadData()
    }

    //MARK: Close btn action
    @IBAction func btnCloseAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    //MARK: Select btn action
    @IBAction func btnSelectAction(_ sender: UIButton) {
        dismiss(animated: true) {
            self.completionHandler?(self.selectedCategory)
        }
    }
}

//MARK: - UITableView Delegate and Datasource Methods
extension MoneyPoolCategoryVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? MoneyPoolCategoryTVCell else {
            return .init()
        }
        
        let category = arrCategory[indexPath.row]
        cell.lblTitle.text = category.title
        cell.btnSelect.isSelected = (selectedCategory == category)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategory = arrCategory[indexPath.row]
        tableView.reloadData()
    }
}

//MARK: - Show Animation
extension MoneyPoolCategoryVC {
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
}

//
//  UpcomingMatchesFilterVC.swift
//  India’s fantasy
//
//  Created by admin on 01/06/23.
//

import UIKit

class UpcomingMatchesFilterVC: UIViewController {
    
    @IBOutlet weak var tblSeries: UITableView!
    @IBOutlet weak var btnReset: UIButton!
    
    private let cellId = "SeriesTVCell"
    private var arrSeries = [MatchSeries]() {
        didSet {
            if arrSeries.count == 0 {
                tblSeries.setEmptyMessage(ConstantMessages.NoSeriesFound)
            }else {
                tblSeries.restoreEmptyMessage()
            }
            tblSeries.reloadData()
        }
    }
    
    private var arrFavSeries = [MatchSeries]()
    
    var selectedSeriesId: Int? = nil
    var completion: ((_ seriesId: Int?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnReset.isHidden =  (selectedSeriesId == nil) ? true : false
        setupTableView()
//        getSeriesListing()
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: cellId, bundle: nil)
        tblSeries.register(nib, forCellReuseIdentifier: cellId)
    }
    
    @IBAction func btnBackPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnResetPressed(_ sender: UIButton) {
     
        selectedSeriesId = nil
        
        self.dismiss(animated: true) {
            if let completion = self.completion {
                completion(self.selectedSeriesId)
            }
        }
    }
    
}

//MARK: - Table DataSource and Delegate Method
extension UpcomingMatchesFilterVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return section == 0 ? arrFavSeries.count : arrSeries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? SeriesTVCell else { return .init() }
        
        let series = indexPath.section == 0 ? arrFavSeries[indexPath.row] : arrSeries[indexPath.row]
        cell.setData = series
        
        if let selectedSeriesId = selectedSeriesId, selectedSeriesId == series.idAPI {
            cell.imgCheckBox.image = UIImage(named: "CheckRound_ic")
        }else {
            cell.imgCheckBox.image = nil
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 && arrFavSeries.isEmpty { return .none }
        if section == 1 && arrSeries.isEmpty { return .none }
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 20))
        
        //headerView.backgroundColor = .Color.headerBlue.value
        
        let lblHeader:UILabel = UILabel(frame: CGRect(x: 20, y: 0, width: 200, height: 20))
        lblHeader.text = section == 0 ? "Favorites" : "All"
        lblHeader.textColor = .appHighlightedTextColor
        lblHeader.font = UIFont(name: customFontSemiBold, size: 16)
        headerView.addSubview(lblHeader)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let seriesID = indexPath.section == 0 ? arrFavSeries[indexPath.row].idAPI : arrSeries[indexPath.row].idAPI
        selectedSeriesId = seriesID
        
        self.dismiss(animated: true) {
            if let completion = self.completion {
                completion(seriesID)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 && arrFavSeries.isEmpty { return 0 }
        if section == 1 && arrSeries.isEmpty { return 0 }
        return 20
    }
    
}

//MARK: API Call
extension UpcomingMatchesFilterVC {
    
    func getSeriesListing() {
        
        WebCommunication.shared.getSeriesList(hostController: self, showLoader: true) { series in
            
            let favSeries = (series ?? []).filter({$0.isFavourite == true})
            self.arrFavSeries = favSeries
            self.arrSeries = series ?? []
        }
    }
}


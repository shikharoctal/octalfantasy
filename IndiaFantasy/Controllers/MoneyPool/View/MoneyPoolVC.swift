//
//  MoneyPoolVC.swift
//  IndiaFantasy
//
//  Created by Sunil on 11/03/24.
//

import UIKit

class MonyPoolCategoryCVCell: UICollectionViewCell {
    
    @IBOutlet weak var lblCategoryTitle: OctalLabel!
}

class MoneyPoolVC: BaseClassVC {
    
    @IBOutlet weak var navigationView: CustomNavigation!
    @IBOutlet weak var viewLiveHeader: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout! 
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnResetFilter: UIButton!
    
    @IBOutlet weak var viewLive: UIView!
    @IBOutlet weak var btnLive: UIButton!
    
    @IBOutlet weak var viewJoined: UIView!
    @IBOutlet weak var btnJoined: UIButton!
    
    @IBOutlet weak var viewCompleted: UIView!
    @IBOutlet weak var btnCompleted: UIButton!
    @IBOutlet weak var btnCategory: UIButton!
    
    @IBOutlet weak var btnLiveEvent: UIButton!
    @IBOutlet weak var btnPerception: UIButton!
    
    
    @IBOutlet weak var btnMore: OctalButton!
    @IBOutlet weak var collectionCategory: UICollectionView!
    
    
    var selectedPoolType: PoolType = .liveEvent
    var selectedButton: UIButton = UIButton()
    var selectedCategory: PoolCategoryData? {
        didSet {
            guard let category = selectedCategory else { return }
            self.btnCategory.setTitle(category.title, for: .normal)
            btnTabActionPressed(selectedButton)
        }
    }
    
    private let liveTVCellId = "MoneyPoolLiveTVCell"
    private let perceptionTVCellId = "PerceptionTVCell"
    private let liveCVCellId = "MoneyPoolLiveCVCell"
    private let headerId = "MoneyPoolTVHeader"
    private let joinedTVCellId = "MoneyPoolJoinedTVCell"
    private let completedTVCellId = "MoneyPoolCompletedTVCell"
    private let categoryCVCellId = "MonyPoolCategoryCVCell"
    
    var matchList = [Match]()
    var categoryList = [PoolCategoryData]()
    var selectedMatchId = "" {
        didSet {
            btnResetFilter.isHidden = selectedMatchId.isEmpty
        }
    }
    private var showAnimation = false
    
    private var currentPage = 1
    private var totalItemCount = 0
    private var refreshControl = UIRefreshControl()
    
    private var arrQuestions: [PoolQuestionResult] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Constants.kAppDelegate.startSocketConnection()
        GDP.switchToCricket()
        setupNavigationView()
        setupTableView()
        setupCollectionView()
        selectedMatchId = ""
        selectedButton = btnLive
        btnPoolTypeAction(btnLiveEvent)
        getAdminUploadedBanners()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        guard selectedPoolType == .liveEvent else { return }
        getMatchListResponse()
    }
    
    //MARK: - Setup NavigationView
    private func setupNavigationView() {
        
        navigationView.configureNavigationBarWithController(controller: self, title: "Money Pool", hideNotification: false, hideAddMoney: true, hideBackBtn: true)
        navigationView.sideMenuBtnView.isHidden = false
        navigationView.avatar.isHidden = true
        navigationView.getBalance()
        CommonFunctions.setupSideMenu(controller: self)
    }
    
    //MARK: - Setup TableView
    private func setupTableView() {
        
        let nib = UINib(nibName: liveTVCellId, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: liveTVCellId)
        
//        let nib1 = UINib(nibName: joinedTVCellId, bundle: nil)
//        tableView.register(nib1, forCellReuseIdentifier: joinedTVCellId)
        
        let nib2 = UINib(nibName: perceptionTVCellId, bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: perceptionTVCellId)
        
        let nib3 = UINib(nibName: completedTVCellId, bundle: nil)
        tableView.register(nib3, forCellReuseIdentifier: completedTVCellId)
        
//        let nibHeader = UINib(nibName: headerId, bundle: nil)
//        tableView.register(nibHeader, forHeaderFooterViewReuseIdentifier: headerId)
        
        tableView.contentInset = .init(top: 10, left: 0, bottom: 0, right: 0)
        
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0
        }
        
        setupRefreshControl()
    }
    
    //MARK: - Setup Refresh Control
    private func setupRefreshControl() {
        
        refreshControl = UIRefreshControl()
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh",attributes: attributes)
        refreshControl.addTarget(self, action: #selector(getDataFromServer), for: .valueChanged)
        refreshControl.tintColor = .white
        tableView.refreshControl = refreshControl
    }
    
    @objc func getDataFromServer() {
        
        if self.refreshControl.isRefreshing { self.refreshControl.endRefreshing() }
        currentPage = 1
        self.getQuestionListResponse()
    }
    
    //MARK: Setup CollectionView
    private func setupCollectionView() {
        
        let nib = UINib(nibName: liveCVCellId, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: liveCVCellId)
        
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 15
        layout.minimumLineSpacing = 15
        layout.sectionInset = .init(top: 0, left: 15, bottom: 0, right: 10)
        // layout.itemSize = CGSize(width: (self.view.bounds.width - 30), height: 50)
        collectionCategory.collectionViewLayout = layout
        collectionCategory.delegate = self
        collectionCategory.dataSource = self
    }
    
    //MARK: - Tab's Actions
    @IBAction func btnTabActionPressed(_ sender: UIButton) {
        
        arrQuestions.removeAll()
        
        self.selectedButton = sender
        btnLive.isSelected = false
        btnJoined.isSelected = false
        btnCompleted.isSelected = false
        
        viewLive.backgroundColor = UIColor.clear
        viewJoined.backgroundColor = UIColor.clear
        viewCompleted.backgroundColor = UIColor.clear
        
        sender.isSelected = true
        
        switch sender {
        case btnLive:
            viewLive.backgroundColor = UIColor.appRedColor
            viewLiveHeader.isHidden = false
            collectionView.isHidden = !(selectedCategory?.title == "Cricket")
            
        case btnJoined:
            viewJoined.backgroundColor = UIColor.appRedColor
            viewLiveHeader.isHidden = true
            collectionView.isHidden = true
            
        case btnCompleted: 
            viewCompleted.backgroundColor = UIColor.appRedColor
            viewLiveHeader.isHidden = true
            collectionView.isHidden = true
            
        default: break
        }
        
        getDataFromServer()
        //getQuestionListResponse()
    }

    //MARK: - Filter Reset Btn Action
    @IBAction func btnFilterBtnAction(_ sender: UIButton) {
        selectedMatchId = ""
        collectionView.reloadData()
        getDataFromServer()
    }
   
    //MARK: - Select Category Btn Action
    @IBAction func btnCategoryAction(_ sender: UIButton) {
        
        let visibleCell = collectionCategory.visibleCells as? [MonyPoolCategoryCVCell]
        
        
        guard let pushVC = Constants.KMoneyPoolStoryboard.instantiateViewController(withIdentifier: "MoneyPoolCategoryVC") as? MoneyPoolCategoryVC else { return }
        pushVC.modalTransitionStyle = .crossDissolve
        pushVC.modalPresentationStyle = .overFullScreen
        pushVC.selectedCategory = selectedCategory
        pushVC.arrCategory = categoryList
        pushVC.completionHandler = { [weak self] category in
            guard let self = self else { return }
            self.selectedCategory = category
            //self.btnMore.setTitle(self.selectedCategory?.title ?? "", for: .normal)
            if let visibleCell = visibleCell, visibleCell.contains(where: {$0.lblCategoryTitle.text == category?.title}) {
                self.btnMore.setTitleColor(.white, for: .normal)
                self.btnMore.tintColor = .white
            }else {
                self.btnMore.setTitleColor(.appYellowColor, for: .normal)
                self.btnMore.tintColor = .appYellowColor
            }
            self.collectionCategory.reloadData()
        }
        
        present(pushVC, animated: true)
    }
    
    @IBAction func btnPoolTypeAction(_ sender: UIButton) {
        
        btnLiveEvent.backgroundColor = .white
        btnPerception.backgroundColor = .white
        
        btnLiveEvent.isSelected = false
        btnPerception.isSelected = false
         
        sender.isSelected = true
        sender.backgroundColor = .appSelectedBlueColor
        selectedPoolType = (sender == btnLiveEvent) ? .liveEvent : .perception
        selectedMatchId = ""
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
        getCategoryListResponse()
    }
}

//MARK: - UITableView Delegate and Datasource Methods
extension MoneyPoolVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrQuestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch selectedButton {
        case btnLive:
            
            switch selectedPoolType {
            case .liveEvent:
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: liveTVCellId, for: indexPath) as? MoneyPoolLiveTVCell else { return .init() }
                
                cell.currentIndex = indexPath
                cell.delegate = self
                cell.setData = arrQuestions.count > indexPath.row ? arrQuestions[indexPath.row] : nil
                cell.viewTeamImage.isHidden = !(selectedCategory?.title == "Cricket")
                
                cell.btnYes.tag = indexPath.row
                cell.btnYes.addTarget(self, action: #selector(btnOptionAPressed(_:)), for: .touchUpInside)
                
                cell.btnNo.tag = indexPath.row
                cell.btnNo.addTarget(self, action: #selector(btnOptionBPressed(_:)), for: .touchUpInside)
                
                cell.btnTie.tag = indexPath.row
                cell.btnTie.addTarget(self, action: #selector(btnOptionCPressed(_:)), for: .touchUpInside)
                
                return cell
            case .perception:
                return tableViewPerception(tableView, cellForRowAt: indexPath)
            }
            
            
        case btnJoined:  
            
            switch selectedPoolType {
            case .liveEvent:
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: liveTVCellId, for: indexPath) as? MoneyPoolLiveTVCell else { return .init() }
                
                guard arrQuestions.count > indexPath.row else { return cell }
                cell.setJoinedData = arrQuestions[indexPath.row]
                cell.viewTeamImage.isHidden = !(selectedCategory?.title == "Cricket")
                return cell
            case .perception:
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: perceptionTVCellId, for: indexPath) as? PerceptionTVCell else { return .init() }
                
                guard arrQuestions.count > indexPath.row else { return cell }
                cell.setJoinedData = arrQuestions[indexPath.row]
                return cell
            }
                
        case btnCompleted:
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: completedTVCellId, for: indexPath) as? MoneyPoolCompletedTVCell else { return .init() }
            
            guard arrQuestions.count > indexPath.row else { return cell }
            let pool = arrQuestions[indexPath.row]
            cell.viewTeamImage.isHidden = !(selectedCategory?.title == "Cricket")
            cell.setData = pool
            
            cell.btnTap.tag = indexPath.row
            cell.btnTap.addTarget(self, action: #selector(btnCollapsePressed(_:)), for: .touchUpInside)
            
            if showAnimation && self.arrQuestions[indexPath.row].isSelected && self.arrQuestions[indexPath.row].winningData?.winngsAmount != 0 {
                showAnimation = false
                cell.showAnimationView()
            }
            
            return cell
        default: return UITableViewCell()
        }
    }
    
    func tableViewPerception(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: perceptionTVCellId, for: indexPath) as? PerceptionTVCell else { return .init() }
        
        cell.currentIndex = indexPath
        cell.delegate = self
        
        guard arrQuestions.count > indexPath.row else { return cell }
        cell.setData = arrQuestions[indexPath.row]
        
        cell.btnOptionA.tag = indexPath.row
        cell.btnOptionA.addTarget(self, action: #selector(btnOptionAPressed(_:)), for: .touchUpInside)
        
        cell.btnOptionB.tag = indexPath.row
        cell.btnOptionB.addTarget(self, action: #selector(btnOptionBPressed(_:)), for: .touchUpInside)
        
        cell.btnOptionC.tag = indexPath.row
        cell.btnOptionC.addTarget(self, action: #selector(btnOptionCPressed(_:)), for: .touchUpInside)
        
        cell.btnOptionD.tag = indexPath.row
        cell.btnOptionD.addTarget(self, action: #selector(btnOptionDPressed(_:)), for: .touchUpInside)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        submitAnswer(answer: "", index: indexPath.row)
    }
    
    @objc func btnOptionAPressed(_ sender: UIButton) {
        submitAnswer(answer: "optionA", index: sender.tag)
    }
    
    @objc func btnOptionBPressed(_ sender: UIButton) {
        submitAnswer(answer: "optionB", index: sender.tag)
    }
    
    @objc func btnOptionCPressed(_ sender: UIButton) {
        submitAnswer(answer: "optionC", index: sender.tag)
    }
    
    @objc func btnOptionDPressed(_ sender: UIButton) {
        submitAnswer(answer: "optionD", index: sender.tag)
    }
    
    @objc func btnCollapsePressed(_ sender: UIButton) {
        
        arrQuestions[sender.tag].isSelected.toggle()
        if arrQuestions[sender.tag].isSelected == true && arrQuestions[sender.tag].winningData?.winngsAmount != 0 {
            self.showAnimation = true
        }
        
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
    }
    
    func submitAnswer(answer: String, index: Int) {
        guard selectedButton == btnLive else { return }
        guard let pushVC = Constants.KMoneyPoolStoryboard.instantiateViewController(withIdentifier: "MoneyPoolDetailVC") as? MoneyPoolDetailVC else { return }
        pushVC.questionData = arrQuestions[index]
        pushVC.selectedAnswer = answer
        pushVC.type = selectedPoolType
        pushVC.category = selectedCategory?.title ?? ""
        pushVC.completionJoin = { [weak self] in
            guard let self = self else { return }
            self.getDataFromServer()
        }
        self.navigationController?.pushViewController(pushVC, animated: true)
    }
    
    //MARK: Check TableView Scrolling To End
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == tableView else { return }
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
            
            if totalItemCount > arrQuestions.count {
                currentPage += 1
                self.getQuestionListResponse()
            }
        }
    }
}

//MARK: - UICollectionView Delegate and Datasource Methods
extension MoneyPoolVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == collectionCategory {
            return categoryList.count + 1
        } else {
            return matchList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     
        if collectionView == collectionCategory {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCVCellId, for: indexPath) as? MonyPoolCategoryCVCell else { return .init() }
            
            if indexPath.row == 0 {
                cell.lblCategoryTitle.text = "Category"
                cell.lblCategoryTitle.textAlignment = .left
                cell.lblCategoryTitle.textColor = .Color.boosterDisableColor.value
            } else {
                let rowIndex = indexPath.item - 1
                cell.lblCategoryTitle.textAlignment = .center
                cell.lblCategoryTitle.text = categoryList[rowIndex].title ?? ""
                cell.lblCategoryTitle.textColor = ((self.selectedCategory?.id ?? "") == (categoryList[rowIndex].id ?? "")) ? .Color.headerYellow.value : .white
            }
            return cell
            
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: liveCVCellId, for: indexPath) as? MoneyPoolLiveCVCell else { return .init() }
            
            let match = matchList[indexPath.item]
            cell.setData = match
            cell.viewMain.alpha = ("\(matchList[indexPath.item].match_id ?? 0)" == selectedMatchId) ? 0.8 : 1
            
            DispatchQueue.main.async {
                if let matchDate = CommonFunctions.getDateFromString(date: match.match_date ?? "", format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") {
                    cell.releaseDate = matchDate as NSDate
                    let elapseTimeInSeconds =  cell.releaseDate!.timeIntervalSince(Date())
                    cell.expiryTimeInterval = elapseTimeInSeconds
                }
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == collectionCategory {
            guard (indexPath.row != 0) else { return }
            
            let rowIndex = indexPath.item - 1
            self.selectedCategory = categoryList[rowIndex]
            //self.btnMore.setTitle(self.selectedCategory?.title ?? "", for: .normal)
            self.btnMore.setTitleColor(.white, for: .normal)
            self.btnMore.tintColor = .white
            self.collectionCategory.reloadData()
            
        } else {
            guard selectedMatchId != "\(matchList[indexPath.item].match_id ?? 0)" else {
                selectedMatchId = ""
                getDataFromServer()
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
                return
            }
            selectedMatchId = "\(matchList[indexPath.item].match_id ?? 0)"
            getDataFromServer()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == collectionCategory {
            return CGSize(width: collectionView.frame.width/4.2, height: 49)
        } else {
            return CGSize(width: collectionView.frame.width/2.1, height: 40)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView == collectionCategory {
            return .init(top: 0, left: 20, bottom: 0, right: 8)
        } else {
            return .init(top: 20, left: 20, bottom: 0, right: 20)
        }
    }
}


//MARK: - API requests
extension MoneyPoolVC {
    
    func getMatchListResponse() {
        WebCommunication.shared.getMoneyPoolMatchList(showLoader: true) { matchList in
            self.matchList = matchList ?? []
            self.collectionView.reloadData()
        }
    }
    
    func getCategoryListResponse() {
        
        WebCommunication.shared.getMoneyPoolCategoryList(type: selectedPoolType.rawValue, showLoader: true) { categories in
            
            self.categoryList = categories ?? []
            self.btnMore.isHidden = !(self.categoryList.count > 2)
            self.btnMore.setTitleColor(.white, for: .normal)
            self.btnMore.tintColor = .white
            
            guard !(self.categoryList.isEmpty) else {
                self.collectionCategory.reloadData();
                return
            }
            self.selectedCategory = self.categoryList.first
            //self.btnMore.setTitle(self.selectedCategory?.title ?? "", for: .normal)
            self.collectionCategory.reloadData()
        }
    }
    
    func getQuestionListResponse() {
        
        var status = ""
        switch selectedButton {
        case btnLive: status = "live"
        case btnJoined: status = "joined"
        case btnCompleted: status = "completed"
        default: break
        }
        
        if currentPage == 1 {
            self.arrQuestions.removeAll()
        }
        
        let request = PoolQuestionsRequest(status: status, type: selectedPoolType.rawValue, categoryId: selectedCategory?.id ?? "", matchId: selectedMatchId, page: currentPage)
        
        WebCommunication.shared.getPoolQuestionList(request: request) { questionList, totalDocs in
            
            self.totalItemCount = totalDocs
            if self.currentPage == 1 {
                var questions = questionList ?? []
                
                if self.selectedButton == self.btnCompleted && questions.count != 0 {
                    questions[0].isSelected = true
                    if questions[0].winningData?.winngsAmount != 0 {
                        self.showAnimation = true
                    }
                }
                self.arrQuestions = questions
            }else {
                self.arrQuestions += questionList ?? []
            }
            
            self.checkEmptyTable()
        }
    }
    
    func checkEmptyTable() {
        if arrQuestions.count == 0 {
            tableView.setEmptyMessage(ConstantMessages.NotFound)
        }else {
            tableView.restoreEmptyMessage()
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func getAdminUploadedBanners() {
        WebCommunication.shared.getAdminBanners { banner in
            guard let banner = banner, !(banner.mediaURL ?? "").isEmpty else { return }
            
            let pushVC = Constants.KMoneyPoolStoryboard.instantiateViewController(withIdentifier: "AdminBannerVC") as! AdminBannerVC
            pushVC.bannerData = banner
            pushVC.modalTransitionStyle = .crossDissolve
            pushVC.modalPresentationStyle = .overFullScreen
            self.present(pushVC, animated: true)
        }
    }
}

extension MoneyPoolVC: PoolTimeExpiredDelegate {
    
    func poolEventExpired(indexPath: IndexPath, id:String) {
        debugPrint("index = \(indexPath.row)")
        if self.arrQuestions.count > indexPath.row && self.arrQuestions[indexPath.row].id == id {
           
            self.arrQuestions.remove(at: indexPath.row)
            checkEmptyTable()
            //self.tableView.reloadData()
        }
    }
}

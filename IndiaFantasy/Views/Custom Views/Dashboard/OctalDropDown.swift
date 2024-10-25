//
//  OctalDropDown.swift
//
//  Created by Octal-Mac on 02/11/22.
//

import UIKit

@objc protocol OctalDropDownDelegate
{
    func didSelectOptionAtIndex(index : Int, selectedString:String)
}

class OctalDropDown: UIView {
    @IBOutlet weak var tblDropDown: UITableView!
    weak var delegate : OctalDropDownDelegate?
    var isSingleSelection = false
    var showClearFilter = false

    var dateFilter:CustomDateFooterView? = nil
    var data = [String]()
    var arrItems = [OctalDDModel]()
    var selectedString = ""
    
    @IBOutlet weak var btnApply: UIButton!
    var showDateFilter = false
    @IBOutlet weak var btnClear: UIButton!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "OctalDropDown", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
      }
    
    func updateView(){
        let nibSetUp = UINib(nibName: "OctalDropDownTVCell", bundle: nil)
        tblDropDown.register(nibSetUp, forCellReuseIdentifier: "OctalDropDownTVCell")
        self.btnClear.isHidden = !self.showClearFilter
        self.resetAllData(force: false)
    }
    
    func refreshAllSelections(){
        self.arrItems.removeAll()
        let nibSetUp = UINib(nibName: "OctalDropDownTVCell", bundle: nil)
        tblDropDown.register(nibSetUp, forCellReuseIdentifier: "OctalDropDownTVCell")
        self.btnClear.isHidden = !self.showClearFilter
        for str in data{
            var model = OctalDDModel()
            model.title = str
            model.isSelected = false
            self.arrItems.append(model)
        }
        
        tblDropDown.reloadData()
        self.updateDateFilter()
    }
    
    func resetAllData(force:Bool){
        self.arrItems.removeAll()
        var val = false
        var isIn = false
        for str in data{
            var model = OctalDDModel()
            model.title = str
            if self.selectedString.count > 0{
                let arr = self.selectedString.components(separatedBy: ",")
                if arr.contains(str){
                    if str.uppercased() == "ALL"{
                        if force == true{
                            val = model.isSelected
                            isIn = true
                        }else{
                            model.isSelected = true
                        }
                    }else{
                        model.isSelected = true
                    }
                }else{
                    model.isSelected = false
                }
            }else{
                model.isSelected = false
            }            
            self.arrItems.append(model)
        }
        
        
        if isIn == true{
            self.toggelAllRows(selected: val)
        }
        tblDropDown.reloadData()
        
        self.updateDateFilter()
    }
    
    func toggelAllRows(selected:Bool){
        for i in 0 ..< arrItems.count {
            var model = arrItems[i]
            model.isSelected = selected
            self.arrItems[i] = model
        }
    }
    
    func checkAllRowsIfRequired(){
         let arr = self.arrItems.filter({$0.isSelected == true})
            if arr.count == self.arrItems.count - 1{
            self.toggelAllRows(selected: true)
        }
    }
    
    func updateDateFilter(){
        if self.showDateFilter == true{
            if dateFilter != nil{
                dateFilter?.removeFromSuperview()
                dateFilter = nil
            }
            self.dateFilter = CustomDateFooterView.instanceFromNib() as? CustomDateFooterView
            self.dateFilter?.parentView = self
            self.dateFilter?.updateView()
            self.tblDropDown.tableFooterView = self.dateFilter
        }
    }
    
  
    func clearSelections(){
        self.arrItems.removeAll()
        for str in data{
            var model = OctalDDModel()
            model.title = str
            model.isSelected = false
            self.arrItems.append(model)
        }
        
        tblDropDown.reloadData()
    }
    
    func selectAllData(){
        self.arrItems.removeAll()
        for str in data{
            var model = OctalDDModel()
            model.title = str
            model.isSelected = true
            self.arrItems.append(model)
        }
        
        selectedString = arrItems.map { $0.title ?? "" }.joined(separator: ",")

        tblDropDown.reloadData()
    }
    
    @objc func btnCheckPressed(sender:UIButton){
        var str = ""
        if self.isSingleSelection == true{
            self.handleSingleSelections(index: sender.tag)
        }else{
            var model = self.arrItems[sender.tag]
            model.isSelected = !model.isSelected

            debugPrint(model)
            if (model.title?.uppercased() ?? "") == "ALL"{
                if model.isSelected == true{
                    self.selectAllData()
                }else{
                    self.resetAllData(force: true)
                }
            }else{
                if model.isSelected == false{
                    if self.showDateFilter == false{
                        var model = self.arrItems.first
                        model?.isSelected = false
                        self.arrItems[0] = model!
                    }
                }
                self.arrItems[sender.tag] = model
                
                selectedString = arrItems.map { $0.title ?? "" }.joined(separator: ",")
            }
           
            if self.showDateFilter == false{
                self.checkAllRowsIfRequired()
            }
        }

        tblDropDown.reloadData()

        if self.delegate != nil
        {
            var arrSelectedItems = [String]()
            for model in self.arrItems{
                if model.isSelected == true{
                    arrSelectedItems.append(model.title ?? "")
                }
            }
            
            str = arrSelectedItems.joined(separator: ",")
            self.delegate?.didSelectOptionAtIndex(index: sender.tag, selectedString: str)
        }
    }

    
    func handleSingleSelections(index:Int){
        for i in 0..<arrItems.count{
            var model = self.arrItems[i]
            if i != index{
                model.isSelected = false
            }
            self.arrItems[i] = model
        }
        var model = self.arrItems[index]
        model.isSelected = !model.isSelected
        self.arrItems[index] = model
    }
}
//MARK: UITableView (Delegate & DataSource)
extension OctalDropDown: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OctalDropDownTVCell") as! OctalDropDownTVCell

        let obj = self.arrItems[indexPath.row]
        cell.lblTitle.text = obj.title
        cell.btnCheck.tag = indexPath.row
        cell.btnCheck.isSelected = obj.isSelected
        cell.btnCheck.addTarget(self, action: #selector(btnCheckPressed(sender:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


struct OctalDDModel{
    var title:String?
    var isSelected = false
}

//
//  UITableViewExtension.swift
//  India’s fantasy
//
//  Created by admin on 16/05/23.
//

import Foundation
import SwiftUI

extension UITableView {

    func setEmptyMessage(_ message: String,_ textColor: UIColor = .white) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = textColor
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: customFontRegular, size: 14)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
    }

    func restoreEmptyMessage() {
        self.backgroundView = nil
    }
    
    func scrollTableViewToBottom(animated: Bool) {
           guard let dataSource = dataSource else { return }

           var lastSectionWithAtLeasOneElements = (dataSource.numberOfSections?(in: self) ?? 1) - 1

           while dataSource.tableView(self, numberOfRowsInSection: lastSectionWithAtLeasOneElements) < 1 {
               lastSectionWithAtLeasOneElements -= 1
           }

           let lastRow = dataSource.tableView(self, numberOfRowsInSection: lastSectionWithAtLeasOneElements) - 1

           guard lastSectionWithAtLeasOneElements > -1 && lastRow > -1 else { return }

           let bottomIndex = IndexPath(item: lastRow, section: lastSectionWithAtLeasOneElements)
           scrollToRow(at: bottomIndex, at: .bottom, animated: animated)
       }
    
    func checkIfLastCellIsVisible() -> Bool {
        guard let lastIndexPath = self.indexPathsForVisibleRows?.last else {
            // No cells are currently visible
            return false
        }
        
        let lastRowIndex = self.numberOfRows(inSection: 0) - 1
        if lastIndexPath.row == lastRowIndex {
            // The last cell is currently visible
            return true
        }
        return false
    }
}

extension UICollectionView {

    func setEmptyMessage(_ message: String,_ textColor: UIColor = .white) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = textColor
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: customFontRegular, size: 14)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
    }

    func restoreEmptyMessage() {
        self.backgroundView = nil
    }
}

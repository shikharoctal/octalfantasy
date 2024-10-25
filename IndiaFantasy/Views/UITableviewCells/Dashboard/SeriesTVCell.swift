//
//  SeriesTVCell.swift
//  India’s fantasy
//
//  Created by admin on 01/06/23.
//

import UIKit

class SeriesTVCell: UITableViewCell {

    @IBOutlet weak var lblSeriesName: UILabel!
    @IBOutlet weak var imgCheckBox: UIImageView!
    
    var setData: MatchSeries? {
        didSet {
            guard let series = setData else { return }
            lblSeriesName.text = series.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

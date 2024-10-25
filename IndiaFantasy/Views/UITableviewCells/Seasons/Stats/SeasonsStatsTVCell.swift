//
//  SeasonsStatsTVCell.swift
//  India’s fantasy
//
//  Created by admin on 27/04/23.
//

import UIKit

class SeasonsStatsTVCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var collectionViewPlayers: UICollectionView!
    
    private let cellId = "SeasonsStatsCVCell"

    var playersList: [LeaguePlayers] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        setupCollectionView()
    }
    
    func setupCollectionView() {
        
        collectionViewPlayers.delegate = self
        collectionViewPlayers.dataSource = self
        
        let nib = UINib(nibName: cellId, bundle: nil)
        collectionViewPlayers.register(nib, forCellWithReuseIdentifier: cellId)
    }

}

extension SeasonsStatsTVCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return playersList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SeasonsStatsCVCell
        
        cell.setPlayers = playersList[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width/2.5, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 20, bottom: 0, right: 20)
    }
    
}


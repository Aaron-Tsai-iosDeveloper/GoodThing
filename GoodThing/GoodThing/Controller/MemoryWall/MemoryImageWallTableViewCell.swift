//
//  memoryImageWallTableViewCell.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/21.
//

import UIKit

class MemoryImageWallTableViewCell: UITableViewCell {
    
    @IBOutlet weak var memoryWallPosterNameLabel: UILabel!
    @IBOutlet weak var memoryWallArticleImageView: UIImageView!
    @IBOutlet weak var memoryWallArticleNameLabel: UILabel!
    @IBOutlet weak var memoryWallArticleContentLabel: UILabel!
    @IBOutlet weak var memoryWallArticleCreatedTimeLabel: UILabel!
    @IBOutlet weak var memoryImageWallArticleTagsCollectionView: UICollectionView!
    
    var memoryTags: [String] = [] {
        didSet {
            memoryImageWallArticleTagsCollectionView.reloadData()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        memoryImageWallArticleTagsCollectionView.dataSource = self
        memoryImageWallArticleTagsCollectionView.delegate = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }
    
}

extension MemoryImageWallTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(memoryTags.count, 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoryImageWallCollectionViewCell", for: indexPath) as? MemoryImageWallCollectionViewCell {
            cell.memoryImageWallArticleTagLabel.text = memoryTags[indexPath.item]
            return cell
        }
        return MemoryImageWallCollectionViewCell()
    }
}

extension MemoryImageWallTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 30, height: 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

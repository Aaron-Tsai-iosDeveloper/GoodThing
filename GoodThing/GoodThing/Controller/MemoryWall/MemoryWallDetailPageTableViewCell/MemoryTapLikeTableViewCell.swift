//
//  MemoryWallDetailTapLikeTableViewCell.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/22.
//

import UIKit

class MemoryTapLikeTableViewCell: UITableViewCell {
    @IBOutlet weak var memoryWallDetailPageLikeImageView: UIImageView!
    @IBOutlet weak var memoryWallDetailPageLikeNumberLabel: UILabel!
    @IBOutlet weak var memoryWallDetailPageShareButton: UIButton!
    @IBOutlet weak var memoryWallDetailPageTapLikeButton: UIButton!
    @IBOutlet weak var memoryWallDetailPageCollectionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

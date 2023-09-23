//
//  MemoryImageWallDetailTableViewCell.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/22.
//

import UIKit

class MemoryImageWallDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var memoryImageWallDetailPageArticleNameLabel: UILabel!
    @IBOutlet weak var memoryImageWallDetailPagePosterNameButton: UIButton!
    @IBOutlet weak var memoryImageWallDetailPageArticleCreatedTimeLabel: UILabel!
    @IBOutlet weak var memoryImageWallDetailPageArticleImageView: UIImageView!
    @IBOutlet weak var memoryImageWallDetailPageArticleContentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

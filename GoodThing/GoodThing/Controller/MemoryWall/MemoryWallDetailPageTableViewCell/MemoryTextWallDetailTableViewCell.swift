//
//  MemoryTextWallDetailTableViewCell.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/22.
//

import UIKit

class MemoryTextWallDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var memoryTextWallDetailPageArticleNameLabel: UILabel!
    @IBOutlet weak var memoryTextWallDetailPagePosterButton: UIButton!
    @IBOutlet weak var memoryTextWallDetailPageArticleContentLabel: UILabel!
    @IBOutlet weak var memoryTextWallDetailPageArticleCreatedTimeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}

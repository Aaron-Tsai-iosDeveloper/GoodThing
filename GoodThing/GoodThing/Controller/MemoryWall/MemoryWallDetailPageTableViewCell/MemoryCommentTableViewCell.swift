//
//  MemoryWallDetailCommentTableViewCell.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/22.
//

import UIKit

class MemoryCommentTableViewCell: UITableViewCell {
    @IBOutlet weak var memoryWallDetailPageCommenterButton: UIButton!
    @IBOutlet weak var memoryWallDetailPageCommentContentLabel: UILabel!
    @IBOutlet weak var memoryWallDetailPageRowNumberLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

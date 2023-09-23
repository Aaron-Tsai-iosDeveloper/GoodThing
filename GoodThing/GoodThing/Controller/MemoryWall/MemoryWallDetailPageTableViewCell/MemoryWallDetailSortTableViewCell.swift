//
//  MemoryWallDetailSortTableViewCell.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/22.
//

import UIKit

class MemoryWallDetailSortTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var memoryWallDetailPageSortByHotsButton: UIButton!
    @IBOutlet weak var memoryWallDetailPageSortFromNewButton: UIButton!
    @IBOutlet weak var memoryWallDetailPageSortFromOldButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

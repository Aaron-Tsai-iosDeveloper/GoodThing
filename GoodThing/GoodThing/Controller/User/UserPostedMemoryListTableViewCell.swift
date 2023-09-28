//
//  UserPostedMemoryListTableViwCell.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/28.
//

import UIKit

class UserPostedMemoryListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postedMemoryTitleLabel: UILabel!
    @IBOutlet weak var postedMemoryContentLabel: UILabel!
    @IBOutlet weak var postedMemoryDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

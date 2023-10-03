//
//  UserInfoPostedContentTableViwCell.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/28.
//

import UIKit

class UserPostedTaskListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postedTaskTitleLabel: UILabel!
    @IBOutlet weak var postedTaskContentLabel: UILabel!
    @IBOutlet weak var postedTaskDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

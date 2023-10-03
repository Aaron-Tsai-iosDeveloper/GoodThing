//
//  UserFriendLetterListTableViewCell.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/10/2.
//

import UIKit

class UserFriendLetterListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var letterListPenNameButton: UIButton!
    @IBOutlet weak var letterCreatedTimeLabel: UILabel!
    @IBOutlet weak var letterTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

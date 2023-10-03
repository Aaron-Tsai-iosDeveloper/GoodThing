//
//  UserProfileFriendListTableViewCell.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/10/2.
//

import UIKit

class UserFriendListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userProfileFriendNameButton: UIButton!
    
    @IBOutlet weak var userProfileFriendListNotificationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

//
//  GroupsTableViewCell.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/18.
//

import UIKit

class GroupsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var groupNameLabel: UILabel!
    
    @IBOutlet weak var groupTimeLabel: UILabel!
    
    @IBOutlet weak var groupLocationLabel: UILabel!
    
    @IBOutlet weak var peopleNumberLimitLabel: UILabel!
    
    @IBOutlet weak var currentPeopleNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

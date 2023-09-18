//
//  DetailGroupTableViewCell.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/18.
//

import UIKit

class DetailGroupTableViewCell: UITableViewCell {
    
    @IBOutlet weak var detailGroupIDLabel: UILabel!
    @IBOutlet weak var detailGroupNameLabel: UILabel!
    @IBOutlet weak var detailGroupTimeLabel: UILabel!
    @IBOutlet weak var detailGroupLocationLabel: UILabel!
    @IBOutlet weak var detailGroupOrganizerIDLabel: UILabel!
    @IBOutlet weak var detailGroupCreatedTimeLabel: UILabel!
    @IBOutlet weak var detailGroupDeadLineLabel: UILabel!
    @IBOutlet weak var detailGroupPeopleNumberLimitLabel: UILabel!
    @IBOutlet weak var detailGroupContentLabel: UILabel!
    @IBOutlet weak var detailGroupCurrentPeopleNumberLabel: UILabel!
    @IBOutlet weak var detailGroupPostButton: UIButton!
    @IBAction func joinButtonTapped(_ sender: UIButton) {
        joinButtonAction?()
    }
    var joinButtonAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

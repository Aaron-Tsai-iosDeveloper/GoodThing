//
//  UserInfoDetailTableViwCell.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/28.
//

import UIKit

class UserInfoDetailTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var userInfoUserNameLabel: UILabel!
    @IBOutlet weak var userInfoIdLabel: UILabel!
    @IBOutlet weak var userInfoRegistrationTimeLabel: UILabel!
    @IBOutlet weak var userInfoIntroductionLabel: UILabel!
    @IBOutlet weak var userInfoFavoriteSentenceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}

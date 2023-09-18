//
//  PrivateMemoryTableViewCell.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/18.
//

import UIKit

class PrivateMemoryTableViewCell: UITableViewCell {

    @IBOutlet weak var privateMemoryTitleLabel: UILabel!
    @IBOutlet weak var privateMemoryCreatedTimeLabel: UILabel!
    @IBOutlet weak var privateMemoryTagLabel: UILabel!
    @IBOutlet weak var privateMemoryContentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}

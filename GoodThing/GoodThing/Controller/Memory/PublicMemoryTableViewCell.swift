//
//  PublicMemoryTableViewCell.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/18.
//

import UIKit

class PublicMemoryTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var publicMemoryTitleLabel: UILabel!
    @IBOutlet weak var publicMemoryCreatedTimeLabel: UILabel!
    @IBOutlet weak var publicMemoryTagLabel: UILabel!
    @IBOutlet weak var publicMemoryAuthorLabel: UILabel!
    @IBOutlet weak var publicMemoryContentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

     
    }

}

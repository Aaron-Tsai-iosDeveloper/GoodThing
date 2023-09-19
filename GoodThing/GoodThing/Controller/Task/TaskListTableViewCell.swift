//
//  TaskListTableViewCell.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/18.
//

import UIKit

class TaskListTableViewCell: UITableViewCell {

    @IBOutlet weak var taskListDeleteButton: UIButton!
    @IBOutlet weak var taskTitleListLabel: UILabel!
    
    var onDelete: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    
    @IBAction func deleteTaskButton(_ sender: UIButton) {
        onDelete?()
    }
}

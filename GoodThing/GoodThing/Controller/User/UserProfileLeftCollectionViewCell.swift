//
//  userProfileLeftCollectionViewCell.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/10/3.
//

import UIKit

class UserProfileLeftCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var userProfileButton: UIButton!
    
    var buttonTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userProfileButton.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
    }
    

    
    @objc func buttonClicked() {
        buttonTapped?()
    }
    
    func configure(with attributes: ButtonAttributes) {
        userProfileButton.setTitle(attributes.title, for: .normal)
        userProfileButton.setTitleColor(attributes.titleColor, for: .normal)
        userProfileButton.layer.borderWidth = 1.0
        userProfileButton.layer.cornerRadius = 20
    }
}

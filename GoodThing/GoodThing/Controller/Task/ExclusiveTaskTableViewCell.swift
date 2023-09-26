//
//  ExclusiveTaskTableViewCell.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/26.
//

import UIKit

class ExclusiveTaskTableViewCell: UITableViewCell {

    let taskNameLabel: UILabel = {
        let label = UILabel()
        label.text = "任務名稱"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let checkmarkButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("✓", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.setTitleColor(.green, for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(taskNameLabel)
        addSubview(checkmarkButton)
        
        // Setup layout constraints
        NSLayoutConstraint.activate([
            taskNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            taskNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            checkmarkButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkmarkButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            checkmarkButton.widthAnchor.constraint(equalToConstant: 44),
            checkmarkButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        checkmarkButton.addTarget(self, action: #selector(didTapCheckmarkButton), for: .touchUpInside)
    }
    
    @objc private func didTapCheckmarkButton() {
        checkmarkButton.isSelected.toggle()
        print("Button is now: \(checkmarkButton.isSelected ? "Selected" : "Not Selected")")
    }

}

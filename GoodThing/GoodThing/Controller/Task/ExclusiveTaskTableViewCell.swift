//
//  ExclusiveTaskTableViewCell.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/26.
//

import UIKit

class ExclusiveTaskTableViewCell: UITableViewCell {
    
    var onCheckmarkTapped: ((IndexPath) -> Void)?
    var indexPath: IndexPath?
    
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
        bringSubviewToFront(checkmarkButton)
        
        NSLayoutConstraint.activate([
            taskNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            taskNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            checkmarkButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkmarkButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            checkmarkButton.widthAnchor.constraint(equalToConstant: 120),
            checkmarkButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        checkmarkButton.addTarget(self, action: #selector(didTapCheckmarkButton), for: .touchUpInside)
      
    }
    
    @objc func didTapCheckmarkButton() {
        print("Checkmark button was tapped!")
        checkmarkButton.isSelected.toggle()
        if let currentIndexPath = self.indexPath {
            print("About to call the onCheckmarkTapped closure")
            onCheckmarkTapped?(currentIndexPath)
        }
        print("Button is now: \(checkmarkButton.isSelected ? "Selected" : "Not Selected")")
    }
    // TODO: 之後回頭確認這部分的原理，為什麼這樣才能點擊到按鈕
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if checkmarkButton.frame.contains(point) {
            return checkmarkButton
        }
        return super.hitTest(point, with: event)
    }
}

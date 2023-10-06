//
//  ExclusiveTaskCollectionViewCell.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/26.
//

import UIKit
import FirebaseFirestore

class ExclusiveTaskCollectionViewCell: UICollectionViewCell {

    var tasks: [GoodThingExclusiveTasks] = [] {
        didSet {
            exclusiveTaskTableView.reloadData()
        }
    }
    
    weak var delegate: ExclusiveTaskCollectionViewCellDelegate?
    
    let exclusiveTaskTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ExclusiveTaskTableViewCell.self, forCellReuseIdentifier: "ExclusiveTaskTableViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let exclusiveTaskPostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("發佈專屬任務", for: .normal)
        button.tintColor = .lightGray
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.brown.cgColor
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let taskTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "輸入新的任務"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        exclusiveTaskTableView.delegate = self
        exclusiveTaskTableView.dataSource = self
        exclusiveTaskPostButton.addTarget(self, action: #selector(didTapPostButton), for: .touchUpInside)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapPostButton() {
        if let newTaskTitle = taskTextField.text, !newTaskTitle.isEmpty {
            delegate?.didRequestToPostExclusiveTask(title: newTaskTitle, from: self)
            taskTextField.text = ""
        }
    }
    
    private func setupUI() {
        addSubview(exclusiveTaskTableView)
        addSubview(exclusiveTaskPostButton)
        addSubview(taskTextField)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.addGestureRecognizer(tapGesture)
        
        
        NSLayoutConstraint.activate([
            exclusiveTaskTableView.topAnchor.constraint(equalTo: topAnchor),
            exclusiveTaskTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            exclusiveTaskTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            exclusiveTaskTableView.bottomAnchor.constraint(equalTo: taskTextField.topAnchor, constant: -10),
            
            taskTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1),
            taskTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            taskTextField.heightAnchor.constraint(equalToConstant: 44),
            
            exclusiveTaskPostButton.topAnchor.constraint(equalTo: taskTextField.bottomAnchor, constant: 10),
            exclusiveTaskPostButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -20),
            exclusiveTaskPostButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -200),
            exclusiveTaskPostButton.widthAnchor.constraint(equalToConstant: 120),
            exclusiveTaskPostButton.heightAnchor.constraint(equalToConstant: 40)
        ])

    }
    
    @objc func dismissKeyboard() {
        self.endEditing(true)
    }
}

extension ExclusiveTaskCollectionViewCell: UITableViewDataSource,UITableViewDelegate {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
        print(tasks.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExclusiveTaskTableViewCell", for: indexPath) as! ExclusiveTaskTableViewCell
        cell.taskNameLabel.text = tasks[indexPath.row].exclusiveTaskTitle
        cell.checkmarkButton.isSelected = tasks[indexPath.row].completedStatus
        cell.indexPath = indexPath
        cell.onCheckmarkTapped = { [weak self] indexPath in
            print("The onCheckmarkTapped closure is being called for row: \(indexPath.row)")
            guard let strongSelf = self else { return }
            strongSelf.delegate?.didTapCheckmarkButton(at: indexPath, from: strongSelf)
        }
        print("Setting the onCheckmarkTapped closure for cell at row: \(indexPath.row)")
        return cell
    }
    
}
extension ExclusiveTaskCollectionViewCell: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            return false
        }
        return true
    }
    
   
}
protocol ExclusiveTaskCollectionViewCellDelegate: AnyObject {
    func didRequestToPostExclusiveTask(title: String, from cell: ExclusiveTaskCollectionViewCell)
    func didTapCheckmarkButton(at indexPath: IndexPath, from cell: ExclusiveTaskCollectionViewCell)
}

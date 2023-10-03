//
//  ExclusiveTaskCollectionViewCell.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/26.
//

import UIKit

class ExclusiveTaskCollectionViewCell: UICollectionViewCell {

        var tasks = ["捐款家扶中心", "微笑", "說聲早安"]
        var selectedTasks: [Bool] = [false, false, false]

    
        let exclusiveTaskTableView: UITableView = {
            let tableView = UITableView()
            tableView.register(ExclusiveTaskTableViewCell.self, forCellReuseIdentifier: "ExclusiveTaskTableViewCell")
            tableView.translatesAutoresizingMaskIntoConstraints = false
            return tableView
        }()
        
        let exclusiveTaskPostButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("發佈專屬任務", for: .normal)
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
            if let newTask = taskTextField.text, !newTask.isEmpty {
                tasks.append(newTask)
                selectedTasks.append(false)
                exclusiveTaskTableView.reloadData()
                taskTextField.text = ""
            }
        }
        private func setupUI() {
            addSubview(exclusiveTaskTableView)
            addSubview(exclusiveTaskPostButton)
            addSubview(taskTextField)
            
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//            self.addGestureRecognizer(tapGesture)

            NSLayoutConstraint.activate([
                exclusiveTaskTableView.topAnchor.constraint(equalTo: topAnchor),
                exclusiveTaskTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
                exclusiveTaskTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
                
                taskTextField.bottomAnchor.constraint(equalTo: exclusiveTaskPostButton.topAnchor, constant: -10),
                taskTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                taskTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                taskTextField.heightAnchor.constraint(equalToConstant: 44),
                
                exclusiveTaskPostButton.topAnchor.constraint(equalTo: exclusiveTaskTableView.bottomAnchor),
                exclusiveTaskPostButton.leadingAnchor.constraint(equalTo: leadingAnchor),
                exclusiveTaskPostButton.trailingAnchor.constraint(equalTo: trailingAnchor),
                exclusiveTaskPostButton.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -200)
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
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExclusiveTaskTableViewCell", for: indexPath) as! ExclusiveTaskTableViewCell
        cell.taskNameLabel.text = tasks[indexPath.row]
        cell.checkmarkButton.isSelected = selectedTasks[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTasks[indexPath.row].toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

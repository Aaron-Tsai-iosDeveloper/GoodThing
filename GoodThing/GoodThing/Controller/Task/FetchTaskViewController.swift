//
//  FetchTaskViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/17.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class FetchTaskViewController: UIViewController {
    @IBOutlet weak var fetchTasksButton: UIButton!
    @IBOutlet weak var taskGiverLabel: UILabel!
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskContentLabel: UILabel!
    @IBOutlet weak var taskListsButton: UIButton!
    
    @IBOutlet weak var taskListTableView: UITableView!
    
    lazy var db = Firestore.firestore()
    var tasks = [GoodThingTasks]()
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTasksButton.addTarget(self, action: #selector(fetchDailyTasks), for: .touchUpInside)
        taskListsButton.addTarget(self, action: #selector(fetchTasksList), for: .touchUpInside)
        
        taskListTableView.dataSource = self
        taskListTableView.delegate = self
    }
    
    @objc func fetchDailyTasks() {
        fetchTasks(){
            self.updateTaskUI()
        }
    }
    
    @objc func fetchTasksList() {
        fetchTasks(byCreatorID: "Aaron",withPrivateStatus: false) {
            self.taskListTableView.reloadData()
        }
    }
     func fetchTasks(byCreatorID creatorID: String? = nil, withPrivateStatus isPrivate: Bool? = nil, completion: @escaping () -> Void) {
         var query: Query = db.collection("GoodThingTasks").order(by: "taskCreatedTime", descending: true)
         if let creatorID = creatorID {
             query = query.whereField("taskCreatorId", isEqualTo: creatorID)
         }
         if let isPrivate = isPrivate {
             query = query.whereField("privacyStatus", isEqualTo: isPrivate)
         }
         query.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("error about fetchTasks : \(error) ")
            } else {
                self.tasks.removeAll()
                for document in querySnapshot!.documents {
                    do {
                        let task = try document.data(as: GoodThingTasks.self, decoder: Firestore.Decoder())
                        self.tasks.append(task)
                    } catch let error {
                        print("fetchTasks decoding error: \(error)")
                    }
                }
                print("successfully fethchTasks:\(self.tasks)")
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    func updateTaskUI() {
        if let firstTask = tasks.first {
            self.taskGiverLabel.text = " 來自 \(firstTask.taskCreatorId) 發佈的好事任務"
            self.taskTitleLabel.text = " 好事任務： \(firstTask.taskTitle)"
            self.taskContentLabel.text = firstTask.taskContent
        }
    }
}



extension FetchTaskViewController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListTableViewCell",for: indexPath) as? TaskListTableViewCell {
            let task = tasks[indexPath.row]
            cell.taskTitleListLabel.text = task.taskTitle
            cell.onDelete = { [weak self] in
                self?.deleteTask(at: indexPath)
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    func deleteTask(at indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        let Id = task.taskId
        db.collection("GoodThingTasks").document(Id).delete() { [weak self] error in
            if let error = error {
                print("Failed to delete task: \(error)")
            } else {
                self?.tasks.remove(at: indexPath.row)
                DispatchQueue.main.async {
                    self?.taskListTableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
}

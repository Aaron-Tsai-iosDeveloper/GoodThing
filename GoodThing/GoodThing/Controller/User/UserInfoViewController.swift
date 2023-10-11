//
//  fetchUserInfoViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/28.
//

import UIKit
import FirebaseFirestore

class UserInfoViewController: UIViewController {

    var userInfo: GoodThingUser?
    var userTaskList = [GoodThingTasks]()
    var userMemoryList = [GoodThingMemory]()
    let db = Firestore.firestore()
    //TODO: 要注意是顯示“用戶個人”的資訊還是“用戶好友”資訊，要依據不同segue變化
    var user: GoodThingUser?
    var userId: String? {
        return user?.userId
    }
    
    
    @IBOutlet weak var userInfoTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userInfoTableView.dataSource = self
        self.userInfoTableView.delegate = self
       fetchUserInfo()
       fetchUserPostedTasks()
       fetchUserPostedMemory()
    }
    func fetchUserInfo() {
        var query: Query = db.collection("GoodThingUser").whereField("userId", isEqualTo: userId)
        
        query.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error fetching userInfo: \(error)")
            } else if let document = querySnapshot?.documents.first {
                do {
                    let fetchedUserInfo = try document.data(as: GoodThingUser.self, decoder: Firestore.Decoder())
                    self.userInfo = fetchedUserInfo
                    print("userInfo fetched successfully: \(fetchedUserInfo)")
                    
                    DispatchQueue.main.async {
                        self.userInfoTableView.reloadData()
                    }
                } catch let error {
                    print("Decoding error: \(error)")
                }
            }
        }
    }
    func fetchUserPostedMemory() {
        
        var query: Query = db.collection("GoodThingMemory")
            .order(by: "memoryCreatedTime", descending: true)
            .whereField("memoryCreatorID", isEqualTo: userId)
            .whereField("memoryPrivacyStatus", isEqualTo: false)
        
        query.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("error about fetchUserMemory : \(error) ")
            } else {
                self.userMemoryList.removeAll()
                for document in querySnapshot!.documents {
                    do {
                        let memory = try document.data(as: GoodThingMemory.self, decoder: Firestore.Decoder())
                        self.userMemoryList.append(memory)
                    } catch let error {
                        print("fetchUserMemory decoding error: \(error)")
                    }
                }
                print("successfully fetchUserMemory:\(self.userMemoryList)")
                DispatchQueue.main.async {
                    self.userInfoTableView.reloadData()
                }
            }
        }
    }
    func fetchUserPostedTasks() {
        
        var query: Query = db.collection("GoodThingTasks")
            .order(by: "taskCreatedTime", descending: true)
            .whereField("taskCreatorId", isEqualTo: userId)
            .whereField("privacyStatus", isEqualTo: false)
        
        query.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("error about fetchUserTasks : \(error) ")
            } else {
                self.userTaskList.removeAll()
                for document in querySnapshot!.documents {
                    do {
                        let task = try document.data(as: GoodThingTasks.self, decoder: Firestore.Decoder())
                        self.userTaskList.append(task)
                    } catch let error {
                        print("fetchUserTasks decoding error: \(error)")
                    }
                }
                print("successfully fetchUsertasks:\(self.userTaskList)")
                DispatchQueue.main.async {
                    self.userInfoTableView.reloadData()
                }
            }
        }
    }
}

extension UserInfoViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return userMemoryList.count
        case 2:
            return userTaskList.count
        default:
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "用戶資訊"
        case 1:
            return "分享好心情"
        case 2:
            return "傳遞好事任務"
        default:
            return nil
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoDetailTableViewCell", for: indexPath) as? UserInfoDetailTableViewCell {
                cell.userInfoFavoriteSentenceLabel.text = userInfo?.favoriteSentence
                cell.userInfoIdLabel.text = userInfo?.userId
                cell.userInfoIntroductionLabel.text = userInfo?.introduction
                cell.userInfoRegistrationTimeLabel.text = userInfo?.registrationTime
                cell.userInfoUserNameLabel.text = userInfo?.userName
                return cell
            }
        case 1:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "UserPostedMemoryListTableViewCell", for: indexPath) as? UserPostedMemoryListTableViewCell {
                let memory = userMemoryList[indexPath.row]
                cell.postedMemoryTitleLabel.text = memory.memoryTitle
                cell.postedMemoryContentLabel.text = memory.memoryContent
                cell.postedMemoryDateLabel.text = memory.memoryCreatedTime
                return cell
            }
        case 2:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "UserPostedTaskListTableViewCell", for: indexPath) as? UserPostedTaskListTableViewCell {
                let task = userTaskList[indexPath.row]
                cell.postedTaskTitleLabel.text = task.taskTitle
                cell.postedTaskContentLabel.text = task.taskContent
                cell.postedTaskDateLabel.text = task.taskCreatedTime
                return cell
            }
        default:
            break
        }
        return UITableViewCell()
    }
}

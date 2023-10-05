//
//  TasksViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/26.
//

import UIKit
import FirebaseFirestore

class TasksViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var task: GoodThingTasks?
    var exclusiveTasks: [GoodThingExclusiveTasks] = []
    var listener: ListenerRegistration?
    private let collectionView: UICollectionView
    private let pairingButton = UIButton(type: .system)
    private let exclusiveButton = UIButton(type: .system)
    private let indicatorView = UIView()
    
    required init?(coder: NSCoder) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        collectionView.delegate = self
        fetchExclusiveTasks()
        listenForExclusiveTasksChanges()
        
        if let savedDate = fetchDateFromUserDefaults(), Calendar.current.isDateInToday(savedDate),
           let savedTask = fetchTaskFromUserDefaults() {
            self.task = savedTask
            self.collectionView.reloadData()
        } else {
            fetchTask {
                self.collectionView.reloadData()
            }
        }
        
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        let lightBrown = UIColor(red: 210.0/255.0, green: 180.0/255.0, blue: 140.0/255.0, alpha: 1.0)
        pairingButton.setTitle(" 配對任務頁面 ", for: .normal)
        pairingButton.backgroundColor = lightBrown
        pairingButton.setTitleColor(.white, for: .normal)
        pairingButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        pairingButton.layer.cornerRadius = 8
        pairingButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        pairingButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pairingButton)
        exclusiveButton.setTitle(" 專屬任務頁面 ", for: .normal)
        exclusiveButton.backgroundColor = lightBrown
        exclusiveButton.setTitleColor(.white, for: .normal)
        exclusiveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        exclusiveButton.layer.cornerRadius = 8
        exclusiveButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        exclusiveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exclusiveButton)
        
        
        indicatorView.backgroundColor = .brown
        indicatorView.frame = CGRect(x: 25, y: 150, width: 140, height: 2)
        view.addSubview(indicatorView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(PairingTaskCollectionViewCell.self, forCellWithReuseIdentifier: "PairingTaskCollectionViewCell")
        collectionView.register(ExclusiveTaskCollectionViewCell.self, forCellWithReuseIdentifier: "ExclusiveTaskCollectionViewCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            pairingButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            pairingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            pairingButton.widthAnchor.constraint(equalToConstant: 150),
            pairingButton.heightAnchor.constraint(equalToConstant: 30),
            
            exclusiveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            exclusiveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            exclusiveButton.widthAnchor.constraint(equalToConstant: 150),
            exclusiveButton.heightAnchor.constraint(equalToConstant: 30),
            
            collectionView.topAnchor.constraint(equalTo: pairingButton.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func didTapButton(_ sender: UIButton) {
        let screenWidth = collectionView.bounds.width
        let targetOffset: CGPoint
        
        if sender == pairingButton {
            targetOffset = CGPoint(x: 0, y: 0)
        } else {
            targetOffset = CGPoint(x: screenWidth, y: 0)
        }
        collectionView.setContentOffset(targetOffset, animated: true)
        
        UIView.animate(withDuration: 0.3) {
            let targetCenterX = sender.center.x
            self.indicatorView.center.x = targetCenterX
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
        //TODO: usernameLabel 替換成button，用於跳轉用戶個人頁面
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            if indexPath.item == 0 {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PairingTaskCollectionViewCell", for: indexPath) as? PairingTaskCollectionViewCell {
                    
                    if let task = self.task {
                        cell.usernameButton.setTitle(task.taskCreatorId, for: .normal)
                        cell.taskTitleLabel.text = task.taskTitle
                        cell.taskContentLabel.text = task.taskContent
                    }
                    if  let imageUrlString = self.task?.taskImage {
                        cell.taskImageView.isHidden = false
                        MediaDownloader.shared.downloadImage(from: imageUrlString) { (image) in
                            cell.taskImageView.image = image
                        }
                    }
                    if let audioURL = self.task?.taskVoice {
                        MediaDownloader.shared.downloadAudio(from: audioURL) { url in
                            if let url = url {
                                cell.setupAudioPlayer(with: url)
                            }
                        }
                    }
                    
                    cell.onPostButtonTapped = { [weak self] in
                        self?.performSegue(withIdentifier: "toPostTaskVCSegue", sender: self)
                    }
                    cell.onReplyButtonTapped = { [weak self] in
                        self?.performSegue(withIdentifier: "toReplyTaskVCSegue", sender: self)
                    }
                    cell.onReceiveButtonTapped = { [weak self] in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let viewController = storyboard.instantiateViewController(withIdentifier: "TaskResponseReceptionViewController") as? TaskResponseReceptionViewController {
                            self?.navigationController?.pushViewController(viewController, animated: true)
                        }

                    }
                    return cell
                }
            } else {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExclusiveTaskCollectionViewCell", for: indexPath) as? ExclusiveTaskCollectionViewCell {
                    cell.tasks = exclusiveTasks
                    cell.delegate = self
                    return cell
                }
            }
            return PairingTaskCollectionViewCell()
        }

       
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return collectionView.bounds.size
        }
        
        deinit {
            listener?.remove()
        }
}

extension TasksViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPostTaskVCSegue" {
           
        } else if segue.identifier == "toReplyTaskVCSegue", let destinationVC = segue.destination as? ReplyTaskViewController {
                destinationVC.task = self.task
        }
    }
}

extension TasksViewController {
    
    func fetchTask(completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let yesterdayString = Date.dateFormatterWithDate.string(from: yesterday)
        let currentDate = Date.dateFormatterWithDate.string(from: Date())
        let randomValue = Double.random(in: 0..<1)
        print(randomValue)
        let query: Query = db.collection("GoodThingTasks")
            .whereField("lastFetchedTime", isEqualTo: yesterdayString)
            .whereField("randomSelectionValue", isGreaterThan: randomValue)
            .order(by: "randomSelectionValue")
            .limit(to: 1)
        query.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error fetching task: \(error)")
            } else if let document = querySnapshot?.documents.first {
                do {
                    let fetchedTask = try document.data(as: GoodThingTasks.self, decoder: Firestore.Decoder())
                    self.task = fetchedTask
                    self.saveTaskToUserDefaults(task: fetchedTask)
                    print("Task fetched successfully: \(fetchedTask)")
                    
                    let docRef = db.collection("GoodThingTasks").document(document.documentID)
                    docRef.updateData(["lastFetchedTime": currentDate]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                    
                    DispatchQueue.main.async {
                        completion()
                    }
                } catch let error {
                    print("Decoding error: \(error)")
                }
            }
        }
    }
}

extension TasksViewController {
    func saveTaskToUserDefaults(task: GoodThingTasks) {
        if let encoded = try? JSONEncoder().encode(task) {
            UserDefaults.standard.set(encoded, forKey: "currentTask")
            UserDefaults.standard.set(Date().description, forKey: "taskDate")
        }
    }

    func fetchTaskFromUserDefaults() -> GoodThingTasks? {
        if let savedTask = UserDefaults.standard.object(forKey: "currentTask") as? Data {
            if let loadedTask = try? JSONDecoder().decode(GoodThingTasks.self, from: savedTask) {
                return loadedTask
            }
        }
        return nil
    }

    func fetchDateFromUserDefaults() -> Date? {
        if let dateString = UserDefaults.standard.string(forKey: "taskDate"),
           let date = Date.dateFormatterWithDate.date(from: dateString) {
            return date
        }
        return nil
    }

}

extension TasksViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let xOffset = scrollView.contentOffset.x
        let screenWidth = scrollView.bounds.width
        let indicatorFraction = xOffset / screenWidth
        let totalDistance = exclusiveButton.center.x - pairingButton.center.x

        indicatorView.center.x = pairingButton.center.x + totalDistance * indicatorFraction
    }
}

extension TasksViewController {
    func postExclusiveTask(title: String) {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else { return }
        let db = Firestore.firestore()
        let time = Date.dateFormatterWithTime.string(from: Date())
        let exclusiveTaskCollection = db.collection("GoodThingUsers").document(userId).collection("GoodThingExclusiveTasks")
        let document = exclusiveTaskCollection.document()
        let exclusiveTaskId = document.documentID
        let data: [String: Any] = [
            "exclusiveTaskId": exclusiveTaskId,
            "exclusiveTaskTitle": title,
            "exclusiveTaskContent": "",
            "createdTime": time,
            "completedTime": "",
            "completedStatus": false
        ]
        
        exclusiveTaskCollection.document(exclusiveTaskId).setData(data) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(exclusiveTaskId)")
            }
        }
    }
    
    func fetchExclusiveTasks() {
           guard let userId = UserDefaults.standard.string(forKey: "userId") else { return }
           let db = Firestore.firestore()
           let exclusiveTaskCollection = db.collection("GoodThingUsers").document(userId).collection("GoodThingExclusiveTasks")

           exclusiveTaskCollection
            .whereField("completedStatus", isEqualTo: false)
            .order(by: "createdTime")
            .getDocuments { (snapshot, error) in
               if let error = error {
                   print("取得專屬任務時發生錯誤: \(error)")
               } else {
                   self.exclusiveTasks = snapshot?.documents.compactMap {
                       try? $0.data(as: GoodThingExclusiveTasks.self)
                   } ?? []
                   DispatchQueue.main.async {
                       self.collectionView.reloadData()
                   }
               }
           }
       }
    func listenForExclusiveTasksChanges() {
            guard let userId = UserDefaults.standard.string(forKey: "userId") else { return }
            let db = Firestore.firestore()
            let exclusiveTaskCollection = db.collection("GoodThingUsers").document(userId).collection("GoodThingExclusiveTasks")

            listener = exclusiveTaskCollection.whereField("completedStatus", isEqualTo: false)
            .order(by: "createdTime")
            .addSnapshotListener { (snapshot, error) in
                guard let documents = snapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                self.exclusiveTasks = documents.compactMap {
                    try? $0.data(as: GoodThingExclusiveTasks.self)
                }
                self.collectionView.reloadData()
            }
        }
    func updateTaskInFirebase(task: GoodThingExclusiveTasks, completion: @escaping (Bool) -> Void) {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let documentRef = db.collection("GoodThingUsers").document(userId).collection("GoodThingExclusiveTasks").document(task.exclusiveTaskId)
        print("Attempting to update task: \(task.exclusiveTaskId)")
        documentRef.updateData(["completedStatus": true]) { err in
            if let err = err {
                print("Error updating document: \(err)")
                completion(false)
            } else {
                print("Document successfully updated")
                completion(true)
            }
        }
    }
}

extension TasksViewController: ExclusiveTaskCollectionViewCellDelegate {
    func didRequestToPostExclusiveTask(title: String, from cell: ExclusiveTaskCollectionViewCell) {
        postExclusiveTask(title: title)
    }
    func didTapCheckmarkButton(at indexPath: IndexPath, from cell: ExclusiveTaskCollectionViewCell) {
        print("Checkmark button tapped at indexPath: \(indexPath)")

        let taskToModify = exclusiveTasks[indexPath.row]
        
        
        guard let userId = UserDefaults.standard.string(forKey: "userId") else { return }
        let db = Firestore.firestore()
        let exclusiveTaskDocument = db.collection("GoodThingUsers").document(userId).collection("GoodThingExclusiveTasks").document(taskToModify.exclusiveTaskId)
        
        exclusiveTaskDocument.updateData(["completedStatus": true]) { error in
            if let error = error {
                print("Failed to update data: \(error)")
                return
            }

            // TODO: 之後回頭確認這部分的原理，print仍有Invalid index path
            // 更新數據源
            if indexPath.row < self.exclusiveTasks.count {
                self.exclusiveTasks.remove(at: indexPath.row)
                
                // 主線程上更新表格視圖
                DispatchQueue.main.async {
                    cell.exclusiveTaskTableView.beginUpdates()
                    cell.exclusiveTaskTableView.deleteRows(at: [indexPath], with: .automatic)
                    cell.exclusiveTaskTableView.endUpdates()
                }
            } else {
                print("Error: Invalid index path")
            }
        }

    }
}

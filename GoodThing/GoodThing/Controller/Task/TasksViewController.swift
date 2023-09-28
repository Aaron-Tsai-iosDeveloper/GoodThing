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
    
        private let collectionView: UICollectionView
        private let pairingButton = UIButton(type: .system)
        private let exclusiveButton = UIButton(type: .system)

   
        required init?(coder: NSCoder) {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            super.init(coder: coder)
        }

  
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            fetchTask {
                self.collectionView.reloadData()
            }
        }
    
     
    
        private func setupUI() {
            view.backgroundColor = .white

          
            pairingButton.setTitle("配對任務頁面", for: .normal)
            exclusiveButton.setTitle("專屬任務頁面", for: .normal)
            
            pairingButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
            exclusiveButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)

            
            let stackView = UIStackView(arrangedSubviews: [pairingButton, exclusiveButton])
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(stackView)

            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.isPagingEnabled = true
            collectionView.register(PairingTaskCollectionViewCell.self, forCellWithReuseIdentifier: "PairingTaskCollectionViewCell")
            collectionView.register(ExclusiveTaskCollectionViewCell.self, forCellWithReuseIdentifier: "ExclusiveTaskCollectionViewCell")
            collectionView.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(collectionView)

            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

                collectionView.topAnchor.constraint(equalTo: stackView.bottomAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }

        @objc private func didTapButton(_ sender: UIButton) {
            let index = sender == pairingButton ? 0 : 1
            collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
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
                    return cell
                }
            } else {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExclusiveTaskCollectionViewCell", for: indexPath) as? ExclusiveTaskCollectionViewCell {
                   
                    return cell
                }
            }
            return PairingTaskCollectionViewCell()
        }

       
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return collectionView.bounds.size
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

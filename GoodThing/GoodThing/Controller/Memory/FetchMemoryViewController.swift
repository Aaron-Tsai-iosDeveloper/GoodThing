//
//  FetchMemoryViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/18.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import AVFAudio

class FetchMemoryViewController: UIViewController {
    
    @IBOutlet weak var privateMemoryTableView: UITableView!
    @IBOutlet weak var datePicker: UIDatePicker!
    lazy var db = Firestore.firestore()
    let userId = UserDefaults.standard.string(forKey: "userId")
    var privateMemory = [GoodThingMemory]()
    var selectedMemory = [GoodThingMemory]()
    var datePickerObserver: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        privateMemoryTableView.dataSource = self
        privateMemoryTableView.delegate = self
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(setupBackgroundDimmingView), for: .touchUpOutside)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePickerObserver = datePicker.observe(\.frame, options: [.new], changeHandler: { [weak self] (picker, change) in
            if let newFrame = change.newValue, newFrame.height > 100 {
                self?.setupBackgroundDimmingView()
            }
        })

        listenForPrivateMemoryUpdates()
        fetchMemory(byCreatorID: userId, withPrivateStatus: true) {
            print(self.userId)
            self.privateMemoryTableView.reloadData()
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self.view)
            if !datePicker.frame.contains(location) {
                removeBackgroundDimmingView()
            }
        }
    }

    func fetchMemory(byCreatorID creatorID: String? = nil, withPrivateStatus isPrivate: Bool? = nil, completion: @escaping () -> Void) {
        var query: Query = db.collection("GoodThingMemory").order(by: "memoryCreatedTime", descending: true)
        if let creatorID = creatorID {
            query = query.whereField("memoryCreatorID", isEqualTo: creatorID)
        }
        if let isPrivate = isPrivate {
            query = query.whereField("memoryPrivacyStatus", isEqualTo: isPrivate)
        }
        query.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("error about fetchmemory : \(error) ")
            } else {
                if isPrivate == true {
                    self.privateMemory.removeAll()
                }
                for document in querySnapshot!.documents {
                    print("Document data:\(document.data())")
                    do {
                        let newMemory = try document.data(as: GoodThingMemory.self, decoder: Firestore.Decoder())
                        if isPrivate == true {
                            self.privateMemory.append(newMemory)
                        }
                    } catch let error {
                        print("fetchmemory decoding error: \(error)")
                    }
                }
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    func fetchDataForSelectedDate(_ date: Date) {
        
        let selectedDateString = Date.dateFormatterWithDate.string(from: date)
        var query: Query = db.collection("GoodThingMemory")
            .whereField("memoryCreatorID", isEqualTo: userId ?? "")
            .whereField("memoryPrivacyStatus", isEqualTo: true)
            .whereField("memoryCreatedDate", isEqualTo: selectedDateString)
            
        query.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("error about fetchmemory : \(error) ")
            } else {
                self.privateMemory.removeAll()
                for document in querySnapshot!.documents {
                    do {
                        let group = try document.data(as: GoodThingMemory.self, decoder: Firestore.Decoder())
                        self.privateMemory.append(group)
                    } catch let error {
                        print("fetchgroups decoding error: \(error)")
                    }
                }
                print("successfully fetchmemory:\(self.privateMemory)")
                DispatchQueue.main.async {
                    self.privateMemoryTableView.reloadData()
                }
            }
        }
    }
    
    deinit {
        datePickerObserver?.invalidate()
    }
}
    extension FetchMemoryViewController:UITableViewDelegate,UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return privateMemory.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PrivateMemoryTableViewCell", for: indexPath) as? PrivateMemoryTableViewCell else { return UITableViewCell() }
            cell.privateMemoryTitleLabel.text = privateMemory[indexPath.row].memoryTitle
            cell.privateMemoryCreatedTimeLabel.text = privateMemory[indexPath.row].memoryCreatedTime
            cell.privateMemoryContentLabel.text = privateMemory[indexPath.row].memoryContent
            
            let imageUrlString = privateMemory[indexPath.row].memoryImage ?? ""
            MediaDownloader.shared.downloadImage(from: imageUrlString) { (image) in
                DispatchQueue.main.async {
                    cell.privateMemoryImage.image = image
                }
            }
            
            if let audioURL = privateMemory[indexPath.row].memoryVoice {
                MediaDownloader.shared.downloadAudio(from: audioURL) { url in
                    if let url = url {
                        DispatchQueue.main.async {
                            cell.setupAudioPlayer(with: url)
                        }
                    }
                }
            }
            return cell
        }
        
    }
    
extension FetchMemoryViewController {
        
        func listenForPrivateMemoryUpdates() {
            let query = db.collection("GoodThingMemory")
                .whereField("memoryPrivacyStatus", isEqualTo: true)
                .whereField("memoryCreatorID", isEqualTo: userId)
            
            query.addSnapshotListener { (snapshot, error) in
                if let error = error {
                    print("Error fetching updates: \(error)")
                    return
                }
                
                var newMemories: [GoodThingMemory] = []
                
                for documentChange in snapshot!.documentChanges {
                    switch documentChange.type {
                    case .added:
                        do {
                            let newMemory = try Firestore.Decoder().decode(GoodThingMemory.self, from: documentChange.document.data())
                            newMemories.append(newMemory)
                        } catch let error {
                            print("Decoding error: \(error)")
                        }
                        
                    default:
                        break
                    }
                }
                
                if !newMemories.isEmpty {
                    self.privateMemory.append(contentsOf: newMemories)
                    
                    self.privateMemory.sort(by: { $0.memoryCreatedTime > $1.memoryCreatedTime })
                    
                    DispatchQueue.main.async {
                        self.privateMemoryTableView.reloadData()
                    }
                }
            }
        }
    }
    extension FetchMemoryViewController {
        @objc func datePickerValueChanged(_ sender: UIDatePicker) {
            fetchDataForSelectedDate(sender.date)
        }
        
        @objc func setupBackgroundDimmingView() {
            let dimmingView = UIView(frame: self.view.bounds)
            dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.3)
            dimmingView.tag = 100
            self.view.insertSubview(dimmingView, belowSubview: datePicker)
        }
        
        func removeBackgroundDimmingView() {
            if let dimmingView = self.view.viewWithTag(100) {
                dimmingView.removeFromSuperview()
            }
        }
    }

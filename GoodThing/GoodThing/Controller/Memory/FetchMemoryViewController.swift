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
    @IBOutlet weak var privateMemoryDatePicker: UIDatePicker!
    
    lazy var db = Firestore.firestore()
    let userId = UserDefaults.standard.string(forKey: "userId")
    var privateMemory = [GoodThingMemory]()
    var selectedMemory = [GoodThingMemory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        privateMemoryTableView.dataSource = self
        privateMemoryTableView.delegate = self
        listenForPrivateMemoryUpdates()
        privateMemoryDatePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        fetchDataForSelectedDate()
        fetchMemory(byCreatorID: userId, withPrivateStatus: true) {
            print(self.userId)
            self.privateMemoryTableView.reloadData()
        }
    }
    
    @objc func datePickerValueChanged() {
        fetchDataForSelectedDate()
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
    func fetchDataForSelectedDate() {
        
        let selectedDate = privateMemoryDatePicker.date
        let selectedDateString = Date.dateFormatterWithDate.string(from: selectedDate)
        
        var query: Query = db.collection("GoodThingMemory")
            .order(by: "memoryCreatedTime", descending: true)
            .whereField("memoryCreatedTime", isEqualTo: selectedDateString)
        
        query.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("error about fetchmemory : \(error) ")
            } else {
                self.selectedMemory.removeAll()
                for document in querySnapshot!.documents {
                    do {
                        let group = try document.data(as: GoodThingMemory.self, decoder: Firestore.Decoder())
                        self.selectedMemory.append(group)
                    } catch let error {
                        print("fetchgroups decoding error: \(error)")
                    }
                }
                print("successfully fetchmemory:\(self.selectedMemory)")
                DispatchQueue.main.async {
                    self.privateMemoryTableView.reloadData()
                }
            }
        }
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

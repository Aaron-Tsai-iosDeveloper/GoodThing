//
//  GoodThingMemoryWallViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/21.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift

class GoodThingMemoryWallViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var memoryWallTableView: UITableView!
    var db = Firestore.firestore()
    var publicMemory = [GoodThingMemory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memoryWallTableView.dataSource = self
        memoryWallTableView.delegate = self
        fetchMemory(withPrivateStatus: false) {
            self.memoryWallTableView.reloadData()
        }
        listenForMemoryWallUpdates()
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
                self.publicMemory.removeAll()
                for document in querySnapshot!.documents {
                    print("Document data:\(document.data())")
                    do {
                        let newMemory = try document.data(as: GoodThingMemory.self, decoder: Firestore.Decoder())
                            self.publicMemory.append(newMemory)
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
}

extension GoodThingMemoryWallViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        publicMemory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if publicMemory[indexPath.row].memoryImage != "" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoryImageWallTableViewCell", for: indexPath) as? MemoryImageWallTableViewCell else { return UITableViewCell() }
            let memory = publicMemory[indexPath.row]
            cell.memoryWallArticleNameLabel.text = "文章：\(memory.memoryTitle)"
            cell.memoryWallPosterNameLabel.text = "筆名：\(memory.memoryCreatorID)"
            cell.memoryWallArticleContentLabel.text = (memory.memoryContent)
            cell.memoryWallArticleCreatedTimeLabel.text = (memory.memoryCreatedTime)
            let imageUrlString = memory.memoryImage
            MediaDownloader.shared.downloadImage(from: imageUrlString) { (image) in
                cell.memoryWallArticleImageView.image = image
            }
            cell.memoryTags = memory.memoryTag
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoryTextWallTableViewCell", for: indexPath) as? MemoryTextWallTableViewCell else { return UITableViewCell() }
            cell.memoryWallPosterNameLabel.text = "筆名：\(publicMemory[indexPath.row].memoryID)"
            cell.memoryWallArticleNameLabel.text = "文章：\(publicMemory[indexPath.row].memoryTitle)"
            cell.memoryWallArticleCreatedTimeLabel.text = publicMemory[indexPath.row].memoryCreatedTime
            cell.memoryWallArticleContentLabel.text = publicMemory[indexPath.row].memoryContent
            return cell
        }
    }
}
extension GoodThingMemoryWallViewController {
    func listenForMemoryWallUpdates() {
        db.collection("GoodThingMemory").addSnapshotListener { (snapshot, error) in
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
                self.publicMemory.append(contentsOf: newMemories)
                
                self.publicMemory.sort(by: { $0.memoryCreatedTime > $1.memoryCreatedTime })
                
                DispatchQueue.main.async {
                    self.memoryWallTableView.reloadData()
                }
            }
        }
    }
}

extension GoodThingMemoryWallViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toMemoryWallDetailPage", sender: publicMemory[indexPath.row])
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMemoryWallDetailPage",
           let nextVC = segue.destination as? MemoryWallDetailPageViewController,
           let selectedMemory = sender as? GoodThingMemory {
            nextVC.selectedMemory = selectedMemory
        }
    }
}

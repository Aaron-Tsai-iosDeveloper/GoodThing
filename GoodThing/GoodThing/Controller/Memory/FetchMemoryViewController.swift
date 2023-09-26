//
//  FetchMemoryViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/18.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class FetchMemoryViewController: UIViewController {
    @IBOutlet weak var fetchPrivateMemoryButton: UIButton!
    @IBOutlet weak var privateMemoryTableView: UITableView!
    @IBOutlet weak var fetchPublicMemoryButton: UIButton!
    @IBOutlet weak var publicMemoryTableView: UITableView!
    
    lazy var db = Firestore.firestore()
    var privateMemory = [GoodThingMemory]()
    var publicMemory = [GoodThingMemory]()
    override func viewDidLoad() {
        super.viewDidLoad()
//        fetchPrivateMemoryButton.addTarget(self, action: #selector(fetchPrivateMemory), for: .touchUpInside)
//        fetchPublicMemoryButton.addTarget(self, action: #selector(fetchPublicMemory), for: .touchUpInside)
//        privateMemoryTableView.dataSource = self
//        privateMemoryTableView.delegate = self
//        publicMemoryTableView.dataSource = self
//        publicMemoryTableView.delegate = self
        
    }
    @objc func fetchPrivateMemory() {
        fetchMemory(byCreatorID: "Aaron", withPrivateStatus: true){
            self.privateMemoryTableView.reloadData()
        }
    }
    @objc func fetchPublicMemory() {
        fetchMemory(withPrivateStatus: false){
            self.publicMemoryTableView.reloadData()
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
               } else {
                   self.publicMemory.removeAll()
               }
               for document in querySnapshot!.documents {
                   print("Document data:\(document.data())")
                   do {
                       let newMemory = try document.data(as: GoodThingMemory.self, decoder: Firestore.Decoder())
                       if isPrivate == true {
                           self.privateMemory.append(newMemory)
                       } else {
                           self.publicMemory.append(newMemory)
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
}

extension FetchMemoryViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == privateMemoryTableView {
            return privateMemory.count
        } else if tableView == publicMemoryTableView {
            return publicMemory.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == privateMemoryTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PrivateMemoryTableViewCell", for: indexPath) as? PrivateMemoryTableViewCell else { return UITableViewCell() }
            cell.privateMemoryTitleLabel.text = privateMemory[indexPath.row].memoryTitle
            cell.privateMemoryCreatedTimeLabel.text = privateMemory[indexPath.row].memoryCreatedTime
            cell.privateMemoryTagLabel.text = privateMemory[indexPath.row].memoryTag[0]
            cell.privateMemoryContentLabel.text = privateMemory[indexPath.row].memoryContent
            let imageUrlString = privateMemory[indexPath.row].memoryImage
            MediaDownloader.shared.downloadImage(from: imageUrlString) { (image) in
                cell.privateMemoryImage.image = image
            }
            cell.deletePrivateMemory = { [weak self] in
                self?.deletePrivateMemory(at: indexPath)
            }
            return cell
        } else if tableView == publicMemoryTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PublicMemoryTableViewCell", for: indexPath) as? PublicMemoryTableViewCell  else { return UITableViewCell() }
            cell.publicMemoryTitleLabel.text = publicMemory[indexPath.row].memoryTitle
            cell.publicMemoryCreatedTimeLabel.text = publicMemory[indexPath.row].memoryCreatedTime
            cell.publicMemoryContentLabel.text = publicMemory[indexPath.row].memoryContent
            cell.publicMemoryAuthorLabel.text = publicMemory[indexPath.row].memoryCreatorID
            return cell
        }
        return UITableViewCell()
    }
    func deletePrivateMemory(at indexPath: IndexPath) {
        let privateMemory = privateMemory[indexPath.row]
        let Id = privateMemory.memoryID
        db.collection("GoodThingMemory").document(Id).delete() { [weak self] error in
            if let error = error {
                print("Failed to delete memory: \(error)")
            } else {
                self?.privateMemory.remove(at: indexPath.row)
                DispatchQueue.main.async {
                    self?.privateMemoryTableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }

}

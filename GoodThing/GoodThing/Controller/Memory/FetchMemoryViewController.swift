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
    @IBOutlet weak var PrivateMemoryTableView: UITableView!
    @IBOutlet weak var fetchPublicMemoryButton: UIButton!
    @IBOutlet weak var PublicMemoryTableView: UITableView!
    
    lazy var db = Firestore.firestore()
    var privateMemory = [GoodThingMemory]()
    var publicMemory = [GoodThingMemory]()
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPrivateMemoryButton.addTarget(self, action: #selector(fetchPrivateMemory), for: .touchUpInside)
        fetchPublicMemoryButton.addTarget(self, action: #selector(fetchPublicMemory), for: .touchUpInside)
        PrivateMemoryTableView.dataSource = self
        PrivateMemoryTableView.delegate = self
        PublicMemoryTableView.dataSource = self
        PublicMemoryTableView.delegate = self
    }
    @objc func fetchPrivateMemory() {
        fetchMemory(byCreatorID: "Aaron", withPrivateStatus: true){
            self.PrivateMemoryTableView.reloadData()
        }
    }
    @objc func fetchPublicMemory() {
        fetchMemory(withPrivateStatus: false){
            self.PublicMemoryTableView.reloadData()
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
        if tableView == PrivateMemoryTableView {
            return privateMemory.count
        } else if tableView == PublicMemoryTableView {
            return publicMemory.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == PrivateMemoryTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PrivateMemoryTableViewCell", for: indexPath) as? PrivateMemoryTableViewCell else { return UITableViewCell() }
            cell.privateMemoryTitleLabel.text = privateMemory[indexPath.row].memoryTitle
            cell.privateMemoryCreatedTimeLabel.text = privateMemory[indexPath.row].memoryCreatedTime
            cell.privateMemoryTagLabel.text = privateMemory[indexPath.row].memoryTag
            cell.privateMemoryContentLabel.text = privateMemory[indexPath.row].memoryContent
            return cell
        } else if tableView == PublicMemoryTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PublicMemoryTableViewCell", for: indexPath) as? PublicMemoryTableViewCell  else { return UITableViewCell() }
            cell.publicMemoryTitleLabel.text = publicMemory[indexPath.row].memoryTitle
            cell.publicMemoryTagLabel.text = publicMemory[indexPath.row].memoryTag
            cell.publicMemoryCreatedTimeLabel.text = publicMemory[indexPath.row].memoryCreatedTime
            cell.publicMemoryContentLabel.text = publicMemory[indexPath.row].memoryContent
            cell.publicMemoryAuthorLabel.text = publicMemory[indexPath.row].memoryCreatorID
            return cell
        }
        return UITableViewCell()
    }
}
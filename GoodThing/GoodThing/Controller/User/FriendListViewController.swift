//
//  FriendListViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/19.
//

import UIKit
import FirebaseFirestore

class FriendListViewController: UIViewController {

    @IBOutlet weak var friendListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
   func createUsers() {
        let db = Firestore.firestore()
        let document = db.collection("GoodThingUsers").document()
        let id = document.documentID
        let time = Date.dateFormatter.string(from: Date())
       
        var data: [String: Any] = [
            "userId": id,
            "userName": "王小明",
            "birthday": "1995.12.34",
            "registrationTime": "2023.09.17",
            "introduction": "很高興與善良的你相遇！",
            "groupsList": ["團A","團B","團C"],
            "goodSentences": ["療癒句1","療癒句2","療癒句3","療癒句4",],
            "friends": ["王大大","王小小","王樂樂"],
            "articlesCollection": ["U1Nv8Hmk4JTy4Vgy4pLN","eJ0exCleJ3qqyK05CEiP"]
        ]
      
        db.collection("GoodThingUsers").document(id).setData(data) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(id)")
            }
        }
    }
    
}

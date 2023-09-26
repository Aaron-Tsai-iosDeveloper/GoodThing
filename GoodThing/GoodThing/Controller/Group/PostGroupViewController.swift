//
//  PostGroupViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/18.
//

import UIKit
import FirebaseFirestore

class PostGroupViewController: UIViewController {
    
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var groupTimeDatePicker: UIDatePicker!
    @IBOutlet weak var groupLocationTextField: UITextField!
    @IBOutlet weak var groupContentTextView: UITextView!
    @IBOutlet weak var peopleNumberTextField: UITextField!
    @IBOutlet weak var deadLineDatePicker: UIDatePicker!
    @IBOutlet weak var postGroupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deadLineDatePicker.date = Date()
        groupTimeDatePicker.date = Date()
        
        postGroupButton.addTarget(self, action: #selector(postGroup), for: .touchUpInside)
        groupContentTextView.layer.borderWidth = 1.0
        groupContentTextView.layer.borderColor = CGColor(gray: 0.5, alpha: 0.6)

    }
    
    @objc func postGroup() {
        guard let title = groupNameTextField.text, !title.isEmpty,
              let location = groupLocationTextField.text, !location.isEmpty,
              let peopleNumberLimitString = peopleNumberTextField.text, !peopleNumberLimitString.isEmpty,
              let content = groupContentTextView.text, !content.isEmpty else { return }
        
        guard let peopleNumberLimit = Int(peopleNumberLimitString) else {
            
            print("Error: peopleNumberLimit is not a valid integer.")
            return
        }
        
        let db = Firestore.firestore()
        let document = db.collection("GoodThingGroup").document()
        let id = document.documentID
        let participants = ["Aaron","Eric","Hank","Ella"]
        let groupTime = Date.dateFormatterWithTime.string(from: groupTimeDatePicker.date)
        let deadLine = Date.dateFormatterWithTime.string(from: deadLineDatePicker.date)
        let createdTime = Date.dateFormatterWithTime.string(from: Date())
        
        db.collection("GoodThingGroup").document(id).setData([
            "groupID": id,
            "groupTime": groupTime,
            "groupName": title,
            "groupContent": content,
            "groupLocation": location,
            "organizerID": "Aaron",
            "createdTime": createdTime,
            "deadLine": deadLine,
            "peopleNumberLimit": peopleNumberLimit,
            "participants": participants,
            "currentPeopleNumber": participants.count
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(id)")
            }
        }
    }

}

//
//  ViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/14.
//

import UIKit
import FirebaseFirestore

class PostTaskViewController: UIViewController {

    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var taskContentTextView: UITextView!
    @IBOutlet weak var postPrivateTaskButton: UIButton!
    @IBOutlet weak var postPublicTaskButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        postPrivateTaskButton.addTarget(self, action: #selector(postPrivateTask), for: .touchUpInside)
        postPublicTaskButton.addTarget(self, action: #selector(postPublicTask), for: .touchUpInside)
    }
    @objc func postPrivateTask() {
        postTask(privacy: false)
    }
    @objc func postPublicTask() {
        postTask()
    }
    func postTask(privacy privacyStatus: Bool = true) {
        guard let title = taskTitleTextField.text, !title.isEmpty,
              let content = taskContentTextView.text, !content.isEmpty else { return }
        let db = Firestore.firestore()
        let document = db.collection("GoodThingTasks").document()
        let id = document.documentID
        let time = Date.dateFormatter.string(from: Date())
        db.collection("GoodThingTasks").document(id).setData([
            "taskID": id,
            "taskTitle": title,
            "taskContent": content,
            "taskImage": "",
            "taskVoice": "",
            "taskCreatorID": "Aaron",
            "privacyStatus": privacyStatus,
            "taskCreatedTime": time
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(id)")
            }
        }

    }
}

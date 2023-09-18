//
//  PostMemoryViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/18.
//

import UIKit
import FirebaseFirestore

class PostMemoryViewController: UIViewController {

    @IBOutlet weak var momeryTitleTextField: UITextField!
    @IBOutlet weak var memoryContentTextView: UITextView!
    @IBOutlet weak var postMemoryButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        postMemoryButton.addTarget(self, action: #selector(postMemory), for: .touchUpInside)
    }
    @objc func postMemory(privacy privacyStatus: Bool = false) {
        guard let title = momeryTitleTextField.text, !title.isEmpty,
              let content = memoryContentTextView.text, !content.isEmpty else { return }
        let db = Firestore.firestore()
        let document = db.collection("GoodThingMemory").document()
        let id = document.documentID
        let time = Date.dateFormatter.string(from: Date())
        db.collection("GoodThingMemory").document(id).setData([
            "memoryID": id,
            "memoryTitle": title,
            "memoryContent": content,
            "memoryTag": "感謝",
            "memoryImage": "",
            "memoryPrivacyStatus": true,
            "memoryCreatedTime": time,
            "memoryCreatorID": "Aaron"
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(id)")
            }
        }

    }
}

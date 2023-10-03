//
//  EditUserInfoViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/28.
//

import UIKit
import FirebaseFirestore

class UserInfoEditionViewController: UIViewController {
    
    @IBOutlet weak var penNameTextField: UITextField!
    @IBOutlet weak var introductionTextView: UITextView!
    @IBOutlet weak var favoriteSentenceTextView: UITextView!
    @IBOutlet weak var userInfoUpdateButton: UIButton!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userInfoUpdateButton.addTarget(self, action: #selector(updateUserInfo), for: .touchUpInside)
    }
    
    @objc func updateUserInfo() {
        guard let penName = penNameTextField.text, !penName.isEmpty,
              let introduction = introductionTextView.text, !introduction.isEmpty,
              let favoriteSentence = favoriteSentenceTextView.text, !favoriteSentence.isEmpty,
              let userId = UserDefaults.standard.string(forKey: "userId") else { return }
        
        let document = db.collection("GoodThingUsers").document()
        var data: [String: Any] = [
            "userName": penName,
            "introduction": introduction,
            "favoriteSentence": favoriteSentence
        ]
        
        db.collection("GoodThingUsers").document(userId).updateData(data) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(userId)")
                print("已經更新:用戶資訊頁面")
            }
        }
    }
}

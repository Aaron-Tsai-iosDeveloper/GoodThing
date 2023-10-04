//
//  UserLetterWritingViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/10/2.
//

import UIKit
import FirebaseFirestore

class UserLetterWritingViewController: UIViewController {
    
    @IBOutlet weak var letterTitleTextField: UITextField!
    @IBOutlet weak var letterContentTextView: UITextView!
    @IBOutlet weak var letterSendButton: UIButton!
    @IBOutlet weak var letterReceiverPenNameButton: UIButton!
    var friend: GoodThingUser?
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        letterSendButton.addTarget(self, action: #selector(sendLetterButtonTapped), for: .touchUpInside)
        setupKeyboardClosed()
    }
    
    func getConversationId(for user1: String, and user2: String) -> String {
        return user1 < user2 ? "\(user1)_\(user2)" : "\(user2)_\(user1)"
    }
    
    @objc func sendLetterButtonTapped() {
        guard let senderId = UserDefaults.standard.string(forKey: "userId") else {
            print("Error: Unable to retrieve userId from UserDefaults")
            return
        }
       
        guard let receiverId = friend?.userId else {
            print("Error: No friend selected to send letter")
            return
        }
        
        sendLetter(from: senderId, to: receiverId) { error in
            if let error = error {
                print("Failed to send letter: \(error)")
            } else {
                print("Letter sent successfully!")
            }
        }
    }
    
    func sendLetter(from sender: String, to receiver: String, completion: @escaping (Error?) -> Void) {
        guard let title = letterTitleTextField.text, !title.isEmpty,
              let content = letterContentTextView.text, !content.isEmpty else {
            print("Error: Letter title or content is empty")
            completion(nil)
            return
        }
        
        let conversationId = getConversationId(for: sender, and: receiver)
        let time = Date.dateFormatterWithTime.string(from: Date())
        let letterData: [String: Any] = [
            "user1": sender,
            "user2": receiver,
            "title": title,
            "content": content,
            "createdTime": time
        ]
        
        // Ensure the conversation document exists in the Inbox collection
        let conversationDocRef = db.collection("Inbox").document(conversationId)
        conversationDocRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
                completion(error)
            } else if !document!.exists {
              
                conversationDocRef.setData(["metadata": "dummyData"]) { error in
                    if let error = error {
                        completion(error)
                    } else {
                        
                        conversationDocRef.collection("Letters").addDocument(data: letterData, completion: completion)
                    }
                }
            } else {
                
                conversationDocRef.collection("Letters").addDocument(data: letterData, completion: completion)
            }
        }
    }
}
extension UserLetterWritingViewController {
    func setupKeyboardClosed() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

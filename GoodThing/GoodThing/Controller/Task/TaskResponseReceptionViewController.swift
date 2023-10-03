//
//  TaskResponseReceptionViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/10/2.
//

import UIKit
import FirebaseFirestore
import Firebase
//TODO: 只有大概的code，還沒完整檢查
//TODO: 想一下不同意按了之後，畫面要顯示或變化什麼？
class TaskResponseReceptionViewController: UIViewController {

    var latestTaskId: String?
    var completerId: String?
    
    @IBOutlet weak var taskCompleterLabel: UILabel!
    @IBOutlet weak var taskResponseLabel: UITextView!
    @IBOutlet weak var taskResponsePlayButton: UIButton!
    @IBOutlet weak var taskResponseImageView: UIImageView!
    @IBOutlet weak var agreeAddFriendButton: UIButton!
    @IBOutlet weak var disagreeAddFriendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        latestTaskId = UserDefaults.standard.string(forKey: "latestPostedTaskId")

        if latestTaskId == nil {
            fetchLatestTaskIDFromFirebase()
        } else {
            fetchResponsesForTask(withId: latestTaskId ?? "")
        }
    }

    func fetchLatestTaskIDFromFirebase() {
        
        let userId = Auth.auth().currentUser?.uid ?? ""
        let db = Firestore.firestore()
        db.collection("GoodThingUsers").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                self.latestTaskId = document.get("latestPostedTaskId") as? String
                if let taskId = self.latestTaskId {
                    self.fetchResponsesForTask(withId: taskId)
                }
            } else {
                print("Error fetching user document: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }

    func fetchResponsesForTask(withId taskId: String) {
        let db = Firestore.firestore()
        db.collection("GoodThingTasks").document(taskId).collection("GoodThingTasksResponses").getDocuments { (querySnapshot, error) in
            if let documents = querySnapshot?.documents {
                for document in documents {
                    do {
                        let response = try document.data(as: GoodThingTasksResponses.self, decoder: Firestore.Decoder())
                            print(response)
                        self.taskCompleterLabel.text = response.completerId
                        self.completerId = response.completerId
                        self.taskResponseLabel.text = response.responseContent
                        let imageUrlString = response.responseImage
                        MediaDownloader.shared.downloadImage(from: imageUrlString) { (image) in
                            self.taskResponseImageView.image = image
                        }
                    } catch let error {
                        print("Error decoding response: \(error)")
                    }
                }
            } else {
                print("Error fetching responses: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }
    @IBAction func agreeButtonTapped(_ sender: UIButton) {
        guard let taskPosterId = Auth.auth().currentUser?.uid,
              let completerId = self.completerId  else {
            print("Error: Invalid user IDs.")
            return
        }
        addFriend(taskPosterId: taskPosterId, completerId: completerId)
    }
    //TODO: 檢查一下func addFriend內容
    func addFriend(taskPosterId: String, completerId: String) {
        let db = Firestore.firestore()
        let taskPosterRef = db.collection("GoodThingUsers").document(taskPosterId)
        let completerRef = db.collection("GoodThingUsers").document(completerId)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let taskPosterDocument: DocumentSnapshot
            do {
                try taskPosterDocument = transaction.getDocument(taskPosterRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            let completerDocument: DocumentSnapshot
            do {
                try completerDocument = transaction.getDocument(completerRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            if var taskPosterFriends = taskPosterDocument.data()?["friends"] as? [String],
               var completerFriends = completerDocument.data()?["friends"] as? [String] {
                
                if !taskPosterFriends.contains(completerId) {
                    taskPosterFriends.append(completerId)
                }
                
                if !completerFriends.contains(taskPosterId) {
                    completerFriends.append(taskPosterId)
                }
                
                transaction.updateData(["friends": taskPosterFriends], forDocument: taskPosterRef)
                transaction.updateData(["friends": completerFriends], forDocument: completerRef)
            }
            
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }
}

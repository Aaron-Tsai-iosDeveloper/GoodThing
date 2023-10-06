//
//  TaskResponseReceptionViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/10/2.
//

import UIKit
import FirebaseFirestore
import Firebase
import AVFoundation

class TaskResponseReceptionViewController: UIViewController {
      
    var latestTaskId: String?
    var completerId: String?
    var audioPlayer: AVPlayer?
    var responseId:String?
    var exclusiveTasks: [GoodThingExclusiveTasks] = []
    
    @IBOutlet weak var taskCompleterLabel: UILabel!
    @IBOutlet weak var taskResponseLabel: UITextView!
    @IBOutlet weak var taskResponsePlayButton: UIButton!
    @IBOutlet weak var taskResponseImageView: UIImageView!
    @IBOutlet weak var agreeAddFriendButton: UIButton!
    @IBOutlet weak var disagreeAddFriendButton: UIButton!
    @IBOutlet weak var responseRecordingLabel: UILabel!
    @IBOutlet weak var responseAddFriendLabel: UILabel!
    @IBOutlet weak var taskResponseTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        latestTaskId = UserDefaults.standard.string(forKey: "latestPostedTaskId")
        
        setUI()
        
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
        db.collection("GoodThingTasks").document(taskId).collection("GoodThingTasksResponses")
            .whereField("checkedStatus", isEqualTo: false)
            .order(by: "responseTime", descending: true)
            .limit(to: 1)
            .getDocuments { (querySnapshot, error) in
            if let documents = querySnapshot?.documents {
                for document in documents {
                    do {
                        let response = try document.data(as: GoodThingTasksResponses.self, decoder: Firestore.Decoder())
                            print(response)
                        self.taskCompleterLabel.text = response.completerId
                        self.completerId = document.documentID
                        self.taskResponseLabel.text = response.responseContent
                        self.responseId = response.responseId
                        let imageUrlString = response.responseImage
                        MediaDownloader.shared.downloadImage(from: imageUrlString) { (image) in
                            self.taskResponseImageView.image = image
                        }
                        if let recordingUrlString = response.responseRecording, let url = URL(string: recordingUrlString) {
                            self.audioPlayer = AVPlayer(url: url)
                            self.taskResponsePlayButton.isHidden = false
                        } else {
                            self.taskResponsePlayButton.isHidden = true
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
    
    func updateCheckedStatusForResponse(withId docId: String) {
        let db = Firestore.firestore()
        let responseDocumentRef = db.collection("GoodThingTasks").document(latestTaskId ?? "").collection("GoodThingTasksResponses").document(responseId ?? "")
        
        responseDocumentRef.updateData([
            "checkedStatus": true
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    @IBAction func agreeButtonTapped(_ sender: UIButton) {
        guard let taskPosterId = Auth.auth().currentUser?.uid,
              let completerId = self.completerId else {
            print("Error: Invalid user IDs or document ID.")
            return
        }
        
        updateCheckedStatusForResponse(withId: latestTaskId ?? "")
        addFriend(taskPosterId: taskPosterId, completerId: completerId)
    }
    
    @IBAction func disagreeButtonTapped(_ sender: UIButton) {
        self.taskCompleterLabel.text = ""
        self.taskResponseImageView.image = nil
        self.taskResponseLabel.text = ""
        self.audioPlayer = nil
        self.taskResponsePlayButton.isHidden = true
    }
    
    @IBAction func playAudioTapped(_ sender: UIButton) {
        self.audioPlayer?.play()
    }
    
    //TODO: 檢查一下func addFriend內容
    func addFriend(taskPosterId: String, completerId: String) {
        print("taskPosterId: \(taskPosterId), completerId: \(completerId)")
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

extension TaskResponseReceptionViewController {
    func setUI() {
        taskCompleterLabel.layer.cornerRadius = 10
        taskCompleterLabel.layer.borderWidth = 0.4
        responseRecordingLabel.layer.cornerRadius = 10
        responseRecordingLabel.layer.borderWidth = 0.4
        responseAddFriendLabel.layer.cornerRadius = 10
        responseAddFriendLabel.layer.borderWidth = 0.4
        taskResponseImageView.layer.cornerRadius = 10
        taskResponseTextView.layer.cornerRadius = 10
        taskResponseTextView.layer.borderWidth = 0.4
        taskResponsePlayButton.setTitle("", for: .normal)
        agreeAddFriendButton.setTitle("", for: .normal)
        disagreeAddFriendButton.setTitle("", for: .normal)
    }
}

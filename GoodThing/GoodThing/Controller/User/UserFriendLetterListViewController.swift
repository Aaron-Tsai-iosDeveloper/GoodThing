//
//  UserFriendLetterListViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/10/2.
//

import UIKit
import FirebaseFirestore

class UserFriendLetterListViewController: UIViewController {

    @IBOutlet weak var userFriendLetterListTableView: UITableView!
    @IBOutlet weak var userFriendLetterListWriteButton: UIButton!
    var friend: GoodThingUser?
        var letters = [GoodThingLetter]()
        let db = Firestore.firestore()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            print("View did load.")
            userFriendLetterListTableView.dataSource = self
            userFriendLetterListTableView.delegate = self
            
            fetchLetters { (fetchedLetters, error) in
                if let error = error {
                    print("Error fetching letters: \(error)")
                } else if let fetchedLetters = fetchedLetters {
                    self.letters = fetchedLetters
                    DispatchQueue.main.async {
                        self.userFriendLetterListTableView.reloadData()
                    }
                }
            }
        }

        @IBAction func LetterListWriteButtonTapped(_ sender: UIButton) {
            performSegue(withIdentifier: "FromLetterListVCToWriteVC", sender: friend)
        }
    }

    extension UserFriendLetterListViewController {
        
        func getConversationId(for user1: String, and user2: String) -> String {
            return user1 < user2 ? "\(user1)_\(user2)" : "\(user2)_\(user1)"
        }
        
        func fetchLetters(completion: @escaping ([GoodThingLetter]?, Error?) -> Void) {
            print("Fetching letters...")
            guard let user1 = UserDefaults.standard.string(forKey: "userId"),
                  let user2 = friend?.userId else { return }
            print("user2: \(user2)")
            print("user1: \(user1)")
            let conversationId = getConversationId(for: user1, and: user2)
            
            db.collection("Inbox").document(conversationId).collection("Letters").order(by: "CreatedTime").getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching letters: \(error)")
                    completion(nil, error)
                } else {
                    guard let snapshotDocuments = snapshot?.documents else {
                        print("No documents in snapshot.")
                        completion([], nil)
                        return
                    }
                    var letters = [GoodThingLetter]()
                    for document in snapshotDocuments {
                        do {
                            let letter = try document.data(as: GoodThingLetter.self, decoder: Firestore.Decoder())
                            letters.append(letter)
                        } catch let decodingError {
                            print("Error decoding document ID \(document.documentID): \(decodingError)")
                        }
                    }
                    print("Successfully fetched \(letters.count) letters.")
                    completion(letters, nil)
                }
            }
        }
    }

    extension UserFriendLetterListViewController: UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            print("Number of letters: \(letters.count)")
            return letters.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            print("Creating cell for row: \(indexPath.row)")
            if let cell = tableView.dequeueReusableCell(withIdentifier: "UserFriendLetterListTableViewCell", for: indexPath) as? UserFriendLetterListTableViewCell {
                if !letters.isEmpty {
                    let letter = letters[indexPath.row]
                    cell.letterCreatedTimeLabel.text = letter.createdTime
                    cell.letterListPenNameButton.setTitle(friend?.userName, for: .normal)
                    cell.letterTitleLabel.text = letter.title
                } else {
                    cell.letterCreatedTimeLabel.text = ""
                    cell.letterListPenNameButton.setTitle("", for: .normal)
                    cell.letterTitleLabel.text = "目前還沒有新信件！"
                }
                return cell
            }
            return UITableViewCell()
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            print("Selected row at index: \(indexPath.row)")
            tableView.deselectRow(at: indexPath, animated: true)
            let letter = letters[indexPath.row]
            let combinedData = (letter: letter, friend: friend)
            performSegue(withIdentifier: "ToLetterDetailVC", sender: combinedData)
        }
    }

    extension UserFriendLetterListViewController {
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "ToLetterDetailVC", let destinationVC = segue.destination as? UserFriendLetterDetailViewController, let combinedData = sender as? (letter: GoodThingLetter?, friend: GoodThingUser?) {
                destinationVC.selectedLetter = combinedData.letter
                destinationVC.friend = combinedData.friend
            } else if segue.identifier == "FromLetterListVCToWriteVC", let destinationVC = segue.destination as? UserLetterWritingViewController, let friend = sender as? GoodThingUser {
                destinationVC.friend = friend
            }
        }
    }

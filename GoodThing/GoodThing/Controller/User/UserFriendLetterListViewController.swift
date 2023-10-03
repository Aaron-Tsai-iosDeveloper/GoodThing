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
    var letters = [GoodThingLetter?]()
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        userFriendLetterListTableView.dataSource = self
        userFriendLetterListTableView.delegate = self
        
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
        guard let user1 = UserDefaults.standard.string(forKey: "userId"),
              let user2 = friend?.userId else { return }
        let conversationId = getConversationId(for: user1, and: user2)
        db.collection("Inbox").document(conversationId).collection("Letters").order(by: "CreatedTime").getDocuments { (snapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                var letters = [GoodThingLetter]()
                for document in snapshot!.documents {
                    do {
                        let letter = try document.data(as: GoodThingLetter.self, decoder: Firestore.Decoder())
                        letters.append(letter)
                    } catch let decodingError {
                        print("Error decoding: \(decodingError)")
                    }
                }
                completion(letters, nil)
            }
        }
    }

}

extension UserFriendLetterListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        letters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "UserFriendLetterListTableViewCell", for: indexPath) as? UserFriendLetterListTableViewCell {
            if !letters.isEmpty {
                let letter = letters[indexPath.row]
                cell.letterCreatedTimeLabel.text = letter?.CreatedTime
                cell.letterListPenNameButton.setTitle(friend?.userName, for: .normal)
                cell.letterTitleLabel.text = letter?.title
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

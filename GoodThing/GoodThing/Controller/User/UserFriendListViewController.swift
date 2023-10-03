//
//  UserFriendListViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/10/2.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
class UserFriendListViewController: UIViewController {
    
    @IBOutlet weak var userProfileFriendListTableView: UITableView!
    var friendDetails = [GoodThingUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userProfileFriendListTableView.dataSource = self
        userProfileFriendListTableView.delegate = self
        fetchFriendDetails()
    }
    
    func fetchFriendDetails() {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else { return }
        print(userId)
        let db = Firestore.firestore()

        db.collection("GoodThingUsers").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                if let fetchedFriendIds = document.get("friends") as? [String] {
                    for friendId in fetchedFriendIds {
                        self.fetchUserDetails(userId: friendId)
                    }
                } else {
                    print("Error parsing friends list.")
                }
            } else {
                print("Error fetching user document: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }

    func fetchUserDetails(userId: String) {
        let db = Firestore.firestore()
        db.collection("GoodThingUsers").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                do {
                    let friendData = try document.data(as: GoodThingUser.self)
                    DispatchQueue.main.async {
                        self.friendDetails.append(friendData)
                        self.userProfileFriendListTableView.reloadData()
                    }
                } catch let decodingError {
                    print("Decoding error: \(decodingError)")
                }
            }
        }
    }
}

extension UserFriendListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        friendDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserFriendListTableViewCell", for: indexPath) as? UserFriendListTableViewCell else { return UITableViewCell() }
        let friendName = friendDetails[indexPath.row].userName
        cell.userProfileFriendNameButton.setTitle(friendName, for: .normal)
        cell.userProfileFriendNameButton.tag = indexPath.row
        cell.userProfileFriendNameButton.addTarget(self, action: #selector(friendNameButtonTapped(_:)), for: .touchUpInside)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let friend = friendDetails[indexPath.row]
        performSegue(withIdentifier: "ToUserFriendLetterListVC", sender: friend)
    }

}

extension UserFriendListViewController {
    
    @objc func friendNameButtonTapped(_ sender: UIButton) {
        let friend = friendDetails[sender.tag]
        performSegue(withIdentifier: "ToUserInfoVC", sender: friend)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToUserInfoVC", let destinationVC = segue.destination as? UserInfoViewController, let friend = sender as? GoodThingUser {
            destinationVC.user = friend
        } else if segue.identifier == "ToUserFriendLetterListVC", let destinationVC = segue.destination as? UserFriendLetterListViewController, let friend = sender as? GoodThingUser {
            destinationVC.friend = friend
        }
    }
}

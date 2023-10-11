//
//  UserProfileViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/10/2.
//

import UIKit
import FirebaseFirestore

class UserProfileViewController: UIViewController {

    @IBOutlet weak var userProfilePenNameLabel: UILabel!
    @IBOutlet weak var userProfilePublicTaskNumberLabel: UILabel!
    @IBOutlet weak var userProfilePublicMemoryNumberLabel: UILabel!
    @IBOutlet weak var userProfileGoodThingDaysLabel: UILabel!
    @IBOutlet weak var userProfileLeftCollectionView: UICollectionView!
    @IBOutlet weak var userProfileRightCollectionView: UICollectionView!
    let leftButtonAttributes: [ButtonAttributes] = [
        ButtonAttributes(title: "筆友收信匣", titleColor: UIColor.black),
        ButtonAttributes(title: "修改好事任務", titleColor: UIColor.black)
    ]

    let rightButtonAttributes: [ButtonAttributes] = [
        ButtonAttributes(title: "編輯個人資訊", titleColor: UIColor.black),
        ButtonAttributes(title: "修改好事多貼文", titleColor: UIColor.black)
    ]
    
    var userData: GoodThingUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userProfileLeftCollectionView.dataSource = self
        userProfileLeftCollectionView.delegate = self
        userProfileLeftCollectionView.tag = 1
        userProfileRightCollectionView.dataSource = self
        userProfileRightCollectionView.delegate = self
        userProfileRightCollectionView.tag = 2
        
        userProfileLeftCollectionView.setCollectionViewLayout(customFlowLayout(for: userProfileLeftCollectionView), animated: false)
        userProfileRightCollectionView.setCollectionViewLayout(customFlowLayout(for: userProfileRightCollectionView), animated: false)
        
        fetchUserData { user in
            self.userData = user
            if let registrationDateString = user?.registrationTime {
                self.userProfileGoodThingDaysLabel.text = self.calculateDaysSinceRegistration(from: registrationDateString)
            }
        }

    }
}

extension UserProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if collectionView.tag == 1 {
                return leftButtonAttributes.count
            } else {
                return rightButtonAttributes.count
            }
        }
    //TODO: 設置點擊按鈕跳轉頁面
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserProfileLeftCollectionViewCell", for: indexPath) as! UserProfileLeftCollectionViewCell
            cell.configure(with: leftButtonAttributes[indexPath.row])
            cell.buttonTapped = {
                switch indexPath.row {
                case 0:
                    self.performSegue(withIdentifier: "ToFriendListVC", sender: self)
                case 1:
                    print("等待設置Button跳轉頁面")
                case 2:
                    print("等待設置Button跳轉頁面")
                default:
                    print("等待設置Button跳轉頁面")
                }
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserProfileRightCollectionViewCell", for: indexPath) as! UserProfileRightCollectionViewCell
            cell.configure(with: rightButtonAttributes[indexPath.row])
            cell.buttonTapped = {
                switch indexPath.row {
                case 0:
                    self.performSegue(withIdentifier: "ToUserInfoEditionVC", sender: self)
                case 1:
                    self.performSegue(withIdentifier: " ToUserPostedMemoryListVC", sender: self)
                case 2:
                    print("等待設置Button跳轉頁面")
                default:
                    print("等待設置Button跳轉頁面")
                }
            }
            return cell
        }
    }
}

extension UserProfileViewController {
    func customFlowLayout(for collectionView: UICollectionView) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let availableWidth = collectionView.bounds.width - (layout.sectionInset.left + layout.sectionInset.right)
        layout.itemSize = CGSize(width: availableWidth, height: 100)
        layout.minimumLineSpacing = 100
        return layout
    }
}

extension UserProfileViewController {
    func fetchUserData(completion: @escaping (GoodThingUser?) -> Void)  {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else { return }
        print(userId)
        let db = Firestore.firestore()
        
        db.collection("GoodThingUsers").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                do {
                    let user = try document.data(as: GoodThingUser.self, decoder: Firestore.Decoder())
                    self.userData = user
                    completion(user)
                    print(user)
                } catch let error {
                    completion(nil)
                    print("Error decoding user details: \(error)")
                }
            } else {
                print("Error fetching user document: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }
    func calculateDaysSinceRegistration(from registrationDateString: String) -> String {
        let registrationDate = Date.dateFormatterWithTime.date(from: registrationDateString)
        var daysString = ""
        
        if let registrationDate = registrationDate {
            let calendar = Calendar.current
            let currentDate = Date()
            let registrationSimpleDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: registrationDate)!
            let currentSimpleDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: currentDate)!
            
            let components = calendar.dateComponents([.day], from: registrationSimpleDate, to: currentSimpleDate)
            let days = components.day ?? 0
            daysString = "\(days)"
        }
        
        return daysString
    }
}

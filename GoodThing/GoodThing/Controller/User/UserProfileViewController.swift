//
//  UserProfileViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/10/2.
//

import UIKit

class UserProfileViewController: UIViewController {

    @IBOutlet weak var userProfilePenNameLabel: UILabel!
    @IBOutlet weak var userProfileUserIdLabel: UILabel!
    @IBOutlet weak var userProfileRegistrationTimeLabel: UILabel!
    @IBOutlet weak var userProfilePublicTaskNumberLabel: UILabel!
    @IBOutlet weak var userProfilePrivateTaskNumberLabel: UILabel!
    @IBOutlet weak var userProfilePrivateMemoryNumberLabel: UILabel!
    @IBOutlet weak var userProfilePublicMemoryNumberLabel: UILabel!
    @IBOutlet weak var userProfileGoodThingDaysLabel: UILabel!
    @IBOutlet weak var userProfileLeftCollectionView: UICollectionView!
    @IBOutlet weak var userProfileRightCollectionView: UICollectionView!
    let leftButtonAttributes: [ButtonAttributes] = [
        ButtonAttributes(title: "筆友收信匣", titleColor: UIColor.black),
        ButtonAttributes(title: "好事揪團歷程", titleColor: UIColor.black)
    ]

    let rightButtonAttributes: [ButtonAttributes] = [
        ButtonAttributes(title: "更好的自己", titleColor: UIColor.black),
        ButtonAttributes(title: "好心情收藏", titleColor: UIColor.black)
    ]

    
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
                    print("等待設置Button跳轉頁面")
                case 1:
                    print("等待設置Button跳轉頁面")
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

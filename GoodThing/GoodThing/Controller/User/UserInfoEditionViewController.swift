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
    @IBOutlet weak var userInfoEdtionAlertLabel: UILabel!
    @IBOutlet weak var userInfoPageLabel: UILabel!
    @IBOutlet weak var userInfoPenNameLabel: UILabel!
    @IBOutlet weak var userInfoIntruductionLabel: UILabel!
    @IBOutlet weak var userInfoFavoriteSentenceLabel: UILabel!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userInfoUpdateButton.addTarget(self, action: #selector(updateUserInfo), for: .touchUpInside)
        setUI()
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
                self.userInfoEdtionAlertLabel.text = "用戶資訊更新成功！"
            }
        }
    }
}

extension UserInfoEditionViewController {
    func setUI() {
        introductionTextView.layer.borderWidth = 0.7
        introductionTextView.layer.borderColor = UIColor.systemBrown.cgColor
        introductionTextView.layer.cornerRadius = 10
        favoriteSentenceTextView.layer.borderWidth = 0.7
        favoriteSentenceTextView.layer.borderColor = UIColor.systemBrown.cgColor
        favoriteSentenceTextView.layer.cornerRadius = 10
        userInfoUpdateButton.layer.borderWidth = 0.7
        userInfoUpdateButton.layer.borderColor = UIColor.systemBrown.cgColor
        userInfoUpdateButton.tintColor = .white
        userInfoUpdateButton.backgroundColor = .systemBrown
        userInfoUpdateButton.layer.cornerRadius = 10
        
        userInfoPageLabel.layer.borderWidth = 0.7
        userInfoPageLabel.layer.borderColor = UIColor.white.cgColor
        userInfoPageLabel.backgroundColor = .brown
        userInfoPageLabel.clipsToBounds = true
        userInfoPageLabel.text = " 個人資訊編輯 "
        userInfoPageLabel.textColor = .white
        userInfoPageLabel.layer.cornerRadius = 10
        
        userInfoPenNameLabel.layer.borderWidth = 0.7
        userInfoPenNameLabel.layer.borderColor = UIColor.white.cgColor
        userInfoPenNameLabel.backgroundColor = .brown
        userInfoPenNameLabel.clipsToBounds = true
        userInfoPenNameLabel.text = " 筆名 "
        userInfoPenNameLabel.textColor = .white
        userInfoPenNameLabel.layer.cornerRadius = 10
        
        userInfoFavoriteSentenceLabel.layer.borderWidth = 0.7
        userInfoFavoriteSentenceLabel.layer.borderColor = UIColor.white.cgColor
        userInfoFavoriteSentenceLabel.backgroundColor = .brown
        userInfoFavoriteSentenceLabel.clipsToBounds = true
        userInfoFavoriteSentenceLabel.text = " 最喜歡的一段話 "
        userInfoFavoriteSentenceLabel.textColor = .white
        userInfoFavoriteSentenceLabel.layer.cornerRadius = 10
        
        userInfoIntruductionLabel.layer.borderWidth = 0.7
        userInfoIntruductionLabel.layer.borderColor = UIColor.white.cgColor
        userInfoIntruductionLabel.backgroundColor = .brown
        userInfoIntruductionLabel.clipsToBounds = true
        userInfoIntruductionLabel.text = " 自我簡介 "
        userInfoIntruductionLabel.textColor = .white
        userInfoIntruductionLabel.layer.cornerRadius = 10
        
    }
}

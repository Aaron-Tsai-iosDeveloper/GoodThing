//
//  UserSingupViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/10/1.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class UserSingupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userSingupEmailTextField: UITextField!
    @IBOutlet weak var userSingupPasswordTextField: UITextField!
    @IBOutlet weak var userSingupBirthdayDatePicker: UIDatePicker!
    @IBOutlet weak var userSingupAlertMessageLabel: UILabel!
    @IBOutlet weak var userSingupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userSingupEmailTextField.delegate = self
        userSingupPasswordTextField.delegate = self
        userSingupButton.addTarget(self, action: #selector(rigister), for: .touchUpInside)
    }
    
    @objc func rigister() {
        
        guard let userEmail = userSingupEmailTextField.text, !userEmail.isEmpty, let userPassword = userSingupPasswordTextField.text, !userPassword.isEmpty else { return }

        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { authResult, error in
            if let error = error as NSError? {
                print("Register Fail: \(error)")

                if error.domain == AuthErrorDomain {
                    switch error.code {
                    case AuthErrorCode.emailAlreadyInUse.rawValue:
                        self.userSingupAlertMessageLabel.text = "信箱已經被註冊使用"
                    case AuthErrorCode.invalidEmail.rawValue:
                        self.userSingupAlertMessageLabel.text = "請輸入有效信箱"
                    case AuthErrorCode.weakPassword.rawValue:
                        self.userSingupAlertMessageLabel.text = "密碼過於簡單"
                    default:
                        self.userSingupAlertMessageLabel.text = "註冊出現問題，請稍後再試"
                    }
                } else {
                    self.userSingupAlertMessageLabel.text = "未知的錯誤，請稍後再試"
                }
                return
            }
            if let user = authResult?.user {
                print("User regitster in Successly : \(user)")
                self.userSingupAlertMessageLabel.text = "註冊成功！"
                UserDefaults.standard.set(user.uid, forKey: "userId")
                self.postUserData()
            }
        }
    }
    func isValidEmail(_ email:String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func isValidPassword (_ password:String) -> Bool {
        return password.count >= 6
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == userSingupEmailTextField {
            if let email = textField.text, !isValidEmail(email) {
                userSingupAlertMessageLabel.text = "請輸入有效信箱"
            } else {
                userSingupAlertMessageLabel.text = ""
            }
        }
        else if textField == userSingupPasswordTextField {
            if let password = textField.text, !isValidPassword(password) {
                userSingupAlertMessageLabel.text = "密碼至少需要6個字符"
            } else {
                userSingupAlertMessageLabel.text = ""
            }
        }
    }
    
    @objc func postUserData() {
        guard let email = userSingupEmailTextField.text, !email.isEmpty,
              let password = userSingupPasswordTextField.text, !password.isEmpty,
              let uid = Auth.auth().currentUser?.uid
        else {
            userSingupAlertMessageLabel.text = "仍有欄位尚未填寫"
            return
        }
        let db = Firestore.firestore()
        let birthday = Date.dateFormatterWithDate.string(from: userSingupBirthdayDatePicker.date)
        let registrationTime = Date.dateFormatterWithTime.string(from: Date())
        var data: [String: Any] = [
            "userId": uid,
            "userName": "匿名好夥伴",
            "birthday": birthday,
            "registrationTime": registrationTime,
            "introduction": "",
            "favoriteSentence": "",
            "latestPublishedTaskId": "",
            "groupsList": [""],
            "goodSentences": [""],
            "friends": [""],
            "articlesCollection": [""],
            "postedTasksList": [""],
            "postedMemoryList": [""]
        ]
        db.collection("GoodThingUsers").document(uid).setData(data) { err in
            if let err = err {
                print("Error register user: \(err)")
            } else {
                print(" Register user with Document ID: \(uid)")
            }
        }
    }
}

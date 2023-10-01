//
//  UserLoginViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/29.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class UserLoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userLoginEmailTextField: UITextField!
    @IBOutlet weak var userLoginPasswordTextField: UITextField!
    @IBOutlet weak var userLoginAlertMessageLabel: UILabel!
    @IBOutlet weak var userLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userLoginEmailTextField.delegate = self
        userLoginPasswordTextField.delegate = self
        userLoginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
    }

    @objc func login() {
        
        guard let userEmail = userLoginEmailTextField.text, !userEmail.isEmpty, let userPassword = userLoginPasswordTextField.text, !userPassword.isEmpty else { return }
    
        Auth.auth().signIn(withEmail: userEmail, password: userPassword) { authResult, error in
       
            if let error = error {
                print("Login Fail: \(error)")
                self.userLoginAlertMessageLabel.text = "請再次確認信箱密碼或先進行註冊"
                return
            } else if let user = authResult?.user {
                print("User logged in Successly : \(user)")
                self.userLoginAlertMessageLabel.text = "登入成功！"
                UserDefaults.standard.set(user.uid, forKey: "userId")
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
        if textField == userLoginEmailTextField {
            if let email = textField.text, !isValidEmail(email) {
                userLoginAlertMessageLabel.text = "請輸入有效信箱"
            } else {
                userLoginAlertMessageLabel.text = ""
            }
        }
        else if textField == userLoginPasswordTextField {
            if let password = textField.text, !isValidPassword(password) {
                userLoginAlertMessageLabel.text = "密碼至少需要6個字符"
            } else {
                userLoginAlertMessageLabel.text = ""
            }
        }
    }
}


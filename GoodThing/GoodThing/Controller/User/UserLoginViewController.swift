//
//  UserLoginViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/29.
//

import UIKit
import FirebaseFirestore
import CryptoKit
import AuthenticationServices
import FirebaseAuth


class UserLoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userLoginEmailTextField: UITextField!
    @IBOutlet weak var userLoginPasswordTextField: UITextField!
    @IBOutlet weak var userLoginAlertMessageLabel: UILabel!
    @IBOutlet weak var userLoginButton: UIButton!
    @IBOutlet weak var signInWithAppleButtonView: UIView!
    
    fileprivate var currentNonce: String?
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userLoginEmailTextField.delegate = self
        userLoginPasswordTextField.delegate = self
        userLoginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        
        
        let authorizationAppleIDButton: ASAuthorizationAppleIDButton = ASAuthorizationAppleIDButton()
        authorizationAppleIDButton.addTarget(self, action: #selector(startSignInWithAppleFlow), for: .touchUpInside)
        authorizationAppleIDButton.frame = self.signInWithAppleButtonView.bounds
        self.signInWithAppleButtonView.addSubview(authorizationAppleIDButton)
    }
    
    // MARK: - User Login
    @objc func login() {
        guard let userEmail = userLoginEmailTextField.text, !userEmail.isEmpty, let userPassword = userLoginPasswordTextField.text, !userPassword.isEmpty else { return }
        self.activityIndicator.startAnimating()
        Auth.auth().signIn(withEmail: userEmail, password: userPassword) { authResult, error in
            if let error = error {
                print("Login Fail: \(error)")
                self.userLoginAlertMessageLabel.text = "請再次確認信箱密碼或先進行註冊"
                self.showAlert(title: "登入失敗", message: "請再次確認信箱密碼或先進行註冊")
                return
            } else if let user = authResult?.user {
                print("User logged in Successly : \(user)")
                self.userLoginAlertMessageLabel.text = "登入成功！"
                self.activityIndicator.stopAnimating()
                UserDefaults.standard.set(user.uid, forKey: "userId")
                self.showAlert(title: "成功", message: "登入成功！", completion: {
                    if let presenter = self.presentingViewController {
                        presenter.dismiss(animated: true, completion: nil)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                })
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
        } else if textField == userLoginPasswordTextField {
            if let password = textField.text, !isValidPassword(password) {
                userLoginAlertMessageLabel.text = "密碼至少需要6個字符"
            } else {
                userLoginAlertMessageLabel.text = ""
            }
        }
    }
    // MARK: - Sign in with Apple
    private func randomNonceString(length: Int = 32) -> String {
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }
    
    @available(iOS 13, *)
    @objc func startSignInWithAppleFlow() {
        
        self.activityIndicator.startAnimating()
        
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

@available(iOS 13.0, *)
extension UserLoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: appleIDCredential.fullName)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print(error.localizedDescription)
                    self.showAlert(title: "登入失敗", message: "無法使用Apple ID登入")
                    return
                }
                guard let firebaseUserId = authResult?.user.uid else {
                    print("Error retrieving user's uid")
                    return
                }
                let userIdentifier = appleIDCredential.user
                let fullName = appleIDCredential.fullName?.givenName ?? ""
                let email = appleIDCredential.email ?? ""
                self.saveUserInfoToFirestore(userId: firebaseUserId, appleId: userIdentifier, fullName: fullName, email: email)
                self.activityIndicator.stopAnimating()
                UserDefaults.standard.set(firebaseUserId, forKey: "userId")
                self.showAlert(title: "登入成功", message: "開始你的好事生活！")
                if let presenter = self.presentingViewController {
                    presenter.dismiss(animated: true, completion: nil)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
        print("Error description: \(error.localizedDescription)")
        if let userInfo = (error as NSError).userInfo as? [String: Any] {
            for (key, value) in userInfo {
                print("UserInfo Key: \(key), Value: \(value)")
                self.activityIndicator.stopAnimating()
                self.showAlert(title: "登入失敗", message: "無法使用Apple ID登入")
            }
        }
    }
}

extension UserLoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension UserLoginViewController {
    func saveUserInfoToFirestore(userId: String, appleId: String, fullName: String, email: String) {
        let db = Firestore.firestore()
        let usersAccountInfoCollection = db.collection("UserAccountInfo")
        let goodThingUsersCollection = db.collection("GoodThingUsers")
        
        
        usersAccountInfoCollection.document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                
                print("User already exists. No data updated.")
            } else {
                
                let userData: [String: Any] = [
                    "fullName": fullName,
                    "email": email,
                    "appleId": appleId,
                    "userId": userId
                ]
                
                usersAccountInfoCollection.document(userId).setData(userData) { error in
                    if let error = error {
                        print("Error adding user to UserAccountInfo: \(error)")
                    } else {
                        print("User successfully added to UserAccountInfo!")
                    }
                }
                
                let registrationTime = Date.dateFormatterWithTime.string(from: Date())
                var data: [String: Any] = [
                    "userId": userId,
                    "userName": "",
                    "birthday": "",
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
                
                goodThingUsersCollection.document(userId).setData(data) { err in
                    if let err = err {
                        print("Error registering user to GoodThingUsers: \(err)")
                    } else {
                        print("Register user with Document ID: \(userId) to GoodThingUsers")
                    }
                }
            }
        }
    }


}

extension UserLoginViewController {
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: { _ in
            completion?()
        }))
        self.present(alert, animated: true)
    }
    
}

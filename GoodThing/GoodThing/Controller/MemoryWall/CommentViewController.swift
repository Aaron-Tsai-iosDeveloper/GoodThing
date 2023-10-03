//
//  CommentViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/22.
//

import UIKit
import FirebaseFirestore

class CommentViewController: UIViewController {
    var commentTextView: UITextView!
    var confirmButton: UIButton!
    var selectedMemory: GoodThingMemory?
    var dismissClosure: (() -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        let paleCyanBlue = UIColor(red: 0.7, green: 0.9, blue: 1.0, alpha: 1.0)
        view.backgroundColor = paleCyanBlue


        setupLabels()
        setupTextView()
        setupButton()
    }
    private func setupLabels() {
        let nameLabel = UILabel(frame: CGRect(x: 20, y: 20, width: 260, height: 20))
        nameLabel.text = "留言者姓名"
        view.addSubview(nameLabel)
        let floorLabel = UILabel(frame: CGRect(x: 20, y: nameLabel.frame.maxY + 10, width: 130, height: 20))
        floorLabel.text = ""
        view.addSubview(floorLabel)
        let timeLabel = UILabel(frame: CGRect(x: floorLabel.frame.maxX + 10, y: nameLabel.frame.maxY + 10, width: 130, height: 20))
        timeLabel.text = "留言時間"
        view.addSubview(timeLabel)
    }
    private func setupTextView() {
        commentTextView = UITextView(frame: CGRect(x: 20, y: 80, width: 260, height: 50))
        commentTextView.text = "請輸入留言"
        commentTextView.textColor = .lightGray
        commentTextView.layer.borderWidth = 1.0
        commentTextView.layer.borderColor = UIColor.lightGray.cgColor
        commentTextView.layer.cornerRadius = 5.0
        commentTextView.delegate = self
        view.addSubview(commentTextView)
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChange), name: UITextView.textDidChangeNotification, object: commentTextView)
    }
    private func setupButton() {
        confirmButton = UIButton(frame: CGRect(x: commentTextView.frame.maxX + 10 , y: commentTextView.frame.minY , width: 100, height: 40))
        confirmButton.setTitle("取消", for: .normal)
        confirmButton.setTitleColor(.systemBlue, for: .normal)
        confirmButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
        view.addSubview(confirmButton)
    }
    @objc func didTapSubmit() {
        if commentTextView.text.isEmpty || commentTextView.text == "請輸入留言" {
            dismiss(animated: true, completion: nil)
        } else {
            postCommet()
            print("用戶留言：\(commentTextView.text!)")
            dismiss(animated: true, completion: nil)
        }
    }
    @objc func textViewDidChange() {
        if commentTextView.text.isEmpty {
            commentTextView.text = "請輸入留言"
            commentTextView.textColor = .lightGray
        } else if commentTextView.textColor == .lightGray {
            commentTextView.text = nil
            commentTextView.textColor = .black
        }
        confirmButton.setTitle(commentTextView.text.isEmpty || commentTextView.text == "請輸入留言" ? "取消" : "提交", for: .normal)
    }
}

extension CommentViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "請輸入留言"
            textView.textColor = .lightGray
        }
    }
}
//TODO: 登入系統建置後，更改CreatorID
extension CommentViewController {
    func postCommet() {
        guard let commentContent = commentTextView.text, !commentContent.isEmpty,
              let memoryId = selectedMemory?.memoryID else { return }
        let db = Firestore.firestore()
        let memoryCommentsCollection = db.collection("GoodThingMemory").document(memoryId).collection("MemoryComments")
        let document = memoryCommentsCollection.document()
        let id = document.documentID
        let time = Date.dateFormatterWithTime.string(from: Date())
        var data: [String: Any] = [
            "memoryId": memoryId,
            "commentId": id,
            "commentContent": commentContent,
            "commentCreatedTime": time,
            "commentCreatorId": "Aaron"
        ]
        document.setData(data) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(id)")
            }
        }

    }
}

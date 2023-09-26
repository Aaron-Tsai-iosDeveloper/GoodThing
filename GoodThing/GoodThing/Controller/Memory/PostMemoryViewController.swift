//
//  PostMemoryViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/18.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class PostMemoryViewController: UIViewController {

    @IBOutlet weak var memoryTitleTextField: UITextField!
    @IBOutlet weak var memoryContentTextView: UITextView!
    @IBOutlet weak var postMemoryButton: UIButton!
    @IBOutlet weak var privateMemoryImageView: UIImageView!
    @IBOutlet weak var addMemoryImageButton: UIButton!
    
    @IBOutlet weak var addMemoryImageLabel: UILabel!
    var imageURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postMemoryButton.addTarget(self, action: #selector(postMemory), for: .touchUpInside)
        memoryContentTextView.layer.borderWidth = 1.0
        memoryContentTextView.layer.borderColor = CGColor(gray: 0.5, alpha: 0.6) 

    }
  
    
    @objc func postMemory() {
        guard let title = memoryTitleTextField.text, !title.isEmpty,
              let content = memoryContentTextView.text, !content.isEmpty else { return }
        let db = Firestore.firestore()
        let document = db.collection("GoodThingMemory").document()
        let id = document.documentID
        let time = Date.dateFormatterWithTime.string(from: Date())
        var data: [String: Any] = [
            "memoryID": id,
            "memoryTitle": title,
            "memoryContent": content,
            "memoryTag": ["感謝"],
            "memoryPrivacyStatus": true,
            "memoryCreatedTime": time,
            "memoryCreatorID": "Aaron"
        ]
        if let imageURL = imageURL {
            data["memoryImage"] = imageURL
        }
        db.collection("GoodThingMemory").document(id).setData(data) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(id)")
                self.addMemoryImageLabel.text = "心情轉換完畢！"
                self.addMemoryImageLabel.textColor = .red
            }
        }

    }
    
    @IBAction func addMemoryImageButtonTapped(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
}

extension PostMemoryViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            privateMemoryImageView.image = selectedImage
            privateMemoryImageView.contentMode = .scaleAspectFit
            uploadImageToFirebase(selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension PostMemoryViewController {
     func uploadImageToFirebase(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.6) else {
            print("Could not convert image to data.")
            return
        }

        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("memoryImages/\(UUID().uuidString).jpg")

        let uploadTask = imageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Failed to upload image: \(error)")
            } else {
                print("Successfully uploaded image.")
                
             
                imageRef.downloadURL { (url, error) in
                    if let error = error {
                        print("Failed to get download URL: \(error)")
                    } else if let downloadURL = url {
                        self.imageURL = downloadURL.absoluteString
                    }
                }
            }
        }
    }
}

//
//  PostMemoryViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/18.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import AVFAudio

class PostPublicMemoryViewController: UIViewController {

    @IBOutlet private weak var memoryTitleTextField: UITextField!
    @IBOutlet private weak var memoryContentTextView: UITextView!
    @IBOutlet private weak var postMemoryButton: UIButton!
    @IBOutlet private weak var privateMemoryImageView: UIImageView!
    @IBOutlet private weak var addMemoryImageButton: UIButton!
    @IBOutlet private weak var addMemoryImageLabel: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var storeButton: UIButton!
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var recordingLabel: UILabel!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer?
    var recordingURL: String?
    private var timer: Timer?
    private var elapsedTimeInSecond: Int = 0
    
    var uploadGroup: DispatchGroup = DispatchGroup()

    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    var imageURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postMemoryButton.addTarget(self, action: #selector(postMemory), for: .touchUpInside)
        memoryContentTextView.layer.borderWidth = 1.0
        memoryContentTextView.layer.borderColor = CGColor(gray: 0.5, alpha: 0.6)
        setupKeyboardClosed()
        self.view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        configure()
    }
  
    
    @objc func postMemory() {
        activityIndicator.startAnimating()
        postMemoryButton.isEnabled = false
        uploadGroup.notify(queue: .main) {
            guard let title = self.memoryTitleTextField.text, !title.isEmpty,
                  let content = self.memoryContentTextView.text, !content.isEmpty else { return }
            guard let userId = UserDefaults.standard.string(forKey: "userId") else {
                self.addMemoryImageLabel.text = "請先進行登入或註冊"
                self.addMemoryImageLabel.textColor = .red
                return
            }
            let db = Firestore.firestore()
            let document = db.collection("GoodThingMemory").document()
            let id = document.documentID
            let time = Date.dateFormatterWithTime.string(from: Date())
            var data: [String: Any] = [
                "memoryID": id,
                "memoryTitle": title,
                "memoryContent": content,
                "memoryTag": ["感謝"],
                "memoryPrivacyStatus": false,
                "memoryCreatedTime": time,
                "memoryCreatorID": userId
            ]
            if let imageURL = self.imageURL {
                data["memoryImage"] = imageURL
            }
            if let recordURL = self.recordingURL {
                data["memoryVoice"] = recordURL
            }
            db.collection("GoodThingMemory").document(id).setData(data) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(id)")
                    self.addMemoryImageLabel.text = "好心情成功分享！"
                    self.addMemoryImageLabel.textColor = .red
                    self.activityIndicator.stopAnimating()
                    self.postMemoryButton.isEnabled = true
                    
                    self.memoryTitleTextField.text = ""
                    self.memoryContentTextView.text = ""
                    self.privateMemoryImageView.image = nil
                }
            }
        }
    }
    
    @IBAction func addMemoryImageButtonTapped(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func stareRecord(sender: UIButton) {
        if let player = audioPlayer, player.isPlaying {
            player.stop()
        }
        if !audioRecorder.isRecording {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(true)
                audioRecorder.record()
                startTimer()
                recordButton.setImage(UIImage(named: "Pause"), for: UIControl.State.normal)
            } catch {
                print(error)
            }
        } else {
            audioRecorder.pause()
            pauseTimer()
            recordButton.setImage(UIImage(named: "Record"), for: UIControl.State.normal)
        }
        storeButton.isEnabled = true
        playButton.isEnabled = false
    }
    @IBAction func storeRecord(sender: UIButton) {
        recordButton.setImage(UIImage(named: "Record"), for: UIControl.State.normal)
        recordButton.isEnabled = true
        storeButton.isEnabled = false
        playButton.isEnabled = true
        audioRecorder?.stop()
        resetTimer()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch {
            print(error)
        }
    }

    @IBAction func play(sender: UIButton) {
        if let player = audioPlayer {
            if player.isPlaying {
                player.pause()
                sender.setTitle("", for: .normal)
                pauseTimer()
            } else {
                player.play()
                startTimer()
                sender.setTitle("", for: .normal)
            }
        } else {
            guard let player = try? AVAudioPlayer(contentsOf: audioRecorder.url) else {
                print("Failed to initialize AVAudioPlayer")
                return
            }
            audioPlayer = player
            audioPlayer?.delegate = self
            audioPlayer?.play()
            startTimer()
            sender.setTitle("", for: .normal)
        }
    }
}

extension PostPublicMemoryViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            privateMemoryImageView.image = selectedImage
            privateMemoryImageView.contentMode = .scaleAspectFit
            uploadImageToFirebase(selectedImage)
        }
        dismiss(animated: true) {
            self.dismissKeyboard()
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension PostPublicMemoryViewController {
     func uploadImageToFirebase(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.6) else {
            print("Could not convert image to data.")
            return
        }
         
        uploadGroup.enter()
         
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
                    self.uploadGroup.leave()
                }
            }
        }
    }
}
extension PostPublicMemoryViewController {
    func setupKeyboardClosed() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

extension PostPublicMemoryViewController {
    private func configure() {
        storeButton.isEnabled = false
        playButton.isEnabled = false
        guard let directoryURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first else {
            let alertMessage = UIAlertController(title: "Error", message: "Failed to get the document directory for recording the audio. Please try again later.", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertMessage, animated: true, completion: nil)
            return
        }
        let audioFileURL = directoryURL.appendingPathComponent("MyAudioMemo.m4a")
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [ .defaultToSpeaker ])
            let recorderSetting: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: recorderSetting)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
        } catch {
            print(error)
        }
    }
}

extension PostPublicMemoryViewController {
    func uploadAudioToFirebase() {
        
        guard let audioURL = audioRecorder?.url,
              let userId = UserDefaults.standard.string(forKey: "userId") else { return }

        let storageRef = Storage.storage().reference().child("audioFiles/\(userId)_\(audioURL.lastPathComponent)")
        storageRef.putFile(from: audioURL, metadata: nil) { metadata, error in
            if let error = error {
                print("Failed to upload audio: \(error)")
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to get download URL: \(error)")
                    return
                }
                guard let downloadURL = url else { return }
                print("Audio file uploaded and available at: \(downloadURL)")
                self.recordingURL = downloadURL.absoluteString
            }
        }
    }
}

extension PostPublicMemoryViewController {
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            self.elapsedTimeInSecond += 1
            self.updateTimeLabel()
        })
    }
    func pauseTimer() {
        timer?.invalidate()
    }

    func resetTimer() {
        timer?.invalidate()
        elapsedTimeInSecond = 0
        updateTimeLabel()
    }

    func updateTimeLabel() {
        let seconds = elapsedTimeInSecond % 60
        let minutes = (elapsedTimeInSecond / 60) % 60
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
}
extension PostPublicMemoryViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            let alertMessage = UIAlertController(title: "錄音完成", message: "加油語錄已經儲存!", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertMessage, animated: true, completion: nil)
            uploadAudioToFirebase()
        }
    }
}
extension PostPublicMemoryViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.isSelected = false
        resetTimer()
        let alertMessage = UIAlertController(title: "播放完成", message: "如果想重錄，再點一次錄音就好囉！", preferredStyle: .alert)
        alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertMessage, animated: true, completion: nil)
    }
}

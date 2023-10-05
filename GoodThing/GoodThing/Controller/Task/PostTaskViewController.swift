//
//  ViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/14.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import AVFAudio

class PostTaskViewController: UIViewController {

    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var taskContentTextView: UITextView!
    @IBOutlet weak var postPublicTaskButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var storeButton: UIButton!
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet weak var imageNameLabel: UILabel!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer?
    var recordingURL: String?
    var imageURL: String?
    private var timer: Timer?
    private var elapsedTimeInSecond: Int = 0
    let textViewPlaceHolderText = "請輸入好事任務內容:"
    override func viewDidLoad() {
        super.viewDidLoad()
        postPublicTaskButton.addTarget(self, action: #selector(postPublicTask), for: .touchUpInside)
        configure()
        
        taskContentTextView.text = textViewPlaceHolderText
        taskContentTextView.textColor = .lightGray
        taskContentTextView.delegate = self
        taskContentTextView.layer.borderWidth = 1.0
        taskContentTextView.layer.borderColor = CGColor(gray: 0.5, alpha: 0.6)
        
        setupKeyboardClosed()
    }
   
    @objc func postPrivateTask() {
        postTask(privacy: true)
    }
    @objc func postPublicTask() {
        postTask()
    }
    func postTask(privacy privacyStatus: Bool = false) {
        guard let title = taskTitleTextField.text, !title.isEmpty,
              let content = taskContentTextView.text, !content.isEmpty,
              let userId = UserDefaults.standard.string(forKey: "userId") else { return }
        let db = Firestore.firestore()
        let document = db.collection("GoodThingTasks").document()
        let id = document.documentID
        let time = Date.dateFormatterWithTime.string(from: Date())
        let date = Date.dateFormatterWithDate.string(from: Date())
        let randomValue = Double.random(in: 0..<1)
        var data: [String: Any] = [
            "taskId": id,
            "taskTitle": title,
            "taskContent": content,
            "taskImage": imageURL ?? "",
            "taskCreatorId": userId,
            "privacyStatus": privacyStatus,
            "taskCreatedTime": time,
            "randomSelectionValue": randomValue,
            "lastFetchedTime": date
        ]
        if let recordURL = recordingURL {
            data["taskVoice"] = recordURL
        }
        db.collection("GoodThingTasks").document(id).setData(data) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(id)")
                self.imageNameLabel.text = "好事任務已經成功發佈！"
                UserDefaults.standard.set(id, forKey: "latestPostedTaskId")
                db.collection("GoodThingUsers").document(userId).updateData([
                    "latestPostedTaskId": id
                ]) { updateUserErr in
                    if let updateUserErr = updateUserErr {
                        print("Error updating user's latest task ID: \(updateUserErr)")
                    } else {
                        print("User's latest task ID successfully updated!")
                    }
                }
            }
        }
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
                sender.setTitle("播放", for: .normal)
                pauseTimer()
            } else {
                player.play()
                startTimer()
                sender.setTitle("暫停", for: .normal)
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
            sender.setTitle("暫停", for: .normal)
        }
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
    
    @IBAction func addPubplicTaskImageButtonTapped(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func previewTaskButton(_ sender: UIButton) {
        if self.imageNameLabel.text == "" {
            performSegue(withIdentifier: "toPostPublicTasksTextPreviewVC", sender: sender)
        } else {
            
            performSegue(withIdentifier: "toPostPublicTasksImagePreviewVC", sender: sender)
        }
    }
}
extension PostTaskViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {

            uploadImageToFirebase(selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
extension PostTaskViewController {
     func uploadImageToFirebase(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.6) else {
            print("Could not convert image to data.")
            return
        }

        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("publicTaskImages/\(UUID().uuidString).jpg")

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
                        self.imageNameLabel.text = "已經成功添加照片！"
                        self.imageNameLabel.textColor = .red
                    }
                }
            }
        }
    }
}

extension PostTaskViewController {
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

extension PostTaskViewController {
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
extension PostTaskViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            let alertMessage = UIAlertController(title: "錄音完成", message: "加油語錄已經儲存!", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertMessage, animated: true, completion: nil)
            uploadAudioToFirebase()
        }
    }
}
extension PostTaskViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.isSelected = false
        resetTimer()
        let alertMessage = UIAlertController(title: "播放完成", message: "如果想重錄，再點一次錄音就好囉！", preferredStyle: .alert)
        alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertMessage, animated: true, completion: nil)
    }
}

//TODO: 建立登入系統後，修改PosterLabel.text "Aaron"
extension PostTaskViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPostPublicTasksImagePreviewVC",
           let nextVC = segue.destination as? PostPublicImageTasksPreviewViewController,
           let taskName = self.taskTitleTextField.text,
           let taskContent = self.taskContentTextView.text,
           let imageURL = self.imageURL,
           let recordingURL = self.recordingURL {
            nextVC.taskName = taskName
            nextVC.taskContent = taskContent
            nextVC.posterName = "Aaron"
            nextVC.imageURL = imageURL
            nextVC.recordingURL = recordingURL
        } else if segue.identifier == "toPostPublicTasksTextPreviewVC",
            let nextVC = segue.destination as? PostPublicTextTasksPreviewViewController,
            let taskName = self.taskTitleTextField.text,
            let taskContent = self.taskContentTextView.text {
            nextVC.taskName = taskName
            nextVC.taskContent = taskContent
            nextVC.posterName = "Aaron"
        }
    }
}

extension PostTaskViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceHolderText {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = textViewPlaceHolderText
            textView.textColor = .lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.isEmpty && range.length > 0 && textView.text == textViewPlaceHolderText {
            textView.text = nil
            textView.textColor = .black
        } else if textView.text.isEmpty && text.isEmpty {
            textView.text = textViewPlaceHolderText
            textView.textColor = .lightGray
        }
        return true
    }
}

extension PostTaskViewController {
    func setupKeyboardClosed() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

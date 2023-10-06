//
//  ReplyTaskViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/26.
//

import UIKit
import AVFAudio
import FirebaseFirestore
import FirebaseStorage
//TODO: 設置任務是否完成的狀態選項功能
class ReplyTaskViewController: UIViewController {
    
    @IBOutlet weak var replyTaskTitleTextField: UITextField!
    @IBOutlet weak var replyTaskTextView: UITextView!
    @IBOutlet weak var replyTaskAddImageButton: UIButton!
    @IBOutlet weak var replyTaskPostButton: UIButton!
    @IBOutlet weak var replyTaskImageMessageLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var storeButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var replyTaskImageView: UIImageView!
    @IBOutlet weak var dailyEncouragementVoiceLabel: UILabel!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer?
    var recordingURL: String?
    var imageURL: String?
    private var timer: Timer?
    private var elapsedTimeInSecond: Int = 0
    let textViewPlaceHolderText = "請輸入好事任務內容:"
    var task: GoodThingTasks?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        replyTaskPostButton.addTarget(self, action: #selector(replyTask), for: .touchUpInside)
        configure()
        
        replyTaskTextView.text = textViewPlaceHolderText
        replyTaskTextView.textColor = .lightGray
        replyTaskTextView.delegate = self
        
        setupKeyboardClosed()
        setUI()
    }
   

    @objc func replyTask() {
        guard let title = replyTaskTitleTextField.text, !title.isEmpty,
              let content =  replyTaskTextView.text, !content.isEmpty else { return }
        guard let taskDocumentID = task?.taskId, !taskDocumentID.isEmpty else {
            print("Error: Task ID is missing!")
            return
        }

        let db = Firestore.firestore()
        let userId = UserDefaults.standard.string(forKey: "userId")
        let taskDocumentRef = db.collection("GoodThingTasks").document(taskDocumentID)
        let responsesCollectionRef = taskDocumentRef.collection("GoodThingTasksResponses")
        let newResponseDocumentRef = responsesCollectionRef.document()
        let id = newResponseDocumentRef.documentID
        let time = Date.dateFormatterWithTime.string(from: Date())
        
        var data: [String: Any] = [
            "taskPosterId": task?.taskCreatorId,
            "completerId": userId,
            "completionStatus": "",
            "responseRecording": recordingURL ?? "",
            "responseImage": imageURL ?? "",
            "responseTitle": title,
            "responseContent": content,
            "checkedStatus": false,
            "responseTime": time,
            "responseId": id
        ]
        
        newResponseDocumentRef.setData(data) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(id)")
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
    
    @IBAction func addReplyTaskImageButtonTapped(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
}

extension ReplyTaskViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            replyTaskImageView.image = selectedImage
            uploadImageToFirebase(selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
extension ReplyTaskViewController {
     func uploadImageToFirebase(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.6) else {
            print("Could not convert image to data.")
            return
        }

        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("taskResponseImages/\(UUID().uuidString).jpg")

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
                        self.replyTaskImageMessageLabel.text = "已經成功添加照片！"
                        self.replyTaskImageMessageLabel.textColor = .red
                    }
                }
            }
        }
    }
}

extension ReplyTaskViewController {
    func uploadAudioToFirebase() {
        //TODO: 建立登入系統後，調整userId
        guard let audioURL = audioRecorder?.url else { return }
        let userId = "Aaron"
        let storageRef = Storage.storage().reference().child("taskResponseAudioFiles/\(userId)_\(audioURL.lastPathComponent)")
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

extension ReplyTaskViewController {
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
extension ReplyTaskViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            let alertMessage = UIAlertController(title: "錄音完成", message: "任務語音回覆已經儲存!", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertMessage, animated: true, completion: nil)
            uploadAudioToFirebase()
        }
    }
}
extension ReplyTaskViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.isSelected = false
        resetTimer()
        let alertMessage = UIAlertController(title: "播放完成", message: "如果想重錄，再點一次錄音就好囉！", preferredStyle: .alert)
        alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertMessage, animated: true, completion: nil)
    }
}
extension ReplyTaskViewController: UITextViewDelegate {
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
extension ReplyTaskViewController {
    func setupKeyboardClosed() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
extension ReplyTaskViewController {
    
    func setUI() {
        playButton.setTitle("", for: .normal)
        recordButton.setTitle("", for: .normal)
        storeButton.setTitle("", for: .normal)
        replyTaskAddImageButton.setTitle("", for: .normal)
        timeLabel.layer.cornerRadius = 10
        timeLabel.layer.borderWidth = 0.4
        replyTaskImageView.layer.cornerRadius = 20
        replyTaskPostButton.layer.borderWidth = 0.6
        replyTaskPostButton.layer.borderColor = UIColor.systemBrown.cgColor
        replyTaskPostButton.layer.cornerRadius = 10
        replyTaskTextView.layer.cornerRadius = 10
        replyTaskTextView.layer.borderWidth = 0.4
        dailyEncouragementVoiceLabel.layer.cornerRadius = 10
    }
}

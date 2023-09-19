//
//  ViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/14.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import AVFoundation

class PostTaskViewController: UIViewController {

    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var taskContentTextView: UITextView!
    @IBOutlet weak var postPrivateTaskButton: UIButton!
    @IBOutlet weak var postPublicTaskButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet private var timeLabel: UILabel!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer?
    var recordURL: String?
    private var timer: Timer?
    private var elapsedTimeInSecond: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postPrivateTaskButton.addTarget(self, action: #selector(postPrivateTask), for: .touchUpInside)
        postPublicTaskButton.addTarget(self, action: #selector(postPublicTask), for: .touchUpInside)
        
        configure()
    }
    
    @objc func postPrivateTask() {
        postTask(privacy: false)
    }
    @objc func postPublicTask() {
        postTask()
    }
    func postTask(privacy privacyStatus: Bool = true) {
        guard let title = taskTitleTextField.text, !title.isEmpty,
              let content = taskContentTextView.text, !content.isEmpty else { return }
        let db = Firestore.firestore()
        let document = db.collection("GoodThingTasks").document()
        let id = document.documentID
        let time = Date.dateFormatter.string(from: Date())
        var data: [String: Any] = [
            "taskID": id,
            "taskTitle": title,
            "taskContent": content,
            "taskImage": "",
            "taskCreatorID": "Aaron",
            "privacyStatus": privacyStatus,
            "taskCreatedTime": time
        ]
        if let recordURL = recordURL {
            data["taskVoice"] = recordURL
        }
        
        db.collection("GoodThingTasks").document(id).setData(data) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(id)")
            }
        }
    }
    
    @IBAction func stop(sender: UIButton) {
        recordButton.setImage(UIImage(named: "Record"), for: UIControl.State.normal)
        recordButton.isEnabled = true
        stopButton.isEnabled = false
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
        if !audioRecorder.isRecording {
            guard let player = try? AVAudioPlayer(contentsOf: audioRecorder.url) else {
                print("Failed to initialize AVAudioPlayer")
                return
            }
            audioPlayer = player
            audioPlayer?.delegate = self
            audioPlayer?.play()
            startTimer()
        }
    }

    @IBAction func record(sender: UIButton) {
        
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
        
        stopButton.isEnabled = true
        playButton.isEnabled = false
    }
    
    private func configure() {
        
        stopButton.isEnabled = false
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

extension PostTaskViewController {
    func uploadAudioToFirebase() {
        //TODO: 建立登入系統後，調整userId
        guard let audioURL = audioRecorder?.url else { return }
        
        let userId = "Aaron"
        
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
                self.recordURL = downloadURL.absoluteString
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

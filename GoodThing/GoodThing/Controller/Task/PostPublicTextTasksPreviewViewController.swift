//
//  PostPublicTasksTextPreviewViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/25.
//

import UIKit
import AVFAudio
class PostPublicTextTasksPreviewViewController: UIViewController, AVAudioPlayerDelegate {
    @IBOutlet weak var previewPublicTextTaskPosterLabel: UILabel!
    @IBOutlet weak var previewPublicTextTaskNameLabel: UILabel!
    @IBOutlet weak var previewPublicTextTaskContentLabel: UILabel!
    @IBOutlet weak var previewPublicTextTaskRecordLabel: UILabel!
    @IBOutlet weak var previewPublicTextTaskPlayButton: UIButton!
    var taskName: String?
    var taskContent: String?
    var posterName: String?
    var recordingURL: String?
    var audioPlayer: AVAudioPlayer?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let taskName = taskName, let taskContent = taskContent, let posterName = posterName {
            self.previewPublicTextTaskNameLabel.text = taskName
            self.previewPublicTextTaskContentLabel.text = taskContent
            self.previewPublicTextTaskPosterLabel.text = posterName
        }
        
        if let audioURL = recordingURL {
            MediaDownloader.shared.downloadAudio(from: audioURL) { [weak self] url in
                if let url = url {
                    self?.setupAudioPlayer(with: url)
                }
            }
        }
    }
    
    func setupAudioPlayer(with url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Audio Player Error: \(error.localizedDescription)")
        }
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        audioPlayer?.delegate = self
        audioPlayer?.play()
    }
}

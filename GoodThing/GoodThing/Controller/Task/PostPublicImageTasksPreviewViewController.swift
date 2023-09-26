//
//  PostPublicTasksImagePreviewViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/25.
//

import UIKit
import AVFAudio

class PostPublicImageTasksPreviewViewController: UIViewController, AVAudioPlayerDelegate {
    @IBOutlet weak var previewPublicImageTaskPosterLabel: UILabel!
    @IBOutlet weak var previewPublicImageTaskImageView: UIImageView!
    @IBOutlet weak var previewPublicImageTaskNameLabel: UILabel!
    @IBOutlet weak var previewPublicImageTaskContentLabel: UILabel!
    @IBOutlet weak var previewPublicImageTaskRecordLabel: UILabel!
    @IBOutlet weak var previewPublicImageTaskPlayButton: UIButton!
    var taskName: String?
    var taskContent: String?
    var posterName: String?
    var imageURL: String?
    var recordingURL: String?
    var audioPlayer: AVAudioPlayer?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let taskName = taskName, let taskContent = taskContent, let posterName = posterName {
            self.previewPublicImageTaskNameLabel.text = taskName
            self.previewPublicImageTaskContentLabel.text = taskContent
            self.previewPublicImageTaskPosterLabel.text = posterName
        }
        
        if let imageURL = imageURL {
            MediaDownloader.shared.downloadImage(from: imageURL) { [weak self] image in
                self?.previewPublicImageTaskImageView.image = image
            }
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

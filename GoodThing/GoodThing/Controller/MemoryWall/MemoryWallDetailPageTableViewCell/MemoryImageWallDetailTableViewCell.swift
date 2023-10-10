//
//  MemoryImageWallDetailTableViewCell.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/22.
//

import UIKit
import AVFAudio

class MemoryImageWallDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var memoryImageWallDetailPageArticleNameLabel: UILabel!
    @IBOutlet weak var memoryImageWallDetailPagePosterNameButton: UIButton!
    @IBOutlet weak var memoryImageWallDetailPageArticleCreatedTimeLabel: UILabel!
    @IBOutlet weak var memoryImageWallDetailPageArticleImageView: UIImageView!
    @IBOutlet weak var memoryImageWallDetailPageArticleContentLabel: UILabel!
    @IBOutlet weak var memoryWallDetailPagePlayLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    var audioPlayer: AVAudioPlayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        playButton.addTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}

extension MemoryImageWallDetailTableViewCell: AVAudioPlayerDelegate {
    func setupAudioPlayer(with url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
        } catch {
            print("Audio Player Error: \(error.localizedDescription)")
        }
    }

    @objc func didTapPlayButton() {
        print("MemoryWallDeatilPagePlayButtonTapped")
        audioPlayer?.play()
    }
}

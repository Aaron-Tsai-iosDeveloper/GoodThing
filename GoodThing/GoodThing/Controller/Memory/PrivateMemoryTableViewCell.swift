//
//  PrivateMemoryTableViewCell.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/18.
//

import UIKit
import AVFAudio

class PrivateMemoryTableViewCell: UITableViewCell {

    @IBOutlet weak var privateMemoryTitleLabel: UILabel!
    @IBOutlet weak var privateMemoryCreatedTimeLabel: UILabel!
    @IBOutlet weak var privateMemoryContentLabel: UILabel!
    @IBOutlet weak var privateMemoryImage: UIImageView!
    
    //TODO: fetchMemoryRecoding
    @IBOutlet weak var playButton: UIButton!
    var audioPlayer: AVAudioPlayer?
    
    var deletePrivateMemory: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        playButton.addTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func privateDeleteButtonTapped(_ sender: UIButton) {
        deletePrivateMemory?()
    }
}
extension PrivateMemoryTableViewCell: AVAudioPlayerDelegate {
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
        audioPlayer?.play()
    }
}

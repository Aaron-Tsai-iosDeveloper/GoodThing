//
//  PairingTaskCollectionViewCell.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/26.
//

    import UIKit
    import AVFAudio

    class PairingTaskCollectionViewCell: UICollectionViewCell, AVAudioPlayerDelegate {
        
            let usernameButton: UIButton = {
                let button = UIButton(type: .system)
                button.setTitle("用戶名稱", for: .normal)
                button.translatesAutoresizingMaskIntoConstraints = false
                return button
            }()
            let taskImageView: UIImageView = {
                let imageView = UIImageView()
                imageView.image = UIImage(named: "placeholder")
                imageView.contentMode = .scaleAspectFit
                imageView.translatesAutoresizingMaskIntoConstraints = false
                return imageView
            }()
            
            let taskTitleLabel: UILabel = {
                let label = UILabel()
                label.text = "任務標題"
                label.translatesAutoresizingMaskIntoConstraints = false
                return label
            }()
            
            let taskContentLabel: UILabel = {
                let label = UILabel()
                label.text = "任務內容"
                label.numberOfLines = 0
                label.translatesAutoresizingMaskIntoConstraints = false
                return label
            }()
            let encouragementLabel: UILabel = {
                let label = UILabel()
                label.text = "任務加油金句"
                label.translatesAutoresizingMaskIntoConstraints = false
                return label
            }()
            let playButton: UIButton = {
                let button = UIButton(type: .system)
                button.setTitle("播放", for: .normal)
                button.translatesAutoresizingMaskIntoConstraints = false
                return button
            }()
            let postButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("添加好事任務", for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
            }()
            let replyButton: UIButton = {
                let button = UIButton(type: .system)
                button.setTitle("回覆今日好事任務", for: .normal)
                button.translatesAutoresizingMaskIntoConstraints = false
                return button
            }()
            let recieveButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("接收任務回覆", for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
            }()
        
            var onPostButtonTapped: (() -> Void)?
            var onReplyButtonTapped: (() -> Void)?
            var onReceiveButtonTapped: (() -> Void)?
            var audioPlayer: AVAudioPlayer?

            override init(frame: CGRect) {
                super.init(frame: frame)
                setupUI()
               postButton.addTarget(self, action: #selector(didTapPostButton), for: .touchUpInside)
               replyButton.addTarget(self, action: #selector(didTapReplyButton), for: .touchUpInside)
               recieveButton.addTarget(self, action: #selector(didTapReceiveButton), for: .touchUpInside)
               playButton.addTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
            }
        
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
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            @objc private func didTapPostButton() {
                onPostButtonTapped?()
            }
            @objc private func didTapReplyButton() {
                onReplyButtonTapped?()
            }
            @objc private func didTapReceiveButton() {
                onReceiveButtonTapped?()
            }
        private func setupUI() {
            let verticalStackView = UIStackView(arrangedSubviews: [usernameButton, taskImageView, taskTitleLabel, taskContentLabel])
            verticalStackView.axis = .vertical
            verticalStackView.alignment = .leading
            verticalStackView.spacing = 10
            let horizontalStackView = UIStackView(arrangedSubviews: [encouragementLabel, playButton])
            horizontalStackView.axis = .horizontal
            horizontalStackView.spacing = 10
            verticalStackView.addArrangedSubview(horizontalStackView)
            verticalStackView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(verticalStackView)
            addSubview(postButton)
            addSubview(replyButton)
            addSubview(recieveButton)
            NSLayoutConstraint.activate([
                verticalStackView.topAnchor.constraint(equalTo: topAnchor),
                verticalStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                verticalStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                postButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -70),
                postButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60),
                postButton.widthAnchor.constraint(equalToConstant: 100),
                postButton.heightAnchor.constraint(equalToConstant: 100),
                replyButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -140),
                replyButton.centerXAnchor.constraint(equalTo: centerXAnchor),
                replyButton.widthAnchor.constraint(equalToConstant: 150),
                replyButton.heightAnchor.constraint(equalToConstant: 90),
                recieveButton.centerYAnchor.constraint(equalTo: postButton.centerYAnchor),
                recieveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
                recieveButton.widthAnchor.constraint(equalToConstant: 150),
                recieveButton.heightAnchor.constraint(equalToConstant: 50),
                taskContentLabel.leadingAnchor.constraint(equalTo: verticalStackView.leadingAnchor, constant: 30),
                taskTitleLabel.leadingAnchor.constraint(equalTo: verticalStackView.leadingAnchor, constant: 30),
                encouragementLabel.leadingAnchor.constraint(equalTo: verticalStackView.leadingAnchor, constant: 30),
                playButton.trailingAnchor.constraint(equalTo: verticalStackView.trailingAnchor, constant: -30),
            ])
            taskImageView.isHidden = true
        }

    }

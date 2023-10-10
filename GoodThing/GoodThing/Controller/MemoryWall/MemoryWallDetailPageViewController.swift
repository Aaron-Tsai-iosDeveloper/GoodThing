//
//  GoodThingMemoryWallDetailPageViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/22.
//

import UIKit
import FirebaseFirestore

class MemoryWallDetailPageViewController: UIViewController {
    
    @IBOutlet weak var memoryWallDetailPageTableView: UITableView!
    @IBOutlet weak var memoryWallDetailPageMessageButton: UIButton!
    
    var selectedMemory: GoodThingMemory?
    var posterName: String?
    var articleComments = [GoodThingComment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memoryWallDetailPageTableView.dataSource = self
        memoryWallDetailPageTableView.delegate = self
        memoryWallDetailPageTableView.estimatedRowHeight = 44
        memoryWallDetailPageTableView.rowHeight = UITableView.automaticDimension
        fetchComments() {
            self.memoryWallDetailPageTableView.reloadData()
        }
        listenForMemoryCommentsUpdates()
    }
    @IBAction func didTapDetailPageMessageButton(_ sender: Any) {
        presentCommentViewController()
    }
    private func presentCommentViewController() {
        let commentViewController = CommentViewController()
        commentViewController.modalPresentationStyle = .custom
        commentViewController.transitioningDelegate = self
        commentViewController.dismissClosure = { [weak commentViewController] in
            commentViewController?.dismiss(animated: true, completion: nil)
        }
        commentViewController.selectedMemory = self.selectedMemory
        present(commentViewController, animated: true, completion: nil)
    }
}

extension MemoryWallDetailPageViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension MemoryWallDetailPageViewController {
    func fetchComments(completion: @escaping () -> Void) {
        guard let memoryId = selectedMemory?.memoryID else { return }
        let db = Firestore.firestore()
        var query: Query = db.collection("GoodThingMemory").document(memoryId).collection("MemoryComments").order(by: "commentCreatedTime", descending: false)
        
        query.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("error about fetchComments : \(error) ")
            } else {
                self.articleComments.removeAll()
                for document in querySnapshot!.documents {
                    do {
                        let comment = try document.data(as: GoodThingComment.self, decoder: Firestore.Decoder())
                        self.articleComments.append(comment)
                    } catch let error {
                        print("fetchComments decoding error: \(error)")
                    }
                }
                print("successfully fethchComments:\(self.articleComments)")
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
}

extension MemoryWallDetailPageViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return articleComments.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if selectedMemory?.memoryImage != "" {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoryImageWallDetailTableViewCell", for: indexPath) as? MemoryImageWallDetailTableViewCell else { return UITableViewCell() }
                cell.memoryImageWallDetailPageArticleContentLabel.text = selectedMemory?.memoryContent
                cell.memoryImageWallDetailPageArticleCreatedTimeLabel.text = selectedMemory?.memoryCreatedTime
                cell.memoryImageWallDetailPageArticleNameLabel.text = selectedMemory?.memoryTitle
                cell.memoryImageWallDetailPagePosterNameButton.setTitle(posterName, for: .normal)
                if let imageUrlString = selectedMemory?.memoryImage, !imageUrlString.isEmpty {
                    cell.memoryImageWallDetailPageArticleImageView.isHidden = false
                    cell.imageViewHeightConstraint.constant = 140
                } else {
                    cell.memoryImageWallDetailPageArticleImageView.isHidden = true
                    cell.imageViewHeightConstraint.constant = 0
                }
                if let audioURL = selectedMemory?.memoryVoice {
                    MediaDownloader.shared.downloadAudio(from: audioURL) { url in
                        if let url = url {
                            cell.setupAudioPlayer(with: url)
                        }
                    }
                }
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoryTextWallDetailTableViewCell", for: indexPath) as? MemoryTextWallDetailTableViewCell else { return UITableViewCell() }
                cell.memoryTextWallDetailPageArticleContentLabel.text = selectedMemory?.memoryContent
                cell.memoryTextWallDetailPageArticleCreatedTimeLabel.text = selectedMemory?.memoryCreatedTime
                cell.memoryTextWallDetailPageArticleNameLabel.text = selectedMemory?.memoryTitle
                cell.memoryTextWallDetailPagePosterButton.setTitle(posterName, for: .normal)
                return cell
            }
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoryCommentTableViewCell", for: indexPath) as? MemoryCommentTableViewCell else { return UITableViewCell() }
            let commenter = articleComments[indexPath.row].commentCreatorId
            let cotent = articleComments[indexPath.row].commentContent
            let createdTime = articleComments[indexPath.row].commentCreatedTime
            cell.memoryWallDetailPageRowNumberLabel.text = "B\(indexPath.row + 1)"
            cell.memoryWallDetailPageCommenterButton.setTitle(commenter, for: .normal)
            cell.memoryWallDetailPageCommentContentLabel.text = cotent
            cell.memoryWallDetailPageCommentCreatedTimeLabel.text = createdTime
            return cell
        //TODO: 未來優化添加 按讚收藏和留言排序
//        case 2:
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoryTapLikeTableViewCell", for: indexPath) as?  MemoryTapLikeTableViewCell else { return UITableViewCell() }
//            cell.memoryWallDetailPageCollectionButton.setTitle("", for: .normal)
//            cell.memoryWallDetailPageShareButton.setTitle("", for: .normal)
//            cell.memoryWallDetailPageTapLikeButton.setTitle("", for: .normal)
//            return cell
//        case 3:
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoryWallDetailSortTableViewCell", for: indexPath) as? MemoryWallDetailSortTableViewCell else { return UITableViewCell() }
//            return cell
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 {
            return 0
        }
        if indexPath.row == 1 {
            return 0
        }
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "好事多"
        case 1:
            return "好留言"
        default:
            return nil
        }
    }


}
extension MemoryWallDetailPageViewController {
    func listenForMemoryCommentsUpdates() {
        guard let memoryId = selectedMemory?.memoryID else { return }
        let db = Firestore.firestore()
        db.collection("GoodThingMemory").document(memoryId).collection("MemoryComments").addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error fetching updates: \(error)")
                return
            }
            
            var newMemoryComments: [GoodThingComment] = []
            
            for documentChange in snapshot!.documentChanges {
                switch documentChange.type {
                case .added:
                    do {
                        let newMemoryComment = try Firestore.Decoder().decode(GoodThingComment.self, from: documentChange.document.data())
                        newMemoryComments.append(newMemoryComment)
                    } catch let error {
                        print("Decoding error: \(error)")
                    }

                default:
                    break
                }
            }
            
            if !newMemoryComments.isEmpty {
                self.articleComments.append(contentsOf: newMemoryComments)
                
                self.articleComments.sort(by: { $0.commentCreatedTime < $1.commentCreatedTime })
                
                DispatchQueue.main.async {
                    self.memoryWallDetailPageTableView.reloadData()
                }
            }
        }
    }
}

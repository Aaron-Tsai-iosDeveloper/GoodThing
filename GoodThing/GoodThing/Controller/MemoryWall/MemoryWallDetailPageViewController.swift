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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 + articleComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            if selectedMemory?.memoryImage != "" {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoryImageWallDetailTableViewCell", for: indexPath) as? MemoryImageWallDetailTableViewCell else { return UITableViewCell() }
                cell.memoryImageWallDetailPageArticleContentLabel.text = selectedMemory?.memoryContent
                cell.memoryImageWallDetailPageArticleCreatedTimeLabel.text = selectedMemory?.memoryCreatedTime
                cell.memoryImageWallDetailPageArticleNameLabel.text = selectedMemory?.memoryTitle
                cell.memoryImageWallDetailPagePosterNameButton.setTitle(selectedMemory?.memoryCreatorID, for: .normal)
                
                let imageUrlString = selectedMemory?.memoryImage ?? ""
                MediaDownloader.shared.downloadImage(from: imageUrlString) { (image) in
                    cell.memoryImageWallDetailPageArticleImageView.image = image
                }
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoryTextWallDetailTableViewCell", for: indexPath) as? MemoryTextWallDetailTableViewCell else { return UITableViewCell() }
                cell.memoryTextWallDetailPageArticleContentLabel.text = selectedMemory?.memoryContent
                cell.memoryTextWallDetailPageArticleCreatedTimeLabel.text = selectedMemory?.memoryCreatedTime
                cell.memoryTextWallDetailPageArticleNameLabel.text = selectedMemory?.memoryTitle
                cell.memoryTextWallDetailPagePosterButton.setTitle(selectedMemory?.memoryCreatorID, for: .normal)
                return cell
            }
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoryTapLikeTableViewCell", for: indexPath) as?  MemoryTapLikeTableViewCell else { return UITableViewCell() }
            cell.memoryWallDetailPageCollectionButton.setTitle("", for: .normal)
            cell.memoryWallDetailPageShareButton.setTitle("", for: .normal)
            cell.memoryWallDetailPageTapLikeButton.setTitle("", for: .normal)
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoryWallDetailSortTableViewCell", for: indexPath) as? MemoryWallDetailSortTableViewCell else { return UITableViewCell() }
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoryCommentTableViewCell", for: indexPath) as? MemoryCommentTableViewCell else { return UITableViewCell() }
            let rowNumber = indexPath.row - 2
            let commenter = articleComments[rowNumber - 1].commentCreatorId
            let cotent = articleComments[rowNumber - 1].commentContent
            let createdTime = articleComments[rowNumber - 1].commentCreatedTime
            cell.memoryWallDetailPageRowNumberLabel.text = "B\(rowNumber)"
            cell.memoryWallDetailPageCommenterButton.setTitle(commenter, for: .normal)
            cell.memoryWallDetailPageCommentContentLabel.text = cotent
            cell.memoryWallDetailPageCommentCreatedTimeLabel.text = createdTime
            return cell
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

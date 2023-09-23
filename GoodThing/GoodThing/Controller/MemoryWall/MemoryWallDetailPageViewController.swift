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
        fetchComments() { self.memoryWallDetailPageTableView.reloadData() }
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
        print(memoryId)
        let db = Firestore.firestore()
        var query: Query = db.collection("GoodThingMemory").document(memoryId).collection("MemoryComments").order(by: "commentCreatedTime", descending: true)
        
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

//extension MemoryWallDetailPageViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//       
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        <#code#>
//    }
//    
//    
//}

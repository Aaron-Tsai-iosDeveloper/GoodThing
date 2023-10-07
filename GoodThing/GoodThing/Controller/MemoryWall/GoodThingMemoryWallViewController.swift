//
//  GoodThingMemoryWallViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/21.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift

class GoodThingMemoryWallViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var memoryWallTableView: UITableView!
    var db = Firestore.firestore()
    var publicMemory = [GoodThingMemory]()
    
    
    var lastFeedbackTime: Date? = nil
    let feedbackInterval: TimeInterval = 0.5
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memoryWallTableView.dataSource = self
        memoryWallTableView.delegate = self
        fetchMemory(withPrivateStatus: false) {
            self.memoryWallTableView.reloadData()
        }
        listenForMemoryWallUpdates()
        memoryWallTableView.decelerationRate = .fast
        addFooterViewWithText()
        setupKeyboardClosed()
    }
    
    
    func fetchMemory(byCreatorID creatorID: String? = nil, withPrivateStatus isPrivate: Bool? = nil, completion: @escaping () -> Void) {
        var query: Query = db.collection("GoodThingMemory").order(by: "memoryCreatedTime", descending: true)
        if let creatorID = creatorID {
            query = query.whereField("memoryCreatorID", isEqualTo: creatorID)
        }
        if let isPrivate = isPrivate {
            query = query.whereField("memoryPrivacyStatus", isEqualTo: isPrivate)
        }
        query.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("error about fetchmemory : \(error) ")
            } else {
                self.publicMemory.removeAll()
                for document in querySnapshot!.documents {
                    print("Document data:\(document.data())")
                    do {
                        let newMemory = try document.data(as: GoodThingMemory.self, decoder: Firestore.Decoder())
                            self.publicMemory.append(newMemory)
                    } catch let error {
                        print("fetchmemory decoding error: \(error)")
                    }
                }
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
}

extension GoodThingMemoryWallViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        publicMemory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if publicMemory[indexPath.row].memoryImage != "" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoryImageWallTableViewCell", for: indexPath) as? MemoryImageWallTableViewCell else { return UITableViewCell() }
            let memory = publicMemory[indexPath.row]
            cell.memoryWallArticleNameLabel.text = "文章：\(memory.memoryTitle)"
            cell.memoryWallPosterNameLabel.text = "筆名：\(memory.memoryCreatorID)"
            cell.memoryWallArticleContentLabel.text = (memory.memoryContent)
            cell.memoryWallArticleCreatedTimeLabel.text = (memory.memoryCreatedTime)
            let imageUrlString = memory.memoryImage ?? ""
            MediaDownloader.shared.downloadImage(from: imageUrlString) { (image) in
                cell.memoryWallArticleImageView.image = image
            }
            cell.memoryTags = (memory.memoryTag ?? []).map { "  \( $0 )  " }
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoryTextWallTableViewCell", for: indexPath) as? MemoryTextWallTableViewCell else { return UITableViewCell() }
            cell.memoryWallPosterNameLabel.text = "筆名：\(publicMemory[indexPath.row].memoryID)"
            cell.memoryWallArticleNameLabel.text = "文章：\(publicMemory[indexPath.row].memoryTitle)"
            cell.memoryWallArticleCreatedTimeLabel.text = publicMemory[indexPath.row].memoryCreatedTime
            cell.memoryWallArticleContentLabel.text = publicMemory[indexPath.row].memoryContent
            
            return cell
        }
    }
}
extension GoodThingMemoryWallViewController {
    func listenForMemoryWallUpdates() {
        db.collection("GoodThingMemory").addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error fetching updates: \(error)")
                return
            }
            
            var newMemories: [GoodThingMemory] = []
            
            for documentChange in snapshot!.documentChanges {
                switch documentChange.type {
                case .added:
                    do {
                        let newMemory = try Firestore.Decoder().decode(GoodThingMemory.self, from: documentChange.document.data())
                        newMemories.append(newMemory)
                    } catch let error {
                        print("Decoding error: \(error)")
                    }

                default:
                    break
                }
            }
            
            if !newMemories.isEmpty {
                self.publicMemory.append(contentsOf: newMemories)
                
                self.publicMemory.sort(by: { $0.memoryCreatedTime > $1.memoryCreatedTime })
                
                DispatchQueue.main.async {
                    self.memoryWallTableView.reloadData()
                }
            }
        }
    }
}

extension GoodThingMemoryWallViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toMemoryWallDetailPage", sender: publicMemory[indexPath.row])
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMemoryWallDetailPage",
           let nextVC = segue.destination as? MemoryWallDetailPageViewController,
           let selectedMemory = sender as? GoodThingMemory {
            nextVC.selectedMemory = selectedMemory
        }
    }
}

extension GoodThingMemoryWallViewController {
    func adjustOpacityForCell(_ cell: UITableViewCell) {
            let cellTopInWindow = memoryWallTableView.convert(cell.frame.origin, to: nil).y
            let cellBottomInWindow = memoryWallTableView.convert(CGPoint(x: cell.frame.origin.x, y: cell.frame.maxY), to: nil).y
            let screenCenter = UIScreen.main.bounds.height / 2
            
            if cellTopInWindow < screenCenter && cellBottomInWindow > screenCenter {
                UIView.animate(withDuration: 0.5) {
                    cell.contentView.alpha = 1.0
                    cell.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
                }
            } else {
                UIView.animate(withDuration: 0.5) {
                    cell.contentView.alpha = 0.3
                    cell.transform = CGAffineTransform.identity
                }
            }
        }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let cellHeight: CGFloat = 385
        let screenCenter = UIScreen.main.bounds.height / 2
        
        let currentOffset = scrollView.contentOffset.y
        let targetOffset = targetContentOffset.pointee.y
        let movingDownward = targetOffset > currentOffset

        var index: CGFloat = 0
        
        if movingDownward {
            index = ceil((targetOffset + screenCenter) / cellHeight)
        } else {
            index = floor((targetOffset + screenCenter) / cellHeight)
        }
        
        targetContentOffset.pointee.y = index * cellHeight - screenCenter
    }



    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleCells = memoryWallTableView.visibleCells
        for cell in visibleCells {
            adjustOpacityForCell(cell)
        }

        let currentTime = Date()
        if lastFeedbackTime == nil || currentTime.timeIntervalSince(lastFeedbackTime!) > feedbackInterval {
            feedbackGenerator.impactOccurred()
            feedbackGenerator.prepare()
            lastFeedbackTime = currentTime
        }
    }



    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        adjustOpacityForCell(cell)
    }

}
extension UITableView {
    var indexPathForLastRow: IndexPath? {
        return indexPathForLastRow(inSection: numberOfSections - 1)
    }

    func indexPathForLastRow(inSection section: Int) -> IndexPath? {
        guard section < numberOfSections else { return nil }
        guard numberOfRows(inSection: section) > 0 else { return nil }
        return IndexPath(row: numberOfRows(inSection: section) - 1, section: section)
    }
}
extension GoodThingMemoryWallViewController {
    func addFooterViewWithText() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: memoryWallTableView.bounds.width, height: UIScreen.main.bounds.height/4))
        footerView.backgroundColor = .clear
        
        let label = UILabel()
        label.text = "讓我們期待明天有更多好心情！"
        label.textAlignment = .center
        label.textColor = .gray
        label.frame = footerView.bounds
        
        footerView.addSubview(label)
        
        memoryWallTableView.tableFooterView = footerView
    }
}

extension GoodThingMemoryWallViewController {
    func setupKeyboardClosed() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

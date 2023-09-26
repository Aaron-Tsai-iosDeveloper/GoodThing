//
//  FetchGroupViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/18.
//

import UIKit
import FirebaseFirestore

class FetchGroupViewController: UIViewController {
    
    @IBOutlet weak var groupsTableView: UITableView!
    
    lazy var db = Firestore.firestore()
    var groups = [GoodThingGroup]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupsTableView.dataSource = self
        groupsTableView.delegate = self
        fetchGroups() { self.groupsTableView.reloadData() }
        listenForGroupsUpdates()
        
    }
    
    func fetchGroups(completion: @escaping () -> Void) {
        var query: Query = db.collection("GoodThingGroup").order(by: "createdTime", descending: true)
        
        query.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("error about fetchgroups : \(error) ")
            } else {
                self.groups.removeAll()
                for document in querySnapshot!.documents {
                    do {
                        let group = try document.data(as: GoodThingGroup.self, decoder: Firestore.Decoder())
                        self.groups.append(group)
                    } catch let error {
                        print("fetchgroups decoding error: \(error)")
                    }
                }
                print("successfully fethchgroups:\(self.groups)")
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
}

extension FetchGroupViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupsTableViewCell", for: indexPath) as? GroupsTableViewCell else { return UITableViewCell() }
        cell.groupNameLabel.text = "名稱： \(groups[indexPath.row].groupName)"
        cell.groupTimeLabel.text = "時間： \(groups[indexPath.row].groupTime)"
        cell.groupLocationLabel.text = "地點： \(groups[indexPath.row].groupLocation)"
        cell.peopleNumberLimitLabel.text = "滿團上限： \(groups[indexPath.row].peopleNumberLimit)"
        cell.currentPeopleNumberLabel.text = "當前人數： \(groups[indexPath.row].currentPeopleNumber)"
        
        cell.selectionStyle = .none

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedGroup = groups[indexPath.row]
        performSegue(withIdentifier: "ToDetailGroupVC", sender: selectedGroup)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? DetailGroupViewController,
           let selectedGroup = sender as? GoodThingGroup {
            destinationVC.groupDetailInfo = selectedGroup
        }
    }
}
extension FetchGroupViewController {
    func listenForGroupsUpdates() {
        db.collection("GoodThingGroup").addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Error fetching updates: \(error)")
                return
            }
            
            var newGroups: [GoodThingGroup] = []
            
            for documentChange in snapshot!.documentChanges {
                switch documentChange.type {
                case .added:
                    do {
                        let newGroup = try Firestore.Decoder().decode(GoodThingGroup.self, from: documentChange.document.data())
                        newGroups.append(newGroup)
                    } catch let error {
                        print("Decoding error: \(error)")
                    }

                default:
                    break
                }
            }
            
            if !newGroups.isEmpty {
                self.groups.append(contentsOf: newGroups)
                
                self.groups.sort(by: { $0.createdTime > $1.createdTime })
                
                DispatchQueue.main.async {
                    self.groupsTableView.reloadData()
                }
            }
        }
    }
}

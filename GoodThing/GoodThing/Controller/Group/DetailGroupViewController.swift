//
//  DetailGroupViewController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/18.
//

import UIKit
import FirebaseFirestore

class DetailGroupViewController: UIViewController {
    var groupDetailInfo: GoodThingGroup?
    @IBOutlet weak var detailGroupTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        detailGroupTableView.dataSource = self
        detailGroupTableView.delegate = self
    }
}

extension DetailGroupViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailGroupTableViewCell", for: indexPath) as? DetailGroupTableViewCell else { return UITableViewCell() }
        let groupID = groupDetailInfo?.groupID ?? ""
        let groupName = groupDetailInfo?.groupName ?? ""
        let groupTime = groupDetailInfo?.groupTime ?? ""
        let groupLocation = groupDetailInfo?.groupLocation ?? ""
        let groupContent = groupDetailInfo?.groupContent ?? ""
        let organizerID = groupDetailInfo?.organizerID ?? ""
        let deadLine = groupDetailInfo?.deadLine ?? ""
        let peopleNumberLimit = groupDetailInfo?.peopleNumberLimit ?? 0
        let currentPeopleNumber = groupDetailInfo?.currentPeopleNumber ?? 0
        let createdTime = groupDetailInfo?.createdTime ?? ""
        cell.detailGroupIDLabel.text = "揪團ID:\(groupID)"
        cell.detailGroupNameLabel.text = "好事揪團：\(groupName)"
        cell.detailGroupTimeLabel.text = "時間：\(groupTime)"
        cell.detailGroupLocationLabel.text = "地點：\(groupLocation)"
        cell.detailGroupContentLabel.text = "揪團內容：\(groupContent)"
        cell.detailGroupOrganizerIDLabel.text = "主揪ID：\(organizerID)"
        cell.detailGroupDeadLineLabel.text = "報名截止：\(deadLine)"
        cell.detailGroupPeopleNumberLimitLabel.text = "人數上限：\(peopleNumberLimit)"
        cell.detailGroupCurrentPeopleNumberLabel.text = "目前人數：\(currentPeopleNumber)"
        cell.detailGroupCreatedTimeLabel.text = "創建時間：\(createdTime)"
        cell.joinButtonAction = {
            self.modifyCurrentPeopleNumber()
        }
        return cell
    }
    //TODO: 登入系統建置後，移除userId預設值Aaron
    func modifyCurrentPeopleNumber(userId: String = "Aaron") {
        let db = Firestore.firestore()
        let id = groupDetailInfo?.groupID ?? ""
        let documentReference =
        db.collection("GoodThingGroup").document("\(id)")
        documentReference.getDocument { document, error in
            guard let document,
                  document.exists,
                  var group = try? document.data(as: GoodThingGroup.self)
            else {
                return
            }
            if !group.participants.contains(userId) && group.currentPeopleNumber < group.peopleNumberLimit {
                group.currentPeopleNumber += 1
                group.participants.append(userId)
                print("加入揪團成功！")
            } else if group.participants.contains(userId) {
                print("您已經加入此揪團！")
            } else {
                print("揪團人數已達上限")
                return
            }
            do {
                try documentReference.setData(from: group)
            } catch {
                print(error)
            }
        }
    }
}

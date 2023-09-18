//
//  GroupModel.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/18.
//

import Foundation

struct GoodThingGroup: Codable {
    var groupID: String
    var groupTime: String
    var groupName: String
    var groupContent: String
    var groupLocation: String
    var organizerID: String
    var createdTime: String
    var deadLine: String
    var peopleNumberLimit: Int
    var currentPeopleNumber: Int
    var participants: [String]
}

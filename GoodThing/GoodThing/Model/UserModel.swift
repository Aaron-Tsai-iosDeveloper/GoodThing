//
//  GoodThingUser.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/19.
//

import Foundation

struct GoodThingUser: Codable {
    var userId: String
    var userName: String
    var birthday: String
    var registrationTime: String
    var introduction: String
    var favoriteSentence: String
    var latestPublishedTaskId: String
    var groupsList: [String]
    var goodSentences: [String]
    var friends: [String]
    var articlesCollection: [String]
    var postedTasksList: [String]
    var postedMemoryList: [String]
}

struct GoodThingLetter: Codable {
    var sender: String
    var receiver: String
    var title: String
    var content: String
    var createdTime: String
    
    enum CodingKeys: String, CodingKey {
        case sender = "user1"
        case receiver = "user2"
        case title, content, createdTime
    }
}

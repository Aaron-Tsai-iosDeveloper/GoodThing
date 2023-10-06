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

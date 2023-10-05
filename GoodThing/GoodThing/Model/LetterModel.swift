//
//  LetterModel.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/10/5.
//

import Foundation

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

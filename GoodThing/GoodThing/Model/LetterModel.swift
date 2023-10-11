//
//  LetterModel.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/10/5.
//

import Foundation

struct GoodThingLetter: Codable {
    var senderId: String
    var receiverId: String
    var title: String
    var content: String
    var createdTime: String
}

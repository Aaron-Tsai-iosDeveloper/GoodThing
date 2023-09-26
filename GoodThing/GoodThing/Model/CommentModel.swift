//
//  CommentModel.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/23.
//

import Foundation

struct GoodThingComment: Codable {
    var commentContent: String
    var commentCreatedTime: String
    var commentCreatorId: String
    var commentId: String
    var memoryId: String
}

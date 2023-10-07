//
//  MemoryModel.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/18.
//

import Foundation

struct GoodThingMemory: Codable {
    var memoryID: String
    var memoryTitle: String
    var memoryContent: String
    var memoryTag: [String]?
    var memoryImage: String?
    var memoryPrivacyStatus: Bool
    var memoryCreatedTime: String
    var memoryCreatorID: String
    var memoryVoice: String?
}

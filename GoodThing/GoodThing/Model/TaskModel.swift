//
//  TaskModel.swift
//  GoodThing
//
//  Created by Aaron on 2023/9/16.  
//

import Foundation

struct GoodThingTasks: Codable {
    var taskID: String
    var taskTitle: String
    var taskContent: String
    var taskImage: String
    var taskVoice: String
    var taskCreatorID: String
    var taskCreatedTime: String
}

struct GoodThingTasksResponses: Codable {
    var completerID: String
    var completionTime: String
    var completionStatus: String
    var completionRecord: String
    var responseTitle: String
    var responseContent: String
    var privacyStatus: String
}

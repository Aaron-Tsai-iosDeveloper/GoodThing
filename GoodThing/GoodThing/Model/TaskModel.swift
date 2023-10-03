//
//  TaskModel.swift
//  GoodThing
//
//  Created by Aaron on 2023/9/16.  
//

import Foundation

struct GoodThingTasks: Codable {
    var taskId: String
    var taskTitle: String
    var taskContent: String
    var taskImage: String?
    var taskVoice: String?
    var taskCreatorId: String
    var taskCreatedTime: String
}

struct GoodThingTasksResponses: Codable {
    var taskPosterId: String
    var completerId: String
    var completionStatus: String
    var responseRecording: String
    var responseImage: String
    var responseTitle: String
    var responseContent: String
    var responseTime: String
}

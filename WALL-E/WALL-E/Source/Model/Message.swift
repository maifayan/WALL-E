//
//  Message.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/5.
//  Copyright © 2018 Tangent. All rights reserved.
//

import RealmSwift

@objcMembers
final class Message: Object {
    dynamic var id = ""
    dynamic var sender: Contact?
    dynamic var receiver: Contact?
    dynamic var content = ""
    dynamic var createdAt = Date()
    dynamic var updatedAt = Date()
    
    static override func primaryKey() -> String? {
        return "id"
    }
}

extension Message {
    convenience init(
        id: String,
        sender: Contact,
        receiver: Contact,
        content: String,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.init()
        self.id = id
        self.sender = sender
        self.receiver = receiver
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

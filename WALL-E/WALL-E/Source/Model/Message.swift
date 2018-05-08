//
//  Message.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/5.
//  Copyright © 2018 Tangent. All rights reserved.
//

import RealmSwift
import EVE

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
    static func create(realm: Realm) -> (EVEMessage) -> Message? {
        return { message in
            guard
                let sender = realm.object(ofType: Contact.self, forPrimaryKey: message.sender),
                let receiver = realm.object(ofType: Contact.self, forPrimaryKey: message.receiver)
            else {
                log("Can not find sender or receiver for message")
                return nil
            }
            
            return Message(id: message.id_p,
                         sender: sender,
                         receiver: receiver,
                         content: message.content,
                         createdAt: message.createdAt.date,
                         updatedAt: message.updatedAt.date)
        }
    }
    
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

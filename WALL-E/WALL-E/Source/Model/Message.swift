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
    dynamic var conversationId = ""
    dynamic var sender: Contact?
    dynamic var receiver: Contact?
    dynamic var content = ""
    dynamic var createdAt = Date()
    dynamic var updatedAt = Date()
    dynamic var typeValue = "normal"
    
    static override func primaryKey() -> String? {
        return "id"
    }
}

extension Message {
    enum MessageType: String {
        case typing
        case normal
    }
    
    var type: MessageType {
        get {
            guard let ret = MessageType(rawValue: typeValue) else {
                fatalError("Impossible type value!")
            }
            return ret
        }
        
        set {
            typeValue = newValue.rawValue
        }
    }
}

extension Message {
    static func create(realm: Realm, uid: String) -> (EVEMessage) -> Message? {
        return { message in
            guard
                let sender = realm.object(ofType: Contact.self, forPrimaryKey: message.sender),
                let receiver = realm.object(ofType: Contact.self, forPrimaryKey: message.receiver)
            else {
                log("Can not find sender or receiver for message")
                return nil
            }
            
            let conversationId = sender.id == uid ? receiver.id : sender.id
            
            return Message(id: message.id_p,
                           conversationId: conversationId,
                           sender: sender,
                           receiver: receiver,
                           content: message.content,
                           createdAt: message.createdAt.date,
                           updatedAt: message.updatedAt.date)
        }
    }
    
    convenience init(
        id: String,
        conversationId: String,
        sender: Contact,
        receiver: Contact,
        content: String,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.init()
        self.id = id
        self.conversationId = conversationId
        self.sender = sender
        self.receiver = receiver
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        type = .normal
    }
}

extension Message {
    // Sender or receiver, except me
    var other: Contact? {
        return sender?.id == conversationId ? sender : receiver
    }
    
    var eveMessage: EVEMessage {
        let ret = EVEMessage()
        ret.id_p = id
        ret.sender = sender?.id ?? ""
        ret.receiver = receiver?.id ?? ""
        ret.content = content
        ret.createdAt = GPBTimestamp(date: createdAt)
        ret.updatedAt = GPBTimestamp(date: updatedAt)
        return ret
    }
    
    static func predicateForContact(_ contact: Contact) -> NSPredicate {
        return NSPredicate(format: "sender.id == %@ OR receiver.id == %@", contact.id, contact.id)
    }
}

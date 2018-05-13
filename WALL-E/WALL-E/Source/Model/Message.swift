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
    dynamic var imageURL = ""
    dynamic var imageWidth: Float = 0
    dynamic var imageHeight: Float = 0
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
        case image
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
    
    enum CreationType {
        case typing
        case normal
        case image(url: String, width: Float, height: Float)
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
            
            let type: CreationType = {
                guard case .image = message.type else { return .normal }
                return .image(url: message.imageURL, width: message.imageWidth, height: message.imageHeight)
            }()
            
            return Message(id: message.id_p,
                           conversationId: conversationId,
                           sender: sender,
                           receiver: receiver,
                           content: message.content,
                           createdAt: message.createdAt.date,
                           updatedAt: message.updatedAt.date,
                           type: type)
        }
    }
    
    convenience init(
        id: String,
        conversationId: String,
        sender: Contact,
        receiver: Contact,
        content: String,
        createdAt: Date,
        updatedAt: Date,
        type: CreationType
    ) {
        self.init()
        self.id = id
        self.conversationId = conversationId
        self.sender = sender
        self.receiver = receiver
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        switch type {
        case .normal:
            self.type = .normal
        case .typing:
            self.type = .typing
        case .image(let url, let width, let height):
            self.type = .image
            self.imageURL = url
            self.imageWidth = width
            self.imageHeight = height
        }
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

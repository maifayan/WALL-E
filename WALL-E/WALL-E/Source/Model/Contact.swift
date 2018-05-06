//
//  Contact.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/5.
//  Copyright © 2018 Tangent. All rights reserved.
//

import RealmSwift

@objcMembers
final class Contact: Object {
    dynamic var id = ""
    dynamic var typeValue = ContactType.robot.rawValue
    dynamic var name = ""
    dynamic var iconURL = ""
    dynamic var isOnline = false
    dynamic var createdAt = Date()
    dynamic var updatedAt = Date()
    
    // Only for membar
    dynamic var phone: String? = nil
    // Only for robot
    dynamic var token: String? = nil
    
    static override func primaryKey() -> String? {
        return "id"
    }
}

extension Contact {
    convenience init(
        id: String,
        creationType: ContactCreationType,
        name: String,
        iconURL: String,
        isOnline: Bool,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.init()
        self.id = id
        
        switch creationType {
        case .robot(let token): self.token = token
        case .member(let phone): self.phone = phone
        }
        
        self.name = name
        self.iconURL = iconURL
        self.isOnline = isOnline
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var type: ContactType {
        get {
            guard let type = ContactType(rawValue: typeValue) else {
                fatalError("Error type value!")
            }
            return type
        }
        set {
            typeValue = newValue.rawValue
        }
    }
}

extension Contact {
    enum ContactType: String {
        case robot
        case member
    }
    
    enum ContactCreationType {
        case robot(token: String)
        case member(phone: String)
    }
}

//
//  Context.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/5.
//  Copyright © 2018 Tangent. All rights reserved.
//

import Foundation

final class Context {
    private(set) var token: String = "123"
    private(set) var uid: String = "Ta"
    
    init(token: String, uid: String) {
        self.token = token
        self.uid = uid
    }
    
    private(set) lazy var request = EVE.Request(self)
    private(set) lazy var auto = Auto(self)
    
    // Current user
    // Must accessed in main thread!
    var me: Contact {
        assert(Thread.isMainThread, "Must accessed in main thread!")
        guard let me = auto.main.objects(Contact.self).filter("id == %@", uid).first else {
            fatalError("Impossible!")
        }
        return me
    }
}

extension Context {
}

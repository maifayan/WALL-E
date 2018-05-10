//
//  Context+Event.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/9.
//  Copyright © 2018 Tangent. All rights reserved.
//

import Foundation
import EVE

extension Context {
    func handle(event: EVE.Connecter.ServiceEvent) {
        switch event {
        case .typing(let typing):
            log("User typing")
        case .message(let msg):
            let uid = self.uid
            auto.asyncWrite {
                guard let message = Message.create(realm: $0, uid: uid)(msg) else { return }
                $0.add(message, update: true)
                log("New message -> \(message)")
            }
        case .contactUpdate(let update):
            auto.asyncWrite {
                let contact = Contact(update.contact)
                $0.add(contact, update: true)
                log("Contact update -> \(contact)")
            }
        default: ()
        }
    }
}

//
//  Context+Sync.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/5.
//  Copyright © 2018 Tangent. All rights reserved.
//

import Foundation
import RxSwift
import EVE
import Realm

extension Context {
    func prepareSync(force: Bool = false) -> Completable {
        return _syncContacts(force: force).andThen(_syncMessagaes(force: force))
    }
}

private extension Context {
    func _syncContacts(force: Bool) -> Completable {
        let oldDate = Date(timeIntervalSince1970: 0)
        let standard = force ? oldDate
            : auto.main.objects(Contact.self).sorted(byKeyPath: "updatedAt", ascending: false).first?.createdAt
            ?? oldDate
        
        return EVE.workWith(request.syncContacts, request: GPBTimestamp(date: standard))
            .map { $0.contactsArray as! [EVEContact] }
            .flatMap(auto.syncContacts)
            .ignoreElements()
    }
    
    func _syncMessagaes(force: Bool) -> Completable {
        let oldDate = Date(timeIntervalSince1970: 0)
        let standard = force ? oldDate
            : auto.main.objects(Message.self).sorted(byKeyPath: "updatedAt", ascending: false).first?.createdAt
            ?? oldDate
        
        return EVE.workWith(request.syncMessages, request: GPBTimestamp(date: standard))
            .map { $0.messagesArray as! [EVEMessage] }
            .flatMap(auto.syncMessages)
            .ignoreElements()
    }
}

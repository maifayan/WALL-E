//
//  Auto+Sync.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/8.
//  Copyright © 2018 Tangent. All rights reserved.
//

import Foundation
import RxSwift
import EVE

// MARK: - Sync
extension Auto {
    var syncContacts: ([EVEContact]) -> Completable {
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        return { [weak self] arr in
            Observable<()>.create { subscribe in
                do {
                    let time = try timeElapsed {
                        try self?.syncWrite {
                            let contacts = arr.map(Contact.init)
                            $0.add(contacts, update: true)
                            log("Sync contacts | count: \(contacts.count) --> \(contacts)")
                        }
                    }
                    log("Sync contacts use time: \(time)")
                    subscribe.onNext(())
                    subscribe.onCompleted()
                } catch {
                    subscribe.onError(error)
                }
                return Disposables.create()
            }.subscribeOn(scheduler).ignoreElements().observeOn(MainScheduler.instance)
        }
    }
    
    var syncMessages: ([EVEMessage]) -> Completable {
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        return { [weak self] arr in
            Observable<()>.create { subscribe in
                do {
                    let time = try timeElapsed {
                        try self?.syncWrite {
                            let messages = arr.compactMap(Message.create(realm: $0))
                            $0.add(messages, update: true)
                            log("Sync messages | count: \(messages.count) --> \(messages)")
                        }
                    }
                    log("Sync messages use time: \(time)")
                    subscribe.onNext(())
                    subscribe.onCompleted()
                } catch {
                    subscribe.onError(error)
                }
                return Disposables.create()
            }.subscribeOn(scheduler).ignoreElements().observeOn(MainScheduler.instance)
        }
    }
}

//
//  Context.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/5.
//  Copyright © 2018 Tangent. All rights reserved.
//

import Foundation
import RxSwift

// Create(Context) -> Connect(Connecter) -> Sync(Context) -> Fetch events from events queue
final class Context {
    let token: String
    let uid: String
    private let _bag = DisposeBag()
    
    init(token: String, uid: String) {
        self.token = token
        self.uid = uid
    }

    private(set) lazy var auto = Auto(self)
    private(set) lazy var request = EVE.Request(self)
    private(set) lazy var connecter = EVE.Connecter(self, stateUpdate: _connecterStateUpdate) { [weak self] event in
        if self?.userState != .connected {
            self?._eventsQueueInSync.append(event)
        } else {
            self?.handle(event: event)
        }
    }
    
    private var _eventsQueueInSync: [EVE.Connecter.ServiceEvent] = []

    // Must accessed in main thread!
    var me: Contact {
        assert(Thread.isMainThread, "Must accessed in main thread!")
        guard let me = auto.main.objects(Contact.self).filter("id == %@", uid).first else {
            fatalError("Impossible!")
        }
        return me
    }
    
    private(set) var userState: UserState = .disconnected {
        didSet {
            guard userState != oldValue else { return }
            print("User State -> \(userState)")
        }
    }
}

extension Context {
    enum UserState {
        case disconnected
        case connecting
        case syncing
        case connected
    }
}

private extension Context {
    func _sync(force: Bool = false) {
        UIApplication.shared.keyWindow?.rootViewController?.showHUD()
        prepareSync().subscribe(onCompleted: { [weak self] in
            guard let `self` = self else { return }
            UIApplication.shared.keyWindow?.rootViewController?.dismissHUD()
            self._eventsQueueInSync.forEach(self.handle)
            self._eventsQueueInSync.removeAll()
            self.userState = .connected
        }) { error in
            print(error)
            // TODO: Handle error
        }.disposed(by: _bag)
    }
    
    var _connecterStateUpdate: (EVE.Connecter.State) -> () {
        return { [weak self] state in
            switch state {
            case .connected:
                self?._sync()
                self?.userState = .syncing
            case .connecting:
                self?.userState = .connecting
            case .disconnected:
                self?.userState = .disconnected
            }
        }
    }
}

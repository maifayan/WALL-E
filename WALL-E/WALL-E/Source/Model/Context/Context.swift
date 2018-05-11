//
//  Context.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/5.
//  Copyright © 2018 Tangent. All rights reserved.
//

import Foundation
import RxSwift

// Create(Context) -> Connect(Connecter) -> Sync(Context) -> Handle events(Queue)
final class Context {
    private let _bag = DisposeBag()
    let token: String
    let uid: String

    init(token: String, uid: String) {
        self.token = token
        self.uid = uid
        Context.current = self
    }
    
    deinit {
        log()
    }

    private(set) lazy var auto = Auto(self)
    private(set) lazy var request = EVE.Request(self)
    private(set) lazy var connecter = EVE.Connecter(self, stateUpdate: _connecterStateUpdate, handler: _receivedEvent)

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
    
    // For Notification
    let typingSubject = PublishSubject<String>()
    let messageSubject = PublishSubject<String>()
}

extension Context {
    private static let _lock = NSRecursiveLock()
    private static var _current: Context?
    
    private(set) static var current: Context? {
        set {
            _lock.lock(); defer { _lock.unlock() }
            _current = newValue
        }
        get {
            _lock.lock(); defer { _lock.unlock() }
            return _current
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
        HUD.show()
        prepareSync().subscribe(onCompleted: { [weak self] in
            guard let `self` = self else { return }
            self._handleEventsInQueue()
            self.userState = .connected
            HUD.dismiss()
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
    
    // 如果此时处于Syncing中，为了保证时序的正确性，先把从Connecter中收到的
    // 事件放进队列中，等Syncing完成后，再将所有事件从队列中取出handle.
    var _receivedEvent: (EVE.Connecter.ServiceEvent) -> () {
        return { [weak self] event in
            if self?.userState == .connected {
                self?.handle(event: event)
            } else {
                self?._eventsQueueInSync.append(event)
            }
        }
    }
    
    func _handleEventsInQueue() {
        _eventsQueueInSync.forEach(handle)
        _eventsQueueInSync.removeAll()
    }
}

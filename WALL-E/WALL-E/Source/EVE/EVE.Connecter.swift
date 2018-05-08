//
//  EVE.Connecter.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/4.
//  Copyright © 2018 Tangent. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import EVE

extension EVE {
    final class Connecter {
        private let _service = EVEConnecter(host: EVE.Config.address)
        private unowned let _context: Context
        private let _stateUpdate: (State) -> ()
        private let _handler: (ServiceEvent) -> ()

        init(_ context: Context, stateUpdate: @escaping (State) -> (), handler: @escaping (ServiceEvent) -> ()) {
            _context = context
            _stateUpdate = stateUpdate
            _handler = handler
        }
        
        deinit {
            _connectDisposable?.dispose()
        }
        
        private(set) var state: State = .disconnected {
            didSet {
                guard state != oldValue else { return }
                switch state {
                case .connected:
                    _reconnectInterval = Config.minReconnectTime
                default: ()
                }
                _stateUpdate(state)
            }
        }
        
        private var _connectDisposable: Disposable?
        private var _reconnectInterval: TimeInterval = Config.minReconnectTime
    }
}

extension EVE.Connecter {
    struct Config {
        static let minReconnectTime: TimeInterval = 2
        static let reconeectIteration: TimeInterval = 3
    }
    
    enum State {
        case disconnected
        case connecting
        case connected
    }
    
    enum ServiceEvent {
        case message(EVEMessage)
        case contactUpdate(EVEContactUpdate)
        case typing(EVETyping)
        case connectSuccess
    }
}

extension EVE.Connecter {
    func connect() {
        guard state == .disconnected else { return }
        _connectDisposable?.dispose()
        _connectDisposable = _connect().subscribeOnMain(_dispatchCenter)
    }
    
    func disconnect() {
        guard state != .disconnected else { return }
        _connectDisposable?.dispose()
    }

    private func _reconnect() {
        DispatchQueue.main.asyncAfter(deadline: .now() + _reconnectInterval) { [weak self] in
            self?.connect()
        }
        _reconnectInterval += Config.reconeectIteration
    }
}

private extension EVE.Connecter {
    func _connect() -> Observable<ServiceEvent> {
        let writer = GRXBufferedPipe()
        return .create { [weak self] subscribe in
            guard let `self` = self else { return Disposables.create() }
            let call = self._service.rpcToConnect(withRequestsWriter: writer) { done, serviceEvent, error in
                if let serviceEvent = serviceEvent, let event = serviceEvent.event {
                    subscribe.onNext(event)
                }
                if let error = error {
                    subscribe.onError(error)
                } else if done {
                    subscribe.onCompleted()
                }
            }
            call.requestHeaders["authorization"] = self._context.token
            call.start()
            self.state = .connecting
            return Disposables.create { call.cancel() }
        }
    }

    var _dispatchCenter: (Event<ServiceEvent>) -> () {
        return { [weak self] in
            switch $0 {
            case .completed:
                self?.state = .disconnected
            case .error(let error):
                print(error)
                // TODO: 根据error判断是需要重连接还是重新登录
                self?.state = .disconnected
                self?._reconnect()
            case.next(let event):
                if case .connectSuccess = event {
                    self?.state = .connected
                }
                self?._handler(event)
            }
        }
    }
}

extension EVEServiceEvent {
    var event: EVE.Connecter.ServiceEvent? {
        switch contentOneOfCase {
        case .message:
            return .message(message)
        case .contactUpdate:
            return .contactUpdate(contactUpdate)
        case .typing:
            return .typing(typing)
        case .connectSuccess:
            return .connectSuccess
        case .gpbUnsetOneOfCase:
            return nil
        }
    }
}

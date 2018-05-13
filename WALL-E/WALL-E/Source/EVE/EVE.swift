//
//  EVE.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/4.
//  Copyright © 2018 Tangent. All rights reserved.
//

import Foundation
import EVE
import RxSwift

enum EVE { }

extension EVE {
    struct Config {
        static let address = "127.0.0.1:8081"
        static let timeout: TimeInterval = 15
    }
    
    static func defaultSetup() {
        GRPCCall.useInsecureConnections(forHost: Config.address)
    }
}

// MARK: - WorkItem
extension EVE {
    struct CallConfig {
        let configure: (GRPCProtoCall) -> ()
        static func + (lhs: CallConfig, rhs: CallConfig) -> CallConfig {
            return CallConfig {
                lhs.configure($0)
                rhs.configure($0)
            }
        }
        
        static let `default` = CallConfig { $0.timeout = Config.timeout }
        
        static func auth(_ token: @escaping @autoclosure () -> String) -> CallConfig {
            return CallConfig {
                $0.requestHeaders["authorization"] = token()
            } + .default
        }
    }
    
    struct WorkItem<I, O> {
        typealias WorkType = (I, @escaping (O?, Error?) -> ()) -> GRPCProtoCall
        private let _work: WorkType
        private let _callConfig: CallConfig?
        init(_ work: @escaping WorkType, _ callConfig: CallConfig? = nil) {
            _work = work
            _callConfig = callConfig
        }
        
        func work(request: I, callback: @escaping (O?, Error?) -> ()) -> GRPCProtoCall {
            let call = _work(request, callback)
            _callConfig?.configure(call)
            return call
        }
    }

    static func work<I, O>(_ work: @escaping WorkItem<I, O>.WorkType, request: I) -> Observable<O> {
        return workWith(WorkItem(work), request: request)
    }
    
    static func workMapper<I, O>(_ work: @escaping WorkItem<I, O>.WorkType) -> (I) -> Observable<O> {
        return workMapper(WorkItem(work))
    }
    
    static func workWith<I, O>(_ item: WorkItem<I, O>, request: I) -> Observable<O> {
        return Observable.create { subscribe in
            let call = item.work(request: request) { response, error in
                if let error = error {
                    subscribe.onError(error)
                } else {
                    subscribe.onNext(response!)
                    subscribe.onCompleted()
                }
            }
            call.start()
            return Disposables.create { call.cancel() }
        }
    }
    
    static func workMapper<I, O>(_ item: WorkItem<I, O>) -> (I) -> Observable<O> {
        return { request in
            Observable.create { subscribe in
                let call = item.work(request: request) { response, error in
                    if let error = error {
                        subscribe.onError(error)
                    } else {
                        subscribe.onNext(response!)
                        subscribe.onCompleted()
                    }
                }
                call.start()
                return Disposables.create { call.cancel() }
            }
        }
    }
}

// MARK: - Init With block
protocol InitWithBlock: class { }

extension InitWithBlock where Self: GPBMessage {
    init(initProperties: (Self) -> ()) {
        self.init()
        initProperties(self)
    }
}

extension GPBMessage: InitWithBlock { }

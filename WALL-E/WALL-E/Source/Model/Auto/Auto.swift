//
//  Auto.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/5.
//  Copyright © 2018 Tangent. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import EVE

final class Auto {
    private let _asyncQueue = DispatchQueue(label: "Auto.asyncQueue", attributes: .concurrent)
    // Only used in main thread
    private let _mainRealm: Realm
    private let _config: Realm.Configuration
    unowned let context: Context

    init(_ context: Context) throws {
        self.context = context
        let config = Auto._config(of: context)
        _mainRealm = try syncInMain {
            return try Realm(configuration: config)
        }
        _config = config
    }
}

// MARK: - Operations
extension Auto {
    // Operations in main
    var main: Realm {
        assert(Thread.isMainThread)
        return _mainRealm
    }

    func writeInMain(_ block: (Realm) throws -> ()) throws {
        assert(Thread.isMainThread)
        try _mainRealm.write {
            try block(_mainRealm)
        }
    }
    
    // Operations in async
    func async(errorHandler: ((Error) -> ())? = nil, _ block: @escaping (Realm) -> ()) {
        _asyncQueue.async { [weak self] in
            guard let `self` = self else { return }
            do {
                let realm = try Realm(configuration: self._config)
                block(realm)
            } catch {
                errorHandler?(error)
            }
        }
    }
    
    func asyncWrite(errorHandler: ((Error) -> ())? = nil, _ block: @escaping (Realm) throws -> ()) {
        _asyncQueue.async { [weak self] in
            guard let `self` = self else { return }
            do {
                let realm = try Realm(configuration: self._config)
                try realm.write {
                    try block(realm)
                }
            } catch {
                errorHandler?(error)
            }
        }
    }
    
    func sync(_ block: @escaping (Realm) -> ()) throws {
        try _asyncQueue.sync { [weak self] in
            guard let `self` = self else { return }
            let realm = try Realm(configuration: self._config)
            block(realm)
        }
    }
    
    func syncWrite(_ block: @escaping (Realm) throws -> ()) throws {
        try _asyncQueue.sync { [weak self] in
            guard let `self` = self else { return }
            let realm = try Realm(configuration: self._config)
            try realm.write { try block(realm) }
        }
    }
}

// MARK: - Configuration
private extension Auto {
    static func _dbFileURL(of uid: String) -> URL {
        let defaultConfig = Realm.Configuration()
        return defaultConfig.fileURL!.deletingLastPathComponent().appendingPathComponent("\(uid).realm")
    }
    
    static func _config(of context: Context) -> Realm.Configuration {
        return Realm.Configuration(
            fileURL: _dbFileURL(of: context.uid),
            schemaVersion: 1,
            migrationBlock: { migration, oldVersion in
                
            }
        )
    }
}

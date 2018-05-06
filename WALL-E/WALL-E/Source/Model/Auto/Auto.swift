//
//  Auto.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/5.
//  Copyright © 2018 Tangent. All rights reserved.
//

import Foundation
import RealmSwift

final class Auto {
    private let _asyncQueue = DispatchQueue(label: "Auto.asyncQueue")
    // Only used in main thread
    private let _mainRealm: Realm
    // Only used in `asyncQueue`
    private let _asyncRealm: Realm
   
    init(_ context: Context) throws {
        let config = Auto._config(of: context)
        _mainRealm = try syncInMain {
            return try Realm(configuration: config)
        }
        _asyncRealm = try _asyncQueue.sync {
            return try Realm(configuration: config)
        }
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
    func async(_ block: @escaping (Realm) -> ()) {
        _asyncQueue.async { [weak self] in
            guard let `self` = self else { return }
            block(self._asyncRealm)
        }
    }
    
    func asyncWrite(errorHandler: ((Error) -> ())? = nil, _ block: @escaping (Realm) throws -> ()) {
        _asyncQueue.async { [weak self] in
            guard let `self` = self else { return }
            do {
                try self._asyncRealm.write {
                    try block(self._asyncRealm)
                }
            } catch {
                errorHandler?(error)
            }
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

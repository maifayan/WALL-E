//
//  PreferenceStore.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/25.
//  Copyright © 2018 Tangent. All rights reserved.
//

import Foundation

final class PreferenceStore {
    static let `default` = PreferenceStore(identifier: "shared")

    let identifier: String
    private let _ud: UserDefaults
    
    init(identifier: String) {
        self.identifier = identifier
        _ud = UserDefaults.standard
    }
}

extension PreferenceStore {
    subscript<T>(key: String) -> T? {
        set {
            _set(newValue, for: key)
        }
        get {
            return _value(for: key)
        }
    }
}

extension PreferenceStore {
    func synchronize() {
        _ud.synchronize()
    }
    
    func remove(_ key: String) {
        _remove(key)
    }
    
    func removeAll() {
        _ud.dictionaryRepresentation().keys.filter(flip(String.hasPrefix)(_keyPrefix)).forEach(_ud.removeObject)
    }
}

private extension PreferenceStore {
    func _set<T>(_ value: T?, for key: String) {
        _ud.set(value, forKey: _realKey(key))
        _ud.synchronize()
    }
    
    func _value<T>(for key: String) -> T? {
        return _ud.object(forKey: _realKey(key)) as? T
    }
    
    func _remove(_ key: String, sync: Bool = true) {
        _remove(realKey: _realKey(key), sync: sync)
    }
    
    func _remove(realKey: String, sync: Bool = true) {
        _ud.removeObject(forKey: realKey)
        if sync { _ud.synchronize() }
    }
    
    var _keyPrefix: String {
        return "__WALL-E_PS_\(identifier)_"
    }
    
    func _realKey(_ key: String) -> String {
        return "\(_keyPrefix)\(key)"
    }
}

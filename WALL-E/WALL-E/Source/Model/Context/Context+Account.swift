//
//  Context+Account.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/12.
//  Copyright © 2018 Tangent. All rights reserved.
//

import Foundation
import KeychainAccess

// For User Account
extension Context {
    private typealias _AccountInfo = (token: String, uid: String)
    private static let _service = "WALL-E"
    private static let _keychain = Keychain(service: _service)
    private static let _infoKey = "AccountInfo"
    
    static func clearAccountInfo() {
        _keychain[_infoKey] = nil
    }
    
    static func createFromPreviousAccount() -> Context? {
        guard let info = _accountInfo else { return nil }
        return Context(token: info.token, uid: info.uid)
    }
    
    static func createAndStoreAccount(token: String, uid: String) -> Context {
        let info: _AccountInfo = (token, uid)
        defer { _accountInfo = info }
        return Context(token: token, uid: uid)
    }
    
    private static var _accountInfo: _AccountInfo? {
        get {
            guard
                let data = _keychain[data: _infoKey],
                let dic = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : String],
                let token = dic["token"], let uid = dic["uid"]
                else { return nil }
            return (token, uid)
        }
        set {
            guard let newValue = newValue else { return }
            let dic = ["token": newValue.token, "uid": newValue.uid]
            let data = NSKeyedArchiver.archivedData(withRootObject: dic)
            _keychain[data: _infoKey] = data
        }
    }
}

//
//  Account.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/6.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit
import KeychainAccess

enum Account {
    typealias AccountInfo = (token: String, uid: String)
    typealias LoginSuccess = (AccountInfo) -> ()
    enum Login { }
    enum Register { }
}

extension Account {
    final class View: UINavigationController {
        init(_ loginSuccess: @escaping LoginSuccess) {
            super.init(rootViewController: Login.View(loginSuccess))
        }
        
        override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            isNavigationBarHidden = true
        }
    }
}

// For User Account
extension Account {
    private static let _service = "WALL-E"
    private static let _keychain = Keychain(service: _service)
    private static let _infoKey = "AccountInfo"
    
    static func clearAccountInfo() {
        _keychain[_infoKey] = nil
    }
    
    static var accountInfo: AccountInfo? {
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

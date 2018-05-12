//
//  Account.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/6.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit

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
        
        deinit { log() }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            isNavigationBarHidden = true
        }
    }
}

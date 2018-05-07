//
//  Account.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/6.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit

enum Account {
    enum Login { }
    enum Register { }
}

extension Account {
    final class View: UINavigationController {
        init() {
            super.init(rootViewController: Login.View())
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

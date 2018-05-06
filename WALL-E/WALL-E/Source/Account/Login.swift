//
//  Login.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/6.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit

enum Login { }

extension Login {
    final class View: UIViewController {
        private var _loginView: LoginView { return view as! LoginView }
        
        override func loadView() {
            view = R.nib.loginView().instantiate(withOwner: nil, options: nil).first as! UIView
        }
    }
}

final class LoginView: UIView {
    
}
